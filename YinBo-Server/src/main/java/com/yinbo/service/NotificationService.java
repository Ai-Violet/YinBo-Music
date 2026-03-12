package com.yinbo.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.yinbo.entity.Notification;

public interface NotificationService {
    void create(Long userId, Long fromUserId, String type, Long refId, String refType, String extra);
    IPage<Notification> getMyNotifications(Long userId, int page, int size);
    int getUnreadCount(Long userId);
    void markAllRead(Long userId);
}
