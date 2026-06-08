import 'package:flutter/material.dart';
import 'package:the_gioi_di_dong/core/app_colors.dart';
import 'package:the_gioi_di_dong/core/utils.dart';
import 'package:the_gioi_di_dong/models/order_model.dart';
import 'package:the_gioi_di_dong/services/api_service.dart';

class OrderStatusScreen extends StatefulWidget {
  final OrderModel? order;
  final String? orderId;

  const OrderStatusScreen({super.key, this.order, this.orderId});

  @override
  State<OrderStatusScreen> createState() => _OrderStatusScreenState();
}

class _OrderStatusScreenState extends State<OrderStatusScreen> {
  OrderModel? _order;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _order = widget.order;
    if (_order == null && widget.orderId != null) {
      _loadOrder();
    }
  }

  Future<void> _loadOrder() async {
    setState(() => _isLoading = true);
    final order = await ApiService.getOrderDetail(widget.orderId!);
    if (!mounted) return;
    setState(() {
      _order = order;
      _isLoading = false;
    });
  }

  int _statusIndex(String status) {
    final lower = status.toLowerCase();
    if (lower.contains('đã giao') ||
        lower.contains('hoàn thành') ||
        lower.contains('thành công'))
      return 3;
    if (lower.contains('giao')) return 2;
    if (lower.contains('xử lý') ||
        lower.contains('xác nhận') ||
        lower.contains('đã đặt'))
      return 1;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final order = _order;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        title: const Text(
          'Trạng thái đơn hàng',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primaryThis,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : order == null
          ? _buildNotFound()
          : _buildOrderBody(order),
    );
  }

  Widget _buildNotFound() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 12),
            const Text(
              'Không tìm thấy đơn hàng',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  Navigator.popUntil(context, (route) => route.isFirst),
              child: const Text('Về trang chủ'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderBody(OrderModel order) {
    final currentStep = _statusIndex(order.trangThai);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _headerCard(order),
          const SizedBox(height: 16),
          _statusCard(currentStep, order.trangThai),
          const SizedBox(height: 16),
          _itemsCard(order),
          const SizedBox(height: 16),
          _paymentCard(order),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryThis,
                foregroundColor: Colors.black,
              ),
              onPressed: () =>
                  Navigator.popUntil(context, (route) => route.isFirst),
              icon: const Icon(Icons.home_outlined),
              label: const Text(
                'VỀ TRANG CHỦ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerCard(OrderModel order) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.check_circle, color: Colors.green),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Đặt hàng thành công',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Mã đơn: ${order.maHd}',
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          _infoRow('Người nhận', order.hoTen ?? 'Đang cập nhật'),
          _infoRow('Số điện thoại', order.soDienThoai ?? 'Đang cập nhật'),
          _infoRow('Địa chỉ', order.diaChi ?? 'Đang cập nhật'),
        ],
      ),
    );
  }

  Widget _statusCard(int currentStep, String currentStatus) {
    final steps = [
      'Đặt hàng thành công',
      'Đang xác nhận',
      'Đang giao hàng',
      'Đã giao hàng',
    ];

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Theo dõi vận chuyển',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          ...List.generate(steps.length, (index) {
            final done = index <= currentStep;
            final isLast = index == steps.length - 1;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Icon(
                      done ? Icons.check_circle : Icons.radio_button_unchecked,
                      color: done ? Colors.green : Colors.grey,
                      size: 24,
                    ),
                    if (!isLast)
                      Container(
                        width: 2,
                        height: 32,
                        color: done ? Colors.green : Colors.grey.shade300,
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      steps[index],
                      style: TextStyle(
                        color: done ? Colors.black : Colors.grey,
                        fontWeight: done ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
          const SizedBox(height: 8),
          Text(
            'Trạng thái hiện tại: $currentStatus',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _itemsCard(OrderModel order) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sản phẩm đã đặt',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 10),
          if (order.items.isEmpty)
            Text(
              'Chi tiết sản phẩm sẽ được cập nhật từ hệ thống.',
              style: TextStyle(color: Colors.grey.shade600),
            )
          else
            ...order.items.map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Expanded(child: Text('${item.tenSp} x${item.soLuong}')),
                    Text(
                      AppUtils.formatCurrency(
                        item.thanhTien > 0
                            ? item.thanhTien
                            : item.donGia * item.soLuong,
                      ),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _paymentCard(OrderModel order) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thanh toán',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 10),
          _infoRow('Phương thức', _paymentText(order.phuongThucThanhToan)),
          _infoRow('Tạm tính', AppUtils.formatCurrency(order.tongTien)),
          _infoRow('Giảm giá', '-${AppUtils.formatCurrency(order.giamGia)}'),
          const Divider(height: 22),
          _infoRow(
            'Tổng thanh toán',
            AppUtils.formatCurrency(order.thanhTien),
            highlight: true,
          ),
        ],
      ),
    );
  }

  String _paymentText(String? value) {
    switch (value) {
      case 'BANKING_QR':
        return 'Chuyển khoản QR';
      case 'TRA_GOP':
        return 'Mua trả góp';
      case 'COD':
      default:
        return 'Thanh toán khi nhận hàng';
    }
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _infoRow(String label, String value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: TextStyle(color: Colors.grey.shade700)),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: highlight ? AppColors.priceRed : Colors.black,
                fontWeight: highlight ? FontWeight.bold : FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
