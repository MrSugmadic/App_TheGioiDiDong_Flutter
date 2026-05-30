import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import 'package:the_gioi_di_dong/core/utils.dart';
import 'order_detail_screen.dart'; // Import cái file chi tiết đơn hàng hôm trước để xài ké MockOrder

class OrderListScreen extends StatelessWidget {
  final String status; // Trạng thái đơn hàng (VD: "Đang giao", "Chờ xác nhận")

  const OrderListScreen({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    // TẠM THỜI: Tạo ra 2 cái đơn hàng giả lập đang giao để test giao diện
    final List<MockOrder> dummyOrders = [
      MockOrder(
        orderId: 'DH100999',
        status: status,
        orderDate: '08:00 - 31/05/2026',
        customerName: 'Anh Long',
        phone: '0987654321',
        address: '123 Đường Điện Biên Phủ, Quận Bình Thạnh, TP.HCM',
        shippingFee: 30000,
        totalAmount: 34030000,
        items: [
          MockOrderItem(
            name: 'iPhone 15 Pro Max 256GB',
            imageUrl: 'assets/images/laptop.png',
            quantity: 1,
            price: 34000000,
          ),
        ],
      ),
      MockOrder(
        orderId: 'DH100888',
        status: status,
        orderDate: '15:20 - 29/05/2026',
        customerName: 'Anh Long',
        phone: '0987654321',
        address: '123 Đường Điện Biên Phủ, Quận Bình Thạnh, TP.HCM',
        shippingFee: 15000,
        totalAmount: 515000,
        items: [
          MockOrderItem(
            name: 'Sạc dự phòng Samsung 10000mAh',
            imageUrl: 'assets/images/laptop.png',
            quantity: 1,
            price: 500000,
          ),
        ],
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(
          'Đơn hàng $status',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primaryThis,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: dummyOrders.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: dummyOrders.length,
              itemBuilder: (context, index) {
                final order = dummyOrders[index];
                return _buildOrderCard(context, order);
              },
            ),
    );
  }

  // Khối thiết kế cho 1 thẻ Đơn hàng
  Widget _buildOrderCard(BuildContext context, MockOrder order) {
    return GestureDetector(
      onTap: () {
        // Bấm vào thẻ thì bay sang màn hình Chi tiết đơn hàng
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetailScreen(order: order),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header: Mã đơn + Trạng thái
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Mã: ${order.orderId}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    order.status,
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ), // Màu xanh cho Đang giao
                  ),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),

            // Body: Hình ảnh và thông tin món hàng đầu tiên
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Image.asset(
                      order.items.first.imageUrl,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.items.first.name,
                          style: const TextStyle(fontSize: 15),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'x${order.items.first.quantity}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                            Text(
                              AppUtils.formatCurrency(order.items.first.price),
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
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
            const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),

            // Footer: Tổng tiền và Nút bấm
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Thành tiền:',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      Text(
                        AppUtils.formatCurrency(order.totalAmount),
                        style: const TextStyle(
                          color: AppColors.priceRed,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  // Nút Đã nhận được hàng (dành riêng cho trạng thái Đang giao)
                  if (status == 'Đang giao')
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryThis,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Xác nhận đã nhận hàng thành công!'),
                          ),
                        );
                      },
                      child: const Text('ĐÃ NHẬN HÀNG'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Giao diện khi không có đơn hàng nào
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'Chưa có đơn hàng nào',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
