import 'package:flutter/material.dart';
import 'package:the_gioi_di_dong/core/app_colors.dart';
import 'package:the_gioi_di_dong/core/utils.dart';
import 'package:the_gioi_di_dong/models/order_model.dart';

class OrderStatusScreen extends StatelessWidget {
  final OrderModel? order;

  const OrderStatusScreen({super.key, this.order});

  @override
  Widget build(BuildContext context) {
    final status = order?.trangThai ?? 'Chờ xác nhận';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trạng thái đơn hàng'),
        backgroundColor: AppColors.primaryThis,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order == null
                      ? 'Đơn hàng của bạn đã được ghi nhận'
                      : 'Đơn hàng ${order!.maHd}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (order != null) ...[
                  const SizedBox(height: 6),
                  Text('Người nhận: ${order!.hoTen} - ${order!.soDienThoai}'),
                  const SizedBox(height: 4),
                  Text('Tổng tiền: ${AppUtils.formatCurrency(order!.thanhTien)}'),
                ],
              ],
            ),
          ),
          _step('Đặt hàng thành công', true),
          _step('Chờ admin xác nhận', _isReached(status, 'Chờ xác nhận')),
          _step('Đã xác nhận', _isReached(status, 'Đã xác nhận')),
          _step('Đang chuẩn bị hàng', _isReached(status, 'Đang chuẩn bị hàng')),
          _step('Đang giao hàng', _isReached(status, 'Đang giao hàng')),
          _step('Hoàn tất', _isReached(status, 'Hoàn tất')),
          if (status == 'Đã hủy') _step('Đã hủy', true, color: Colors.red),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: AppColors.primaryThis,
                foregroundColor: Colors.black,
              ),
              onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
              child: const Text('VỀ TRANG CHỦ'),
            ),
          ),
        ],
      ),
    );
  }

  bool _isReached(String current, String target) {
    const statuses = [
      'Chờ xác nhận',
      'Đã xác nhận',
      'Đang chuẩn bị hàng',
      'Đang giao hàng',
      'Hoàn tất',
    ];

    final currentIndex = statuses.indexOf(current);
    final targetIndex = statuses.indexOf(target);
    if (currentIndex == -1 || targetIndex == -1) return false;
    return currentIndex >= targetIndex;
  }

  Widget _step(String title, bool ok, {Color? color}) {
    final activeColor = color ?? Colors.green;
    return ListTile(
      leading: Icon(
        ok ? Icons.check_circle : Icons.radio_button_unchecked,
        color: ok ? activeColor : Colors.grey,
      ),
      title: Text(
        title,
        style: TextStyle(color: ok ? Colors.black : Colors.grey),
      ),
    );
  }
}
