package com.yinbo.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.yinbo.common.Result;
import com.yinbo.dto.UserDTO;
import com.yinbo.entity.Comment;
import com.yinbo.entity.PlayHistory;
import com.yinbo.entity.Track;
import com.yinbo.entity.User;
import com.yinbo.mapper.CommentMapper;
import com.yinbo.mapper.PlayHistoryMapper;
import com.yinbo.mapper.TrackMapper;
import com.yinbo.security.CurrentUser;
import com.yinbo.service.FavoriteService;
import com.yinbo.service.MinioService;
import com.yinbo.service.PlaylistService;
import com.yinbo.service.UserService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.HashMap;
import java.util.Map;

@Tag(name = "User API", description = "User related endpoints")
@RestController
@RequestMapping("/users")
@RequiredArgsConstructor
public class UserController {
    
    private final UserService userService;
    private final FavoriteService favoriteService;
    private final PlaylistService playlistService;
    private final MinioService minioService;
    private final CommentMapper commentMapper;
    private final PlayHistoryMapper playHistoryMapper;
    private final TrackMapper trackMapper;
    private final PasswordEncoder passwordEncoder;
    
    @Operation(summary = "Get current user info")
    @GetMapping("/me")
    public Result<UserDTO> getCurrentUser(@AuthenticationPrincipal CurrentUser user) {
        User userInfo = userService.getById(user.getUserId());
        return Result.success(toDTO(userInfo));
    }
    
    @Operation(summary = "Update user info")
    @PutMapping("/me")
    public Result<UserDTO> updateUserInfo(
            @RequestBody UpdateUserRequest request,
            @AuthenticationPrincipal CurrentUser user) {
        User userInfo = new User();
        userInfo.setNickname(request.getNickname());
        userInfo.setSignature(request.getSignature());
        userInfo.setGender(request.getGender());
        userInfo.setRegion(request.getRegion());
        
        // Parse birthday if provided
        if (request.getBirthday() != null && !request.getBirthday().isEmpty()) {
            try {
                userInfo.setBirthday(java.time.LocalDate.parse(request.getBirthday()));
            } catch (Exception e) {
                // Invalid date format, ignore
            }
        }
        
        User updated = userService.updateUserInfo(user.getUserId(), userInfo);
        return Result.success(toDTO(updated));
    }
    
    @Operation(summary = "Upload avatar")
    @PostMapping("/me/avatar")
    public Result<String> uploadAvatar(
            @RequestParam("avatar") MultipartFile file,
            @AuthenticationPrincipal CurrentUser user) {
        
        // Upload to MinIO avatar/ directory
        String avatarKey = minioService.uploadAvatar(file);
        
        // Update user avatar in database (save object key, not presigned URL)
        userService.updateAvatar(user.getUserId(), avatarKey);
        
        // Generate presigned URL for immediate display
        String avatarUrl = minioService.getAvatarUrl(avatarKey);
        return Result.success("Avatar uploaded successfully", avatarUrl);
    }
    
    @Operation(summary = "Change password")
    @PutMapping("/me/password")
    public Result<Void> changePassword(
            @RequestBody ChangePasswordRequest request,
            @AuthenticationPrincipal CurrentUser user) {
        userService.changePassword(user.getUserId(), request.getOldPassword(), request.getNewPassword());
        return Result.success();
    }
    
    @Operation(summary = "Get user public info")
    @GetMapping("/{id}")
    public Result<UserDTO> getUserInfo(@PathVariable Long id) {
        User user = userService.getById(id);
        if (user == null) {
            throw new RuntimeException("用户不存在");
        }
        
        UserDTO dto = new UserDTO();
        dto.setId(user.getId());
        dto.setUsername(user.getUsername());
        dto.setNickname(user.getNickname());
        dto.setSignature(user.getSignature());
        dto.setGender(user.getGender());
        dto.setRegion(user.getRegion());
        if (user.getBirthday() != null) {
            dto.setBirthday(user.getBirthday().toString());
        }
        // Generate presigned URL for avatar if exists
        if (user.getAvatar() != null && !user.getAvatar().isEmpty()) {
            dto.setAvatar(minioService.getAvatarUrl(user.getAvatar()));
        }
        
        return Result.success(dto);
    }
    
    private UserDTO toDTO(User user) {
        UserDTO dto = new UserDTO();
        dto.setId(user.getId());
        dto.setUsername(user.getUsername());
        dto.setEmail(user.getEmail());
        dto.setRole(user.getRole());
        dto.setNickname(user.getNickname());
        dto.setSignature(user.getSignature());
        dto.setGender(user.getGender());
        dto.setRegion(user.getRegion());
        if (user.getBirthday() != null) {
            dto.setBirthday(user.getBirthday().toString());
        }
        // Generate presigned URL for avatar if exists
        if (user.getAvatar() != null && !user.getAvatar().isEmpty()) {
            dto.setAvatar(minioService.getAvatarUrl(user.getAvatar()));
        }
        return dto;
    }
    
    @Data
    public static class UpdateUserRequest {
        private String nickname;
        private String signature;
        private String gender;
        private String birthday;
        private String region;
    }
    
    @Data
    public static class ChangePasswordRequest {
        private String oldPassword;
        private String newPassword;
    }
    
    @Operation(summary = "Get play history")
    @GetMapping("/me/play-history")
    public Result<IPage<Map<String, Object>>> getPlayHistory(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int size,
            @AuthenticationPrincipal CurrentUser user) {
        return Result.success(getUserPlayHistoryPage(user.getUserId(), page, size));
    }

