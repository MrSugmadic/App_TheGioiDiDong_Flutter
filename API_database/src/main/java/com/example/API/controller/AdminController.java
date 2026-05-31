package com.example.API.controller;

import com.example.API.repository.AccountRepository;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/admin")
@CrossOrigin(origins = "*")
public class AdminController {

    private final JdbcTemplate jdbcTemplate;
    private final AccountRepository accountRepository;

    public AdminController(JdbcTemplate jdbcTemplate, AccountRepository accountRepository) {
        this.jdbcTemplate = jdbcTemplate;
        this.accountRepository = accountRepository;
    }

    @GetMapping("/orders")
    public List<Map<String, Object>> getAllOrders() {
        return jdbcTemplate.queryForList(
                "SELECT MAHD as maHd, MANV as maNv, MAKH as maKh, NGAYLAP as ngayLap, " +
                        "TRANGTHAITT as trangThai, TONGTIEN_HD as thanhTien " +
                        "FROM HOADON ORDER BY NGAYLAP DESC"
        );
    }

    @GetMapping("/accounts")
    public List<Map<String, Object>> getAllAccounts() {
        return accountRepository.findAll().stream()
                .map(account -> {
                    Map<String, Object> row = new LinkedHashMap<>();
                    row.put("id", account.getId() == null ? "" : account.getId());
                    row.put("email", account.getEmail() == null ? "" : account.getEmail());
                    row.put("role", account.getRole() == null ? "" : account.getRole());
                    row.put("customerId", account.getCustomerId() == null ? "" : account.getCustomerId());
                    return row;
                })
                .toList();
    }

    @PatchMapping("/products/{maSp}")
    public Map<String, Object> updateProduct(@PathVariable String maSp, @RequestBody Map<String, Object> body) {
        jdbcTemplate.update(
                "UPDATE SANPHAM SET TENSP = ?, DONGIA_SP = ?, SOLUONGTON = ? WHERE MASP = ?",
                stringValue(body.get("tenSp")),
                doubleValue(body.get("donGia")),
                intValue(body.get("soLuongTon")),
                maSp
        );
        return Map.of("maSp", maSp);
    }

    @DeleteMapping("/products/{maSp}")
    public Map<String, Object> deleteProduct(@PathVariable String maSp) {
        jdbcTemplate.update("DELETE FROM SANPHAM WHERE MASP = ?", maSp);
        return Map.of("maSp", maSp);
    }

    @PatchMapping("/categories/{maLoai}")
    public Map<String, Object> updateCategory(@PathVariable String maLoai, @RequestBody Map<String, Object> body) {
        jdbcTemplate.update(
                "UPDATE LOAISANPHAM SET TENLOAI = ? WHERE MALOAI = ?",
                stringValue(body.get("tenLoai")),
                maLoai
        );
        return Map.of("maLoai", maLoai);
    }

    @DeleteMapping("/categories/{maLoai}")
    public Map<String, Object> deleteCategory(@PathVariable String maLoai) {
        jdbcTemplate.update("DELETE FROM LOAISANPHAM WHERE MALOAI = ?", maLoai);
        return Map.of("maLoai", maLoai);
    }

    @PatchMapping("/orders/{maHd}/status")
    public Map<String, Object> updateOrderStatus(@PathVariable String maHd, @RequestBody Map<String, Object> body) {
        String status = stringValue(body.get("trangThai"));
        jdbcTemplate.update("UPDATE HOADON SET TRANGTHAITT = ? WHERE MAHD = ?", status, maHd);
        return Map.of("maHd", maHd, "trangThai", status);
    }

    @DeleteMapping("/orders/{maHd}")
    public Map<String, Object> deleteOrder(@PathVariable String maHd) {
        jdbcTemplate.update("DELETE FROM CHITIETHOADON WHERE MAHD = ?", maHd);
        jdbcTemplate.update("DELETE FROM HOADON WHERE MAHD = ?", maHd);
        return Map.of("maHd", maHd);
    }

    @PatchMapping("/accounts/{maTk}/role")
    public Map<String, Object> updateAccountRole(@PathVariable String maTk, @RequestBody Map<String, Object> body) {
        String role = stringValue(body.get("role"));
        jdbcTemplate.update("UPDATE TAIKHOAN SET LOAI_TAIKHOAN = ? WHERE MATK = ?", role, maTk);
        return Map.of("id", maTk, "role", role);
    }

    @DeleteMapping("/accounts/{maTk}")
    public Map<String, Object> deleteAccount(@PathVariable String maTk) {
        jdbcTemplate.update("DELETE FROM TAIKHOAN WHERE MATK = ?", maTk);
        return Map.of("id", maTk);
    }

    @PatchMapping("/notifications/{id}")
    public Map<String, Object> updateNotification(@PathVariable Integer id, @RequestBody Map<String, Object> body) {
        jdbcTemplate.update(
                "UPDATE THONGBAO SET TIEUDE = ?, NOIDUNG = ?, LOAI = ? WHERE ID = ?",
                stringValue(body.get("title")),
                stringValue(body.get("content")),
                stringValue(body.get("type")),
                id
        );
        return Map.of("id", id);
    }

    @DeleteMapping("/notifications/{id}")
    public Map<String, Object> deleteNotification(@PathVariable Integer id) {
        jdbcTemplate.update("DELETE FROM THONGBAO WHERE ID = ?", id);
        return Map.of("id", id);
    }

    private String stringValue(Object value) {
        return value == null ? "" : value.toString();
    }

    private double doubleValue(Object value) {
        if (value instanceof Number number) return number.doubleValue();
        try {
            return Double.parseDouble(stringValue(value));
        } catch (NumberFormatException e) {
            return 0;
        }
    }

    private int intValue(Object value) {
        if (value instanceof Number number) return number.intValue();
        try {
            return Integer.parseInt(stringValue(value));
        } catch (NumberFormatException e) {
            return 0;
        }
    }
}
