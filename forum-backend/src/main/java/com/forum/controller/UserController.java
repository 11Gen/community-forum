package com.forum.controller;

import com.forum.common.Result;
import com.forum.dto.LoginDTO;
import com.forum.dto.RegisterDTO;
import com.forum.entity.User;
import com.forum.service.SecurityQuestionService;
import com.forum.service.UserService;
import com.forum.service.ViewHistoryService;
import com.forum.entity.ViewHistory;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import jakarta.validation.Valid;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.util.List;
import java.util.Map;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/user")
public class UserController {

    private final UserService userService;
    private final SecurityQuestionService questionService;
    private final ViewHistoryService viewHistoryService;

    public UserController(UserService userService, SecurityQuestionService questionService,
                          ViewHistoryService viewHistoryService) {
        this.userService = userService;
        this.questionService = questionService;
        this.viewHistoryService = viewHistoryService;
    }

    @PostMapping("/register")
    public Result<?> register(@Valid @RequestBody RegisterDTO dto) {
        try {
            userService.register(dto);
            return Result.ok("注册成功");
        } catch (RuntimeException e) {
            return Result.fail(e.getMessage());
        }
    }

    @PostMapping("/login")
    public Result<?> login(@Valid @RequestBody LoginDTO dto) {
        try {
            String token = userService.login(dto);
            Map<String, String> data = new HashMap<>();
            data.put("token", token);
            return Result.ok(data);
        } catch (RuntimeException e) {
            return Result.fail(e.getMessage());
        }
    }

    @GetMapping("/profile")
    public Result<?> profile(Authentication authentication) {
        Long userId = (Long) authentication.getPrincipal();
        Map<String, Object> profile = userService.getPublicProfile(userId, userId);
        return Result.ok(profile);
    }

    @GetMapping("/{id}")
    public Result<?> getUser(@PathVariable Long id, Authentication authentication) {
        Long currentUserId = authentication != null ? (Long) authentication.getPrincipal() : null;
        Map<String, Object> profile = userService.getPublicProfile(id, currentUserId);
        if (profile == null) {
            return Result.fail("用户不存在");
        }
        return Result.ok(profile);
    }

    @PutMapping("/profile")
    public Result<?> updateProfile(@RequestBody Map<String, Object> body, Authentication authentication) {
        Long userId = (Long) authentication.getPrincipal();
        try {
            userService.updateProfile(userId,
                    (String) body.get("nickname"),
                    (String) body.get("signature"),
                    body.get("gender") != null ? ((Number) body.get("gender")).intValue() : null,
                    (String) body.get("phone"));
            return Result.ok("更新成功");
        } catch (RuntimeException e) {
            return Result.fail(e.getMessage());
        }
    }

    @PostMapping("/avatar")
    public Result<?> uploadAvatar(@RequestParam("file") MultipartFile file, Authentication authentication) {
        if (file.isEmpty()) {
            return Result.fail("文件不能为空");
        }
        try {
            String originalFilename = file.getOriginalFilename();
            String ext = originalFilename != null ? originalFilename.substring(originalFilename.lastIndexOf(".")) : ".png";
            String filename = UUID.randomUUID() + ext;

            String basePath = System.getProperty("user.dir");
            File uploadDir = new File(basePath, "uploads/avatars/");
            if (!uploadDir.exists()) {
                uploadDir.mkdirs();
            }
            File dest = new File(uploadDir, filename);
            file.transferTo(dest);

            Long userId = (Long) authentication.getPrincipal();
            String avatarUrl = "/uploads/avatars/" + filename;
            userService.updateAvatar(userId, avatarUrl);
            return Result.ok(Map.of("url", avatarUrl));
        } catch (IOException e) {
            return Result.fail("上传失败: " + e.getMessage());
        }
    }

    @GetMapping("/history")
    public Result<?> history(@RequestParam(defaultValue = "1") int page,
                             @RequestParam(defaultValue = "10") int size,
                             Authentication authentication) {
        Page<ViewHistory> result = viewHistoryService.getHistory(
                (Long) authentication.getPrincipal(), page, size);
        return Result.ok(result);
    }

    // ===== 密保问题 =====
    @PostMapping("/security-questions")
    public Result<?> saveQuestions(@RequestBody Map<String, Object> body, Authentication authentication) {
        Long userId = (Long) authentication.getPrincipal();
        @SuppressWarnings("unchecked")
        List<Map<String, String>> questions = (List<Map<String, String>>) body.get("questions");
        try {
            questionService.saveQuestions(userId, questions);
            return Result.ok("保存成功");
        } catch (RuntimeException e) {
            return Result.fail(e.getMessage());
        }
    }

    @GetMapping("/security-questions/{userId}")
    public Result<?> getQuestions(@PathVariable Long userId) {
        List<Map<String, Object>> questions = questionService.getQuestions(userId);
        return Result.ok(questions);
    }

    // ===== 忘记密码 =====
    @PostMapping("/forgot-password/questions")
    public Result<?> getForgotQuestions(@RequestBody Map<String, String> body) {
        String username = body.get("username");
        User user = userService.getUserByUsername(username);
        if (user == null) {
            return Result.fail("用户不存在");
        }
        List<Map<String, Object>> questions = questionService.getQuestions(user.getId());
        return Result.ok(Map.of("userId", user.getId(), "questions", questions));
    }

    @PostMapping("/forgot-password/verify")
    public Result<?> verifyForPassword(@RequestBody Map<String, Object> body) {
        String username = (String) body.get("username");
        User user = userService.getUserByUsername(username);
        if (user == null) {
            return Result.fail("用户不存在");
        }
        @SuppressWarnings("unchecked")
        List<Map<String, String>> answers = (List<Map<String, String>>) body.get("answers");
        if (!questionService.verifyAnswers(user.getId(), answers)) {
            return Result.fail("密保答案错误");
        }
        String token = questionService.generateResetToken(user.getId());
        return Result.ok(Map.of("userId", user.getId(), "token", token));
    }

    @PostMapping("/forgot-password/reset")
    public Result<?> resetPassword(@RequestBody Map<String, Object> body) {
        Long userId = ((Number) body.get("userId")).longValue();
        String token = (String) body.get("token");
        String newPassword = (String) body.get("password");
        try {
            questionService.resetPassword(userId, token, newPassword);
            return Result.ok("密码重置成功，请登录");
        } catch (RuntimeException e) {
            return Result.fail(e.getMessage());
        }
    }
}
