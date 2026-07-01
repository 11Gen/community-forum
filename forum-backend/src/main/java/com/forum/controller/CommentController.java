package com.forum.controller;

import com.forum.common.Result;
import com.forum.dto.CommentDTO;
import com.forum.entity.Comment;
import com.forum.service.CommentService;
import jakarta.validation.Valid;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/comment")
public class CommentController {

    private final CommentService commentService;

    public CommentController(CommentService commentService) {
        this.commentService = commentService;
    }

    private Long getCurrentUserId() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth != null && auth.getPrincipal() instanceof Number) {
            return ((Number) auth.getPrincipal()).longValue();
        }
        return null;
    }

    @GetMapping("/post/{postId}")
    public Result<?> getByPost(@PathVariable Long postId) {
        List<Comment> comments = commentService.getByPostId(postId, getCurrentUserId());
        return Result.ok(comments);
    }

    @PostMapping("/create")
    public Result<?> create(@Valid @RequestBody CommentDTO dto, Authentication authentication) {
        Long userId = (Long) authentication.getPrincipal();
        try {
            Comment comment = commentService.create(userId, dto);
            return Result.ok(comment);
        } catch (RuntimeException e) {
            return Result.fail(e.getMessage());
        }
    }

    @DeleteMapping("/{id}")
    public Result<?> delete(@PathVariable Long id, Authentication authentication) {
        try {
            commentService.delete((Long) authentication.getPrincipal(), id);
            return Result.ok("删除成功");
        } catch (RuntimeException e) {
            return Result.fail(e.getMessage());
        }
    }

    @PostMapping("/like/{commentId}")
    public Result<?> toggleLike(@PathVariable Long commentId, Authentication authentication) {
        boolean liked = commentService.toggleLike((Long) authentication.getPrincipal(), commentId);
        return Result.ok(Map.of("liked", liked));
    }

    @PutMapping("/{commentId}/pin")
    public Result<?> togglePin(@PathVariable Long commentId, @RequestBody Map<String, Long> body,
                               Authentication authentication) {
        try {
            commentService.togglePin((Long) authentication.getPrincipal(), commentId, body.get("postId"));
            return Result.ok("操作成功");
        } catch (RuntimeException e) {
            return Result.fail(e.getMessage());
        }
    }
}
