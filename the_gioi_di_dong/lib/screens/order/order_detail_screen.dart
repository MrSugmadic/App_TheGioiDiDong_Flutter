import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import 'package:the_gioi_di_dong/core/utils.dart';

// TẠM THỜI: Lớp OrderItem và Order giả lập để ông chạy thử lên UI.
// Về sau ông xóa đi và import Model thật từ API của ông vào nhé!
class MockOrderItem {
  final String name;
  final String imageUrl;
  final int quantity;
  final double price;
  MockOrderItem({
    required this.name,
    required this.imageUrl,
    required this.quantity,
    required this.price,
  });
}

class MockOrder {
  final String orderId;
  final String status;
  final String orderDate;
  final String customerName;
  final String phone;
  final String address;
  final List<MockOrderItem> items;
  final double shippingFee;
  final double totalAmount;

  MockOrder({
    required this.orderId,
    required this.status,
    required this.orderDate,
    required this.customerName,
    required this.phone,
    required this.address,
    required this.items,
    required this.shippingFee,
    required this.totalAmount,
  });
}

// ==========================================
// MÀN HÌNH CHÍNH
// ==========================================
class OrderDetailScreen extends StatelessWidget {
  // Thay MockOrder bằng Model thật của ông sau này
  final MockOrder order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.grey[100], // Màu nền xám nhạt để làm nổi bật các khối trắng
      appBar: AppBar(
        title: const Text(
          'Chi tiết đơn hàng',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primaryThis,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildOrderStatusSection(),
            const SizedBox(height: 8),
            _buildShippingAddressSection(),
            const SizedBox(height: 8),
            _buildOrderItemsSection(),
            const SizedBox(height: 8),
            _buildOrderSummarySection(),
            const SizedBox(height: 20),
          ],
        ),
      ),
      // Nút hành động ở dưới đáy (Hủy đơn / Mua lại)
      bottomNavigationBar: _buildBottomActions(context),
    );
  }

  // 1. Khối trạng thái đơn hàng
  Widget _buildOrderStatusSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Mã đơn hàng: ${order.orderId}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                order.status,
                style: const TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Ngày đặt: ${order.orderDate}',
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // 2. Khối địa chỉ giao hàng
  Widget _buildShippingAddressSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.location_on, color: Colors.green),
              SizedBox(width: 8),
              Text(
                'Địa chỉ nhận hàng',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${order.customerName} - ${order.phone}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            order.address,
            style: const TextStyle(color: Colors.black87, height: 1.4),
          ),
        ],
      ),
    );
  }

  // 3. Khối danh sách sản phẩm
  Widget _buildOrderItemsSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Sản phẩm đã đặt',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(height: 1),
          // Danh sách các món hàng
          ...order.items.map(
            (item) => Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hình ảnh sản phẩm
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Image.asset(
                      item.imageUrl,
                      fit: BoxFit.contain,
                    ), // Thay bằng network image nếu lấy từ API
                  ),
                  const SizedBox(width: 12),
                  // Thông tin sản phẩm
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'x${item.quantity}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                            Text(
                              AppUtils.formatCurrency(item.price),
                              style: const TextStyle(
                                color: AppColors.priceRed,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 4. Khối tính toán tiền bạc
  Widget _buildOrderSummarySection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSummaryRow('Tạm tính', order.totalAmount - order.shippingFee),
          const SizedBox(height: 8),
          _buildSummaryRow('Phí vận chuyển', order.shippingFee),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Thành tiền',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                AppUtils.formatCurrency(order.totalAmount),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.priceRed,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(
          AppUtils.formatCurrency(value),
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  // 5. Nút điều hướng dưới đáy (Tùy theo trạng thái đơn mà hiện nút tương ứng)
  Widget _buildBottomActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Nếu đơn đang "Chờ xác nhận" thì cho phép Hủy
          if (order.status == 'Chờ xác nhận')
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: Colors.grey),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  // Gọi API Hủy đơn hàng
                },
                child: const Text(
                  'HỦY ĐƠN',
                  style: TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          if (order.status == 'Chờ xác nhận') const SizedBox(width: 12),

          // Nút hành động chính (Mua lại / Liên hệ CSKH...)
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryThis,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                // Logic mua lại hoặc quay về trang chủ
              },
              child: const Text(
                'MUA LẠI',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
