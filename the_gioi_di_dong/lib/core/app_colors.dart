import 'package:flutter/material.dart';

class AppColors {
  // Chặn việc khởi tạo class này (vì mình chỉ dùng biến static)
  AppColors._();

  // Màu thương hiệu (Brand Colors)
  static const Color primaryThis = Color.fromARGB(
    255,
    54,
    236,
    148,
  ); // Tự chỉnh
  static const Color backgroundLight = Color(0xFFF5F5F5); // Xám nhạt cho nền
  static const Color white = Colors.white;

  // Màu chữ (Text Colors)
  static const Color textPrimary = Color.fromARGB(
    255,
    0,
    0,
    0,
  ); // Đen nhạt dễ đọc hơn đen tuyền
  static const Color textSecondary = Color(0xFF757575); // Xám cho text phụ
  static const Color priceRed = Color(0xFFD32F2F); // Đỏ chuẩn cho giá tiền

  // Màu trạng thái (Status Colors)
  static const Color success = Color(0xFF388E3C); // Xanh lá
  static const Color error = Color(0xFFD32F2F); // Đỏ báo lỗi
}
