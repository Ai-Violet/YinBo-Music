package com.yinbo.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.yinbo.common.Result;
import com.yinbo.dto.TrackDTO;
import com.yinbo.entity.Category;
import com.yinbo.dto.CommentDTO;
import com.yinbo.entity.Comment;
import com.yinbo.entity.Singer;
import com.yinbo.entity.Track;
import com.yinbo.entity.User;
import com.yinbo.mapper.CategoryMapper;
import com.yinbo.mapper.PlaylistMapper;
import com.yinbo.mapper.TrackMapper;
import com.yinbo.mapper.UserMapper;
import com.yinbo.security.CurrentUser;
import com.yinbo.dto.UserDTO;
import com.yinbo.service.MinioService;
import com.yinbo.service.CommentService;
import com.yinbo.service.SingerService;
import com.yinbo.service.TrackService;
import com.yinbo.service.UserService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Tag(name = "Admin API")
@RestController
@RequestMapping("/admin")
@RequiredArgsConstructor
public class AdminController {
    
    private final UserService userService;
    private final TrackService trackService;
    private final MinioService minioService;
    private final UserMapper userMapper;
    private final TrackMapper trackMapper;
    private final CategoryMapper categoryMapper;
    private final PlaylistMapper playlistMapper;
    private final CommentService commentService;
    private final SingerService singerService;
    
    @Operation(summary = "Get dashboard statistics")
    @GetMapping("/stats")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<Map<String, Object>> getStats() {
        Map<String, Object> stats = new HashMap<>();
        stats.put("userCount", userMapper.selectCount(null));
        stats.put("trackCount", trackMapper.selectCount(null));
        stats.put("playlistCount", playlistMapper.selectCount(null));
        stats.put("playCount", 0); // TODO: count from play history table
        
        // Pending tracks count
        LambdaQueryWrapper<Track> pendingWrapper = new LambdaQueryWrapper<>();
        pendingWrapper.eq(Track::getStatus, 0);
        stats.put("pendingTracks", trackMapper.selectCount(pendingWrapper));

        LambdaQueryWrapper<Comment> pendingCommentWrapper = new LambdaQueryWrapper<>();
        pendingCommentWrapper.eq(Comment::getStatus, 0).eq(Comment::getDeleted, 0);
        stats.put("pendingComments", commentService.count(pendingCommentWrapper));
        
        return Result.success(stats);
    }
    
