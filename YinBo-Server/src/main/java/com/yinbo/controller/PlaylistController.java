package com.yinbo.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.yinbo.common.Result;
import com.yinbo.dto.PlaylistDTO;
import com.yinbo.dto.TrackDTO;
import com.yinbo.entity.Playlist;
import com.yinbo.security.CurrentUser;
import com.yinbo.service.PlaylistService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.HashMap;
import java.util.Map;

@Tag(name = "Playlist API", description = "Playlist related endpoints")
@RestController
@RequestMapping("/playlists")
@RequiredArgsConstructor
public class PlaylistController {
    
    private final PlaylistService playlistService;
    
    @Operation(summary = "Get public playlists by user")
    @GetMapping("/public/user/{userId}")
    public Result<Map<String, Object>> getUserPublicPlaylists(
            @PathVariable Long userId,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int size) {
        IPage<PlaylistDTO> result = playlistService.getUserPlaylists(userId, page - 1, size);
        
        Map<String, Object> response = new HashMap<>();
        response.put("records", result.getRecords());
        response.put("total", result.getTotal());
        response.put("pages", result.getPages());
        response.put("current", result.getCurrent());
        
        return Result.success(response);
    }
    
    @Operation(summary = "Get public playlists")
    @GetMapping("/public")
    public Result<Map<String, Object>> getPublicPlaylists(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int size) {
        IPage<PlaylistDTO> result = playlistService.getPublicPlaylists(page - 1, size);
        
        Map<String, Object> response = new HashMap<>();
        response.put("records", result.getRecords());
        response.put("total", result.getTotal());
        response.put("pages", result.getPages());
        response.put("current", result.getCurrent());
        
        return Result.success(response);
    }
    
    @Operation(summary = "Get current user's playlists")
    @GetMapping("/mine")
    public Result<Map<String, Object>> getMyPlaylists(
            @AuthenticationPrincipal CurrentUser user,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int size) {
        IPage<PlaylistDTO> result = playlistService.getUserPlaylists(user.getUserId(), page - 1, size);
        
        Map<String, Object> response = new HashMap<>();
        response.put("records", result.getRecords());
        response.put("total", result.getTotal());
        response.put("pages", result.getPages());
        response.put("current", result.getCurrent());
        
        return Result.success(response);
    }
    
    @Operation(summary = "Get playlist detail")
    @GetMapping("/public/{id}")
    public Result<PlaylistDTO> getPlaylistDetail(
            @PathVariable Long id,
            @AuthenticationPrincipal CurrentUser user) {
        Long userId = user != null ? user.getUserId() : null;
        PlaylistDTO dto = playlistService.getPlaylistDetail(id, userId);
        return Result.success(dto);
    }
    
    @Operation(summary = "Create playlist")
    @PostMapping
    public Result<PlaylistDTO> createPlaylist(
            @RequestBody CreatePlaylistRequest request,
            @AuthenticationPrincipal CurrentUser user) {
        try {
            if (request.getName() == null || request.getName().trim().isEmpty()) {
                return Result.error("Playlist name required");
            }
            
            Playlist playlist = playlistService.createPlaylist(
                request.getName().trim(), 
                request.getDescription(), 
                user.getUserId()
            );
            
            PlaylistDTO dto = playlistService.getPlaylistDetail(playlist.getId(), user.getUserId());
            return Result.success(dto);
        } catch (Exception e) {
            return Result.error("Failed to create playlist: " + e.getMessage());
        }
    }
    
    @Operation(summary = "Create playlist with cover")
    @PostMapping("/with-cover")
    public Result<PlaylistDTO> createPlaylistWithCover(
            @RequestParam String name,
            @RequestParam(required = false) String description,
            @RequestParam(required = false) MultipartFile cover,
            @AuthenticationPrincipal CurrentUser user) {
        try {
            if (name == null || name.trim().isEmpty()) {
                return Result.error("Playlist name required");
            }
            
            Playlist playlist = playlistService.createPlaylist(name.trim(), description, user.getUserId());
            
            if (cover != null && !cover.isEmpty()) {
                playlistService.updateCover(playlist.getId(), cover, user.getUserId());
            }
            
            PlaylistDTO dto = playlistService.getPlaylistDetail(playlist.getId(), user.getUserId());
            return Result.success(dto);
        } catch (Exception e) {
            return Result.error("Failed to create playlist: " + e.getMessage());
        }
    }
    
    @Operation(summary = "Update playlist")
    @PutMapping("/{id}")
    public Result<PlaylistDTO> updatePlaylist(
            @PathVariable Long id,
            @RequestBody UpdatePlaylistRequest request,
            @AuthenticationPrincipal CurrentUser user) {
        playlistService.updatePlaylist(id, request.getName(), request.getDescription(), user.getUserId());
        PlaylistDTO dto = playlistService.getPlaylistDetail(id, user.getUserId());
        return Result.success(dto);
    }
    
    @Operation(summary = "Update playlist cover")
    @PutMapping("/{id}/cover")
    public Result<PlaylistDTO> updatePlaylistCover(
            @PathVariable Long id,
            @RequestParam MultipartFile cover,
            @AuthenticationPrincipal CurrentUser user) {
        playlistService.updateCover(id, cover, user.getUserId());
        PlaylistDTO dto = playlistService.getPlaylistDetail(id, user.getUserId());
        return Result.success(dto);
    }
    
    @Operation(summary = "Delete playlist")
    @DeleteMapping("/{id}")
    public Result<Void> deletePlaylist(
            @PathVariable Long id,
            @AuthenticationPrincipal CurrentUser user) {
        playlistService.deletePlaylist(id, user.getUserId());
        return Result.success(null);
    }
    
    @Operation(summary = "Get playlist tracks")
    @GetMapping("/{id}/tracks")
    public Result<Map<String, Object>> getPlaylistTracks(
            @PathVariable Long id,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int size,
            @AuthenticationPrincipal CurrentUser user) {
        Long userId = user != null ? user.getUserId() : null;
        IPage<TrackDTO> result = playlistService.getPlaylistTracks(id, page, size, userId);
        
        Map<String, Object> response = new HashMap<>();
        response.put("records", result.getRecords());
        response.put("total", result.getTotal());
        response.put("pages", result.getPages());
        response.put("current", result.getCurrent());
        
        return Result.success(response);
    }
    
    @Operation(summary = "Add track to playlist")
    @PostMapping("/{playlistId}/tracks")
    public Result<Void> addTrackToPlaylist(
            @PathVariable Long playlistId,
            @RequestBody AddTrackRequest request,
            @AuthenticationPrincipal CurrentUser user) {
        playlistService.addTrackToPlaylist(playlistId, request.getTrackId(), user.getUserId());
        return Result.success(null);
    }
    
    @Operation(summary = "Remove track from playlist")
    @DeleteMapping("/{playlistId}/tracks/{trackId}")
    public Result<Void> removeTrackFromPlaylist(
            @PathVariable Long playlistId,
            @PathVariable Long trackId,
            @AuthenticationPrincipal CurrentUser user) {
        playlistService.removeTrackFromPlaylist(playlistId, trackId, user.getUserId());
        return Result.success(null);
    }
    
    // Request DTOs
    @Data
    public static class CreatePlaylistRequest {
        private String name;
        private String description;
    }
    
    @Data
    public static class UpdatePlaylistRequest {
        private String name;
        private String description;
    }
    
    @Data
    public static class AddTrackRequest {
        private Long trackId;
    }
}
