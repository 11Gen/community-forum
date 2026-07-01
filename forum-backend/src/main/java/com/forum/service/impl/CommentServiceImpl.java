package com.forum.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.forum.dto.CommentDTO;
import com.forum.entity.*;
import com.forum.mapper.CommentLikeMapper;
import com.forum.mapper.CommentMapper;
import com.forum.mapper.PostMapper;
import com.forum.mapper.UserMapper;
import com.forum.service.CommentService;
import com.forum.service.NotificationService;
import org.springframework.stereotype.Service;

import java.util.*;

@Service
public class CommentServiceImpl implements CommentService {

    private final CommentMapper commentMapper;
    private final CommentLikeMapper commentLikeMapper;
    private final PostMapper postMapper;
    private final UserMapper userMapper;
    private final NotificationService notificationService;

    public CommentServiceImpl(CommentMapper commentMapper, CommentLikeMapper commentLikeMapper,
                              PostMapper postMapper, UserMapper userMapper,
                              NotificationService notificationService) {
        this.commentMapper = commentMapper;
        this.commentLikeMapper = commentLikeMapper;
        this.postMapper = postMapper;
        this.userMapper = userMapper;
        this.notificationService = notificationService;
    }

    @Override
    public Comment create(Long userId, CommentDTO dto) {
        User user = userMapper.selectById(userId);
        if (user != null && (user.getStatus() == 1 || user.getStatus() == 3)) {
            throw new RuntimeException("你已被禁言，无法发表评论");
        }
        Post post = postMapper.selectById(dto.getPostId());
        if (post == null || post.getStatus() == 1) {
            throw new RuntimeException("帖子不存在");
        }
        Comment comment = new Comment();
        comment.setContent(dto.getContent());
        comment.setUserId(userId);
        comment.setPostId(dto.getPostId());
        comment.setParentId(dto.getParentId());
        comment.setIsPinned(0);
        comment.setLikeCount(0);
        comment.setStatus(0);
        commentMapper.insert(comment);

        post.setCommentCount(post.getCommentCount() + 1);
        postMapper.updateById(post);

        String preview = dto.getContent();
        if (preview.length() > 50) preview = preview.substring(0, 50) + "...";
        if (!post.getUserId().equals(userId)) {
            notificationService.createNotification(post.getUserId(),
                    (user != null ? user.getNickname() : "有人") + " 评论了你的帖子: " + preview, "COMMENT", post.getId());
        }
        if (dto.getParentId() != null) {
            Comment parentComment = commentMapper.selectById(dto.getParentId());
            if (parentComment != null && !parentComment.getUserId().equals(userId)) {
                notificationService.createNotification(parentComment.getUserId(),
                        (user != null ? user.getNickname() : "有人") + " 回复了你的评论: " + preview, "COMMENT", post.getId());
            }
        }
        return comment;
    }

    @Override
    public void delete(Long userId, Long commentId) {
        Comment comment = commentMapper.selectById(commentId);
        if (comment == null) throw new RuntimeException("评论不存在");
        if (!comment.getUserId().equals(userId)) throw new RuntimeException("只能删除自己的评论");
        comment.setStatus(1);
        commentMapper.updateById(comment);
        Post post = postMapper.selectById(comment.getPostId());
        if (post != null && post.getCommentCount() > 0) {
            post.setCommentCount(post.getCommentCount() - 1);
            postMapper.updateById(post);
        }
    }

    @Override
    public List<Comment> getByPostId(Long postId, Long currentUserId) {
        LambdaQueryWrapper<Comment> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Comment::getPostId, postId).eq(Comment::getStatus, 0);
        List<Comment> allComments = commentMapper.selectList(wrapper);

        // Fill user info, like count, reply count, isLiked
        for (Comment comment : allComments) {
            User user = userMapper.selectById(comment.getUserId());
            if (user != null) {
                comment.setNickname(user.getNickname());
                comment.setAvatar(user.getAvatar());
            }
            if (currentUserId != null) {
                comment.setIsLiked(isCommentLiked(currentUserId, comment.getId()));
            }
            // Count replies
            long replyCount = allComments.stream().filter(c -> c.getParentId() != null && c.getParentId().equals(comment.getId())).count();
            comment.setReplyCount((int) replyCount);
        }

