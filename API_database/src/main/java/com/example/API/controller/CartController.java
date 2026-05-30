package com.example.API.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.API.entity.Cart;
import com.example.API.repository.CartRepository;

@RestController
@RequestMapping("/api/cart")
@CrossOrigin(origins = "*")
public class CartController {

    @Autowired
    private CartRepository cartRepository;

    // 1. API Xem giỏ hàng của một user
    @GetMapping("/{maTk}")
    public List<Cart> getCartByUser(@PathVariable String maTk) {
        return cartRepository.findByMaTk(maTk);
    }

    // 2. API Thêm sản phẩm vào giỏ hàng
    @PostMapping("/add")
    public Cart addToCart(@RequestBody Cart cartRequest) {
        // Kiểm tra xem SP này user đã thêm trước đó chưa
        Cart existingItem = cartRepository.findByMaTkAndMaSp(cartRequest.getMaTk(), cartRequest.getMaSp());
        
        if (existingItem != null) {
            // Nếu có rồi thì cộng dồn số lượng
            existingItem.setSoLuong(existingItem.getSoLuong() + cartRequest.getSoLuong());
            return cartRepository.save(existingItem);
        } else {
            // Nếu chưa có thì tạo dòng mới
            return cartRepository.save(cartRequest);
        }
    }
}