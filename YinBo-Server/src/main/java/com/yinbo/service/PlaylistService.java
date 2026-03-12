package com.yinbo.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.service.IService;
import com.yinbo.dto.PlaylistDTO;
import com.yinbo.entity.Playlist;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

public interface PlaylistService extends IService<Playlist> {
    
    Playlist createPlaylist(String name, String description, Long ownerId);
    
    Playlist updatePlaylist(Long playlistId, String name, String description, Long userId);
    
    void updateCover(Long playlistId, MultipartFile coverFile, Long userId);
    
    void deletePlaylist(Long playlistId, Long userId);
    
    PlaylistDTO getPlaylistDetail(Long playlistId, Long userId);
    
    void addTrackToPlaylist(Long playlistId, Long trackId, Long userId);
    
    void removeTrackFromPlaylist(Long playlistId, Long trackId, Long userId);
    
    void reorderTracks(Long playlistId, List<Long> trackIds, Long userId);
    
    IPage<PlaylistDTO> getUserPlaylists(Long userId, int page, int size);
    
    IPage<PlaylistDTO> getPublicPlaylists(int page, int size);
    
    IPage<com.yinbo.dto.TrackDTO> getPlaylistTracks(Long playlistId, int page, int size, Long userId);
    
    void deleteAllPlaylists(Long userId);
}