package com.forum.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.forum.entity.Follow;
import com.forum.entity.Message;
import com.forum.entity.User;
import com.forum.mapper.FollowMapper;
import com.forum.mapper.MessageMapper;
import com.forum.mapper.UserMapper;
import com.forum.service.MessageService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;

@Service
public class MessageServiceImpl implements MessageService {

    private final MessageMapper messageMapper;
    private final FollowMapper followMapper;
    private final UserMapper userMapper;

    public MessageServiceImpl(MessageMapper messageMapper, FollowMapper followMapper, UserMapper userMapper) {
        this.messageMapper = messageMapper;
        this.followMapper = followMapper;
        this.userMapper = userMapper;
    }

    @Override
    @Transactional
    public void send(Long fromUserId, Long toUserId, String content) {
        if (fromUserId.equals(toUserId)) {
            throw new RuntimeException("不能给自己发消息");
        }

        // Check if mutual follow
        LambdaQueryWrapper<Follow> followWrapper = new LambdaQueryWrapper<>();
        followWrapper.eq(Follow::getUserId, fromUserId).eq(Follow::getFollowUserId, toUserId);
        boolean aFollowsB = followMapper.selectOne(followWrapper) != null;

        followWrapper = new LambdaQueryWrapper<>();
        followWrapper.eq(Follow::getUserId, toUserId).eq(Follow::getFollowUserId, fromUserId);
        boolean bFollowsA = followMapper.selectOne(followWrapper) != null;

        boolean mutual = aFollowsB && bFollowsA;

        // If not mutual, enforce 1-message limit
        if (!mutual) {
            // Count messages from A to B
            LambdaQueryWrapper<Message> msgWrapper = new LambdaQueryWrapper<>();
            msgWrapper.eq(Message::getFromUserId, fromUserId).eq(Message::getToUserId, toUserId);
            long countAtoB = messageMapper.selectCount(msgWrapper);

            // Count messages from B to A
            msgWrapper = new LambdaQueryWrapper<>();
            msgWrapper.eq(Message::getFromUserId, toUserId).eq(Message::getToUserId, fromUserId);
            long countBtoA = messageMapper.selectCount(msgWrapper);

            // If recipient has never messaged sender, only allow 1 message
            if (countBtoA == 0 && countAtoB >= 1) {
                throw new RuntimeException("对方尚未回复，不能继续发送消息");
            }
        }

        Message message = new Message();
        message.setFromUserId(fromUserId);
        message.setToUserId(toUserId);
        message.setContent(content);
        message.setIsRead(0);
        messageMapper.insert(message);
    }

    @Override
    public List<Message> getConversation(Long userId1, Long userId2) {
        LambdaQueryWrapper<Message> wrapper = new LambdaQueryWrapper<>();
        wrapper.and(w -> w
                .and(w1 -> w1.eq(Message::getFromUserId, userId1).eq(Message::getToUserId, userId2))
                .or(w2 -> w2.eq(Message::getFromUserId, userId2).eq(Message::getToUserId, userId1))
        ).orderByAsc(Message::getCreateTime);
        List<Message> messages = messageMapper.selectList(wrapper);
        List<Message> filtered = new java.util.ArrayList<>();
        for (Message msg : messages) {
            // Only skip messages deleted by the current user
            if (msg.getDeletedBy() != null && msg.getDeletedBy().equals(userId1)) continue;
            // Handle recalled
            if (msg.getIsRecalled() != null && msg.getIsRecalled() == 1) {
                if (msg.getFromUserId().equals(userId1)) {
                    msg.setContent("你撤回了一条消息");
                } else {
                    msg.setContent("对方撤回了一条消息");
                }
            }
            User fromUser = userMapper.selectById(msg.getFromUserId());
            if (fromUser != null) {
                msg.setSenderId(fromUser.getId());
                msg.setSenderNickname(fromUser.getNickname());
                msg.setSenderAvatar(fromUser.getAvatar());
            }
            filtered.add(msg);
        }
        return filtered;
    }

    @Override
    public List<Map<String, Object>> getConversations(Long userId) {
        // Get all messages involving this user
        LambdaQueryWrapper<Message> wrapper = new LambdaQueryWrapper<>();
        wrapper.and(w -> w
                .eq(Message::getFromUserId, userId)
                .or()
                .eq(Message::getToUserId, userId)
        ).orderByDesc(Message::getCreateTime);
        List<Message> allMessages = messageMapper.selectList(wrapper);

        // Group by the other user, keep latest non-deleted message per conversation
        Map<Long, Message> conversationMap = new LinkedHashMap<>();
        for (Message msg : allMessages) {
            Long otherUserId = msg.getFromUserId().equals(userId) ? msg.getToUserId() : msg.getFromUserId();
            if (!conversationMap.containsKey(otherUserId)) {
                // Skip if this message was deleted by current user
                if (msg.getDeletedBy() != null && msg.getDeletedBy().equals(userId)) continue;
                conversationMap.put(otherUserId, msg);
            }
        }

        List<Map<String, Object>> result = new ArrayList<>();
        for (Map.Entry<Long, Message> entry : conversationMap.entrySet()) {
            Long otherUserId = entry.getKey();
            Message latestMsg = entry.getValue();
            User otherUser = userMapper.selectById(otherUserId);

            // Count unread: messages from other user to this user that are unread
            LambdaQueryWrapper<Message> unreadWrapper = new LambdaQueryWrapper<>();
            unreadWrapper.eq(Message::getFromUserId, otherUserId)
                         .eq(Message::getToUserId, userId)
                         .eq(Message::getIsRead, 0);
            long unreadCount = messageMapper.selectCount(unreadWrapper);

            // Format preview text
            String preview = latestMsg.getContent();
            if (latestMsg.getIsRecalled() != null && latestMsg.getIsRecalled() == 1) {
                preview = latestMsg.getFromUserId().equals(userId) ? "你撤回了一条消息" : "对方撤回了一条消息";
            }
            if (latestMsg.getDeletedBy() != null && latestMsg.getDeletedBy().equals(userId)) {
                continue; // Skip conversations where latest msg is deleted by current user
            }
            Map<String, Object> conv = new HashMap<>();
            conv.put("userId", otherUserId);
            conv.put("nickname", otherUser != null ? otherUser.getNickname() : "未知用户");
            conv.put("avatar", otherUser != null ? otherUser.getAvatar() : null);
            conv.put("lastMessage", preview);
            conv.put("lastMessageTime", latestMsg.getCreateTime());
            conv.put("unreadCount", unreadCount);
            result.add(conv);
        }

        return result;
    }

    @Override
    @Transactional
    public void markRead(Long messageId) {
        Message message = messageMapper.selectById(messageId);
        if (message == null) {
            throw new RuntimeException("消息不存在");
        }
        message.setIsRead(1);
        messageMapper.updateById(message);
    }

    @Override
    public void deleteMessage(Long messageId, Long userId) {
        Message msg = messageMapper.selectById(messageId);
        if (msg == null || !msg.getFromUserId().equals(userId)) return;
        msg.setDeletedBy(userId);
        messageMapper.updateById(msg);
    }

    @Override
    public void recallMessage(Long messageId, Long userId) {
        Message msg = messageMapper.selectById(messageId);
        if (msg == null || !msg.getFromUserId().equals(userId)) return;
        msg.setIsRecalled(1);
        messageMapper.updateById(msg);
    }

    @Override
    public long getUnreadCount(Long userId) {
        LambdaQueryWrapper<Message> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Message::getToUserId, userId).eq(Message::getIsRead, 0);
        return messageMapper.selectCount(wrapper);
    }
}
