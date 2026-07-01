package com.forum.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.forum.entity.Category;
import com.forum.mapper.CategoryMapper;
import com.forum.service.CategoryService;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class CategoryServiceImpl implements CategoryService {

    private final CategoryMapper categoryMapper;

    public CategoryServiceImpl(CategoryMapper categoryMapper) {
        this.categoryMapper = categoryMapper;
    }

    @Override
    public List<Category> listAll() {
        LambdaQueryWrapper<Category> wrapper = new LambdaQueryWrapper<>();
        wrapper.orderByAsc(Category::getSortOrder);
        return categoryMapper.selectList(wrapper);
    }

    @Override
    public Category create(String name, String description) {
        Category category = new Category();
        category.setName(name);
        category.setDescription(description);
        category.setSortOrder(99);
        categoryMapper.insert(category);
        return category;
    }

    @Override
    public Category update(Long id, String name, String description, Integer sortOrder) {
        Category category = categoryMapper.selectById(id);
        if (category == null) {
            throw new RuntimeException("分类不存在");
        }
        if (name != null) category.setName(name);
        if (description != null) category.setDescription(description);
        if (sortOrder != null) category.setSortOrder(sortOrder);
        categoryMapper.updateById(category);
        return category;
    }

    @Override
    public void delete(Long id) {
        categoryMapper.deleteById(id);
    }
}
