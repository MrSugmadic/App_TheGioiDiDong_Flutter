import 'package:flutter/material.dart';

class OrderStatusScreen extends StatelessWidget {
  const OrderStatusScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Trạng thái đơn hàng"), backgroundColor: Colors.amber),
      body: Column(
        children: [
          Container(padding: EdgeInsets.all(20), child: Text("Đơn hàng #TGDD123 của Hồ Gia Tiến", style: TextStyle(fontWeight: FontWeight.bold))),
          _step("Đặt hàng thành công", true),
          _step("Đang xác nhận", true),
          _step("Đang giao hàng", false),
          _step("Thành công", false),
          Spacer(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
              onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
              child: Text("VỀ TRANG CHỦ"),
            ),
          )
        ],
      ),
    );
  }

  Widget _step(String title, bool ok) {
    return ListTile(
      leading: Icon(ok ? Icons.check_circle : Icons.radio_button_unchecked, color: ok ? Colors.green : Colors.grey),
      title: Text(title, style: TextStyle(color: ok ? Colors.black : Colors.grey)),
    );
  }
}