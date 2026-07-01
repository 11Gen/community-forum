package com.forum.service;

import com.forum.dto.CommentDTO;
import com.forum.entity.Comment;
import java.util.List;

public interface CommentService {
    Comment create(Long userId, CommentDTO dto);
    void delete(Long userId, Long commentId);
    List<Comment> getByPostId(Long postId, Long currentUserId);
    void togglePin(Long userId, Long commentId, Long postId);
    boolean toggleLike(Long userId, Long commentId);
    boolean isCommentLiked(Long userId, Long commentId);
}
