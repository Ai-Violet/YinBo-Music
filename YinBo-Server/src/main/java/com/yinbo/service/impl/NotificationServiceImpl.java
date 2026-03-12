package com.yinbo.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.yinbo.entity.Notification;
import com.yinbo.mapper.NotificationMapper;
import com.yinbo.service.NotificationService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class NotificationServiceImpl implements NotificationService {

    private final NotificationMapper notificationMapper;

    @Override
    public void create(Long userId, Long fromUserId, String type, Long refId, String refType, String extra) {
        if (userId == null || userId.equals(fromUserId)) return;
        Notification n = new Notification();
        n.setUserId(userId);
        n.setFromUserId(fromUserId);
        n.setType(type);
        n.setRefId(refId);
        n.setRefType(refType);
        n.setExtra(extra);
        n.setRead(0);
        notificationMapper.insert(n);
    }

    @Override
    public IPage<Notification> getMyNotifications(Long userId, int page, int size) {
        LambdaQueryWrapper<Notification> w = new LambdaQueryWrapper<>();
        w.eq(Notification::getUserId, userId).orderByDesc(Notification::getCreatedAt);
        return notificationMapper.selectPage(new Page<>(page, size), w);
    }

    @Override
    public int getUnreadCount(Long userId) {
        LambdaQueryWrapper<Notification> w = new LambdaQueryWrapper<>();
        w.eq(Notification::getUserId, userId).eq(Notification::getRead, 0);
        return Math.toIntExact(notificationMapper.selectCount(w));
    }

    @Override
    public void markAllRead(Long userId) {
        notificationMapper.markAllReadByUserId(userId);
    }
}
