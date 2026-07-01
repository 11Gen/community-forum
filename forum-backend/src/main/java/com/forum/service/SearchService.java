package com.forum.service;

import com.forum.entity.SearchHistory;

import java.util.List;
import java.util.Map;

public interface SearchService {
    void recordSearch(Long userId, String keyword);

    List<SearchHistory> getHistory(Long userId);

    void clearHistory(Long userId);

    List<Map<String, Object>> getHotKeywords(int limit);
}
