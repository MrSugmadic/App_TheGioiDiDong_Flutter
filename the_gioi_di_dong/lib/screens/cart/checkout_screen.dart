import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_gioi_di_dong/core/app_colors.dart';
import 'package:the_gioi_di_dong/core/constants.dart';
import 'package:the_gioi_di_dong/core/utils.dart';
import 'package:the_gioi_di_dong/models/order_model.dart';
import 'package:the_gioi_di_dong/providers/cart_provider.dart';
import 'package:the_gioi_di_dong/providers/user_profile_provider.dart';
import 'package:the_gioi_di_dong/services/api_service.dart';

import 'order_status_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final double total;
  final double discount;
  final double finalTotal;
  final String voucherCode;

  const CheckoutScreen({
    super.key,
    required this.total,
    this.discount = 0,
    double? finalTotal,
    this.voucherCode = '',
  }) : finalTotal = finalTotal ?? total;

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _noteController = TextEditingController();

  int _paymentIndex = 0;
  bool _isLoading = false;
  bool _syncedProfile = false;

  String get _paymentMethod {
    switch (_paymentIndex) {
      case 1:
        return 'BANKING_QR';
      case 2:
        return 'TRA_GOP';
      default:
        return 'COD';
    }
  }

  String get _paymentTitle {
    switch (_paymentIndex) {
      case 1:
        return 'Chuyển khoản QR';
      case 2:
        return 'Mua trả góp';
      default:
        return 'Thanh toán khi nhận hàng';
    }
  }

  String get _qrUrl {
    final amount = widget.finalTotal.round();
    final info = Uri.encodeComponent('TGDD THANH TOAN DON HANG');
    final accountName = Uri.encodeComponent('THE GIOI DI DONG');
    return 'https://img.vietqr.io/image/MB-0123456789-compact2.png?amount=$amount&addInfo=$info&accountName=$accountName';
  }

  @override
  void initState() {
    super.initState();
    _nameController.text = context.read<UserProfileProvider>().name;
    _phoneController.text = context.read<UserProfileProvider>().phone;
    _addressController.text = context.read<UserProfileProvider>().address;
    _noteController.text = context.read<UserProfileProvider>().note;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;

    final profile = context.read<UserProfileProvider>();
    if (profile.maTk.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng đăng nhập trước khi thanh toán'),
        ),
      );
      return;
    }

    final cart = context.read<CartProvider>();
    if (cart.items.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Giỏ hàng đang trống.')));
      return;
    }

    setState(() => _isLoading = true);

    await profile.saveReceiver(
      name: _nameController.text,
      phone: _phoneController.text,
      address: _addressController.text,
      note: _noteController.text,
    );

    final items = cart.items.values.map((item) {
      return OrderItemModel(
        maSp: item.id,
        tenSp: item.name,
        donGia: item.price,
        soLuong: item.quantity,
        thanhTien: item.price * item.quantity,
      );
    }).toList();

    final order = await ApiService.createOrder(
      maTk: profile.maTk,
      hoTen: _nameController.text.trim(),
      soDienThoai: _phoneController.text.trim(),
      diaChi: _addressController.text.trim(),
      phuongThucThanhToan: _paymentMethod,
      maGiamGia: widget.voucherCode,
      tongTien: widget.total,
      giamGia: widget.discount,
      thanhTien: widget.finalTotal,
      items: items,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (order == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể tạo đơn hàng. Kiểm tra API.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    cart.clearCart();
    await ApiService.clearCartOnServer(profile.maTk);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => OrderStatusScreen(order: order)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<UserProfileProvider>();
    if (!_syncedProfile && profile.isLoaded) {
      _syncedProfile = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _nameController.text = profile.name;
        _phoneController.text = profile.phone;
        _addressController.text = profile.address;
        _noteController.text = profile.note;
      });
    }

    return Scaffold(
      backgroundColor:
          Colors.grey[100], // Nền xám nhạt để nổi bật các Card trắng
      appBar: AppBar(
        title: const Text(
          'Xác nhận đơn hàng',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: AppColors.primaryThis,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle(Icons.location_on, 'Thông tin nhận hàng'),
              _buildShippingCard(profile),

              _sectionTitle(Icons.payment, 'Phương thức thanh toán'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _buildPaymentMethod(
                      0,
                      Icons.local_atm,
                      'Thanh toán tiền mặt (COD)',
                      'Thanh toán khi nhận sản phẩm',
                    ),
                    _buildPaymentMethod(
                      1,
                      Icons.qr_code_2,
                      'Chuyển khoản QR',
                      'Mở app ngân hàng quét mã nhanh',
                    ),
                    _buildPaymentMethod(
                      2,
                      Icons.credit_score,
                      'Mua trả góp',
                      'Duyệt hồ sơ nhanh chóng',
                    ),
                  ],
                ),
              ),
              if (_paymentIndex == 1) _buildQrPaymentCard(),
              if (_paymentIndex == 2) _buildInstallmentDetail(),

              _sectionTitle(Icons.shopping_bag_outlined, 'Chi tiết sản phẩm'),
              _buildOrderItems(),

              const SizedBox(height: 12),
              _buildSummaryCard(),
              const SizedBox(height: 30), // Khoảng trống dưới cùng
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildStickyBottomBar(),
    );
  }

  // Tiêu đề của từng khu vực
  Widget _sectionTitle(IconData icon, String title) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
    child: Row(
      children: [
        Icon(icon, size: 20, color: Colors.black87),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    ),
  );

  // Khung chứa nội dung (Card)
  Widget _buildCard({required Widget child}) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 16),
    width: double.infinity,
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
    child: child,
  );

  // Thẻ Thông tin giao hàng
  Widget _buildShippingCard(UserProfileProvider profile) {
    return _buildCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (profile.email.isNotEmpty)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryThis.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.account_circle,
                      color: AppColors.primaryThis,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Tài khoản: ${profile.email}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryThis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            _inputField(
              controller: _nameController,
              label: 'Họ tên người nhận',
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Vui lòng nhập họ tên'
                  : null,
            ),
            const SizedBox(height: 12),
            _inputField(
              controller: _phoneController,
              label: 'Số điện thoại',
              keyboardType: TextInputType.phone,
              validator: (value) {
                final phone = value?.trim() ?? '';
                if (phone.isEmpty) return 'Vui lòng nhập SĐT';
                if (!RegExp(r'^(0|\+84)[0-9]{9,10}$').hasMatch(phone))
                  return 'SĐT không hợp lệ';
                return null;
              },
            ),
            const SizedBox(height: 12),
            _inputField(
              controller: _addressController,
              label: 'Địa chỉ nhận hàng cụ thể',
              maxLines: 2,
              validator: (value) => value == null || value.trim().length < 8
                  ? 'Vui lòng nhập địa chỉ cụ thể'
                  : null,
            ),
            const SizedBox(height: 12),
            _inputField(
              controller: _noteController,
              label: 'Ghi chú (Không bắt buộc)',
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  // Cấu hình ô nhập liệu mượt mà
  Widget _inputField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.primaryThis,
            width: 1.5,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  // Thẻ chọn Phương thức thanh toán
  Widget _buildPaymentMethod(
    int index,
    IconData icon,
    String title,
    String subtitle,
  ) {
    final isSelected = _paymentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _paymentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryThis.withOpacity(0.05)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primaryThis : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 8,
                  ),
                ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primaryThis : Colors.grey[500],
              size: 28,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected ? AppColors.primaryThis : Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  // Mã QR Ngân hàng
  Widget _buildQrPaymentCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryThis.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const Text(
            'Quét mã QR để thanh toán',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 8),
          Text(
            AppUtils.formatCurrency(widget.finalTotal),
            style: const TextStyle(
              color: AppColors.priceRed,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              _qrUrl,
              width: 200,
              height: 200,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                width: 200,
                height: 200,
                color: Colors.grey[100],
                child: const Center(child: Text('Không tải được mã QR')),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Trả góp
  Widget _buildInstallmentDetail() {
    final monthly = widget.finalTotal * 1.05 / 6;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.orange, size: 18),
              SizedBox(width: 6),
              Text(
                'Ước tính trả góp',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${AppUtils.formatCurrency(monthly)}/tháng trong 6 tháng',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 6),
          Text(
            'Nhân viên sẽ liên hệ để xác nhận hồ sơ (Cần CCCD/CMND).',
            style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // Danh sách sản phẩm mua
  Widget _buildOrderItems() {
    final items = context.watch<CartProvider>().items.values.toList();
    return _buildCard(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const Divider(height: 24),
        itemBuilder: (context, index) {
          final item = items[index];
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  '${item.name}  x${item.quantity}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                AppUtils.formatCurrency(item.price * item.quantity),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          );
        },
      ),
    );
  }

  // Bảng tính tiền
  Widget _buildSummaryCard() => _buildCard(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _priceRow('Tổng tiền hàng', AppUtils.formatCurrency(widget.total)),
          _priceRow('Phí vận chuyển', 'Miễn phí', color: Colors.green),
          if (widget.discount > 0)
            _priceRow(
              'Voucher giảm giá',
              '-${AppUtils.formatCurrency(widget.discount)}',
              color: Colors.green,
            ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(height: 1),
          ),
          _priceRow(
            'TỔNG THANH TOÁN',
            AppUtils.formatCurrency(widget.finalTotal),
            color: AppColors.priceRed,
            isBold: true,
            fontSize: 18,
          ),
        ],
      ),
    ),
  );

  Widget _priceRow(
    String label,
    String value, {
    Color? color,
    bool isBold = false,
    double fontSize = 14,
  }) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isBold ? Colors.black87 : Colors.grey[600],
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: isBold ? 14 : 13,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color ?? Colors.black87,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            fontSize: fontSize,
          ),
        ),
      ],
    ),
  );

  // Thanh Nút bấm ở dưới cùng (Sticky Bottom Bar)
  Widget _buildStickyBottomBar() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, -5),
        ),
      ],
    ),
    child: SafeArea(
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tổng thanh toán',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  AppUtils.formatCurrency(widget.finalTotal),
                  style: const TextStyle(
                    fontSize: 20,
                    color: AppColors.priceRed,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: _isLoading ? null : _placeOrder,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryThis,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'ĐẶT HÀNG NGAY',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
          ),
        ],
      ),
    ),
  );
}
