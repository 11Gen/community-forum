package com.forum.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.forum.entity.ViewHistory;

public interface ViewHistoryService {
    void record(Long userId, Long postId);
    Page<ViewHistory> getHistory(Long userId, int page, int size);
}
