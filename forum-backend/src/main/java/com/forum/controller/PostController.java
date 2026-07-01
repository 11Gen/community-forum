package com.forum.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.forum.common.Result;
import com.forum.dto.PostDTO;
import com.forum.entity.Post;
import com.forum.service.PostService;
import com.forum.service.ViewHistoryService;
import jakarta.validation.Valid;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/post")
public class PostController {

    private final PostService postService;
    private final ViewHistoryService viewHistoryService;

    public PostController(PostService postService, ViewHistoryService viewHistoryService) {
        this.postService = postService;
        this.viewHistoryService = viewHistoryService;
    }

    private Long getCurrentUserId() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth != null && auth.getPrincipal() instanceof Number) {
            return ((Number) auth.getPrincipal()).longValue();
        }
        return null;
    }

    @GetMapping("/list")
    public Result<?> list(@RequestParam(defaultValue = "1") int page,
                          @RequestParam(defaultValue = "10") int size,
                          @RequestParam(required = false) Long categoryId,
                          @RequestParam(defaultValue = "latest") String sort) {
        Long cu = getCurrentUserId();
        Page<Post> result = postService.getList(page, size, categoryId, sort, cu);
        return Result.ok(result);
    }

    @GetMapping("/essence")
    public Result<?> essence(@RequestParam(defaultValue = "1") int page,
                             @RequestParam(defaultValue = "10") int size) {
        Page<Post> result = postService.getEssence(page, size);
        return Result.ok(result);
    }

    @GetMapping("/recommended")
    public Result<?> recommended(@RequestParam(defaultValue = "1") int page,
                                 @RequestParam(defaultValue = "10") int size,
                                 @RequestParam(required = false) Long categoryId) {
        Long cu = getCurrentUserId();
        Page<Post> result = postService.getRecommended(page, size, cu, categoryId);
        return Result.ok(result);
    }

    @GetMapping("/{id}")
    public Result<?> detail(@PathVariable Long id) {
        try {
            Long cu = getCurrentUserId();
            Post post = postService.getById(id, cu);
            if (cu != null) {
                viewHistoryService.record(cu, id);
            }
            return Result.ok(post);
        } catch (RuntimeException e) {
            return Result.fail(e.getMessage());
        }
    }

    @PostMapping("/create")
    public Result<?> create(@Valid @RequestBody PostDTO dto, Authentication authentication) {
        Long userId = (Long) authentication.getPrincipal();
        Post post = postService.create(userId, dto);
        return Result.ok(post);
    }

    @PutMapping("/{id}")
    public Result<?> update(@PathVariable Long id, @Valid @RequestBody PostDTO dto,
                            Authentication authentication) {
        try {
            Long userId = (Long) authentication.getPrincipal();
            Post post = postService.update(userId, id, dto);
            return Result.ok(post);
        } catch (RuntimeException e) {
            return Result.fail(e.getMessage());
        }
    }

    @DeleteMapping("/{id}")
    public Result<?> delete(@PathVariable Long id, Authentication authentication) {
        try {
            Long userId = (Long) authentication.getPrincipal();
            postService.delete(userId, id);
            return Result.ok("删除成功");
        } catch (RuntimeException e) {
            return Result.fail(e.getMessage());
        }
    }

    @GetMapping("/search")
    public Result<?> search(@RequestParam String keyword,
                            @RequestParam(defaultValue = "1") int page,
                            @RequestParam(defaultValue = "10") int size) {
        Page<Post> result = postService.search(keyword, page, size);
        return Result.ok(result);
    }
}
