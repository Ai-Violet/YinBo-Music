package com.yinbo.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.yinbo.common.Result;
import com.yinbo.dto.PortalSearchResult;
import com.yinbo.dto.TrackDTO;
import com.yinbo.entity.Category;
import com.yinbo.entity.Track;
import com.yinbo.mapper.CategoryMapper;
import com.yinbo.security.CurrentUser;
import com.yinbo.service.TrackService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

@Tag(name = "Track API", description = "Track related endpoints")
@RestController
@RequestMapping("/tracks")
@RequiredArgsConstructor
public class TrackController {
    
    private final TrackService trackService;
    private final CategoryMapper categoryMapper;
    
    @Operation(summary = "Get all categories (public)")
    @GetMapping("/public/categories")
    public Result<java.util.List<Category>> getPublicCategories() {
        var wrapper = new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<Category>();
        wrapper.eq(Category::getDeleted, 0).orderByAsc(Category::getSort);
        return Result.success(categoryMapper.selectList(wrapper));
    }

    @Operation(summary = "Get track list")
    @GetMapping("/public/list")
    public Result<IPage<TrackDTO>> getTrackList(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) Long categoryId,
            @RequestParam(required = false) Long singerId,
            @RequestParam(required = false) String artist,
            @AuthenticationPrincipal CurrentUser user) {
        Long userId = user != null ? user.getUserId() : null;
        return Result.success(trackService.getTrackList(page, size, keyword, categoryId, singerId, artist, userId));
    }
    
    @Operation(summary = "Get hot tracks")
    @GetMapping("/public/hot")
    public Result<IPage<TrackDTO>> getHotTracks(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(defaultValue = "false") boolean random) {
        return Result.success(trackService.getHotTracks(page, size, random));
    }
    
    @Operation(summary = "Get new tracks")
    @GetMapping("/public/new")
    public Result<IPage<TrackDTO>> getNewTracks(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int size) {
        return Result.success(trackService.getNewTracks(page, size));
    }

    @Operation(summary = "Get most liked tracks")
    @GetMapping("/public/most-liked")
    public Result<IPage<TrackDTO>> getMostLikedTracks(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int size) {
        return Result.success(trackService.getMostLikedTracks(page, size));
    }

    @Operation(summary = "Get most commented tracks")
    @GetMapping("/public/most-commented")
    public Result<IPage<TrackDTO>> getMostCommentedTracks(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int size) {
        return Result.success(trackService.getMostCommentedTracks(page, size));
    }
    
    @Operation(summary = "Search tracks")
    @GetMapping("/public/search")
    public Result<IPage<TrackDTO>> searchTracks(
            @RequestParam(required = false, defaultValue = "") String keyword,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int size) {
        return Result.success(trackService.searchTracks(keyword != null ? keyword : "", page, size));
    }

    @Operation(summary = "聚合搜索：歌手 + 歌曲（含拼音/首字母 search_norm）")
    @GetMapping("/public/search/portal")
    public Result<PortalSearchResult> searchPortal(
            @RequestParam(required = false, defaultValue = "") String keyword,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(defaultValue = "12") int singerLimit,
            @RequestParam(required = false) Long categoryId,
            @AuthenticationPrincipal CurrentUser user) {
        Long userId = user != null ? user.getUserId() : null;
        return Result.success(trackService.searchPortal(
                keyword != null ? keyword : "", page, size, singerLimit, categoryId, userId));
    }
    
    @Operation(summary = "Get search hot keywords")
    @GetMapping("/public/search/hot-keywords")
    public Result<java.util.List<String>> getSearchHotKeywords() {
        return Result.success(trackService.getSearchHotKeywords());
    }
    
    @Operation(summary = "Get track detail")
    @GetMapping("/public/{id}")
    public Result<TrackDTO> getTrackDetail(
            @PathVariable Long id,
            @AuthenticationPrincipal CurrentUser user) {
        Long userId = user != null ? user.getUserId() : null;
        return Result.success(trackService.getTrackDetail(id, userId));
    }
    
    @Operation(summary = "Upload track (Admin)")
    @PostMapping("/upload")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<TrackDTO> uploadTrack(
            @RequestParam("music") MultipartFile musicFile,
            @RequestParam(value = "cover", required = false) MultipartFile coverFile,
            @RequestParam(value = "lyric", required = false) MultipartFile lyricFile,
            @RequestParam String title,
            @RequestParam String artist,
            @RequestParam(required = false) String album,
            @RequestParam(required = false) Long categoryId,
            @RequestParam(required = false) String lyrics,
            @RequestParam(required = false) Long artistId,
            @AuthenticationPrincipal CurrentUser user) {
        
        Track track = trackService.uploadTrack(
                musicFile, coverFile, lyricFile, title, artist, album,
                categoryId, lyrics, artistId, user.getUserId()
        );
        
        return Result.success("Upload success, pending review", toDTO(track));
    }
    
    @Operation(summary = "Record play")
    @PostMapping("/{id}/play")
    public Result<Void> recordPlay(
            @PathVariable Long id,
            @RequestBody PlayRequest request,
            @AuthenticationPrincipal CurrentUser user) {
        Long userId = user != null ? user.getUserId() : null;
        trackService.recordPlay(id, userId, request.getDurationPlayed());
        return Result.success();
    }
    
    @Operation(summary = "Refresh all track durations (Admin)")
    @PostMapping("/admin/refresh-durations")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<Integer> refreshAllDurations() {
        int updated = trackService.refreshAllTrackDurations();
        return Result.success("Updated " + updated + " track durations", updated);
    }
    
    @Operation(summary = "Refresh single track duration (Admin)")
    @PostMapping("/admin/{id}/refresh-duration")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<Integer> refreshTrackDuration(@PathVariable Long id) {
        int duration = trackService.refreshTrackDuration(id);
        return Result.success("Track duration updated to " + duration + " seconds", duration);
    }
    
    private TrackDTO toDTO(Track track) {
        TrackDTO dto = new TrackDTO();
        dto.setId(track.getId());
        dto.setTitle(track.getTitle());
        dto.setArtist(track.getArtist());
        dto.setAlbum(track.getAlbum());
        dto.setDuration(track.getDuration());
        dto.setCoverUrl(track.getCoverUrl());
        return dto;
    }
    
    @Data
    public static class PlayRequest {
        private Integer durationPlayed;
    }
}