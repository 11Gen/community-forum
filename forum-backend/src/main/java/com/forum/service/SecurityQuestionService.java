package com.forum.service;

import java.util.List;
import java.util.Map;

public interface SecurityQuestionService {
    void saveQuestions(Long userId, List<Map<String, String>> questions);
    List<Map<String, Object>> getQuestions(Long userId);
    boolean verifyAnswers(Long userId, List<Map<String, String>> answers);
    String generateResetToken(Long userId);
    boolean validateResetToken(Long userId, String token);
    void resetPassword(Long userId, String token, String newPassword);
}
