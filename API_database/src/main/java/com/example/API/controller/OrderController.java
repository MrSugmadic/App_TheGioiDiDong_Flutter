package com.example.API.controller;

import com.example.API.dto.CreateOrderRequest;
import com.example.API.dto.OrderItemRequest;
import com.example.API.entity.Account;
import com.example.API.repository.AccountRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.*;

import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;

@RestController
@RequestMapping("/api/orders")
@CrossOrigin(origins = "*")
public class OrderController {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @Autowired
    private AccountRepository accountRepository;

    @PostMapping("/create")
    public ResponseEntity<?> createOrder(@RequestBody CreateOrderRequest request) {
        try {
            if (request.getItems() == null || request.getItems().isEmpty()) {
                return ResponseEntity.badRequest().body(Map.of("message", "Giỏ hàng đang trống!"));
            }

            String maHd = generateOrderId();
            String maKh = null;

            if (request.getMaTk() != null && !request.getMaTk().isBlank()) {
                Optional<Account> account = accountRepository.findById(request.getMaTk());
                if (account.isPresent()) {
                    maKh = account.get().getCustomerId();
                }
            }

            double thanhTien = valueOrZero(request.getThanhTien());
            if (thanhTien <= 0) {
                thanhTien = valueOrZero(request.getTongTien()) - valueOrZero(request.getGiamGia());
            }

            jdbcTemplate.update(
                    "INSERT INTO HOADON (MAHD, MANV, MAKH, NGAYLAP, TRANGTHAITT, TONGTIEN_HD) VALUES (?, ?, ?, ?, ?, ?)",
                    maHd,
                    null,
                    maKh,
                    Timestamp.valueOf(LocalDateTime.now()),
                    "Chờ xác nhận",
                    thanhTien
            );

            for (OrderItemRequest item : request.getItems()) {
                int quantity = item.getSoLuong() == null || item.getSoLuong() <= 0 ? 1 : item.getSoLuong();
                double price = item.getDonGia() == null ? 0 : item.getDonGia();
                double lineTotal = price * quantity;

                jdbcTemplate.update(
                        "INSERT INTO CHITIETHOADON (MASP, MAHD, SOLUONGSP_HD, THANHTIEN) VALUES (?, ?, ?, ?)",
                        item.getMaSp(),
                        maHd,
                        String.valueOf(quantity),
                        lineTotal
                );
            }

            if (request.getMaTk() != null && !request.getMaTk().isBlank()) {
                jdbcTemplate.update("DELETE FROM GIOHANG WHERE MATK = ?", request.getMaTk());
            }

            createOrderNotification(request.getMaTk(), maHd, thanhTien, request.getPhuongThucThanhToan());

            Map<String, Object> response = new LinkedHashMap<>();
            response.put("maHd", maHd);
            response.put("maTk", request.getMaTk());
            response.put("maKh", maKh);
            response.put("hoTen", request.getHoTen());
            response.put("soDienThoai", request.getSoDienThoai());
            response.put("diaChi", request.getDiaChi());
            response.put("phuongThucThanhToan", request.getPhuongThucThanhToan());
            response.put("maGiamGia", request.getMaGiamGia());
            response.put("tongTien", valueOrZero(request.getTongTien()));
            response.put("giamGia", valueOrZero(request.getGiamGia()));
            response.put("thanhTien", thanhTien);
            response.put("trangThai", "Chờ xác nhận");
            response.put("ngayLap", LocalDateTime.now().format(DateTimeFormatter.ISO_LOCAL_DATE_TIME));
            response.put("items", request.getItems());

            return ResponseEntity.ok(response);
        } catch (Exception e) {
            return ResponseEntity.internalServerError().body(Map.of("message", "Không thể tạo đơn hàng: " + e.getMessage()));
        }
    }

    @GetMapping("/user/{maTk}")
    public ResponseEntity<?> getOrdersByUser(@PathVariable String maTk) {
        Optional<Account> account = accountRepository.findById(maTk);
        if (account.isEmpty() || account.get().getCustomerId() == null) {
            return ResponseEntity.ok(List.of());
        }

        String maKh = account.get().getCustomerId();
        List<Map<String, Object>> orders = jdbcTemplate.queryForList(
                "SELECT MAHD as maHd, MAKH as maKh, NGAYLAP as ngayLap, TRANGTHAITT as trangThai, TONGTIEN_HD as thanhTien " +
                        "FROM HOADON WHERE MAKH = ? ORDER BY NGAYLAP DESC",
                maKh
        );
        return ResponseEntity.ok(orders);
    }

    @GetMapping("/{maHd}")
    public ResponseEntity<?> getOrderDetail(@PathVariable String maHd) {
        List<Map<String, Object>> orderRows = jdbcTemplate.queryForList(
                "SELECT MAHD as maHd, MAKH as maKh, NGAYLAP as ngayLap, TRANGTHAITT as trangThai, TONGTIEN_HD as thanhTien FROM HOADON WHERE MAHD = ?",
                maHd
        );

        if (orderRows.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        List<Map<String, Object>> items = jdbcTemplate.queryForList(
                "SELECT ct.MASP as maSp, sp.TENSP as tenSp, sp.DONGIA_SP as donGia, ct.SOLUONGSP_HD as soLuong, ct.THANHTIEN as thanhTien " +
                        "FROM CHITIETHOADON ct JOIN SANPHAM sp ON ct.MASP = sp.MASP WHERE ct.MAHD = ?",
                maHd
        );

        Map<String, Object> result = new LinkedHashMap<>(orderRows.get(0));
        result.put("items", items);
        return ResponseEntity.ok(result);
    }

    @PatchMapping("/{maHd}/status")
    public ResponseEntity<?> updateOrderStatus(@PathVariable String maHd, @RequestBody Map<String, String> body) {
        String status = body.getOrDefault("trangThai", "Chờ xác nhận");
        int updated = jdbcTemplate.update("UPDATE HOADON SET TRANGTHAITT = ? WHERE MAHD = ?", status, maHd);
        if (updated == 0) return ResponseEntity.notFound().build();
        return ResponseEntity.ok(Map.of("maHd", maHd, "trangThai", status));
    }

    private String generateOrderId() {
        String suffix = String.valueOf(System.currentTimeMillis() % 100000000L);
        String maHd = "HD" + suffix;
        if (maHd.length() > 10) {
            maHd = maHd.substring(0, 10);
        }
        return maHd;
    }

    private double valueOrZero(Double value) {
        return value == null ? 0 : value;
    }

    private void createOrderNotification(String maTk, String maHd, double thanhTien, String paymentMethod) {
        try {
            jdbcTemplate.update(
                    "INSERT INTO THONGBAO (MATK, TIEUDE, NOIDUNG, LOAI, DADOC, NGAYTAO, LINK, MA_LIENQUAN) VALUES (?, ?, ?, ?, ?, ?, ?, ?)",
                    maTk,
                    "Đặt hàng thành công",
                    "Đơn hàng " + maHd + " đã được ghi nhận. Tổng thanh toán: " + String.format("%,.0f", thanhTien) + "đ. Phương thức: " + paymentMethod,
                    "ORDER",
                    false,
                    Timestamp.valueOf(LocalDateTime.now()),
                    "/orders/" + maHd,
                    maHd
            );
        } catch (Exception ignored) {
            // Không để lỗi thông báo làm hỏng quy trình đặt hàng.
        }
    }
}
