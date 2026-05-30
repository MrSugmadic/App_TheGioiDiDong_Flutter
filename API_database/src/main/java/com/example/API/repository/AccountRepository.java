package com.example.API.repository;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.example.API.entity.Account;

@Repository
public interface AccountRepository extends JpaRepository<Account, String> {
    // Tự động tạo câu lệnh: SELECT * FROM TAIKHOAN WHERE EMAIL_TK = ?
    Optional<Account> findByEmail(String email);
}