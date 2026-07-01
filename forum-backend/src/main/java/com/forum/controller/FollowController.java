package com.forum.controller;

import com.forum.common.Result;
import com.forum.service.FollowService;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/follow")
public class FollowController {

    private final FollowService followService;

    public FollowController(FollowService followService) {
        this.followService = followService;
    }

    @PostMapping("/{userId}")
    public Result<?> follow(@PathVariable Long userId, Authentication authentication) {
        Long currentUserId = (Long) authentication.getPrincipal();
        followService.follow(currentUserId, userId);
        return Result.ok();
    }

    @DeleteMapping("/{userId}")
    public Result<?> unfollow(@PathVariable Long userId, Authentication authentication) {
        Long currentUserId = (Long) authentication.getPrincipal();
        followService.unfollow(currentUserId, userId);
        return Result.ok();
    }

    @GetMapping("/check/{userId}")
    public Result<?> checkFollowing(@PathVariable Long userId, Authentication authentication) {
        Long currentUserId = (Long) authentication.getPrincipal();
        Map<String, Boolean> status = followService.isFollowing(currentUserId, userId);
        return Result.ok(status);
    }

    @GetMapping("/followers/{userId}")
    public Result<?> followers(@PathVariable Long userId) {
        List<Map<String, Object>> followers = followService.getFollowers(userId);
        return Result.ok(followers);
    }

    @GetMapping("/following/{userId}")
    public Result<?> following(@PathVariable Long userId) {
        List<Map<String, Object>> following = followService.getFollowing(userId);
        return Result.ok(following);
    }

    @GetMapping("/stats/{userId}")
    public Result<?> stats(@PathVariable Long userId) {
        long followerCount = followService.getFollowerCount(userId);
        long followingCount = followService.getFollowingCount(userId);
        return Result.ok(Map.of("followerCount", followerCount, "followingCount", followingCount));
    }
}
