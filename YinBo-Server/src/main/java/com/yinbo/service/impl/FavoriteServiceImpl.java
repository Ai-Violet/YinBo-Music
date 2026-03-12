package com.yinbo.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.yinbo.dto.TrackDTO;
import com.yinbo.entity.Favorite;
import com.yinbo.entity.Track;
import com.yinbo.mapper.FavoriteMapper;
import com.yinbo.mapper.TrackMapper;
import com.yinbo.service.FavoriteService;
import com.yinbo.service.MinioService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class FavoriteServiceImpl extends ServiceImpl<FavoriteMapper, Favorite> implements FavoriteService {
    
    private final MinioService minioService;
    
    private final FavoriteMapper favoriteMapper;
    private final TrackMapper trackMapper;
    
    @Override
    @Transactional
    public void addFavorite(Long userId, Long trackId) {
        Track track = trackMapper.selectById(trackId);
        if (track == null || track.getStatus() != 1) {
            throw new RuntimeException("Track not found or not published");
        }
        
        if (isFavorited(userId, trackId)) {
            throw new RuntimeException("Already favorited");
        }
        
        Favorite favorite = new Favorite();
        favorite.setTrackId(trackId);
        favorite.setUserId(userId);
        favorite.setCreatedAt(LocalDateTime.now());
        favoriteMapper.insert(favorite);
        
        trackMapper.incrementLikeCount(trackId);
        
        log.info("User {} added favorite to track {}", userId, trackId);
    }
    
    @Override
    @Transactional
    public void removeFavorite(Long userId, Long trackId) {
        int deleted = favoriteMapper.delete(
                new LambdaQueryWrapper<Favorite>()
                        .eq(Favorite::getUserId, userId)
                        .eq(Favorite::getTrackId, trackId)
        );
        
        if (deleted > 0) {
            trackMapper.decrementLikeCount(trackId);
            log.info("User {} removed favorite from track {}", userId, trackId);
        }
    }
    
    @Override
    public IPage<TrackDTO> getUserFavorites(Long userId, int page, int size) {
        IPage<Favorite> favoritePage = favoriteMapper.selectPage(
                new Page<>(page, size),
                new LambdaQueryWrapper<Favorite>()
                        .eq(Favorite::getUserId, userId)
                        .orderByDesc(Favorite::getCreatedAt)
        );
        
        List<Long> trackIds = favoritePage.getRecords().stream()
                .map(Favorite::getTrackId)
                .collect(Collectors.toList());
        
        if (trackIds.isEmpty()) {
            Page<TrackDTO> emptyPage = new Page<>(page, size, favoritePage.getTotal());
            emptyPage.setRecords(List.of());
            return emptyPage;
        }
        
        List<Track> tracks = trackMapper.selectBatchIds(trackIds);
        Map<Long, Track> trackMap = tracks.stream().collect(Collectors.toMap(Track::getId, t -> t));

        List<TrackDTO> dtoList = trackIds.stream()
                .map(trackMap::get)
                .filter(Objects::nonNull)
                .filter(t -> t.getStatus() == 1)
                .map(t -> {
                    TrackDTO dto = new TrackDTO();
                    dto.setId(t.getId());
                    dto.setTitle(t.getTitle());
                    dto.setArtist(t.getArtist());
                    dto.setAlbum(t.getAlbum());
                    dto.setDuration(t.getDuration());
                    if (t.getCoverKey() != null && !t.getCoverKey().isEmpty()) {
                        dto.setCoverUrl(minioService.getCoverUrl(t.getCoverKey()));
                    } else if (t.getCoverUrl() != null) {
                        dto.setCoverUrl(t.getCoverUrl());
                    }
                    if (t.getMinioKey() != null && !t.getMinioKey().isEmpty()) {
                        dto.setPlayUrl(minioService.getMusicUrl(t.getMinioKey()));
                    }
                    dto.setLyrics(t.getLyrics());
                    dto.setPlayCount(t.getPlayCount());
                    dto.setLikeCount(t.getLikeCount());
                    dto.setIsFavorited(true);
                    return dto;
                })
                .collect(Collectors.toList());
        
        Page<TrackDTO> resultPage = new Page<>(page, size, favoritePage.getTotal());
        resultPage.setRecords(dtoList);
        return resultPage;
    }
    
    @Override
    public boolean isFavorited(Long userId, Long trackId) {
        if (userId == null) {
            return false;
        }
        Long count = favoriteMapper.selectCount(
                new LambdaQueryWrapper<Favorite>()
                        .eq(Favorite::getUserId, userId)
                        .eq(Favorite::getTrackId, trackId)
        );
        return count > 0;
    }
    
    @Override
    @Transactional
    public void removeAllFavorites(Long userId) {
        favoriteMapper.delete(
                new LambdaQueryWrapper<Favorite>()
                        .eq(Favorite::getUserId, userId)
        );
        log.info("Removed all favorites for user {}", userId);
    }
}
