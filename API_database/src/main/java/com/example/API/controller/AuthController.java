package com.example.API.controller;

import com.example.API.entity.Account;
import com.example.API.repository.AccountRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;
import java.util.Optional;
import java.util.UUID;

@RestController
@RequestMapping("/api/auth")
@CrossOrigin(origins = "*")
public class AuthController {

    @Autowired
    private AccountRepository accountRepository;

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody Map<String, String> loginData) {
        String email = loginData.get("email");
        String password = loginData.get("password");

        Optional<Account> accountOpt = accountRepository.findByEmail(email);

        if (accountOpt.isPresent()) {
            Account account = accountOpt.get();
            if (account.getPassword().equals(password)) {
                return ResponseEntity.ok(account);
            }
        }

        return ResponseEntity.status(401).body("Sai email hoac mat khau!");
    }

    @PostMapping("/register")
    public ResponseEntity<?> register(@RequestBody Map<String, String> registerData) {
        String email = registerData.get("email");
        String password = registerData.get("password");
        String hoTen = defaultValue(registerData.get("hoTen"), registerData.get("name"));
        String soDienThoai = defaultValue(registerData.get("soDienThoai"), registerData.get("phone"));
        String diaChi = defaultValue(registerData.get("diaChi"), registerData.get("address"));

        if (email == null || email.isBlank() || password == null || password.isBlank()) {
            return ResponseEntity.badRequest().body("Email va mat khau khong duoc de trong!");
        }

        if (accountRepository.findByEmail(email).isPresent()) {
            return ResponseEntity.status(400).body("Email nay da duoc su dung!");
        }

        String maKh = generateCustomerId();
        jdbcTemplate.update(
                "INSERT INTO KHACHHANG (MAKH, TENKH, SDT_KH, DIACHI_KH, EMAIL_KH) VALUES (?, ?, ?, ?, ?)",
                maKh,
                hoTen == null || hoTen.isBlank() ? email : hoTen.trim(),
                soDienThoai,
                diaChi,
                email
        );

        Account newAccount = new Account();
        newAccount.setId(generateAccountId());
        newAccount.setCustomerId(maKh);
        newAccount.setEmail(email);
        newAccount.setPassword(password);
        newAccount.setRole("KhachHang");

        accountRepository.save(newAccount);

        return ResponseEntity.ok(Map.of(
                "message", "Dang ky thanh cong!",
                "id", newAccount.getId(),
                "maKh", maKh,
                "email", email,
                "hoTen", hoTen == null || hoTen.isBlank() ? email : hoTen.trim(),
                "role", newAccount.getRole()
        ));
    }

    @GetMapping("/profile/{maTk}")
    public ResponseEntity<?> getProfile(@PathVariable String maTk) {
        Optional<Account> accountOpt = accountRepository.findById(maTk);
        if (accountOpt.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        Account account = accountOpt.get();
        linkCustomerByEmailIfMissing(account);

        if (account.getCustomerId() == null || account.getCustomerId().isBlank()) {
            return ResponseEntity.ok(baseProfile(account, "", "", ""));
        }

        var rows = jdbcTemplate.queryForList(
                "SELECT MAKH as maKh, TENKH as hoTen, SDT_KH as soDienThoai, DIACHI_KH as diaChi FROM KHACHHANG WHERE MAKH = ?",
                account.getCustomerId()
        );

        if (rows.isEmpty()) {
            return ResponseEntity.ok(baseProfile(account, "", "", ""));
        }

        Map<String, Object> customer = rows.get(0);
        return ResponseEntity.ok(Map.of(
                "maTk", account.getId(),
                "maKh", valueOrEmpty(mapValue(customer, "maKh", "MAKH")),
                "email", valueOrEmpty(account.getEmail()),
                "role", valueOrEmpty(account.getRole()),
                "hoTen", valueOrEmpty(mapValue(customer, "hoTen", "HOTEN")),
                "soDienThoai", valueOrEmpty(mapValue(customer, "soDienThoai", "SODIENTHOAI")),
                "diaChi", valueOrEmpty(mapValue(customer, "diaChi", "DIACHI"))
        ));
    }

    @PatchMapping("/profile/{maTk}")
    public ResponseEntity<?> updateProfile(@PathVariable String maTk, @RequestBody Map<String, String> data) {
        Optional<Account> accountOpt = accountRepository.findById(maTk);
        if (accountOpt.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        Account account = accountOpt.get();
        linkCustomerByEmailIfMissing(account);

        String maKh = account.getCustomerId();
        String hoTen = defaultValue(data.get("hoTen"), account.getEmail());
        String soDienThoai = defaultValue(data.get("soDienThoai"), "");
        String diaChi = defaultValue(data.get("diaChi"), "");

        if (maKh == null || maKh.isBlank()) {
            maKh = generateCustomerId();
            jdbcTemplate.update(
                    "INSERT INTO KHACHHANG (MAKH, TENKH, SDT_KH, DIACHI_KH, EMAIL_KH) VALUES (?, ?, ?, ?, ?)",
                    maKh,
                    hoTen,
                    soDienThoai,
                    diaChi,
                    account.getEmail()
            );
            account.setCustomerId(maKh);
            accountRepository.save(account);
        } else {
            jdbcTemplate.update(
                    "UPDATE KHACHHANG SET TENKH = ?, SDT_KH = ?, DIACHI_KH = ?, EMAIL_KH = ? WHERE MAKH = ?",
                    hoTen,
                    soDienThoai,
                    diaChi,
                    account.getEmail(),
                    maKh
            );
        }

        return getProfile(maTk);
    }

    private Map<String, Object> baseProfile(Account account, String hoTen, String soDienThoai, String diaChi) {
        return Map.of(
                "maTk", account.getId(),
                "email", valueOrEmpty(account.getEmail()),
                "role", valueOrEmpty(account.getRole()),
                "hoTen", valueOrEmpty(hoTen),
                "soDienThoai", valueOrEmpty(soDienThoai),
                "diaChi", valueOrEmpty(diaChi)
        );
    }

    private String generateAccountId() {
        String id;
        do {
            id = "TK" + UUID.randomUUID().toString().replace("-", "").substring(0, 8).toUpperCase();
        } while (accountRepository.existsById(id));
        return id;
    }

    private void linkCustomerByEmailIfMissing(Account account) {
        if (account.getCustomerId() != null && !account.getCustomerId().isBlank()) {
            return;
        }

        var rows = jdbcTemplate.queryForList(
                "SELECT MAKH FROM KHACHHANG WHERE EMAIL_KH = ?",
                account.getEmail()
        );

        if (!rows.isEmpty()) {
            String maKh = valueOrEmpty(mapValue(rows.get(0), "MAKH", "maKh"));
            if (!maKh.isBlank()) {
                account.setCustomerId(maKh);
                accountRepository.save(account);
            }
        }
    }

    private String generateCustomerId() {
        String id;
        do {
            id = "KH" + UUID.randomUUID().toString().replace("-", "").substring(0, 8).toUpperCase();
        } while (!jdbcTemplate.queryForList("SELECT MAKH FROM KHACHHANG WHERE MAKH = ?", id).isEmpty());
        return id;
    }

    private String defaultValue(String value, String fallback) {
        return value == null || value.isBlank() ? fallback : value.trim();
    }

    private String valueOrEmpty(Object value) {
        return value == null ? "" : value.toString();
    }

    private Object mapValue(Map<String, Object> row, String primaryKey, String fallbackKey) {
        return row.containsKey(primaryKey) ? row.get(primaryKey) : row.get(fallbackKey);
    }
}
