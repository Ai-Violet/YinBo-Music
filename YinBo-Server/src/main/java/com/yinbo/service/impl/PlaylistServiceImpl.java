package com.yinbo.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.yinbo.dto.PlaylistDTO;
import com.yinbo.dto.TrackDTO;
import com.yinbo.entity.Playlist;
import com.yinbo.entity.PlaylistItem;
import com.yinbo.entity.Track;
import com.yinbo.entity.User;
import com.yinbo.mapper.PlaylistItemMapper;
import com.yinbo.mapper.PlaylistMapper;
import com.yinbo.mapper.TrackMapper;
import com.yinbo.mapper.UserMapper;
import com.yinbo.service.MinioService;
import com.yinbo.service.PlaylistService;
import com.yinbo.service.TrackService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class PlaylistServiceImpl extends ServiceImpl<PlaylistMapper, Playlist> implements PlaylistService {
    
    private final PlaylistMapper playlistMapper;
    private final PlaylistItemMapper playlistItemMapper;
    private final TrackMapper trackMapper;
    private final UserMapper userMapper;
    private final MinioService minioService;
    private final TrackService trackService;
    
    @Override
    @Transactional
    public Playlist createPlaylist(String name, String description, Long ownerId) {
        Playlist playlist = new Playlist();
        playlist.setName(name);
        playlist.setDescription(description);
        playlist.setOwnerId(ownerId);
        playlist.setIsPublic(1);
        playlist.setPlayCount(0L);
        playlist.setTrackCount(0);
        playlist.setDeleted(0);
        
        playlistMapper.insert(playlist);
        log.info("Playlist created: {} by user {}", name, ownerId);
        
        return playlist;
    }
    
    @Override
    @Transactional
    public Playlist updatePlaylist(Long playlistId, String name, String description, Long userId) {
        Playlist playlist = getPlaylistAndCheckOwner(playlistId, userId);
        
        if (name != null) {
            playlist.setName(name);
        }
        if (description != null) {
            playlist.setDescription(description);
        }
        
        playlistMapper.updateById(playlist);
        return playlist;
    }
    
    @Override
    @Transactional
    public void updateCover(Long playlistId, MultipartFile coverFile, Long userId) {
        Playlist playlist = getPlaylistAndCheckOwner(playlistId, userId);
        
        String coverKey = minioService.uploadCover(coverFile);
        String coverUrl = minioService.getCoverUrl(coverKey);
        
        playlist.setCoverKey(coverKey);
        playlist.setCoverUrl(coverUrl);
        playlistMapper.updateById(playlist);
    }
    
    @Override
    @Transactional
    public void deletePlaylist(Long playlistId, Long userId) {
        getPlaylistAndCheckOwner(playlistId, userId);
        
        playlistItemMapper.delete(
                new LambdaQueryWrapper<PlaylistItem>()
                        .eq(PlaylistItem::getPlaylistId, playlistId)
        );
        
        // 使用显式 SQL 执行逻辑删除，确保 deleted 字段被正确更新
        int rows = playlistMapper.logicalDeleteById(playlistId);
        if (rows == 0) {
            log.warn("Playlist {} logical delete affected 0 rows, may already be deleted", playlistId);
        }
        log.info("Playlist {} deleted by user {}", playlistId, userId);
    }
    
    @Override
    public PlaylistDTO getPlaylistDetail(Long playlistId, Long userId) {
        Playlist playlist = playlistMapper.selectById(playlistId);
        if (playlist == null || playlist.getDeleted() == 1) {
            throw new RuntimeException("Playlist not found");
        }
        
        if (playlist.getIsPublic() == 0 && !playlist.getOwnerId().equals(userId)) {
            throw new RuntimeException("Access denied");
        }
        
        return toDTO(playlist);
    }
    
    @Override
    @Transactional
    public void addTrackToPlaylist(Long playlistId, Long trackId, Long userId) {
        Playlist playlist = getPlaylistAndCheckOwner(playlistId, userId);
        
        Track track = trackMapper.selectById(trackId);
        if (track == null || track.getStatus() != 1) {
            throw new RuntimeException("Track not found or not published");
        }
        
        Long count = playlistItemMapper.selectCount(
                new LambdaQueryWrapper<PlaylistItem>()
                        .eq(PlaylistItem::getPlaylistId, playlistId)
                        .eq(PlaylistItem::getTrackId, trackId)
        );
        if (count > 0) {
            throw new RuntimeException("Track already in playlist");
        }
        
        Integer maxPosition = playlistItemMapper.selectList(
                new LambdaQueryWrapper<PlaylistItem>()
                        .eq(PlaylistItem::getPlaylistId, playlistId)
                        .orderByDesc(PlaylistItem::getPosition)
                        .last("LIMIT 1")
        ).stream().findFirst().map(PlaylistItem::getPosition).orElse(0);
        
        PlaylistItem item = new PlaylistItem();
        item.setPlaylistId(playlistId);
        item.setTrackId(trackId);
        item.setPosition(maxPosition + 1);
        playlistItemMapper.insert(item);
        
        playlist.setTrackCount(playlist.getTrackCount() + 1);
        playlistMapper.updateById(playlist);
    }
    
    @Override
    @Transactional
    public void removeTrackFromPlaylist(Long playlistId, Long trackId, Long userId) {
        Playlist playlist = getPlaylistAndCheckOwner(playlistId, userId);
        
        int deleted = playlistItemMapper.delete(
                new LambdaQueryWrapper<PlaylistItem>()
                        .eq(PlaylistItem::getPlaylistId, playlistId)
                        .eq(PlaylistItem::getTrackId, trackId)
        );
        
        if (deleted > 0) {
            playlist.setTrackCount(Math.max(0, playlist.getTrackCount() - 1));
            playlistMapper.updateById(playlist);
        }
    }
    
    @Override
    @Transactional
    public void reorderTracks(Long playlistId, List<Long> trackIds, Long userId) {
        Playlist playlist = getPlaylistAndCheckOwner(playlistId, userId);
        
        for (int i = 0; i < trackIds.size(); i++) {
            PlaylistItem item = playlistItemMapper.selectOne(
                    new LambdaQueryWrapper<PlaylistItem>()
                            .eq(PlaylistItem::getPlaylistId, playlistId)
                            .eq(PlaylistItem::getTrackId, trackIds.get(i))
            );
            if (item != null) {
                item.setPosition(i + 1);
                playlistItemMapper.updateById(item);
            }
        }
    }
    
    @Override
    public IPage<PlaylistDTO> getUserPlaylists(Long userId, int page, int size) {
        LambdaQueryWrapper<Playlist> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Playlist::getOwnerId, userId)
               .eq(Playlist::getDeleted, 0)
               .orderByDesc(Playlist::getCreatedAt);
        
        IPage<Playlist> playlistPage = playlistMapper.selectPage(new Page<>(page, size), wrapper);
        
        return convertToDTOPage(playlistPage);
    }
    
    @Override
    public IPage<PlaylistDTO> getPublicPlaylists(int page, int size) {
        LambdaQueryWrapper<Playlist> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Playlist::getIsPublic, 1)
               .eq(Playlist::getDeleted, 0)
               .orderByDesc(Playlist::getPlayCount);
        
        IPage<Playlist> playlistPage = playlistMapper.selectPage(new Page<>(page, size), wrapper);
        
        return convertToDTOPage(playlistPage);
    }
    
    @Override
    public IPage<TrackDTO> getPlaylistTracks(Long playlistId, int page, int size, Long userId) {
        Playlist playlist = playlistMapper.selectById(playlistId);
        if (playlist == null || playlist.getDeleted() == 1) {
            throw new RuntimeException("Playlist not found");
        }
        
        List<PlaylistItem> items = playlistItemMapper.selectList(
                new LambdaQueryWrapper<PlaylistItem>()
                        .eq(PlaylistItem::getPlaylistId, playlistId)
                        .orderByAsc(PlaylistItem::getPosition)
        );
        
        if (items.isEmpty()) {
            Page<TrackDTO> emptyPage = new Page<>(page, size, 0);
            emptyPage.setRecords(List.of());
            return emptyPage;
        }
        
        List<Long> trackIds = items.stream()
                .map(PlaylistItem::getTrackId)
                .collect(Collectors.toList());
        
        int start = Math.max(0, (page - 1) * size);
        int end = Math.min(start + size, trackIds.size());
        if (start >= trackIds.size()) {
            Page<TrackDTO> emptyResult = new Page<>(page, size, trackIds.size());
            emptyResult.setRecords(List.of());
            return emptyResult;
        }
        List<Long> pageTrackIds = trackIds.subList(start, end);
        
        List<Track> tracks = trackMapper.selectBatchIds(pageTrackIds);
        
        final boolean isOwner = playlist.getOwnerId().equals(userId);
        List<TrackDTO> dtoList = tracks.stream()
                .filter(t -> t.getStatus() == 1 || isOwner)
                .map(t -> {
                    TrackDTO dto = new TrackDTO();
                    dto.setId(t.getId());
                    dto.setTitle(t.getTitle());
                    dto.setArtist(t.getArtist());
                    dto.setAlbum(t.getAlbum());
                    dto.setDuration(t.getDuration());
                    // 动态封面 URL（优先使用 coverKey）
                    if (t.getCoverKey() != null && !t.getCoverKey().isEmpty()) {
                        dto.setCoverUrl(minioService.getCoverUrl(t.getCoverKey()));
                    } else if (t.getCoverUrl() != null) {
                        dto.setCoverUrl(t.getCoverUrl());
                    }
                    // 播放 URL（基于 MinIO 对象）
                    if (t.getMinioKey() != null && !t.getMinioKey().isEmpty()) {
                        dto.setPlayUrl(minioService.getMusicUrl(t.getMinioKey()));
                    }
                    dto.setPlayCount(t.getPlayCount());
                    dto.setLikeCount(t.getLikeCount());
                    if (userId != null) {
                        dto.setIsFavorited(trackService.isFavorited(t.getId(), userId));
                    }
                    return dto;
                })
                .collect(Collectors.toList());
        
        Page<TrackDTO> resultPage = new Page<>(page, size, trackIds.size());
        resultPage.setRecords(dtoList);
        return resultPage;
    }
    
    private Playlist getPlaylistAndCheckOwner(Long playlistId, Long userId) {
        Playlist playlist = playlistMapper.selectById(playlistId);
        if (playlist == null || playlist.getDeleted() == 1) {
            throw new RuntimeException("Playlist not found");
        }
        if (!playlist.getOwnerId().equals(userId)) {
            throw new RuntimeException("Access denied");
        }
        return playlist;
    }
    
    private PlaylistDTO toDTO(Playlist playlist) {
        PlaylistDTO dto = new PlaylistDTO();
        dto.setId(playlist.getId());
        dto.setName(playlist.getName());
        dto.setDescription(playlist.getDescription());
        
        // 动态生成封面URL（使用cover_key）
        if (playlist.getCoverKey() != null && !playlist.getCoverKey().isEmpty()) {
            dto.setCoverUrl(minioService.getCoverUrl(playlist.getCoverKey()));
        } else if (playlist.getCoverUrl() != null) {
            dto.setCoverUrl(playlist.getCoverUrl());
        }
        
        dto.setOwnerId(playlist.getOwnerId());
        dto.setIsPublic(playlist.getIsPublic());
        dto.setPlayCount(playlist.getPlayCount());
        dto.setTrackCount(playlist.getTrackCount());
        
        if (playlist.getOwnerId() != null) {
            User user = userMapper.selectById(playlist.getOwnerId());
            if (user != null) {
                dto.setOwnerName(user.getNickname() != null ? user.getNickname() : user.getUsername());
            }
        }
        
        if (playlist.getCreatedAt() != null) {
            dto.setCreatedAt(playlist.getCreatedAt().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
        }
        
        return dto;
    }
    
    private IPage<PlaylistDTO> convertToDTOPage(IPage<Playlist> playlistPage) {
        List<PlaylistDTO> dtoList = playlistPage.getRecords().stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
        
        Page<PlaylistDTO> dtoPage = new Page<>(playlistPage.getCurrent(), playlistPage.getSize(), playlistPage.getTotal());
        dtoPage.setRecords(dtoList);
        return dtoPage;
    }
    
    @Override
    @Transactional
    public void deleteAllPlaylists(Long userId) {
        // Get all user's playlists
        List<Playlist> playlists = playlistMapper.selectList(
                new LambdaQueryWrapper<Playlist>()
                        .eq(Playlist::getOwnerId, userId)
        );
        
        // Delete playlist items for each playlist
        for (Playlist playlist : playlists) {
            playlistItemMapper.delete(
                    new LambdaQueryWrapper<PlaylistItem>()
                            .eq(PlaylistItem::getPlaylistId, playlist.getId())
            );
        }
        
        // Delete all playlists
        playlistMapper.delete(
                new LambdaQueryWrapper<Playlist>()
                        .eq(Playlist::getOwnerId, userId)
        );
        
        log.info("Deleted all playlists for user {}", userId);
    }
}
