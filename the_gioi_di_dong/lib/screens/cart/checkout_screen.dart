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
        const SnackBar(content: Text('Vui lòng đăng nhập trước khi thanh toán')),
      );
      return;
    }

    final cart = context.read<CartProvider>();
    if (cart.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Giỏ hàng đang trống.')),
      );
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
        const SnackBar(content: Text('Không thể tạo đơn hàng. Kiểm tra API.')),
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
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        title: const Text(
          'Thanh toán',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle('Thông tin nhận hàng'),
              _buildShippingCard(profile),
              _sectionTitle('Phương thức thanh toán'),
              _buildPaymentMethod(
                0,
                Icons.payments_outlined,
                'Thanh toán khi nhận hàng (COD)',
                'Thanh toán tiền mặt khi nhận sản phẩm',
              ),
              _buildPaymentMethod(
                1,
                Icons.qr_code_2_outlined,
                'Chuyển khoản QR',
                'Quét mã QR ngân hàng để thanh toán nhanh',
              ),
              _buildPaymentMethod(
                2,
                Icons.credit_score_outlined,
                'Mua trả góp',
                'Nhân viên sẽ liên hệ xác nhận hồ sơ',
              ),
              if (_paymentIndex == 1) _buildQrPaymentCard(),
              if (_paymentIndex == 2) _buildInstallmentDetail(),
              const SizedBox(height: 16),
              _buildOrderItems(),
              const SizedBox(height: 16),
              _buildSummaryCard(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildStickyButton(),
    );
  }

  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    ),
  );

  Widget _buildCard({required Widget child}) => Container(
    width: double.infinity,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
      boxShadow: [
        BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10),
      ],
    ),
    child: child,
  );

  Widget _buildShippingCard(UserProfileProvider profile) {
    return _buildCard(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            if (profile.email.isNotEmpty)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Tài khoản đang thanh toán: ${profile.email}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            _inputField(
              controller: _nameController,
              label: 'Họ tên người nhận',
              icon: Icons.person_outline,
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Vui lòng nhập họ tên'
                  : null,
            ),
            const SizedBox(height: 10),
            _inputField(
              controller: _phoneController,
              label: 'Số điện thoại',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: (value) {
                final phone = value?.trim() ?? '';
                if (phone.isEmpty) return 'Vui lòng nhập số điện thoại';
                if (!RegExp(r'^(0|\+84)[0-9]{9,10}$').hasMatch(phone)) {
                  return 'Số điện thoại không hợp lệ';
                }
                return null;
              },
            ),
            const SizedBox(height: 10),
            _inputField(
              controller: _addressController,
              label: 'Địa chỉ giao hàng',
              icon: Icons.location_on_outlined,
              maxLines: 2,
              validator: (value) => value == null || value.trim().length < 8
                  ? 'Vui lòng nhập địa chỉ cụ thể'
                  : null,
            ),
            const SizedBox(height: 10),
            _inputField(
              controller: _noteController,
              label: 'Ghi chú cho đơn hàng (không bắt buộc)',
              icon: Icons.note_alt_outlined,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
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
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildPaymentMethod(
    int index,
    IconData icon,
    String title,
    String subtitle,
  ) {
    final isSelected = _paymentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _paymentIndex = index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
          border: Border.all(
            color: isSelected ? AppColors.primaryThis : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? Colors.green : Colors.grey),
            const SizedBox(width: 12),
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
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
            ),
            if (isSelected) const Icon(Icons.check_circle, color: Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildQrPaymentCard() {
    return _buildCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Quét QR để thanh toán',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Số tiền: ${AppUtils.formatCurrency(widget.finalTotal)}',
              style: const TextStyle(
                color: AppColors.priceRed,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.network(
                _qrUrl,
                width: 220,
                height: 220,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) {
                  return Container(
                    width: 220,
                    height: 220,
                    alignment: Alignment.center,
                    color: Colors.grey.shade100,
                    child: const Text('Không tải được QR'),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Ngân hàng: MB Bank\nSố tài khoản: 0123456789\nChủ tài khoản: THE GIOI DI DONG',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstallmentDetail() {
    final monthly = widget.finalTotal * 1.05 / 6;
    return Container(
      margin: const EdgeInsets.only(top: 4, bottom: 10),
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ước tính trả góp',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text('${AppUtils.formatCurrency(monthly)}/tháng trong 6 tháng'),
          const SizedBox(height: 4),
          Text(
            'Cần CCCD/CMND và số điện thoại chính chủ. Nhân viên sẽ liên hệ xác nhận hồ sơ.',
            style: TextStyle(color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItems() {
    final items = context.watch<CartProvider>().items.values.toList();
    return _buildCard(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sản phẩm trong đơn hàng',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${item.name} x${item.quantity}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      AppUtils.formatCurrency(item.price * item.quantity),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() => _buildCard(
    child: Padding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        children: [
          _priceRow('Tiền hàng', AppUtils.formatCurrency(widget.total)),
          _priceRow('Phí vận chuyển', 'Miễn phí', color: Colors.green),
          if (widget.discount > 0)
            _priceRow(
              'Giảm giá',
              '-${AppUtils.formatCurrency(widget.discount)}',
              color: Colors.green,
            ),
          _priceRow('Thanh toán', _paymentTitle),
          const Divider(height: 26),
          _priceRow(
            'TỔNG CỘNG',
            AppUtils.formatCurrency(widget.finalTotal),
            color: Colors.red,
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
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: color,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: fontSize,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildStickyButton() => Container(
    padding: const EdgeInsets.all(AppConstants.defaultPadding),
    color: Colors.white,
    child: SafeArea(
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _placeOrder,
        icon: _isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.black,
                ),
              )
            : const Icon(Icons.verified_outlined),
        label: Text(
          _paymentIndex == 1 ? 'XÁC NHẬN ĐÃ THANH TOÁN' : 'ĐẶT HÀNG NGAY',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryThis,
          minimumSize: const Size(double.infinity, 55),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
          ),
        ),
      ),
    ),
  );
}
