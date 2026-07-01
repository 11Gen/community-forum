package com.forum.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.forum.common.Result;
import com.forum.entity.Post;
import com.forum.service.FavoriteService;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/favorite")
public class FavoriteController {

    private final FavoriteService favoriteService;

    public FavoriteController(FavoriteService favoriteService) {
        this.favoriteService = favoriteService;
    }

    @PostMapping("/toggle/{postId}")
    public Result<?> toggle(@PathVariable Long postId, Authentication authentication) {
        boolean favorited = favoriteService.toggle((Long) authentication.getPrincipal(), postId);
        return Result.ok(Map.of("favorited", favorited));
    }

    @GetMapping("/check/{postId}")
    public Result<?> check(@PathVariable Long postId, Authentication authentication) {
        boolean favorited = favoriteService.isFavorited((Long) authentication.getPrincipal(), postId);
        return Result.ok(Map.of("favorited", favorited));
    }

    @GetMapping("/list")
    public Result<?> list(@RequestParam(defaultValue = "1") int page,
                          @RequestParam(defaultValue = "10") int size,
                          Authentication authentication) {
        Page<Post> result = favoriteService.getFavorites((Long) authentication.getPrincipal(), page, size);
        return Result.ok(result);
    }
}
