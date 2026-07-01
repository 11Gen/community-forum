package com.forum.controller;

import com.forum.common.Result;
import com.forum.entity.Category;
import com.forum.service.CategoryService;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/category")
public class CategoryController {

    private final CategoryService categoryService;

    public CategoryController(CategoryService categoryService) {
        this.categoryService = categoryService;
    }

    @GetMapping("/list")
    public Result<?> list() {
        List<Category> categories = categoryService.listAll();
        return Result.ok(categories);
    }
}
