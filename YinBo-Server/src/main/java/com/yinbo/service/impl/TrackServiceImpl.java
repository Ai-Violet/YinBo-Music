package com.yinbo.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.yinbo.dto.TrackDTO;
import com.yinbo.entity.Category;
import com.yinbo.entity.Favorite;
import com.yinbo.entity.PlayHistory;
import com.yinbo.entity.Track;
import com.yinbo.entity.User;
import com.yinbo.mapper.CategoryMapper;
import com.yinbo.mapper.FavoriteMapper;
import com.yinbo.mapper.PlayHistoryMapper;
import com.yinbo.mapper.TrackMapper;
import com.yinbo.mapper.UserMapper;
import com.yinbo.service.MinioService;
import com.yinbo.service.TrackService;
import org.jaudiotagger.audio.AudioFile;
import org.jaudiotagger.audio.AudioFileIO;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class TrackServiceImpl extends ServiceImpl<TrackMapper, Track> implements TrackService {
    
    private final TrackMapper trackMapper;
    private final CategoryMapper categoryMapper;
    private final UserMapper userMapper;
    private final FavoriteMapper favoriteMapper;
    private final PlayHistoryMapper playHistoryMapper;
    private final MinioService minioService;
    
    @Override
    @Transactional
    public Track uploadTrack(MultipartFile musicFile, MultipartFile coverFile, MultipartFile lyricFile,
                             String title, String artist, String album, 
                             Long categoryId, String lyrics, Long artistId, Long uploaderId) {
        
        // Extract audio duration before uploading
        int duration = extractAudioDuration(musicFile);
        log.info("Extracted audio duration: {} seconds", duration);
        
        String musicKey = minioService.uploadMusic(musicFile);
        
        String coverKey = null;
        String coverUrl = null;
        if (coverFile != null && !coverFile.isEmpty()) {
            coverKey = minioService.uploadCover(coverFile);
            coverUrl = minioService.getCoverUrl(coverKey);
        }
        
        // 歌词：优先使用上传的 .lrc 文件（存 lyricKey），否则用文本（存 lyrics）
        String lyricKey = null;
        if (lyricFile != null && !lyricFile.isEmpty()) {
            lyricKey = minioService.uploadLyrics(lyricFile);
        }
        
        Track track = new Track();
        track.setTitle(title);
        track.setArtist(artist);
        track.setAlbum(album);
        track.setArtistId(artistId);
        track.setDuration(duration);
        track.setMinioKey(musicKey);
        track.setCoverKey(coverKey);
        track.setCoverUrl(coverUrl);
        track.setLyricKey(lyricKey);
        track.setCategoryId(categoryId);
        track.setLyrics(lyrics);
        track.setUploaderId(uploaderId);
        track.setStatus(0);
        track.setPlayCount(0L);
        track.setLikeCount(0L);
        track.setFileSize(musicFile.getSize());
        track.setMime(musicFile.getContentType());
        track.setDeleted(0);
        
        trackMapper.insert(track);
        log.info("Track uploaded: {} by {}, duration: {}s", title, artist, duration);
        
        return track;
    }
    
    /**
     * Extract audio duration from MultipartFile using jaudiotagger
     * Supports MP3, FLAC, WAV, OGG and other formats
     */
    private int extractAudioDuration(MultipartFile file) {
        Path tempFile = null;
        try {
            String originalFilename = file.getOriginalFilename();
            String suffix = ".mp3";
            if (originalFilename != null && originalFilename.contains(".")) {
                suffix = originalFilename.substring(originalFilename.lastIndexOf("."));
            }
            tempFile = Files.createTempFile("audio_", suffix);
            try (InputStream is = file.getInputStream()) {
                Files.copy(is, tempFile, StandardCopyOption.REPLACE_EXISTING);
            }
            File audioFile = tempFile.toFile();
            try {
                AudioFile af = AudioFileIO.read(audioFile);
                if (af != null && af.getAudioHeader() != null) {
                    int len = af.getAudioHeader().getTrackLength();
                    if (len > 0) return len;
                }
            } catch (Exception e) {
                log.warn("JAudioTagger failed for {}: {}", originalFilename, e.getMessage());
            }
            // Fallback: Java Sound API
            try {
                javax.sound.sampled.AudioInputStream ais = javax.sound.sampled.AudioSystem.getAudioInputStream(audioFile);
                long frames = ais.getFrameLength();
                float rate = ais.getFormat().getFrameRate();
                if (rate > 0 && frames > 0) return (int) (frames / rate);
            } catch (Exception e) {
                log.warn("Java Sound failed: {}", e.getMessage());
            }
        } catch (Exception e) {
            log.warn("Failed to extract audio duration: {}", e.getMessage());
        } finally {
            if (tempFile != null) {
                try { Files.deleteIfExists(tempFile); } catch (Exception ignored) {}
            }
        }
        return 0;
    }
    
    @Override
    public TrackDTO getTrackDetail(Long trackId, Long userId) {
        Track track = trackMapper.selectById(trackId);
        if (track == null || track.getDeleted() == 1) {
            throw new RuntimeException("Track not found");
        }
        
        if (track.getStatus() != 1) {
            throw new RuntimeException("Track not published");
        }
        
        TrackDTO dto = toDTO(track);
        
        if (StringUtils.hasText(track.getMinioKey())) {
            dto.setPlayUrl(minioService.getMusicUrl(track.getMinioKey()));
        }
        
        // 若有 lyricKey 且 lyrics 为空，从 MinIO 读取歌词内容
        if (StringUtils.hasText(track.getLyricKey()) && !StringUtils.hasText(track.getLyrics())) {
            try {
                InputStream is = minioService.getFileStream(minioService.getMainBucket(), track.getLyricKey());
                dto.setLyrics(new String(is.readAllBytes(), java.nio.charset.StandardCharsets.UTF_8));
            } catch (Exception e) {
                log.warn("Failed to load lyrics from MinIO: {}", e.getMessage());
            }
        }
        
        if (userId != null) {
            dto.setIsFavorited(isFavorited(trackId, userId));
        }
        
        return dto;
    }
    
    @Override
    public IPage<TrackDTO> getTrackList(int page, int size, String keyword, Long categoryId, Long singerId, String artist, Long userId) {
        LambdaQueryWrapper<Track> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Track::getStatus, 1)
               .eq(Track::getDeleted, 0);
        
        if (StringUtils.hasText(keyword)) {
            wrapper.and(w -> w.like(Track::getTitle, keyword)
                    .or().like(Track::getArtist, keyword)
                    .or().like(Track::getAlbum, keyword));
        }
        if (categoryId != null) {
            wrapper.eq(Track::getCategoryId, categoryId);
        }
        if (singerId != null) {
            wrapper.eq(Track::getArtistId, singerId);
        }
        if (StringUtils.hasText(artist)) {
            wrapper.eq(Track::getArtist, artist.trim());
        }
        wrapper.orderByDesc(Track::getCreatedAt);
        
        IPage<Track> trackPage = trackMapper.selectPage(new Page<>(page, size), wrapper);
        
        return convertToDTOPage(trackPage, userId);
    }
    
    @Override
    public IPage<TrackDTO> getHotTracks(int page, int size, boolean random) {
        LambdaQueryWrapper<Track> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Track::getStatus, 1)
               .eq(Track::getDeleted, 0);
        if (random) {
            wrapper.last("ORDER BY RAND() LIMIT " + size);
            List<Track> list = trackMapper.selectList(wrapper);
            long total = trackMapper.selectCount(
                new LambdaQueryWrapper<Track>().eq(Track::getStatus, 1).eq(Track::getDeleted, 0)
            );
            Page<Track> trackPage = new Page<>(1, size);
            trackPage.setRecords(list);
            trackPage.setTotal(total);
            return convertToDTOPage(trackPage, null);
        } else {
            // 播放次数排行：由 play_history 中所有用户的播放记录加总
            int offset = (page - 1) * size;
            List<Track> list = trackMapper.selectTracksOrderByPlayHistoryCount(size, offset);
            long total = trackMapper.selectCount(
                new LambdaQueryWrapper<Track>().eq(Track::getStatus, 1).eq(Track::getDeleted, 0)
            );
            Page<Track> trackPage = new Page<>(page, size);
            trackPage.setRecords(list);
            trackPage.setTotal(total);
            return convertToDTOPage(trackPage, null);
        }
    }
    
    @Override
    public IPage<TrackDTO> getNewTracks(int page, int size) {
        LambdaQueryWrapper<Track> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Track::getStatus, 1)
               .eq(Track::getDeleted, 0)
               .orderByDesc(Track::getCreatedAt);
        
        IPage<Track> trackPage = trackMapper.selectPage(new Page<>(page, size), wrapper);
        
        return convertToDTOPage(trackPage, null);
    }

    @Override
    public IPage<TrackDTO> getMostLikedTracks(int page, int size) {
        LambdaQueryWrapper<Track> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Track::getStatus, 1)
               .eq(Track::getDeleted, 0)
               .orderByDesc(Track::getLikeCount);
        
        IPage<Track> trackPage = trackMapper.selectPage(new Page<>(page, size), wrapper);
        
        return convertToDTOPage(trackPage, null);
    }

    @Override
    public IPage<TrackDTO> getMostCommentedTracks(int page, int size) {
        long total = trackMapper.selectCount(
            new LambdaQueryWrapper<Track>().eq(Track::getStatus, 1).eq(Track::getDeleted, 0)
        );
        int offset = (page - 1) * size;
        List<Long> ids = trackMapper.selectTrackIdsByCommentCount(size, offset);
        if (ids.isEmpty()) {
            Page<TrackDTO> emptyPage = new Page<>(page, size, total);
            emptyPage.setRecords(List.of());
            return emptyPage;
        }
        List<Track> tracks = trackMapper.selectBatchIds(ids);
        java.util.Map<Long, Track> trackMap = tracks.stream().collect(Collectors.toMap(Track::getId, t -> t));
        List<TrackDTO> dtoList = ids.stream()
                .map(trackMap::get)
                .filter(java.util.Objects::nonNull)
                .map(t -> toDTO(t))
                .collect(Collectors.toList());
        Page<TrackDTO> resultPage = new Page<>(page, size, total);
        resultPage.setRecords(dtoList);
        return resultPage;
    }
    
    @Override
    public IPage<TrackDTO> searchTracks(String keyword, int page, int size) {
        if (!StringUtils.hasText(keyword) || keyword.trim().isEmpty()) {
            return new Page<TrackDTO>(page, size).setRecords(List.of()).setTotal(0);
        }
        String kw = keyword.trim();
        LambdaQueryWrapper<Track> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Track::getStatus, 1)
               .eq(Track::getDeleted, 0)
               .and(w -> w.like(Track::getTitle, kw)
                         .or()
                         .like(Track::getArtist, kw)
                         .or()
                         .like(Track::getAlbum, kw));
        wrapper.orderByDesc(Track::getPlayCount);
        
        IPage<Track> trackPage = trackMapper.selectPage(new Page<>(page, size), wrapper);
        
        return convertToDTOPage(trackPage, null);
    }
    
    @Override
    public List<String> getSearchHotKeywords() {
        java.util.List<String> keywords = new java.util.ArrayList<>();
        // 分类名作为关键词
        List<Category> categories = categoryMapper.selectList(
            new LambdaQueryWrapper<Category>().eq(Category::getDeleted, 0).orderByAsc(Category::getSort).last("LIMIT 8")
        );
        categories.forEach(c -> keywords.add(c.getName()));
        // 热门艺术家
        List<String> artists = trackMapper.selectTopArtists();
        for (String a : artists) {
            if (a != null && !a.isBlank() && !keywords.contains(a)) {
                keywords.add(a);
                if (keywords.size() >= 20) break;
            }
        }
        return keywords;
    }
    
    @Override
    public IPage<TrackDTO> getPendingTracks(int page, int size) {
        LambdaQueryWrapper<Track> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Track::getStatus, 0)
               .eq(Track::getDeleted, 0)
               .orderByDesc(Track::getCreatedAt);
        
        IPage<Track> trackPage = trackMapper.selectPage(new Page<>(page, size), wrapper);
        
        return convertToDTOPage(trackPage, null);
    }
    
    @Override
    public IPage<TrackDTO> getTracksByStatus(int page, int size, Integer status) {
        LambdaQueryWrapper<Track> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Track::getDeleted, 0);
        if (status != null) {
            wrapper.eq(Track::getStatus, status);
        }
        wrapper.orderByDesc(Track::getCreatedAt);
        
        IPage<Track> trackPage = trackMapper.selectPage(new Page<>(page, size), wrapper);
        
        return convertToDTOPage(trackPage, null);
    }
    
    @Override
    public IPage<TrackDTO> getAdminTracks(int page, int size, Integer status, String keyword, Long categoryId) {
        LambdaQueryWrapper<Track> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Track::getDeleted, 0);
        
        if (status != null) {
            wrapper.eq(Track::getStatus, status);
        }
        
        if (StringUtils.hasText(keyword)) {
            wrapper.and(w -> w
                .like(Track::getTitle, keyword)
                .or()
                .like(Track::getArtist, keyword)
                .or()
                .like(Track::getAlbum, keyword)
            );
        }
        
        if (categoryId != null) {
            wrapper.eq(Track::getCategoryId, categoryId);
        }
        
        wrapper.orderByDesc(Track::getCreatedAt);
        
        IPage<Track> trackPage = trackMapper.selectPage(new Page<>(page, size), wrapper);
        
        return convertToDTOPage(trackPage, null);
    }
    
    @Override
    public IPage<TrackDTO> getTopPlayTracks(int limit) {
        // 播放次数排行：由 play_history 中所有用户的播放记录加总
        List<Track> list = trackMapper.selectTracksOrderByPlayHistoryCount(limit, 0);
        Page<Track> trackPage = new Page<>(1, limit);
        trackPage.setRecords(list);
        trackPage.setTotal(list.size());
        return convertToDTOPage(trackPage, null);
    }
    
    @Override
    @Transactional
    public void updateStatus(Long trackId, int status) {
        Track track = trackMapper.selectById(trackId);
        if (track == null) {
            throw new RuntimeException("Track not found");
        }
        track.setStatus(status);
        trackMapper.updateById(track);
        log.info("Track {} status updated to {}", trackId, status);
    }
    
    @Override
    @Transactional
    public void auditTrack(Long trackId, int status, Long operatorId) {
        Track track = trackMapper.selectById(trackId);
        if (track == null) {
            throw new RuntimeException("Track not found");
        }
        
        track.setStatus(status);
        trackMapper.updateById(track);
        log.info("Track {} audited with status {} by {}", trackId, status, operatorId);
    }
    
    @Override
    @Transactional
    public void deleteTrack(Long trackId) {
        Track track = trackMapper.selectById(trackId);
        if (track == null) {
            throw new RuntimeException("Track not found");
        }
        
        String bucketName = minioService.getMainBucket();
        
        if (StringUtils.hasText(track.getMinioKey())) {
            minioService.deleteFile(bucketName, track.getMinioKey());
        }
        if (StringUtils.hasText(track.getCoverKey())) {
            minioService.deleteFile(bucketName, track.getCoverKey());
        }
        
        track.setDeleted(1);
        trackMapper.updateById(track);
        log.info("Track {} deleted", trackId);
    }
    
    @Override
    @Transactional
    public void recordPlay(Long trackId, Long userId, int durationPlayed) {
        trackMapper.incrementPlayCount(trackId);
        
        if (userId != null) {
            PlayHistory history = new PlayHistory();
            history.setUserId(userId);
            history.setTrackId(trackId);
            history.setDurationPlayed(durationPlayed);
            history.setPlayedAt(LocalDateTime.now());
            playHistoryMapper.insert(history);
        }
    }
    
    @Override
    public boolean isFavorited(Long trackId, Long userId) {
        if (userId == null) return false;
        
        Long count = favoriteMapper.selectCount(
                new LambdaQueryWrapper<Favorite>()
                        .eq(Favorite::getUserId, userId)
                        .eq(Favorite::getTrackId, trackId)
        );
        return count > 0;
    }
    
    private TrackDTO toDTO(Track track) {
        TrackDTO dto = new TrackDTO();
        dto.setId(track.getId());
        dto.setTitle(track.getTitle());
        dto.setArtist(track.getArtist());
        dto.setAlbum(track.getAlbum());
        dto.setDuration(track.getDuration());
        dto.setLyrics(track.getLyrics());
        dto.setPlayCount(track.getPlayCount());
        dto.setLikeCount(track.getLikeCount());
        dto.setStatus(track.getStatus());
        dto.setCategoryId(track.getCategoryId());
        dto.setArtistId(track.getArtistId());
        
        // Generate cover URL from cover_key
        if (StringUtils.hasText(track.getCoverKey())) {
            dto.setCoverUrl(minioService.getCoverUrl(track.getCoverKey()));
        }
        
        // Set playUrl from MinIO
        if (StringUtils.hasText(track.getMinioKey())) {
            dto.setPlayUrl(minioService.getMusicUrl(track.getMinioKey()));
        }
        
        if (track.getCategoryId() != null) {
            Category category = categoryMapper.selectById(track.getCategoryId());
            if (category != null) {
                dto.setCategoryName(category.getName());
            }
        }
        
        if (track.getUploaderId() != null) {
            User user = userMapper.selectById(track.getUploaderId());
            if (user != null) {
                dto.setUploaderName(user.getNickname() != null ? user.getNickname() : user.getUsername());
            }
        }
        
        if (track.getCreatedAt() != null) {
            dto.setCreatedAt(track.getCreatedAt().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
        }
        
        return dto;
    }
    
    @Override
    public TrackDTO getTrackDetailForAdmin(Long trackId) {
        Track track = trackMapper.selectById(trackId);
        if (track == null || track.getDeleted() == 1) {
            throw new RuntimeException("Track not found");
        }
        TrackDTO dto = toDTO(track);
        if (StringUtils.hasText(track.getMinioKey())) {
            dto.setPlayUrl(minioService.getMusicUrl(track.getMinioKey()));
        }
        if (StringUtils.hasText(track.getLyricKey()) && !StringUtils.hasText(track.getLyrics())) {
            try {
                InputStream is = minioService.getFileStream(minioService.getMainBucket(), track.getLyricKey());
                dto.setLyrics(new String(is.readAllBytes(), java.nio.charset.StandardCharsets.UTF_8));
            } catch (Exception e) {
                log.warn("Failed to load lyrics from MinIO: {}", e.getMessage());
            }
        }
        return dto;
    }
    
    @Override
    public void updateTrack(Long trackId, String title, String artist, String album, Long categoryId, String lyrics, Long artistId) {
        Track track = trackMapper.selectById(trackId);
        if (track == null || track.getDeleted() == 1) {
            throw new RuntimeException("Track not found");
        }
        if (StringUtils.hasText(title)) track.setTitle(title);
        if (artist != null) track.setArtist(artist);
        if (album != null) track.setAlbum(album);
        if (lyrics != null) track.setLyrics(lyrics);
        track.setCategoryId(categoryId);
        track.setArtistId(artistId);
        trackMapper.updateById(track);
        log.info("Updated track {}: {}", trackId, title != null ? title : track.getTitle());
    }
    
    @Override
    public void updateTrackCover(Long trackId, MultipartFile coverFile) {
        if (coverFile == null || coverFile.isEmpty()) {
            throw new RuntimeException("Cover file is required");
        }
        Track track = trackMapper.selectById(trackId);
        if (track == null || track.getDeleted() == 1) {
            throw new RuntimeException("Track not found");
        }
        String coverKey = minioService.uploadCover(coverFile);
        String coverUrl = minioService.getCoverUrl(coverKey);
        track.setCoverKey(coverKey);
        track.setCoverUrl(coverUrl);
        trackMapper.updateById(track);
        log.info("Updated cover for track {}", trackId);
    }
    
    private IPage<TrackDTO> convertToDTOPage(IPage<Track> trackPage, Long userId) {
        List<TrackDTO> dtoList = trackPage.getRecords().stream()
                .map(track -> {
                    TrackDTO dto = toDTO(track);
                    if (userId != null) {
                        dto.setIsFavorited(isFavorited(track.getId(), userId));
                    }
                    return dto;
                })
                .collect(Collectors.toList());
        
        Page<TrackDTO> dtoPage = new Page<>(trackPage.getCurrent(), trackPage.getSize(), trackPage.getTotal());
        dtoPage.setRecords(dtoList);
        return dtoPage;
    }
    
    @Override
    public int refreshAllTrackDurations() {
        List<Track> tracks = trackMapper.selectList(
            new LambdaQueryWrapper<Track>()
                .eq(Track::getDeleted, 0)
                .isNotNull(Track::getMinioKey)
        );
        
        int updated = 0;
        for (Track track : tracks) {
            try {
                int duration = extractDurationFromMinio(track.getMinioKey());
                if (duration > 0 && duration != track.getDuration()) {
                    track.setDuration(duration);
                    trackMapper.updateById(track);
                    updated++;
                    log.info("Updated duration for track {}: {}s", track.getTitle(), duration);
                }
            } catch (Exception e) {
                log.warn("Failed to refresh duration for track {}: {}", track.getId(), e.getMessage());
            }
        }
        return updated;
    }
    
    @Override
    public int refreshTrackDuration(Long trackId) {
        Track track = trackMapper.selectById(trackId);
        if (track == null || track.getMinioKey() == null) {
            throw new RuntimeException("Track not found or no file");
        }
        
        int duration = extractDurationFromMinio(track.getMinioKey());
        if (duration > 0) {
            track.setDuration(duration);
            trackMapper.updateById(track);
            log.info("Updated duration for track {}: {}s", track.getTitle(), duration);
        }
        return duration;
    }
    
    /**
     * Extract audio duration from MinIO file (reuse same logic as MultipartFile)
     */
    private int extractDurationFromMinio(String minioKey) {
        Path tempFile = null;
        try {
            String bucketName = minioService.getMainBucket();
            InputStream inputStream = minioService.getFileStream(bucketName, minioKey);
            String suffix = minioKey.contains(".") ? minioKey.substring(minioKey.lastIndexOf(".")) : ".mp3";
            tempFile = Files.createTempFile("minio_audio_", suffix);
            Files.copy(inputStream, tempFile, StandardCopyOption.REPLACE_EXISTING);
            inputStream.close();
            File audioFile = tempFile.toFile();
            try {
                AudioFile af = AudioFileIO.read(audioFile);
                if (af != null && af.getAudioHeader() != null) {
                    int len = af.getAudioHeader().getTrackLength();
                    if (len > 0) return len;
                }
            } catch (Exception e) {
                log.warn("JAudioTagger failed: {}", e.getMessage());
            }
            try {
                javax.sound.sampled.AudioInputStream ais = javax.sound.sampled.AudioSystem.getAudioInputStream(audioFile);
                long frames = ais.getFrameLength();
                float rate = ais.getFormat().getFrameRate();
                if (rate > 0 && frames > 0) return (int) (frames / rate);
            } catch (Exception e) {
                log.warn("Java Sound failed: {}", e.getMessage());
            }
        } catch (Exception e) {
            log.error("Failed to extract duration from MinIO: {}", e.getMessage());
        } finally {
            if (tempFile != null) {
                try { Files.deleteIfExists(tempFile); } catch (Exception ignored) {}
            }
        }
        return 0;
    }
}
