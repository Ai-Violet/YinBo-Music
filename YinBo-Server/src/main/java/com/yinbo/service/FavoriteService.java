package com.yinbo.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.service.IService;
import com.yinbo.dto.TrackDTO;
import com.yinbo.entity.Favorite;

public interface FavoriteService extends IService<Favorite> {
    
    void addFavorite(Long userId, Long trackId);
    
    void removeFavorite(Long userId, Long trackId);
    
    boolean isFavorited(Long userId, Long trackId);
    
    IPage<TrackDTO> getUserFavorites(Long userId, int page, int size);
    
    void removeAllFavorites(Long userId);
}