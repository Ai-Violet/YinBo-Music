package com.yinbo.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.yinbo.common.Result;
import com.yinbo.entity.User;
import com.yinbo.entity.UserFollow;
import com.yinbo.mapper.UserFollowMapper;
import com.yinbo.mapper.UserMapper;
import com.yinbo.security.CurrentUser;
import com.yinbo.service.NotificationService;
import com.yinbo.service.MinioService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@Tag(name = "Follow API")
@RestController
@RequestMapping("/follows")
@RequiredArgsConstructor
public class FollowController {

    private final UserFollowMapper followMapper;
    private final UserMapper userMapper;
    private final MinioService minioService;
    private final NotificationService notificationService;

    @Operation(summary = "Follow a user")
    @PostMapping("/{userId}")
    public Result<Void> follow(
            @PathVariable Long userId,
            @AuthenticationPrincipal CurrentUser user) {
        if (userId.equals(user.getUserId())) {
            return Result.error("不能关注自己");
        }
        LambdaQueryWrapper<UserFollow> w = new LambdaQueryWrapper<>();
        w.eq(UserFollow::getFollowerId, user.getUserId())
         .eq(UserFollow::getFollowingId, userId);
        if (followMapper.selectCount(w) > 0) {
            return Result.error("已关注");
        }
        UserFollow f = new UserFollow();
        f.setFollowerId(user.getUserId());
        f.setFollowingId(userId);
        followMapper.insert(f);
        notificationService.create(userId, user.getUserId(), "FOLLOW", userId, "user", null);
        return Result.success();
    }

    @Operation(summary = "Unfollow a user")
    @DeleteMapping("/{userId}")
    public Result<Void> unfollow(
            @PathVariable Long userId,
            @AuthenticationPrincipal CurrentUser user) {
        LambdaQueryWrapper<UserFollow> w = new LambdaQueryWrapper<>();
        w.eq(UserFollow::getFollowerId, user.getUserId())
         .eq(UserFollow::getFollowingId, userId);
        followMapper.delete(w);
        return Result.success();
    }

    @Operation(summary = "Check if following")
    @GetMapping("/check/{userId}")
    public Result<Boolean> isFollowing(
            @PathVariable Long userId,
            @AuthenticationPrincipal CurrentUser user) {
        if (user == null) return Result.success(false);
        LambdaQueryWrapper<UserFollow> w = new LambdaQueryWrapper<>();
        w.eq(UserFollow::getFollowerId, user.getUserId())
         .eq(UserFollow::getFollowingId, userId);
        return Result.success(followMapper.selectCount(w) > 0);
    }

    @Operation(summary = "Get follow counts for a user")
    @GetMapping("/counts/{userId}")
    public Result<Map<String, Long>> getCounts(@PathVariable Long userId) {
        LambdaQueryWrapper<UserFollow> followingW = new LambdaQueryWrapper<>();
        followingW.eq(UserFollow::getFollowerId, userId);
        long followingCount = followMapper.selectCount(followingW);

        LambdaQueryWrapper<UserFollow> followerW = new LambdaQueryWrapper<>();
        followerW.eq(UserFollow::getFollowingId, userId);
        long followerCount = followMapper.selectCount(followerW);

        Map<String, Long> counts = new HashMap<>();
        counts.put("following", followingCount);
        counts.put("followers", followerCount);
        return Result.success(counts);
    }

    @Operation(summary = "Get following list")
    @GetMapping("/{userId}/following")
    public Result<IPage<Map<String, Object>>> getFollowing(
            @PathVariable Long userId,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int size) {
        LambdaQueryWrapper<UserFollow> w = new LambdaQueryWrapper<>();
        w.eq(UserFollow::getFollowerId, userId).orderByDesc(UserFollow::getCreatedAt);
        IPage<UserFollow> p = followMapper.selectPage(new Page<>(page, size), w);
        return Result.success(p.convert(f -> toUserMap(f.getFollowingId())));
    }

    @Operation(summary = "Get followers list")
    @GetMapping("/{userId}/followers")
    public Result<IPage<Map<String, Object>>> getFollowers(
            @PathVariable Long userId,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int size) {
        LambdaQueryWrapper<UserFollow> w = new LambdaQueryWrapper<>();
        w.eq(UserFollow::getFollowingId, userId).orderByDesc(UserFollow::getCreatedAt);
        IPage<UserFollow> p = followMapper.selectPage(new Page<>(page, size), w);
        return Result.success(p.convert(f -> toUserMap(f.getFollowerId())));
    }

    private Map<String, Object> toUserMap(Long userId) {
        Map<String, Object> map = new HashMap<>();
        User u = userMapper.selectById(userId);
        if (u != null) {
            map.put("id", u.getId());
            map.put("username", u.getUsername());
            map.put("nickname", u.getNickname());
            map.put("signature", u.getSignature());
            if (u.getAvatar() != null && !u.getAvatar().isEmpty()) {
                map.put("avatar", minioService.getAvatarUrl(u.getAvatar()));
            }
        }
        return map;
    }
}
