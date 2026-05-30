package com.example.API.controller;

import java.util.Map;
import java.util.Optional;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.API.entity.Account;
import com.example.API.repository.AccountRepository;

@RestController
@RequestMapping("/api/auth")
@CrossOrigin(origins = "*")
public class AuthController {

    @Autowired
    private AccountRepository accountRepository;

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody Map<String, String> loginData) {
        String email = loginData.get("email");
        String password = loginData.get("password");

        Optional<Account> accountOpt = accountRepository.findByEmail(email);

        if (accountOpt.isPresent()) {
            Account account = accountOpt.get();
            // LƯU Ý: Trong SQL mẫu của ông, mật khẩu đang được mã hóa (MD5/SHA).
            // Nếu ông gõ mật khẩu thô, nó sẽ không khớp. Tạm thời check bằng nhau:
            if (account.getPassword().equals(password)) {
                return ResponseEntity.ok(account); // Trả về thông tin user nếu đúng
            }
        }
        return ResponseEntity.status(401).body("Sai email hoặc mật khẩu!");
    }
    @PostMapping("/register")
public ResponseEntity<?> register(@RequestBody Map<String, String> registerData) {
    String email = registerData.get("email");
    String password = registerData.get("password");

    // 1. Kiểm tra xem Email đã tồn tại chưa
    if (accountRepository.findByEmail(email).isPresent()) {
        return ResponseEntity.status(400).body("Email này đã được sử dụng rồi ông giáo ạ!");
    }

    // 2. Tạo tài khoản mới
    Account newAccount = new Account();
    // Tạo mã tài khoản ngẫu nhiên (ví dụ: TK_A1B2C3D4)
    newAccount.setId("TK_" + UUID.randomUUID().toString().substring(0, 2).toUpperCase());
    newAccount.setEmail(email);
    newAccount.setPassword(password); // Tạm thời cứ lưu pass trần để test cho dễ
    newAccount.setRole("KhachHang");  // Mặc định user mới đăng ký là Khách Hàng

    // 3. Lưu xuống Database
    accountRepository.save(newAccount);

    return ResponseEntity.ok(Map.of("message", "Đăng ký thành công!"));
}
}