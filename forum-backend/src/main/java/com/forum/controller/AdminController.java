package com.forum.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.forum.common.Result;
import com.forum.entity.Comment;
import com.forum.entity.Post;
import com.forum.entity.User;
import com.forum.mapper.CommentMapper;
import com.forum.mapper.PostMapper;
import com.forum.mapper.UserMapper;
import com.forum.service.CategoryService;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/admin")
@PreAuthorize("hasRole('ADMIN')")
public class AdminController {

    private final UserMapper userMapper;
    private final PostMapper postMapper;
    private final CommentMapper commentMapper;
    private final CategoryService categoryService;

    private final PasswordEncoder passwordEncoder;

    public AdminController(UserMapper userMapper, PostMapper postMapper,
                           CommentMapper commentMapper, CategoryService categoryService,
                           PasswordEncoder passwordEncoder) {
        this.userMapper = userMapper;
        this.postMapper = postMapper;
        this.commentMapper = commentMapper;
        this.categoryService = categoryService;
        this.passwordEncoder = passwordEncoder;
    }

    // ===== 用户管理 =====
    @GetMapping("/users")
    public Result<?> users(@RequestParam(defaultValue = "1") int page,
                           @RequestParam(defaultValue = "10") int size) {
        Page<User> pageResult = new Page<>(page, size);
        LambdaQueryWrapper<User> wrapper = new LambdaQueryWrapper<>();
        wrapper.orderByDesc(User::getCreateTime);
        Page<User> result = userMapper.selectPage(pageResult, wrapper);
        result.getRecords().forEach(u -> u.setPassword(null));
        return Result.ok(result);
    }

    @PutMapping("/user/{id}/status")
    public Result<?> toggleUserStatus(@PathVariable Long id, @RequestBody Map<String, Integer> body) {
        User user = userMapper.selectById(id);
        if (user != null) {
            user.setStatus(body.get("status"));
            userMapper.updateById(user);
            return Result.ok("更新成功");
        }
        return Result.fail("用户不存在");
    }

    @PutMapping("/user/{id}/reset-password")
    public Result<?> resetUserPassword(@PathVariable Long id) {
        User user = userMapper.selectById(id);
        if (user == null) return Result.fail("用户不存在");
        user.setPassword(passwordEncoder.encode("88888888"));
        userMapper.updateById(user);
        return Result.ok("密码已重置为 88888888");
    }

    // ===== 帖子管理 =====
    @GetMapping("/posts")
    public Result<?> posts(@RequestParam(defaultValue = "1") int page,
                           @RequestParam(defaultValue = "10") int size) {
        Page<Post> pageResult = new Page<>(page, size);
        LambdaQueryWrapper<Post> wrapper = new LambdaQueryWrapper<>();
        wrapper.orderByDesc(Post::getCreateTime);
        return Result.ok(postMapper.selectPage(pageResult, wrapper));
    }

    @DeleteMapping("/post/{id}")
    public Result<?> deletePost(@PathVariable Long id) {
        Post post = postMapper.selectById(id);
        if (post != null) {
            post.setStatus(1);
            postMapper.updateById(post);
        }
        return Result.ok("删除成功");
    }

    @PutMapping("/post/{id}/pin")
    public Result<?> togglePin(@PathVariable Long id) {
        Post post = postMapper.selectById(id);
        if (post != null) {
            post.setIsPinned(post.getIsPinned() == 1 ? 0 : 1);
            postMapper.updateById(post);
        }
        return Result.ok();
    }

    @PutMapping("/post/{id}/essence")
    public Result<?> toggleEssence(@PathVariable Long id) {
        Post post = postMapper.selectById(id);
        if (post != null) {
            post.setIsEssence(post.getIsEssence() == 1 ? 0 : 1);
            postMapper.updateById(post);
        }
        return Result.ok();
    }

    // ===== 评论管理 =====
    @GetMapping("/comments")
    public Result<?> comments(@RequestParam(defaultValue = "1") int page,
                              @RequestParam(defaultValue = "10") int size) {
        Page<Comment> pageResult = new Page<>(page, size);
        LambdaQueryWrapper<Comment> wrapper = new LambdaQueryWrapper<>();
        wrapper.orderByDesc(Comment::getCreateTime);
        return Result.ok(commentMapper.selectPage(pageResult, wrapper));
    }

    @DeleteMapping("/comment/{id}")
    public Result<?> deleteComment(@PathVariable Long id) {
        Comment comment = commentMapper.selectById(id);
        if (comment != null) {
            comment.setStatus(1);
            commentMapper.updateById(comment);
        }
        return Result.ok("删除成功");
    }

    // ===== 分类管理 =====
    @PostMapping("/category")
    public Result<?> createCategory(@RequestBody Map<String, String> body) {
        categoryService.create(body.get("name"), body.get("description"));
        return Result.ok("创建成功");
    }

    @PutMapping("/category/{id}")
    public Result<?> updateCategory(@PathVariable Long id, @RequestBody Map<String, Object> body) {
        categoryService.update(id,
                (String) body.get("name"),
                (String) body.get("description"),
                body.get("sortOrder") != null ? ((Number) body.get("sortOrder")).intValue() : null);
        return Result.ok("更新成功");
    }

    @DeleteMapping("/category/{id}")
    public Result<?> deleteCategory(@PathVariable Long id) {
        categoryService.delete(id);
        return Result.ok("删除成功");
    }
}
