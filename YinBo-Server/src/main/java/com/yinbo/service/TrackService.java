package com.yinbo.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.service.IService;
import com.yinbo.dto.TrackDTO;
import com.yinbo.entity.Track;
import org.springframework.web.multipart.MultipartFile;

public interface TrackService extends IService<Track> {
    
    Track uploadTrack(MultipartFile musicFile, MultipartFile coverFile, MultipartFile lyricFile,
                      String title, String artist, String album, 
                      Long categoryId, String lyrics, Long artistId, Long uploaderId);
    
    TrackDTO getTrackDetail(Long trackId, Long userId);
    
    TrackDTO getTrackDetailForAdmin(Long trackId);
    
    void updateTrack(Long trackId, String title, String artist, String album, Long categoryId, String lyrics, Long artistId);
    
    void updateTrackCover(Long trackId, MultipartFile coverFile);
    
    IPage<TrackDTO> getTrackList(int page, int size, String keyword, Long categoryId, Long singerId, String artist, Long userId);
    
    IPage<TrackDTO> getHotTracks(int page, int size, boolean random);
    
    IPage<TrackDTO> getNewTracks(int page, int size);

    IPage<TrackDTO> getMostLikedTracks(int page, int size);

    IPage<TrackDTO> getMostCommentedTracks(int page, int size);
    
    IPage<TrackDTO> searchTracks(String keyword, int page, int size);
    
    java.util.List<String> getSearchHotKeywords();
    
    IPage<TrackDTO> getPendingTracks(int page, int size);
        
        IPage<TrackDTO> getTracksByStatus(int page, int size, Integer status);
    
    IPage<TrackDTO> getAdminTracks(int page, int size, Integer status, String keyword, Long categoryId);
    
    IPage<TrackDTO> getTopPlayTracks(int limit);
    
    void updateStatus(Long trackId, int status);
    
    void auditTrack(Long trackId, int status, Long operatorId);
    
    void deleteTrack(Long trackId);
    
    void recordPlay(Long trackId, Long userId, int durationPlayed);
    
    boolean isFavorited(Long trackId, Long userId);
    
    /**
     * Refresh duration for all tracks from actual audio files in MinIO
     * @return number of tracks updated
     */
    int refreshAllTrackDurations();
    
    /**
     * Refresh duration for a specific track
     * @param trackId the track ID
     * @return the new duration in seconds
     */
    int refreshTrackDuration(Long trackId);
}