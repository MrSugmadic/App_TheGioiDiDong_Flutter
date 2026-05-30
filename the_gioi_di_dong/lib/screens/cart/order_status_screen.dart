import 'package:flutter/material.dart';
import 'package:the_gioi_di_dong/core/app_colors.dart';

class OrderStatusScreen extends StatelessWidget {
  const OrderStatusScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Trạng thái đơn hàng"),
        backgroundColor: AppColors.primaryThis,
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(20),
            child: Text(
              "Đơn hàng #TGDD123 của Hồ Gia Tiến",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          _step("Đặt hàng thành công", true),
          _step("Đang xác nhận", true),
          _step("Đang giao hàng", false),
          _step("Thành công", false),
          Spacer(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryThis, // Màu nền chuẩn của app
                foregroundColor: Colors.white, // Màu chữ trắng
                minimumSize: const Size(
                  double.infinity,
                  50,
                ), // Chiều rộng tối đa, cao 50
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), // Bo góc cho mềm mại
                ),
              ),
              onPressed: () =>
                  Navigator.popUntil(context, (route) => route.isFirst),
              child: const Text(
                "VỀ TRANG CHỦ",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold, // Chữ in đậm lên form cho đẹp
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _step(String title, bool ok) {
    return ListTile(
      leading: Icon(
        ok ? Icons.check_circle : Icons.radio_button_unchecked,
        color: ok ? Colors.green : Colors.grey,
      ),
      title: Text(
        title,
        style: TextStyle(color: ok ? Colors.black : Colors.grey),
      ),
    );
  }
}
