package com.forum.service;

import com.forum.dto.LoginDTO;
import com.forum.dto.RegisterDTO;
import com.forum.entity.User;
import java.util.Map;

public interface UserService {
    User register(RegisterDTO dto);
    String login(LoginDTO dto);
    User getUserById(Long id);
    User getUserByUsername(String username);
    Map<String, Object> getPublicProfile(Long userId, Long currentUserId);
    User getFullProfile(Long userId);
    void updateProfile(Long userId, String nickname, String signature, Integer gender, String phone);
    String updateAvatar(Long userId, String avatarUrl);
}
