package com.example.API.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.example.API.entity.ProductDescription;

@Repository
public interface ProductDescriptionRepository extends JpaRepository<ProductDescription, String> {
    // Tìm mô tả chi tiết bằng mã sản phẩm
    ProductDescription findByMaSp(String maSp);
}