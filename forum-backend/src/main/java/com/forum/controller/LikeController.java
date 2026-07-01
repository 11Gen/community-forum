package com.forum.controller;

import com.forum.common.Result;
import com.forum.service.LikeService;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/like")
public class LikeController {

    private final LikeService likeService;

    public LikeController(LikeService likeService) {
        this.likeService = likeService;
    }

    @PostMapping("/toggle/{postId}")
    public Result<?> toggle(@PathVariable Long postId, Authentication authentication) {
        Long userId = (Long) authentication.getPrincipal();
        boolean liked = likeService.toggle(userId, postId);
        return Result.ok(Map.of("liked", liked));
    }
}