        // Build tree
        Map<Long, List<Comment>> childrenMap = new HashMap<>();
        for (Comment c : allComments) {
            if (c.getParentId() != null) {
                childrenMap.computeIfAbsent(c.getParentId(), k -> new ArrayList<>()).add(c);
            }
        }

        List<Comment> roots = new ArrayList<>();
        for (Comment c : allComments) {
            if (c.getParentId() == null) {
                c.setChildren(childrenMap.getOrDefault(c.getId(), new ArrayList<>()));
                roots.add(c);
            }
        }

        // Sort: pinned first, then by hotness (likeCount*2 + replyCount*1)
        roots.sort((a, b) -> {
            if (a.getIsPinned() != null && a.getIsPinned() == 1 && (b.getIsPinned() == null || b.getIsPinned() == 0)) return -1;
            if (b.getIsPinned() != null && b.getIsPinned() == 1 && (a.getIsPinned() == null || a.getIsPinned() == 0)) return 1;
            int hotA = (a.getLikeCount() != null ? a.getLikeCount() : 0) * 2 + (a.getReplyCount() != null ? a.getReplyCount() : 0);
            int hotB = (b.getLikeCount() != null ? b.getLikeCount() : 0) * 2 + (b.getReplyCount() != null ? b.getReplyCount() : 0);
            if (hotA != hotB) return Integer.compare(hotB, hotA);
            return a.getCreateTime().compareTo(b.getCreateTime());
        });

        return roots;
    }

    @Override
    public void togglePin(Long userId, Long commentId, Long postId) {
        Post post = postMapper.selectById(postId);
        if (post == null || !post.getUserId().equals(userId))
            throw new RuntimeException("只有帖主才能置顶评论");
        Comment comment = commentMapper.selectById(commentId);
        if (comment == null || !comment.getPostId().equals(postId))
            throw new RuntimeException("评论不属于该帖子");
        if (comment.getParentId() != null)
            throw new RuntimeException("只能置顶一级评论");
        comment.setIsPinned(comment.getIsPinned() != null && comment.getIsPinned() == 1 ? 0 : 1);
        commentMapper.updateById(comment);
    }

    @Override
    public boolean toggleLike(Long userId, Long commentId) {
        LambdaQueryWrapper<CommentLike> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(CommentLike::getUserId, userId).eq(CommentLike::getCommentId, commentId);
        CommentLike existing = commentLikeMapper.selectOne(wrapper);
        Comment comment = commentMapper.selectById(commentId);
        if (existing != null) {
            commentLikeMapper.deleteById(existing.getId());
            if (comment != null && comment.getLikeCount() > 0) {
                comment.setLikeCount(comment.getLikeCount() - 1);
                commentMapper.updateById(comment);
            }
            return false;
        } else {
            CommentLike cl = new CommentLike();
            cl.setUserId(userId);
            cl.setCommentId(commentId);
            commentLikeMapper.insert(cl);
            if (comment != null) {
                comment.setLikeCount(comment.getLikeCount() != null ? comment.getLikeCount() + 1 : 1);
                commentMapper.updateById(comment);
                if (!comment.getUserId().equals(userId)) {
                    User liker = userMapper.selectById(userId);
                    notificationService.createNotification(comment.getUserId(),
                            (liker != null ? liker.getNickname() : "有人") + " 赞了你的评论", "COMMENT_LIKE", comment.getPostId());
                }
            }
            return true;
        }
    }

    @Override
    public boolean isCommentLiked(Long userId, Long commentId) {
        LambdaQueryWrapper<CommentLike> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(CommentLike::getUserId, userId).eq(CommentLike::getCommentId, commentId);
        return commentLikeMapper.selectOne(wrapper) != null;
    }
}