    @Operation(summary = "Get public user play history")
    @GetMapping("/{id}/play-history")
    public Result<IPage<Map<String, Object>>> getPublicUserPlayHistory(
            @PathVariable Long id,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int size) {
        User targetUser = userService.getById(id);
        if (targetUser == null) {
            return Result.error("用户不存在");
        }
        return Result.success(getUserPlayHistoryPage(id, page, size));
    }
    
    @Operation(summary = "Get my comments")
    @GetMapping("/me/comments")
    public Result<IPage<Map<String, Object>>> getMyComments(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int size,
            @AuthenticationPrincipal CurrentUser user) {
        
        Page<Comment> pageParam = new Page<>(page, size);
        LambdaQueryWrapper<Comment> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Comment::getUserId, user.getUserId())
               .eq(Comment::getDeleted, 0)
               .orderByDesc(Comment::getCreatedAt);
        
        IPage<Comment> commentPage = commentMapper.selectPage(pageParam, wrapper);
        
        // Convert to response with track info
        IPage<Map<String, Object>> result = commentPage.convert(comment -> {
            Map<String, Object> map = new HashMap<>();
            map.put("id", comment.getId());
            map.put("content", comment.getContent());
            map.put("status", comment.getStatus() != null ? comment.getStatus() : 1);
            map.put("createdAt", comment.getCreatedAt());
            
            // Get track info
            Track track = trackMapper.selectById(comment.getTrackId());
            if (track != null) {
                map.put("trackId", track.getId());
                map.put("trackTitle", track.getTitle());
                map.put("trackArtist", track.getArtist());
                map.put("trackCover", track.getCoverKey() != null ? 
                    minioService.getCoverUrl(track.getCoverKey()) : null);
            }
            return map;
        });
        
        return Result.success(result);
    }
    
    @Operation(summary = "Clear play history")
    @DeleteMapping("/me/play-history")
    public Result<Void> clearPlayHistory(@AuthenticationPrincipal CurrentUser user) {
        LambdaQueryWrapper<PlayHistory> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(PlayHistory::getUserId, user.getUserId());
        playHistoryMapper.delete(wrapper);
        return Result.success();
    }
    
    /**
     * 删除单条播放记录
     */
    @DeleteMapping("/me/play-history/{historyId}")
    public Result<Void> deletePlayHistoryItem(
            @PathVariable Long historyId,
            @AuthenticationPrincipal CurrentUser user) {
        
        // 验证该记录属于当前用户
        PlayHistory history = playHistoryMapper.selectById(historyId);
        if (history == null) {
            return Result.error("播放记录不存在");
        }
        
        if (!history.getUserId().equals(user.getUserId())) {
            return Result.error("无权删除此记录");
        }
        
        playHistoryMapper.deleteById(historyId);
        return Result.success();
    }
    
    @Operation(summary = "Delete account")
    @DeleteMapping("/me")
    public Result<Void> deleteAccount(
            @RequestBody DeleteAccountRequest request,
            @AuthenticationPrincipal CurrentUser user) {
        
        // Verify username and password
        User userInfo = userService.getById(user.getUserId());
        if (userInfo == null) {
            throw new RuntimeException("用户不存在");
        }
        
        if (!userInfo.getUsername().equals(request.getUsername())) {
            throw new RuntimeException("用户名不匹配");
        }
        
        if (!passwordEncoder.matches(request.getPassword(), userInfo.getPassword())) {
            throw new RuntimeException("密码错误");
        }
        
        Long userId = user.getUserId();
        
        // Delete user's comments
        LambdaQueryWrapper<Comment> commentWrapper = new LambdaQueryWrapper<>();
        commentWrapper.eq(Comment::getUserId, userId);
        commentMapper.delete(commentWrapper);
        
        // Delete user's play history
        LambdaQueryWrapper<PlayHistory> historyWrapper = new LambdaQueryWrapper<>();
        historyWrapper.eq(PlayHistory::getUserId, userId);
        playHistoryMapper.delete(historyWrapper);
        
        // Delete user's favorites
        favoriteService.removeAllFavorites(userId);
        
        // Delete user's playlists
        playlistService.deleteAllPlaylists(userId);
        
        // Delete user
        userService.removeById(userId);
        return Result.success();
    }
    
    @Data
    public static class DeleteAccountRequest {
        private String username;
        private String password;
    }

    private IPage<Map<String, Object>> getUserPlayHistoryPage(Long userId, int page, int size) {
        Page<PlayHistory> pageParam = new Page<>(page, size);
        LambdaQueryWrapper<PlayHistory> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(PlayHistory::getUserId, userId)
               .orderByDesc(PlayHistory::getPlayedAt);

        IPage<PlayHistory> historyPage = playHistoryMapper.selectPage(pageParam, wrapper);

        return historyPage.convert(history -> {
            Map<String, Object> map = new HashMap<>();
            map.put("historyId", history.getId());
            map.put("playedAt", history.getPlayedAt());

            Track track = trackMapper.selectById(history.getTrackId());
            if (track != null) {
                map.put("id", track.getId());
                map.put("trackId", track.getId());
                map.put("title", track.getTitle());
                map.put("artist", track.getArtist());
                map.put("album", track.getAlbum());
                map.put("coverUrl", track.getCoverKey() != null && !track.getCoverKey().isEmpty()
                        ? minioService.getCoverUrl(track.getCoverKey())
                        : track.getCoverUrl());
                map.put("playUrl", track.getMinioKey() != null && !track.getMinioKey().isEmpty()
                        ? minioService.getMusicUrl(track.getMinioKey())
                        : null);
                map.put("duration", track.getDuration());
            }
            return map;
        });
    }
}
