package com.example.API.controller;

import com.example.API.entity.Category;
import com.example.API.repository.CategoryRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/categories")
@CrossOrigin(origins = "*") // Quan trọng: Cho phép Flutter gọi API không bị chặn CORS
public class CategoryController {

    @Autowired
    private CategoryRepository categoryRepository;

    @GetMapping
    public List<Category> getAllCategories() {
        // Trả về toàn bộ danh sách danh mục có trong Database
        return categoryRepository.findAll();
    }
}