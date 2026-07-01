package com.forum.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.forum.entity.SecurityQuestion;
import com.forum.entity.User;
import com.forum.mapper.SecurityQuestionMapper;
import com.forum.mapper.UserMapper;
import com.forum.service.SecurityQuestionService;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;
import java.util.concurrent.ConcurrentHashMap;

@Service
public class SecurityQuestionServiceImpl implements SecurityQuestionService {

    private final SecurityQuestionMapper questionMapper;
    private final UserMapper userMapper;
    private final PasswordEncoder passwordEncoder;
    private final Map<String, String> resetTokenStore = new ConcurrentHashMap<>();

    public SecurityQuestionServiceImpl(SecurityQuestionMapper questionMapper,
                                       UserMapper userMapper,
                                       PasswordEncoder passwordEncoder) {
        this.questionMapper = questionMapper;
        this.userMapper = userMapper;
        this.passwordEncoder = passwordEncoder;
    }

    @Override
    @Transactional
    public void saveQuestions(Long userId, List<Map<String, String>> questions) {
        if (questions.size() != 3) {
            throw new RuntimeException("必须设置3个密保问题");
        }
        // Delete old questions
        LambdaQueryWrapper<SecurityQuestion> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(SecurityQuestion::getUserId, userId);
        questionMapper.delete(wrapper);
        // Insert new ones
        for (Map<String, String> q : questions) {
            SecurityQuestion sq = new SecurityQuestion();
            sq.setUserId(userId);
            sq.setQuestion(q.get("question"));
            sq.setAnswer(q.get("answer"));
            questionMapper.insert(sq);
        }
    }

    @Override
    public List<Map<String, Object>> getQuestions(Long userId) {
        LambdaQueryWrapper<SecurityQuestion> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(SecurityQuestion::getUserId, userId).orderByAsc(SecurityQuestion::getId);
        List<SecurityQuestion> list = questionMapper.selectList(wrapper);
        List<Map<String, Object>> result = new ArrayList<>();
        for (SecurityQuestion sq : list) {
            Map<String, Object> item = new HashMap<>();
            item.put("id", sq.getId());
            item.put("question", sq.getQuestion());
            result.add(item);
        }
        return result;
    }

    @Override
    public boolean verifyAnswers(Long userId, List<Map<String, String>> answers) {
        LambdaQueryWrapper<SecurityQuestion> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(SecurityQuestion::getUserId, userId).orderByAsc(SecurityQuestion::getId);
        List<SecurityQuestion> stored = questionMapper.selectList(wrapper);
        if (stored.size() != 3 || answers.size() != 3) return false;

        for (int i = 0; i < 3; i++) {
            if (!stored.get(i).getAnswer().equals(answers.get(i).get("answer"))) {
                return false;
            }
        }
        return true;
    }

    @Override
    public String generateResetToken(Long userId) {
        String token = UUID.randomUUID().toString();
        resetTokenStore.put(userId + ":" + token, token);
        // Token valid for 10 minutes
        new Thread(() -> {
            try { Thread.sleep(600000); } catch (InterruptedException e) { }
            resetTokenStore.remove(userId + ":" + token);
        }).start();
        return token;
    }

    @Override
    public boolean validateResetToken(Long userId, String token) {
        return token != null && token.equals(resetTokenStore.get(userId + ":" + token));
    }

    @Override
    public void resetPassword(Long userId, String token, String newPassword) {
        if (!validateResetToken(userId, token)) {
            throw new RuntimeException("重置令牌无效或已过期");
        }
        User user = userMapper.selectById(userId);
        if (user == null) {
            throw new RuntimeException("用户不存在");
        }
        user.setPassword(passwordEncoder.encode(newPassword));
        userMapper.updateById(user);
        resetTokenStore.remove(userId + ":" + token);
    }
}
