package com.forum.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.forum.dto.PostDTO;
import com.forum.entity.Post;

public interface PostService {
    Post create(Long userId, PostDTO dto);
    Post update(Long userId, Long postId, PostDTO dto);
    void delete(Long userId, Long postId);
    Post getById(Long postId, Long currentUserId);
    Page<Post> getList(int page, int size, Long categoryId, String sort, Long currentUserId);
    Page<Post> search(String keyword, int page, int size);
    Page<Post> getRecommended(int page, int size, Long currentUserId, Long categoryId);
    Page<Post> getEssence(int page, int size);
}
