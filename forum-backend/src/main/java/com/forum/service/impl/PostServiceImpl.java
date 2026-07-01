package com.forum.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.forum.dto.PostDTO;
import com.forum.entity.Category;
import com.forum.entity.Favorite;
import com.forum.entity.Post;
import com.forum.entity.User;
import com.forum.mapper.CategoryMapper;
import com.forum.mapper.FavoriteMapper;
import com.forum.mapper.PostMapper;
import com.forum.mapper.UserMapper;
import com.forum.service.FavoriteService;
import com.forum.service.LikeService;
import com.forum.service.PostService;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class PostServiceImpl implements PostService {

    private final PostMapper postMapper;
    private final UserMapper userMapper;
    private final CategoryMapper categoryMapper;
    private final FavoriteMapper favoriteMapper;
    private final LikeService likeService;
    private final FavoriteService favoriteService;

    public PostServiceImpl(PostMapper postMapper, UserMapper userMapper,
                           CategoryMapper categoryMapper, FavoriteMapper favoriteMapper,
                           LikeService likeService, FavoriteService favoriteService) {
        this.postMapper = postMapper;
        this.userMapper = userMapper;
        this.categoryMapper = categoryMapper;
        this.favoriteMapper = favoriteMapper;
        this.likeService = likeService;
        this.favoriteService = favoriteService;
    }

    private void fillPostInfo(Post post, Long currentUserId) {
        User user = userMapper.selectById(post.getUserId());
        if (user != null) {
            post.setNickname(user.getNickname());
            post.setAvatar(user.getAvatar());
        }
        Category cat = categoryMapper.selectById(post.getCategoryId());
        if (cat != null) {
            post.setCategoryName(cat.getName());
        }
        if (currentUserId != null) {
            post.setIsLiked(likeService.isLiked(currentUserId, post.getId()));
            post.setIsFavorited(favoriteService.isFavorited(currentUserId, post.getId()));
        }
        Long fc = favoriteMapper.selectCount(
                new LambdaQueryWrapper<Favorite>().eq(Favorite::getPostId, post.getId()));
        post.setFavCount(fc.intValue());
    }

    @Override
    public Post create(Long userId, PostDTO dto) {
        User user = userMapper.selectById(userId);
        if (user != null && (user.getStatus() == 1 || user.getStatus() == 3)) {
            throw new RuntimeException("你已被禁言，无法发布帖子");
        }
        Post post = new Post();
        post.setTitle(dto.getTitle());
        post.setContent(dto.getContent());
        post.setUserId(userId);
        post.setCategoryId(dto.getCategoryId());
        post.setViewCount(0);
        post.setLikeCount(0);
        post.setCommentCount(0);
        post.setIsPinned(0);
        post.setIsEssence(0);
        post.setStatus(0);
        postMapper.insert(post);
        return post;
    }

    @Override
    public Post update(Long userId, Long postId, PostDTO dto) {
        Post post = postMapper.selectById(postId);
        if (post == null) {
            throw new RuntimeException("帖子不存在");
        }
        if (!post.getUserId().equals(userId)) {
            throw new RuntimeException("只能编辑自己的帖子");
        }
        post.setTitle(dto.getTitle());
        post.setContent(dto.getContent());
        post.setCategoryId(dto.getCategoryId());
        postMapper.updateById(post);
        return post;
    }

    @Override
    public void delete(Long userId, Long postId) {
        Post post = postMapper.selectById(postId);
        if (post == null) {
            throw new RuntimeException("帖子不存在");
        }
        if (!post.getUserId().equals(userId)) {
            throw new RuntimeException("只能删除自己的帖子");
        }
        post.setStatus(1);
        postMapper.updateById(post);
    }

    @Override
    public Post getById(Long postId, Long currentUserId) {
        Post post = postMapper.selectById(postId);
        if (post == null || post.getStatus() == 1) {
            throw new RuntimeException("帖子不存在");
        }
        post.setViewCount(post.getViewCount() + 1);
        postMapper.updateById(post);

        fillPostInfo(post, currentUserId);
        return post;
    }

    @Override
    public Page<Post> getList(int page, int size, Long categoryId, String sort, Long currentUserId) {
        LambdaQueryWrapper<Post> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Post::getStatus, 0);
        if (categoryId != null && categoryId > 0) {
            wrapper.eq(Post::getCategoryId, categoryId);
        }
        // 置顶帖优先
        wrapper.orderByDesc(Post::getIsPinned);
        if ("hot".equals(sort)) {
            wrapper.orderByDesc(Post::getLikeCount);
        } else if ("views".equals(sort)) {
            wrapper.orderByDesc(Post::getViewCount);
        }
        wrapper.orderByDesc(Post::getCreateTime);

        Page<Post> pageResult = new Page<>(page, size);
        Page<Post> result = postMapper.selectPage(pageResult, wrapper);

        for (Post post : result.getRecords()) {
            fillPostInfo(post, currentUserId);
        }
        return result;
    }

    @Override
    public Page<Post> search(String keyword, int page, int size) {
        LambdaQueryWrapper<Post> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Post::getStatus, 0)
               .and(w -> w.like(Post::getTitle, keyword).or().like(Post::getContent, keyword))
               .orderByDesc(Post::getIsPinned)
               .orderByDesc(Post::getCreateTime);

        Page<Post> pageResult = new Page<>(page, size);
        Page<Post> result = postMapper.selectPage(pageResult, wrapper);

        for (Post post : result.getRecords()) {
            fillPostInfo(post, null);
        }
        return result;
    }

    @Override
    public Page<Post> getRecommended(int page, int size, Long currentUserId, Long categoryId) {
        LambdaQueryWrapper<Post> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Post::getStatus, 0);
        if (categoryId != null && categoryId > 0) {
            wrapper.eq(Post::getCategoryId, categoryId);
        }
        List<Post> allPosts = postMapper.selectList(wrapper);

        java.time.LocalDateTime now = java.time.LocalDateTime.now();
        allPosts.sort((a, b) -> {
            double scoreA = calcScore(a, now);
            double scoreB = calcScore(b, now);
            return Double.compare(scoreB, scoreA);
        });

        int total = allPosts.size();
        int from = Math.min((page - 1) * size, total);
        int to = Math.min(from + size, total);
        List<Post> pageList = allPosts.subList(from, to);

        for (Post post : pageList) {
            fillPostInfo(post, currentUserId);
        }

        Page<Post> result = new Page<>(page, size, total);
        result.setRecords(pageList);
        return result;
    }

    private double calcScore(Post post, java.time.LocalDateTime now) {
        double engagement = post.getLikeCount() * 3.0
                          + post.getCommentCount() * 2.0
                          + post.getViewCount() * 1.0;
        long days = java.time.Duration.between(post.getCreateTime(), now).toDays();
        double recency = 1.0 + Math.max(0, 7 - days) / 7.0;
        return engagement * recency;
    }

    @Override
    public Page<Post> getEssence(int page, int size) {
        LambdaQueryWrapper<Post> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Post::getStatus, 0).eq(Post::getIsEssence, 1)
               .orderByDesc(Post::getCreateTime);
        Page<Post> result = postMapper.selectPage(new Page<>(page, size), wrapper);
        for (Post post : result.getRecords()) {
            fillPostInfo(post, null);
        }
        return result;
    }
}
