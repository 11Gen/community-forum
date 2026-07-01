package com.forum.controller;

import com.forum.common.Result;
import com.forum.entity.Notification;
import com.forum.service.NotificationService;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/notification")
public class NotificationController {

    private final NotificationService notificationService;

    public NotificationController(NotificationService notificationService) {
        this.notificationService = notificationService;
    }

    @GetMapping("/list")
    public Result<?> list(Authentication authentication) {
        Long userId = (Long) authentication.getPrincipal();
        List<Notification> notifications = notificationService.getByUserId(userId);
        return Result.ok(notifications);
    }

    @GetMapping("/unread-count")
    public Result<?> unreadCount(Authentication authentication) {
        Long userId = (Long) authentication.getPrincipal();
        int count = notificationService.getUnreadCount(userId);
        return Result.ok(Map.of("count", count));
    }

    @PutMapping("/{id}/read")
    public Result<?> markRead(@PathVariable Long id) {
        notificationService.markAsRead(id);
        return Result.ok();
    }

    @PutMapping("/read-all")
    public Result<?> markAllRead(Authentication authentication) {
        notificationService.markAllAsRead((Long) authentication.getPrincipal());
        return Result.ok();
    }
}
