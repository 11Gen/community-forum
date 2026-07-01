package com.forum.service;

import com.forum.entity.Category;
import java.util.List;

public interface CategoryService {
    List<Category> listAll();
    Category create(String name, String description);
    Category update(Long id, String name, String description, Integer sortOrder);
    void delete(Long id);
}
