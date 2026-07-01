package com.forum.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.forum.entity.SearchHistory;
import com.forum.entity.SearchLog;
import com.forum.mapper.SearchHistoryMapper;
import com.forum.mapper.SearchLogMapper;
import com.forum.service.SearchService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;

@Service
public class SearchServiceImpl implements SearchService {

    private final SearchHistoryMapper searchHistoryMapper;
    private final SearchLogMapper searchLogMapper;

    public SearchServiceImpl(SearchHistoryMapper searchHistoryMapper, SearchLogMapper searchLogMapper) {
        this.searchHistoryMapper = searchHistoryMapper;
        this.searchLogMapper = searchLogMapper;
    }

    @Override
    @Transactional
    public void recordSearch(Long userId, String keyword) {
        // Save to user's search history
        SearchHistory history = new SearchHistory();
        history.setUserId(userId);
        history.setKeyword(keyword);
        searchHistoryMapper.insert(history);

        // Save to global search log for hot keywords
        SearchLog log = new SearchLog();
        log.setKeyword(keyword);
        searchLogMapper.insert(log);
    }

    @Override
    public List<SearchHistory> getHistory(Long userId) {
        LambdaQueryWrapper<SearchHistory> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(SearchHistory::getUserId, userId)
               .orderByDesc(SearchHistory::getCreateTime)
               .last("LIMIT 10");
        return searchHistoryMapper.selectList(wrapper);
    }

    @Override
    @Transactional
    public void clearHistory(Long userId) {
        LambdaQueryWrapper<SearchHistory> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(SearchHistory::getUserId, userId);
        searchHistoryMapper.delete(wrapper);
    }

    @Override
    public List<Map<String, Object>> getHotKeywords(int limit) {
        QueryWrapper<SearchLog> wrapper = new QueryWrapper<>();
        wrapper.select("keyword", "COUNT(*) AS count")
               .groupBy("keyword")
               .orderByDesc("count")
               .last("LIMIT " + limit);
        List<Map<String, Object>> list = searchLogMapper.selectMaps(wrapper);
        return list;
    }
}