    @Operation(summary = "Get all tracks with filters")
    @GetMapping("/tracks")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<IPage<TrackDTO>> getAllTracks(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(required = false) Integer status,
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) Long categoryId) {
        return Result.success(trackService.getAdminTracks(page, size, status, keyword, categoryId));
    }
    
    @Operation(summary = "Get top played tracks (ranking)")
    @GetMapping("/tracks/ranking")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<IPage<TrackDTO>> getTrackRanking(
            @RequestParam(defaultValue = "10") int limit) {
        return Result.success(trackService.getTopPlayTracks(limit));
    }
    
    @Operation(summary = "Get all categories")
    @GetMapping("/categories")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<List<Category>> getAllCategories() {
        LambdaQueryWrapper<Category> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Category::getDeleted, 0);
        wrapper.orderByAsc(Category::getSort);
        return Result.success(categoryMapper.selectList(wrapper));
    }
    
    @Operation(summary = "Create category")
    @PostMapping("/categories")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<Category> createCategory(@RequestBody Category category) {
        if (category.getSort() == null) category.setSort(0);
        if (category.getDeleted() == null) category.setDeleted(0);
        categoryMapper.insert(category);
        return Result.success(category);
    }
    
    @Operation(summary = "Update category")
    @PutMapping("/categories/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<Void> updateCategory(@PathVariable Long id, @RequestBody Category category) {
        Category existing = categoryMapper.selectById(id);
        if (existing == null) return Result.badRequest("Category not found");
        category.setId(id);
        categoryMapper.updateById(category);
        return Result.success();
    }
    
    @Operation(summary = "Delete category")
    @DeleteMapping("/categories/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<Void> deleteCategory(@PathVariable Long id) {
        categoryMapper.deleteById(id);
        return Result.success();
    }
    
    @Operation(summary = "List singers")
    @GetMapping("/singers")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<IPage<Singer>> listSingers(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "50") int size,
            @RequestParam(required = false) String keyword) {
        IPage<Singer> pageResult = singerService.listSingers(page, size, keyword);
        pageResult.getRecords().forEach(s -> {
            if (s.getAvatarKey() != null) {
                s.setAvatarUrl(minioService.getSingerAvatarUrl(s.getAvatarKey()));
            }
        });
        return Result.success(pageResult);
    }
    
    @Operation(summary = "Create singer")
    @PostMapping("/singers")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<Singer> createSinger(
            @RequestParam String name,
            @RequestParam(required = false) String description,
            @RequestParam(value = "avatar", required = false) MultipartFile avatarFile) {
        Singer singer = singerService.createSinger(name, avatarFile, description);
        if (singer.getAvatarKey() != null) {
            singer.setAvatarUrl(minioService.getSingerAvatarUrl(singer.getAvatarKey()));
        }
        return Result.success(singer);
    }
    
    @Operation(summary = "Update singer")
    @PutMapping("/singers/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<Singer> updateSinger(
            @PathVariable Long id,
            @RequestParam(required = false) String name,
            @RequestParam(required = false) String description,
            @RequestParam(value = "avatar", required = false) MultipartFile avatarFile) {
        Singer singer = singerService.updateSinger(id, name, avatarFile, description);
        if (singer.getAvatarKey() != null) {
            singer.setAvatarUrl(minioService.getSingerAvatarUrl(singer.getAvatarKey()));
        }
        return Result.success(singer);
    }
    
    @Operation(summary = "Delete singer")
    @DeleteMapping("/singers/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<Void> deleteSinger(@PathVariable Long id) {
        Singer singer = singerService.getById(id);
        if (singer == null) {
            return Result.badRequest("歌手不存在");
        }
        singerService.removeById(id);
        return Result.success();
    }
    
    @Operation(summary = "Get all users")
    @GetMapping("/users")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<IPage<UserDTO>> getUsers(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(required = false) String keyword) {
        IPage<User> userPage = userService.getUserList(page, size, keyword);
        
        // Convert to DTO with avatar URL
        IPage<UserDTO> dtoPage = userPage.convert(this::toUserDTO);
        return Result.success(dtoPage);
    }
    
    @Operation(summary = "Update user status")
    @PutMapping("/users/{id}/status")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<Void> updateUserStatus(
            @PathVariable Long id,
            @RequestParam Integer status,
            @RequestParam(required = false) String adminKey) {
        
        // Check if target user is admin
        User targetUser = userMapper.selectById(id);
        if (targetUser == null) {
            return Result.badRequest("User not found");
        }
        
        // If disabling an admin, require admin key
        if ("ADMIN".equals(targetUser.getRole()) && status != 0) {
            if (!"yinbo".equals(adminKey)) {
                return Result.badRequest("Admin key required to disable admin user");
            }
        }
        
        userService.updateStatus(id, status);
        return Result.success();
    }
    
    @Operation(summary = "Delete user")
    @DeleteMapping("/users/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<Void> deleteUser(
            @PathVariable Long id,
            @RequestParam String adminKey) {
        
        // Verify admin key
        if (!"yinbo".equals(adminKey)) {
            return Result.badRequest("Invalid admin key");
        }
        
        User targetUser = userMapper.selectById(id);
        if (targetUser == null) {
            return Result.badRequest("User not found");
        }
        
        // Hard delete from database
        userMapper.deleteById(id);
        return Result.success();
    }
    
    @Operation(summary = "Batch update user status")
    @PutMapping("/users/batch-status")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<Void> batchUpdateUserStatus(
            @RequestBody java.util.Map<String, Object> body) {
        @SuppressWarnings("unchecked")
        java.util.List<Number> ids = (java.util.List<Number>) body.get("ids");
        Integer status = (Integer) body.get("status");
        if (ids == null || ids.isEmpty() || status == null) {
            return Result.badRequest("Invalid parameters");
        }
        for (Number id : ids) {
            userService.updateStatus(id.longValue(), status);
        }
        return Result.success();
    }

    @Operation(summary = "Get pending tracks")
    @GetMapping("/tracks/pending")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<IPage<TrackDTO>> getPendingTracks(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int size) {
        return Result.success(trackService.getPendingTracks(page, size));
    }
    
    @Operation(summary = "Approve track")
    @PutMapping("/tracks/{id}/approve")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<Void> approveTrack(@PathVariable Long id) {
        trackService.updateStatus(id, 1);
        return Result.success();
    }
    
    @Operation(summary = "Reject track")
    @PutMapping("/tracks/{id}/reject")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<Void> rejectTrack(@PathVariable Long id) {
        trackService.updateStatus(id, 2);
        return Result.success();
    }
    
    @Operation(summary = "Upload track")
    @PostMapping("/tracks/upload")
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
        
        TrackDTO dto = new TrackDTO();
        dto.setId(track.getId());
        dto.setTitle(track.getTitle());
        dto.setArtist(track.getArtist());
        dto.setAlbum(track.getAlbum());
        dto.setDuration(track.getDuration());
        dto.setCoverUrl(track.getCoverUrl());
        
        return Result.success("Upload success", dto);
    }
    
    @Operation(summary = "Get track detail for admin edit")
    @GetMapping("/tracks/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<TrackDTO> getTrackForEdit(@PathVariable Long id) {
        return Result.success(trackService.getTrackDetailForAdmin(id));
    }
    
    @Operation(summary = "Update track")
    @PutMapping("/tracks/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<Void> updateTrack(
            @PathVariable Long id,
            @RequestBody Map<String, Object> body) {
        String title = (String) body.get("title");
        String artist = (String) body.get("artist");
        String album = (String) body.get("album");
        String lyrics = (String) body.get("lyrics");
        Object co = body.get("categoryId");
        Object ao = body.get("artistId");
        Long categoryId = (co != null && !"".equals(String.valueOf(co))) ? Long.valueOf(co.toString()) : null;
        Long artistId = (ao != null && !"".equals(String.valueOf(ao))) ? Long.valueOf(ao.toString()) : null;
        trackService.updateTrack(id, title, artist, album, categoryId, lyrics, artistId);
        return Result.success();
    }
    
    @Operation(summary = "Update track cover")
    @PutMapping("/tracks/{id}/cover")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<Void> updateTrackCover(
            @PathVariable Long id,
            @RequestParam("cover") MultipartFile coverFile) {
        trackService.updateTrackCover(id, coverFile);
        return Result.success();
    }
    
    @Operation(summary = "Delete track")
    @DeleteMapping("/tracks/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<Void> deleteTrack(@PathVariable Long id) {
        trackService.removeById(id);
        return Result.success();
    }

    @Operation(summary = "Get all comments (admin)")
    @GetMapping("/comments")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<IPage<CommentDTO>> getAllComments(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(required = false) Long trackId) {
        return Result.success(commentService.getAllComments(page, size, trackId));
    }

    @Operation(summary = "Audit comment")
    @PutMapping("/comments/{id}/audit")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<Void> auditComment(
            @PathVariable Long id,
            @RequestParam Integer status,
            @AuthenticationPrincipal CurrentUser user) {
        commentService.auditComment(id, status, user.getUserId());
        return Result.success();
    }

    @Operation(summary = "Delete comment")
    @DeleteMapping("/comments/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<Void> deleteComment(
            @PathVariable Long id,
            @AuthenticationPrincipal CurrentUser user) {
        commentService.adminDeleteComment(id, user.getUserId());
        return Result.success();
    }
    
    private UserDTO toUserDTO(User user) {
        UserDTO dto = new UserDTO();
        dto.setId(user.getId());
        dto.setUsername(user.getUsername());
        dto.setEmail(user.getEmail());
        dto.setNickname(user.getNickname());
        dto.setSignature(user.getSignature());
        dto.setRole(user.getRole());
        dto.setStatus(user.getStatus());
        dto.setCreatedAt(user.getCreatedAt() != null ? user.getCreatedAt().toString() : null);
        
        // Generate presigned URL for avatar if exists
        if (user.getAvatar() != null && !user.getAvatar().isEmpty()) {
            dto.setAvatar(minioService.getAvatarUrl(user.getAvatar()));
        }
        
        return dto;
    }
}