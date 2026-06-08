import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_gioi_di_dong/core/app_colors.dart';
import 'package:the_gioi_di_dong/core/utils.dart';
import 'package:the_gioi_di_dong/providers/cart_provider.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final TextEditingController _voucherController = TextEditingController();
  String _appliedVoucher = '';
  String _voucherMessage = '';
  double _discount = 0;

  @override
  void dispose() {
    _voucherController.dispose();
    super.dispose();
  }

  double _calculateDiscount(String code, double total) {
    final voucher = code.trim().toUpperCase();
    if (voucher == 'TGDD10') return total * 0.1;
    if (voucher == 'SALE50K') return total >= 1000000 ? 50000 : 0;
    if (voucher == 'LAPTOP500') return total >= 10000000 ? 500000 : 0;
    if (voucher == 'FREESHIP') return 30000;
    return 0;
  }

  void _applyVoucher(double total) {
    final code = _voucherController.text.trim().toUpperCase();
    if (code.isEmpty) {
      setState(() {
        _appliedVoucher = '';
        _discount = 0;
        _voucherMessage = 'Vui lòng nhập mã giảm giá.';
      });
      return;
    }

    final discount = _calculateDiscount(code, total);
    setState(() {
      if (discount > 0) {
        _appliedVoucher = code;
        _discount = discount > total ? total : discount;
        _voucherMessage = 'Áp dụng mã $code thành công.';
      } else {
        _appliedVoucher = '';
        _discount = 0;
        _voucherMessage = 'Mã không hợp lệ hoặc chưa đủ điều kiện.';
      }
    });
  }

  Widget _productImage(String imageUrl) {
    final image = imageUrl.trim();
    final isNetwork =
        image.startsWith('http://') || image.startsWith('https://');
    final path = image.startsWith('assets/') ? image : 'assets/images/$image';

    if (isNetwork) {
      return Image.network(
        image,
        width: 78,
        height: 78,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _fallbackImage(),
      );
    }

    return Image.asset(
      path,
      width: 78,
      height: 78,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => _fallbackImage(),
    );
  }

  Widget _fallbackImage() {
    return Container(
      width: 78,
      height: 78,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.laptop_mac, size: 42, color: Colors.grey),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final items = cart.items.values.toList();
    final subtotal = cart.totalPrice;
    final finalTotal = (subtotal - _discount).clamp(0, subtotal).toDouble();

    if (_discount > subtotal && subtotal > 0) {
      _discount = subtotal;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        title: Text(
          'Giỏ hàng (${cart.itemCount})',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          if (items.isNotEmpty)
            IconButton(
              tooltip: 'Xóa giỏ hàng',
              onPressed: () {
                cart.clearCart();
                setState(() {
                  _appliedVoucher = '';
                  _voucherController.clear();
                  _discount = 0;
                  _voucherMessage = '';
                });
              },
              icon: const Icon(Icons.delete_outline),
            ),
        ],
      ),
      body: items.isEmpty
          ? _buildEmptyCart(context)
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return Dismissible(
                        key: ValueKey(item.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: Colors.red.shade400,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) => cart.removeItem(item.id),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: _productImage(item.imageUrl),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      AppUtils.formatCurrency(item.price),
                                      style: const TextStyle(
                                        color: AppColors.priceRed,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        _qtyButton(
                                          icon: Icons.remove,
                                          onTap: () =>
                                              cart.decreaseItem(item.id),
                                        ),
                                        Container(
                                          width: 42,
                                          alignment: Alignment.center,
                                          child: Text(
                                            '${item.quantity}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        _qtyButton(
                                          icon: Icons.add,
                                          onTap: () => cart.addItem(
                                            item.id,
                                            item.name,
                                            item.price,
                                            item.imageUrl,
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          AppUtils.formatCurrency(
                                            item.price * item.quantity,
                                          ),
                                          style: const TextStyle(
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
                      );
                    },
                  ),
                ),
                _buildBottomSummary(context, subtotal, finalTotal),
              ],
            ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 90,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            const Text(
              'Giỏ hàng của bạn đang trống',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Hãy chọn máy tính, laptop hoặc phụ kiện phù hợp rồi quay lại thanh toán nhé.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.storefront),
              label: const Text('Tiếp tục mua sắm'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryThis,
                foregroundColor: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _qtyButton({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Icon(icon, size: 18),
      ),
    );
  }

  Widget _buildBottomSummary(
    BuildContext context,
    double subtotal,
    double finalTotal,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _voucherController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      hintText: 'Nhập mã: TGDD10, SALE50K, LAPTOP500',
                      prefixIcon: const Icon(Icons.local_offer_outlined),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _applyVoucher(subtotal),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryThis,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 15,
                    ),
                  ),
                  child: const Text('Áp dụng'),
                ),
              ],
            ),
            if (_voucherMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _voucherMessage,
                    style: TextStyle(
                      color: _discount > 0 ? Colors.green : Colors.red,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 12),
            _priceRow('Tạm tính', AppUtils.formatCurrency(subtotal)),
            _priceRow(
              'Giảm giá${_appliedVoucher.isNotEmpty ? ' ($_appliedVoucher)' : ''}',
              '-${AppUtils.formatCurrency(_discount)}',
              color: Colors.green,
            ),
            const Divider(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Thành tiền',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  AppUtils.formatCurrency(finalTotal),
                  style: const TextStyle(
                    color: AppColors.priceRed,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CheckoutScreen(
                        total: subtotal,
                        discount: _discount,
                        voucherCode: _appliedVoucher,
                        finalTotal: finalTotal,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryThis,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'THANH TOÁN',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _priceRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
