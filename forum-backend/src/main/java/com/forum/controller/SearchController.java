package com.forum.controller;

import com.forum.common.Result;
import com.forum.entity.SearchHistory;
import com.forum.service.SearchService;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/search")
public class SearchController {

    private final SearchService searchService;

    public SearchController(SearchService searchService) {
        this.searchService = searchService;
    }

    @GetMapping("/hot")
    public Result<?> hotKeywords(@RequestParam(defaultValue = "10") int limit) {
        List<Map<String, Object>> hotKeywords = searchService.getHotKeywords(limit);
        return Result.ok(hotKeywords);
    }

    @PostMapping("/history")
    public Result<?> record(@RequestBody Map<String, String> body, Authentication authentication) {
        Long userId = (Long) authentication.getPrincipal();
        searchService.recordSearch(userId, body.get("keyword"));
        return Result.ok();
    }

    @GetMapping("/history")
    public Result<?> history(Authentication authentication) {
        Long userId = (Long) authentication.getPrincipal();
        List<SearchHistory> history = searchService.getHistory(userId);
        return Result.ok(history);
    }

    @DeleteMapping("/history")
    public Result<?> clearHistory(Authentication authentication) {
        Long userId = (Long) authentication.getPrincipal();
        searchService.clearHistory(userId);
        return Result.ok();
    }
}
