package com.forum.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.forum.entity.Post;

public interface FavoriteService {
    boolean toggle(Long userId, Long postId);
    boolean isFavorited(Long userId, Long postId);
    Page<Post> getFavorites(Long userId, int page, int size);
}
