package com.forum.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.forum.entity.*;
import com.forum.mapper.*;
import com.forum.service.FavoriteService;
import com.forum.service.NotificationService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;
import java.util.stream.Collectors;

@Service
public class FavoriteServiceImpl implements FavoriteService {

    private final FavoriteMapper favoriteMapper;
    private final PostMapper postMapper;
    private final UserMapper userMapper;
    private final CategoryMapper categoryMapper;
    private final NotificationService notificationService;

    public FavoriteServiceImpl(FavoriteMapper favoriteMapper, PostMapper postMapper,
                               UserMapper userMapper, CategoryMapper categoryMapper,
                               NotificationService notificationService) {
        this.favoriteMapper = favoriteMapper;
        this.postMapper = postMapper;
        this.userMapper = userMapper;
        this.categoryMapper = categoryMapper;
        this.notificationService = notificationService;
    }

    @Override
    @Transactional
    public boolean toggle(Long userId, Long postId) {
        LambdaQueryWrapper<Favorite> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Favorite::getUserId, userId).eq(Favorite::getPostId, postId);
        Favorite existing = favoriteMapper.selectOne(wrapper);
        if (existing != null) {
            favoriteMapper.deleteById(existing.getId());
            return false;
        } else {
            Favorite fav = new Favorite();
            fav.setUserId(userId);
            fav.setPostId(postId);
            favoriteMapper.insert(fav);
            // Send notification to post author
            Post post = postMapper.selectById(postId);
            User user = userMapper.selectById(userId);
            if (post != null && !post.getUserId().equals(userId) && user != null) {
                notificationService.createNotification(post.getUserId(),
                        user.getNickname() + " 收藏了你的帖子", "FAVORITE", postId);
            }
            return true;
        }
    }

    @Override
    public boolean isFavorited(Long userId, Long postId) {
        LambdaQueryWrapper<Favorite> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Favorite::getUserId, userId).eq(Favorite::getPostId, postId);
        return favoriteMapper.selectOne(wrapper) != null;
    }

    @Override
    public Page<Post> getFavorites(Long userId, int page, int size) {
        LambdaQueryWrapper<Favorite> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Favorite::getUserId, userId).orderByDesc(Favorite::getCreateTime);
        Page<Favorite> favPage = favoriteMapper.selectPage(new Page<>(page, size), wrapper);
        List<Long> postIds = favPage.getRecords().stream()
                .map(Favorite::getPostId).collect(Collectors.toList());
        List<Post> posts = new ArrayList<>();
        if (!postIds.isEmpty()) {
            List<Post> postList = postMapper.selectBatchIds(postIds);
            Map<Long, Post> postMap = postList.stream()
                    .collect(Collectors.toMap(Post::getId, p -> p));
            for (Favorite fav : favPage.getRecords()) {
                Post post = postMap.get(fav.getPostId());
                if (post == null) continue;
                if (post.getStatus() == 1) post.setTitle("该帖子内容已失效");
                User u = userMapper.selectById(post.getUserId());
                if (u != null) { post.setNickname(u.getNickname()); post.setAvatar(u.getAvatar()); }
                Category c = categoryMapper.selectById(post.getCategoryId());
                if (c != null) post.setCategoryName(c.getName());
                post.setIsFavorited(true);
                posts.add(post);
            }
        }
        Page<Post> result = new Page<>(page, size, favPage.getTotal());
        result.setRecords(posts);
        return result;
    }
}
