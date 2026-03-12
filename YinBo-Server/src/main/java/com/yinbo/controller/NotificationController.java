package com.yinbo.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.yinbo.common.Result;
import com.yinbo.dto.NotificationDTO;
import com.yinbo.entity.Notification;
import com.yinbo.entity.User;
import com.yinbo.mapper.UserMapper;
import com.yinbo.security.CurrentUser;
import com.yinbo.service.MinioService;
import com.yinbo.service.NotificationService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Tag(name = "Notification API")
@RestController
@RequestMapping("/notifications")
@RequiredArgsConstructor
public class NotificationController {

    private final NotificationService notificationService;
    private final UserMapper userMapper;
    private final MinioService minioService;

    @Operation(summary = "Get my notifications")
    @GetMapping("/me")
    public Result<Map<String, Object>> getMyNotifications(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int size,
            @AuthenticationPrincipal CurrentUser user) {
        IPage<Notification> p = notificationService.getMyNotifications(user.getUserId(), page, size);
        List<NotificationDTO> list = p.getRecords().stream().map(this::toDTO).collect(Collectors.toList());
        int unreadCount = notificationService.getUnreadCount(user.getUserId());
        Map<String, Object> result = new HashMap<>();
        result.put("records", list);
        result.put("total", p.getTotal());
        result.put("unreadCount", unreadCount);
        return Result.success(result);
    }

    @Operation(summary = "Get unread count")
    @GetMapping("/me/unread-count")
    public Result<Integer> getUnreadCount(@AuthenticationPrincipal CurrentUser user) {
        return Result.success(notificationService.getUnreadCount(user.getUserId()));
    }

    @Operation(summary = "Mark all as read")
    @PutMapping("/me/read")
    public Result<Void> markAllRead(@AuthenticationPrincipal CurrentUser user) {
        notificationService.markAllRead(user.getUserId());
        return Result.success();
    }

    private NotificationDTO toDTO(Notification n) {
        NotificationDTO dto = new NotificationDTO();
        dto.setId(n.getId());
        dto.setUserId(n.getUserId());
        dto.setFromUserId(n.getFromUserId());
        dto.setType(n.getType());
        dto.setRefId(n.getRefId());
        dto.setRefType(n.getRefType());
        dto.setExtra(n.getExtra());
        dto.setRead(n.getRead());
        if (n.getCreatedAt() != null) {
            dto.setCreatedAt(n.getCreatedAt().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
        }
        if (n.getFromUserId() != null) {
            User u = userMapper.selectById(n.getFromUserId());
            if (u != null) {
                dto.setFromUserNickname(u.getNickname() != null ? u.getNickname() : u.getUsername());
                if (u.getAvatar() != null && !u.getAvatar().isEmpty()) {
                    dto.setFromUserAvatar(minioService.getAvatarUrl(u.getAvatar()));
                }
            }
        }
        return dto;
    }
}
