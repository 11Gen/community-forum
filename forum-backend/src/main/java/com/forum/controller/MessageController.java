package com.forum.controller;

import com.forum.common.Result;
import com.forum.dto.MessageSendDTO;
import com.forum.entity.Message;
import com.forum.service.MessageService;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/message")
public class MessageController {

    private final MessageService messageService;

    public MessageController(MessageService messageService) {
        this.messageService = messageService;
    }

    @PostMapping("/send")
    public Result<?> send(@RequestBody MessageSendDTO dto, Authentication authentication) {
        Long userId = (Long) authentication.getPrincipal();
        messageService.send(userId, dto.getToUserId(), dto.getContent());
        return Result.ok();
    }

    @GetMapping("/conversation/{userId}")
    public Result<?> conversation(@PathVariable Long userId, Authentication authentication) {
        Long currentUserId = (Long) authentication.getPrincipal();
        List<Message> messages = messageService.getConversation(currentUserId, userId);
        return Result.ok(messages);
    }

    @GetMapping("/conversations")
    public Result<?> conversations(Authentication authentication) {
        Long userId = (Long) authentication.getPrincipal();
        List<Map<String, Object>> conversations = messageService.getConversations(userId);
        return Result.ok(conversations);
    }

    @PutMapping("/{id}/read")
    public Result<?> markRead(@PathVariable Long id) {
        messageService.markRead(id);
        return Result.ok();
    }

    @GetMapping("/unread-count")
    public Result<?> unreadCount(Authentication authentication) {
        Long userId = (Long) authentication.getPrincipal();
        long count = messageService.getUnreadCount(userId);
        return Result.ok(Map.of("count", count));
    }

    @DeleteMapping("/{id}")
    public Result<?> deleteMsg(@PathVariable Long id, Authentication authentication) {
        messageService.deleteMessage(id, (Long) authentication.getPrincipal());
        return Result.ok();
    }

    @PutMapping("/{id}/recall")
    public Result<?> recall(@PathVariable Long id, Authentication authentication) {
        messageService.recallMessage(id, (Long) authentication.getPrincipal());
        return Result.ok();
    }
}
