import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_gioi_di_dong/core/app_colors.dart';
import 'package:the_gioi_di_dong/core/utils.dart';
import 'package:the_gioi_di_dong/providers/user_profile_provider.dart';

import 'order_detail_screen.dart';

class OrderListScreen extends StatelessWidget {
  final String status;

  const OrderListScreen({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<UserProfileProvider>();
    final orders = _buildDummyOrders(profile);

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(
          'Đơn hàng $status',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primaryThis,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: orders.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                return _buildOrderCard(context, orders[index]);
              },
            ),
    );
  }

  List<MockOrder> _buildDummyOrders(UserProfileProvider profile) {
    final firstStatus = status == 'Tất cả' ? 'Đang giao' : status;
    final secondStatus = status == 'Tất cả' ? 'Chờ xác nhận' : status;

    return [
      MockOrder(
        orderId: 'DH100999',
        status: firstStatus,
        orderDate: '08:00 - 31/05/2026',
        customerName: profile.name.isEmpty ? 'Khách hàng' : profile.name,
        phone: profile.phone,
        address: profile.address.isEmpty
            ? 'Chưa cập nhật địa chỉ'
            : profile.address,
        shippingFee: 30000,
        totalAmount: 34030000,
        items: const [
          MockOrderItem(
            name: 'MacBook Pro 14 M3 512GB',
            imageUrl: 'assets/images/macbook_pro_14_m3_1.jpg',
            quantity: 1,
            price: 34000000,
          ),
        ],
      ),
      MockOrder(
        orderId: 'DH100888',
        status: secondStatus,
        orderDate: '15:20 - 29/05/2026',
        customerName: profile.name.isEmpty ? 'Khách hàng' : profile.name,
        phone: profile.phone,
        address: profile.address.isEmpty
            ? 'Chưa cập nhật địa chỉ'
            : profile.address,
        shippingFee: 15000,
        totalAmount: 515000,
        items: const [
          MockOrderItem(
            name: 'Lenovo IdeaCentre 3',
            imageUrl: 'assets/images/lenovo_ideacentre_3_1.jpg',
            quantity: 1,
            price: 500000,
          ),
        ],
      ),
    ];
  }

  Widget _buildOrderCard(BuildContext context, MockOrder order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderDetailScreen(order: order),
            ),
          );
        },
        child: Column(
          children: [
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
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProductImage(order.items.first.imageUrl, 70),
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
                  if (order.status == 'Đang giao')
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryThis,
                        foregroundColor: Colors.black,
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

  Widget _buildProductImage(String imageUrl, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        imageUrl,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.image_not_supported, color: Colors.grey);
        },
      ),
    );
  }

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
