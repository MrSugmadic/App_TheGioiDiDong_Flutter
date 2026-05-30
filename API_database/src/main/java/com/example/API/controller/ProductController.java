package com.example.API.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.API.entity.Product;
import com.example.API.entity.ProductDescription;
import com.example.API.repository.ProductDescriptionRepository;
import com.example.API.repository.ProductRepository;

@RestController
@RequestMapping("/api/products") // Đường dẫn gốc cho API sản phẩm
@CrossOrigin(origins = "*") // Quan trọng: Cho phép Flutter gọi API mà không bị chặn lỗi CORS
public class ProductController {

    @Autowired
    private ProductRepository productRepository;

    // Lấy tất cả sản phẩm
    @GetMapping
    public List<Product> getAllProducts() {
        return productRepository.findAll();
    }

    // Lấy sản phẩm theo danh mục
    @GetMapping("/category/{maLoai}")
    public List<Product> getProductsByCategory(@PathVariable String maLoai) {
        return productRepository.findByMaLoai(maLoai);
    }
    @Autowired
    private ProductDescriptionRepository descriptionRepository;

    // API lấy chi tiết cấu hình: /api/products/detail/SP001
    @GetMapping("/detail/{maSp}")
    public ProductDescription getProductDetail(@PathVariable String maSp) {
        return descriptionRepository.findByMaSp(maSp);
    }
}
