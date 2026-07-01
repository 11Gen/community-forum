package com.forum.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.forum.entity.Post;
import com.forum.entity.ViewHistory;
import com.forum.mapper.PostMapper;
import com.forum.mapper.ViewHistoryMapper;
import com.forum.service.ViewHistoryService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class ViewHistoryServiceImpl implements ViewHistoryService {

    private final ViewHistoryMapper viewHistoryMapper;
    private final PostMapper postMapper;

    public ViewHistoryServiceImpl(ViewHistoryMapper viewHistoryMapper, PostMapper postMapper) {
        this.viewHistoryMapper = viewHistoryMapper;
        this.postMapper = postMapper;
    }

    @Override
    @Transactional
    public void record(Long userId, Long postId) {
        LambdaQueryWrapper<ViewHistory> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(ViewHistory::getUserId, userId).eq(ViewHistory::getPostId, postId);
        ViewHistory existing = viewHistoryMapper.selectOne(wrapper);
        if (existing != null) {
            existing.setCreateTime(LocalDateTime.now());
            viewHistoryMapper.updateById(existing);
        } else {
            ViewHistory vh = new ViewHistory();
            vh.setUserId(userId);
            vh.setPostId(postId);
            viewHistoryMapper.insert(vh);
        }
        // Limit to 50 records per user
        Long count = viewHistoryMapper.selectCount(
                new LambdaQueryWrapper<ViewHistory>().eq(ViewHistory::getUserId, userId));
        if (count > 50) {
            LambdaQueryWrapper<ViewHistory> oldestWrapper = new LambdaQueryWrapper<>();
            oldestWrapper.eq(ViewHistory::getUserId, userId)
                    .orderByAsc(ViewHistory::getCreateTime)
                    .last("LIMIT " + (count - 50));
            List<ViewHistory> oldest = viewHistoryMapper.selectList(oldestWrapper);
            for (ViewHistory vh : oldest) {
                viewHistoryMapper.deleteById(vh.getId());
            }
        }
    }

    @Override
    public Page<ViewHistory> getHistory(Long userId, int page, int size) {
        LambdaQueryWrapper<ViewHistory> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(ViewHistory::getUserId, userId).orderByDesc(ViewHistory::getCreateTime);
        Page<ViewHistory> result = viewHistoryMapper.selectPage(new Page<>(page, size), wrapper);
        for (ViewHistory vh : result.getRecords()) {
            Post post = postMapper.selectById(vh.getPostId());
            if (post == null || post.getStatus() == 1) {
                vh.setPostTitle("该帖子内容已失效");
                vh.setPostStatus(1);
            } else {
                vh.setPostTitle(post.getTitle());
                vh.setPostStatus(post.getStatus());
            }
        }
        return result;
    }
}
