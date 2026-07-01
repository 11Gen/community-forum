package com.forum.service;

public interface LikeService {
    boolean toggle(Long userId, Long postId);
    boolean isLiked(Long userId, Long postId);
}
