package com.forum.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.forum.entity.Follow;
import com.forum.entity.User;
import com.forum.mapper.FollowMapper;
import com.forum.mapper.UserMapper;
import com.forum.service.FollowService;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;

@Service
public class FollowServiceImpl implements FollowService {

    private final FollowMapper followMapper;
    private final UserMapper userMapper;

    public FollowServiceImpl(FollowMapper followMapper, UserMapper userMapper) {
        this.followMapper = followMapper;
        this.userMapper = userMapper;
    }

    @Override
    @Transactional
    public void follow(Long userId, Long followUserId) {
        if (userId.equals(followUserId)) {
            throw new RuntimeException("不能关注自己");
        }
        LambdaQueryWrapper<Follow> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Follow::getUserId, userId).eq(Follow::getFollowUserId, followUserId);
        Follow existing = followMapper.selectOne(wrapper);
        if (existing != null) {
            throw new RuntimeException("已关注该用户");
        }
        Follow follow = new Follow();
        follow.setUserId(userId);
        follow.setFollowUserId(followUserId);
        try {
            followMapper.insert(follow);
        } catch (DuplicateKeyException e) {
            throw new RuntimeException("已关注该用户");
        }
    }

    @Override
    @Transactional
    public void unfollow(Long userId, Long followUserId) {
        LambdaQueryWrapper<Follow> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Follow::getUserId, userId).eq(Follow::getFollowUserId, followUserId);
        Follow follow = followMapper.selectOne(wrapper);
        if (follow == null) {
            throw new RuntimeException("未关注该用户");
        }
        followMapper.deleteById(follow.getId());
    }

    @Override
    public Map<String, Boolean> isFollowing(Long userId, Long targetUserId) {
        LambdaQueryWrapper<Follow> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Follow::getUserId, userId).eq(Follow::getFollowUserId, targetUserId);
        boolean following = followMapper.selectOne(wrapper) != null;
        boolean mutual = following && isMutualFollow(userId, targetUserId);
        Map<String, Boolean> result = new HashMap<>();
        result.put("following", following);
        result.put("mutual", mutual);
        return result;
    }

    @Override
    public boolean isMutualFollow(Long userId, Long targetUserId) {
        LambdaQueryWrapper<Follow> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Follow::getUserId, userId).eq(Follow::getFollowUserId, targetUserId);
        boolean aFollowsB = followMapper.selectOne(wrapper) != null;
        wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Follow::getUserId, targetUserId).eq(Follow::getFollowUserId, userId);
        boolean bFollowsA = followMapper.selectOne(wrapper) != null;
        return aFollowsB && bFollowsA;
    }

    @Override
    public long getFollowerCount(Long userId) {
        LambdaQueryWrapper<Follow> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Follow::getFollowUserId, userId);
        return followMapper.selectCount(wrapper);
    }

    @Override
    public long getFollowingCount(Long userId) {
        LambdaQueryWrapper<Follow> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Follow::getUserId, userId);
        return followMapper.selectCount(wrapper);
    }

    @Override
    public List<Map<String, Object>> getFollowers(Long userId) {
        LambdaQueryWrapper<Follow> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Follow::getFollowUserId, userId).orderByDesc(Follow::getCreateTime);
        List<Follow> followers = followMapper.selectList(wrapper);
        List<Map<String, Object>> result = new ArrayList<>();
        for (Follow follow : followers) {
            User user = userMapper.selectById(follow.getUserId());
            Map<String, Object> item = new HashMap<>();
            item.put("id", follow.getId());
            item.put("userId", follow.getUserId());
            item.put("followUserId", follow.getFollowUserId());
            item.put("createTime", follow.getCreateTime());
            item.put("nickname", user != null ? user.getNickname() : null);
            item.put("avatar", user != null ? user.getAvatar() : null);
            result.add(item);
        }
        return result;
    }

    @Override
    public List<Map<String, Object>> getFollowing(Long userId) {
        LambdaQueryWrapper<Follow> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Follow::getUserId, userId).orderByDesc(Follow::getCreateTime);
        List<Follow> following = followMapper.selectList(wrapper);
        List<Map<String, Object>> result = new ArrayList<>();
        for (Follow follow : following) {
            User user = userMapper.selectById(follow.getFollowUserId());
            Map<String, Object> item = new HashMap<>();
            item.put("id", follow.getId());
            item.put("userId", follow.getUserId());
            item.put("followUserId", follow.getFollowUserId());
            item.put("createTime", follow.getCreateTime());
            item.put("nickname", user != null ? user.getNickname() : null);
            item.put("avatar", user != null ? user.getAvatar() : null);
            result.add(item);
        }
        return result;
    }
}
