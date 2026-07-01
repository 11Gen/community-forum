package com.forum.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.forum.entity.Like;
import com.forum.entity.Post;
import com.forum.entity.User;
import com.forum.mapper.LikeMapper;
import com.forum.mapper.PostMapper;
import com.forum.mapper.UserMapper;
import com.forum.service.LikeService;
import com.forum.service.NotificationService;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class LikeServiceImpl implements LikeService {

    private final LikeMapper likeMapper;
    private final PostMapper postMapper;
    private final UserMapper userMapper;
    private final NotificationService notificationService;

    public LikeServiceImpl(LikeMapper likeMapper, PostMapper postMapper,
                           UserMapper userMapper, NotificationService notificationService) {
        this.likeMapper = likeMapper;
        this.postMapper = postMapper;
        this.userMapper = userMapper;
        this.notificationService = notificationService;
    }

    @Override
    @Transactional
    public boolean toggle(Long userId, Long postId) {
        LambdaQueryWrapper<Like> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Like::getUserId, userId).eq(Like::getPostId, postId);
        Like existingLike = likeMapper.selectOne(wrapper);

        Post post = postMapper.selectById(postId);
        if (post == null) {
            throw new RuntimeException("帖子不存在");
        }

        if (existingLike != null) {
            likeMapper.deleteById(existingLike.getId());
            post.setLikeCount(Math.max(0, post.getLikeCount() - 1));
            postMapper.updateById(post);
            return false;
        } else {
            Like like = new Like();
            like.setUserId(userId);
            like.setPostId(postId);
            try {
                likeMapper.insert(like);
                post.setLikeCount(post.getLikeCount() + 1);
                postMapper.updateById(post);

                if (!post.getUserId().equals(userId)) {
                    User liker = userMapper.selectById(userId);
                    notificationService.createNotification(post.getUserId(),
                            (liker != null ? liker.getNickname() : "有人") + "赞了你的帖子",
                            "LIKE", postId);
                }
                return true;
            } catch (DuplicateKeyException e) {
                // 已点赞
                return true;
            }
        }
    }

    @Override
    public boolean isLiked(Long userId, Long postId) {
        LambdaQueryWrapper<Like> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Like::getUserId, userId).eq(Like::getPostId, postId);
        return likeMapper.selectOne(wrapper) != null;
    }
}
