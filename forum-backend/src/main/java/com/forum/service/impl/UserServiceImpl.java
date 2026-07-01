package com.forum.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.forum.dto.LoginDTO;
import com.forum.dto.RegisterDTO;
import com.forum.entity.User;
import com.forum.mapper.UserMapper;
import com.forum.security.JwtTokenProvider;
import com.forum.service.UserService;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.Map;

@Service
public class UserServiceImpl implements UserService {

    private final UserMapper userMapper;
    private final PasswordEncoder passwordEncoder;
    private final JwtTokenProvider jwtTokenProvider;

    public UserServiceImpl(UserMapper userMapper, PasswordEncoder passwordEncoder,
                           JwtTokenProvider jwtTokenProvider) {
        this.userMapper = userMapper;
        this.passwordEncoder = passwordEncoder;
        this.jwtTokenProvider = jwtTokenProvider;
    }

    @Override
    public User register(RegisterDTO dto) {
        LambdaQueryWrapper<User> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(User::getUsername, dto.getUsername());
        if (userMapper.selectOne(wrapper) != null) {
            throw new RuntimeException("账号已存在");
        }
        wrapper.clear();
        wrapper.eq(User::getNickname, dto.getNickname());
        if (userMapper.selectOne(wrapper) != null) {
            throw new RuntimeException("昵称已被使用");
        }
        wrapper.clear();
        wrapper.eq(User::getEmail, dto.getEmail());
        if (userMapper.selectOne(wrapper) != null) {
            throw new RuntimeException("邮箱已被注册");
        }

        User user = new User();
        user.setUsername(dto.getUsername());
        user.setNickname(dto.getNickname());
        user.setPassword(passwordEncoder.encode(dto.getPassword()));
        user.setEmail(dto.getEmail());
        user.setRole("USER");
        user.setStatus(0);
        user.setGender(2);
        userMapper.insert(user);
        return user;
    }

    @Override
    public String login(LoginDTO dto) {
        LambdaQueryWrapper<User> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(User::getUsername, dto.getUsername());
        User user = userMapper.selectOne(wrapper);
        if (user == null) {
            throw new RuntimeException("账号或密码错误");
        }
        if (user.getStatus() == 2 || user.getStatus() == 3) {
            throw new RuntimeException("账号已被禁止登录");
        }
        if (!passwordEncoder.matches(dto.getPassword(), user.getPassword())) {
            throw new RuntimeException("账号或密码错误");
        }
        return jwtTokenProvider.generateToken(user.getId(), user.getNickname(), user.getRole());
    }

    @Override
    public User getUserById(Long id) {
        return userMapper.selectById(id);
    }

    @Override
    public User getUserByUsername(String username) {
        LambdaQueryWrapper<User> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(User::getUsername, username);
        return userMapper.selectOne(wrapper);
    }

    @Override
    public Map<String, Object> getPublicProfile(Long userId, Long currentUserId) {
        User user = userMapper.selectById(userId);
        if (user == null) return null;
        Map<String, Object> profile = new HashMap<>();
        profile.put("id", user.getId());
        profile.put("nickname", user.getNickname());
        profile.put("avatar", user.getAvatar());
        profile.put("signature", user.getSignature());
        if (user.getGender() != null && user.getGender() != 2) {
            profile.put("gender", user.getGender());
        }
        // Only show private info to the user themselves or admin
        if (currentUserId != null && (currentUserId.equals(userId) || "ADMIN".equals(user.getRole()))) {
            profile.put("username", user.getUsername());
            profile.put("email", user.getEmail());
            profile.put("phone", user.getPhone());
        }
        return profile;
    }

    @Override
    public User getFullProfile(Long userId) {
        return userMapper.selectById(userId);
    }

    @Override
    public void updateProfile(Long userId, String nickname, String signature, Integer gender, String phone) {
        User user = userMapper.selectById(userId);
        if (user == null) return;
        if (nickname != null && !nickname.isEmpty()) {
            LambdaQueryWrapper<User> wrapper = new LambdaQueryWrapper<>();
            wrapper.eq(User::getNickname, nickname).ne(User::getId, userId);
            if (userMapper.selectOne(wrapper) != null) {
                throw new RuntimeException("昵称已被使用");
            }
            user.setNickname(nickname);
        }
        if (signature != null) user.setSignature(signature);
        if (gender != null) user.setGender(gender);
        if (phone != null) user.setPhone(phone);
        userMapper.updateById(user);
    }

    @Override
    public String updateAvatar(Long userId, String avatarUrl) {
        User user = userMapper.selectById(userId);
        if (user != null) {
            user.setAvatar(avatarUrl);
            userMapper.updateById(user);
        }
        return avatarUrl;
    }
}
