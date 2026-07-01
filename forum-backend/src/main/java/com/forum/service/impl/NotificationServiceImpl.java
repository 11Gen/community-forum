package com.forum.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.forum.entity.Notification;
import com.forum.mapper.NotificationMapper;
import com.forum.service.NotificationService;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class NotificationServiceImpl implements NotificationService {

    private final NotificationMapper notificationMapper;

    public NotificationServiceImpl(NotificationMapper notificationMapper) {
        this.notificationMapper = notificationMapper;
    }

    @Override
    @Async
    public void createNotification(Long userId, String content, String type, Long targetId) {
        Notification notification = new Notification();
        notification.setUserId(userId);
        notification.setContent(content);
        notification.setType(type);
        notification.setTargetId(targetId);
        notification.setIsRead(0);
        notificationMapper.insert(notification);
    }

    @Override
    public List<Notification> getByUserId(Long userId) {
        LambdaQueryWrapper<Notification> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Notification::getUserId, userId)
               .orderByDesc(Notification::getCreateTime);
        return notificationMapper.selectList(wrapper);
    }

    @Override
    public void markAsRead(Long notificationId) {
        Notification notification = notificationMapper.selectById(notificationId);
        if (notification != null) {
            notification.setIsRead(1);
            notificationMapper.updateById(notification);
        }
    }

    @Override
    public void markAllAsRead(Long userId) {
        LambdaQueryWrapper<Notification> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Notification::getUserId, userId).eq(Notification::getIsRead, 0);
        List<Notification> unread = notificationMapper.selectList(wrapper);
        for (Notification n : unread) {
            n.setIsRead(1);
            notificationMapper.updateById(n);
        }
    }

    @Override
    public int getUnreadCount(Long userId) {
        LambdaQueryWrapper<Notification> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Notification::getUserId, userId)
               .eq(Notification::getIsRead, 0);
        return Math.toIntExact(notificationMapper.selectCount(wrapper));
    }
}
