package com.forum.service;

import com.forum.entity.Message;

import java.util.List;
import java.util.Map;

public interface MessageService {
    void send(Long fromUserId, Long toUserId, String content);

    List<Message> getConversation(Long userId1, Long userId2);

    List<Map<String, Object>> getConversations(Long userId);

    void markRead(Long messageId);

    long getUnreadCount(Long userId);
    void deleteMessage(Long messageId, Long userId);
    void recallMessage(Long messageId, Long userId);
}
