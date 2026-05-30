package com.example.API.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.example.API.entity.Cart;

@Repository
public interface CartRepository extends JpaRepository<Cart, Integer> {
    // Tìm toàn bộ sản phẩm trong giỏ của 1 tài khoản
    List<Cart> findByMaTk(String maTk);
    
    // Kiểm tra xem sản phẩm này đã có trong giỏ của tài khoản này chưa
    Cart findByMaTkAndMaSp(String maTk, String maSp);
}