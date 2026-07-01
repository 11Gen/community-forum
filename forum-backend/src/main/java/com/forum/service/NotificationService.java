package com.forum.service;

import com.forum.entity.Notification;
import java.util.List;

public interface NotificationService {
    void createNotification(Long userId, String content, String type, Long targetId);
    List<Notification> getByUserId(Long userId);
    void markAsRead(Long notificationId);
    void markAllAsRead(Long userId);
    int getUnreadCount(Long userId);
}
