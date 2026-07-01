package com.forum.service;

import java.util.List;
import java.util.Map;

public interface FollowService {
    void follow(Long userId, Long followUserId);

    void unfollow(Long userId, Long followUserId);

    Map<String, Boolean> isFollowing(Long userId, Long targetUserId);

    boolean isMutualFollow(Long userId, Long targetUserId);

    long getFollowerCount(Long userId);

    long getFollowingCount(Long userId);

    List<Map<String, Object>> getFollowers(Long userId);

    List<Map<String, Object>> getFollowing(Long userId);
}
