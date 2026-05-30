package com.example.API.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
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

    // 1. API xem giỏ hàng của một user
    @GetMapping("/{maTk}")
    public List<Cart> getCartByUser(@PathVariable String maTk) {
        return cartRepository.findByMaTk(maTk);
    }

    // 2. API thêm sản phẩm vào giỏ hàng
    @PostMapping("/add")
    public Cart addToCart(@RequestBody Cart cartRequest) {
        Cart existingItem = cartRepository.findByMaTkAndMaSp(cartRequest.getMaTk(), cartRequest.getMaSp());
        int requestQty = cartRequest.getSoLuong() == null || cartRequest.getSoLuong() <= 0 ? 1 : cartRequest.getSoLuong();

        if (existingItem != null) {
            existingItem.setSoLuong(existingItem.getSoLuong() + requestQty);
            return cartRepository.save(existingItem);
        }

        cartRequest.setSoLuong(requestQty);
        return cartRepository.save(cartRequest);
    }

    // 3. API cập nhật số lượng sản phẩm
    @PutMapping("/update")
    public ResponseEntity<?> updateCart(@RequestBody Cart cartRequest) {
        Cart existingItem = cartRepository.findByMaTkAndMaSp(cartRequest.getMaTk(), cartRequest.getMaSp());

        if (existingItem == null) {
            return ResponseEntity.notFound().build();
        }

        if (cartRequest.getSoLuong() == null || cartRequest.getSoLuong() <= 0) {
            cartRepository.delete(existingItem);
            return ResponseEntity.ok().build();
        }

        existingItem.setSoLuong(cartRequest.getSoLuong());
        return ResponseEntity.ok(cartRepository.save(existingItem));
    }

    // 4. API xóa một sản phẩm khỏi giỏ hàng
    @Transactional
    @DeleteMapping("/remove")
    public ResponseEntity<?> removeCartItem(@RequestBody Cart cartRequest) {
        cartRepository.deleteByMaTkAndMaSp(cartRequest.getMaTk(), cartRequest.getMaSp());
        return ResponseEntity.ok().build();
    }

    // 5. API xóa toàn bộ giỏ hàng của một tài khoản
    @Transactional
    @DeleteMapping("/clear/{maTk}")
    public ResponseEntity<?> clearCart(@PathVariable String maTk) {
        cartRepository.deleteByMaTk(maTk);
        return ResponseEntity.ok().build();
    }
}
