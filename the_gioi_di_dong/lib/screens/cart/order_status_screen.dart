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

    // Danh sách các trạng thái chuẩn
    final List<String> statuses = [
      'Chờ xác nhận',
      'Đã xác nhận',
      'Đang chuẩn bị hàng',
      'Đang giao hàng',
      'Hoàn tất',
    ];

    bool isCancelled = status == 'Đã hủy';

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Trạng thái đơn hàng',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: AppColors.primaryThis,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // KHU VỰC THÔNG TIN CHUNG
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.receipt_long,
                      color: AppColors.primaryThis,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      order == null
                          ? 'Đơn hàng vừa ghi nhận'
                          : 'Mã ĐH: #${order!.maHd}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                if (order != null) ...[
                  const Divider(height: 24),
                  _infoRow(
                    Icons.person_outline,
                    '${order!.hoTen} - ${order!.soDienThoai}',
                  ),
                  const SizedBox(height: 8),
                  _infoRow(
                    Icons.payments_outlined,
                    AppUtils.formatCurrency(order!.thanhTien),
                    isBold: true,
                    color: AppColors.priceRed,
                  ),
                ],
              ],
            ),
          ),

          // KHU VỰC TIMELINE TRẠNG THÁI
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: isCancelled
                  ? _buildCancelledState()
                  : ListView.builder(
                      itemCount: statuses.length,
                      itemBuilder: (context, index) {
                        final stepStatus = statuses[index];
                        final bool isReached = _isReached(
                          status,
                          stepStatus,
                          statuses,
                        );
                        final bool isLast = index == statuses.length - 1;

                        return _buildTimelineStep(
                          stepStatus,
                          isReached,
                          isLast,
                        );
                      },
                    ),
            ),
          ),

          // NÚT VỀ TRANG CHỦ
          Container(
            padding: const EdgeInsets.all(16),
            child: SafeArea(
              child: ElevatedButton.icon(
                onPressed: () =>
                    Navigator.popUntil(context, (route) => route.isFirst),
                icon: const Icon(Icons.home_outlined),
                label: const Text(
                  'VỀ TRANG CHỦ',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryThis,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Tiện ích hiển thị thông tin
  Widget _infoRow(
    IconData icon,
    String text, {
    bool isBold = false,
    Color? color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: color ?? Colors.black87,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  // Thuật toán kiểm tra trạng thái đã qua
  bool _isReached(String current, String target, List<String> statuses) {
    final currentIndex = statuses.indexOf(current);
    final targetIndex = statuses.indexOf(target);
    if (currentIndex == -1 || targetIndex == -1) return false;
    return currentIndex >= targetIndex;
  }

  // Vẽ 1 điểm trên Timeline
  Widget _buildTimelineStep(String title, bool isReached, bool isLast) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isReached ? AppColors.primaryThis : Colors.grey[300],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check,
                size: 14,
                color: isReached ? Colors.white : Colors.transparent,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: isReached ? AppColors.primaryThis : Colors.grey[300],
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2.0),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: isReached ? FontWeight.bold : FontWeight.normal,
                color: isReached ? Colors.black87 : Colors.grey,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Giao diện khi đơn bị hủy
  Widget _buildCancelledState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cancel_outlined, size: 80, color: Colors.red[300]),
          const SizedBox(height: 16),
          const Text(
            'Đơn hàng đã bị hủy',
            style: TextStyle(
              fontSize: 18,
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
