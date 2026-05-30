import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_gioi_di_dong/core/app_colors.dart';
import 'package:the_gioi_di_dong/providers/cart_provider.dart';
import 'order_status_screen.dart';
import 'package:the_gioi_di_dong/core/utils.dart';
import 'package:the_gioi_di_dong/core/constants.dart';

class CheckoutScreen extends StatefulWidget {
  final double total;
  const CheckoutScreen({super.key, required this.total});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _paymentIndex = 0; // 0: COD, 1: Bank, 2: Installment

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F7),
      appBar: AppBar(
        title: Text("Thanh toán", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle("Thông tin nhận hàng"),
            _buildCard(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.green.withValues(alpha: 0.1),
                  child: Icon(Icons.person, color: Colors.green),
                ),
                title: Text(
                  "Hồ Gia Tiến - 0984449928",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text("Lê Thị Dung, Xã Vĩnh Lộc, TP. HCM"),
                trailing: Icon(Icons.edit, size: 18),
              ),
            ),

            _sectionTitle("Phương thức thanh toán"),
            _buildPaymentMethod(
              0,
              Icons.money,
              "Thanh toán khi nhận hàng (COD)",
            ),
            _buildPaymentMethod(
              1,
              Icons.account_balance,
              "Chuyển khoản / Quẹt thẻ",
            ),
            _buildPaymentMethod(2, Icons.access_time, "Mua trả góp 0%"),

            if (_paymentIndex == 2) _buildInstallmentDetail(),

            SizedBox(height: 20),
            _buildSummaryCard(),
          ],
        ),
      ),
      bottomNavigationBar: _buildStickyButton(),
    );
  }

  Widget _sectionTitle(String title) => Padding(
    padding: EdgeInsets.symmetric(vertical: 12),
    child: Text(
      title,
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    ),
  );

  Widget _buildCard({required Widget child}) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
      boxShadow: [
        BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10),
      ],
    ),
    child: child,
  );

  Widget _buildPaymentMethod(int index, IconData icon, String title) {
    bool isSelected = _paymentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _paymentIndex = index),
      child: Container(
        margin: EdgeInsets.only(bottom: 10),
        padding: EdgeInsets.all(AppConstants.defaultPadding),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
          border: Border.all(
            color: isSelected ? Colors.green : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? Colors.green : Colors.grey),
            SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            Spacer(),
            if (isSelected) Icon(Icons.check_circle, color: Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildInstallmentDetail() => Container(
    margin: EdgeInsets.only(top: 10),
    padding: EdgeInsets.all(AppConstants.defaultPadding),
    decoration: BoxDecoration(
      color: Colors.red.shade50,
      borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
    ),
    child: Text(
      "Ước tính trả góp: ${AppUtils.formatCurrency(widget.total * 1.05 / 6)}/tháng (trong 6 tháng)",
      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
    ),
  );

  Widget _buildSummaryCard() => _buildCard(
    child: Padding(
      padding: EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        children: [
          _priceRow("Tiền hàng", AppUtils.formatCurrency(widget.total)),
          _priceRow("Phí vận chuyển", "Miễn phí", color: Colors.green),
          Divider(height: 30),
          _priceRow(
            "TỔNG CỘNG",
            AppUtils.formatCurrency(widget.total),
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
    String val, {
    Color? color,
    bool isBold = false,
    double fontSize = 14,
  }) => Padding(
    padding: EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(
          val,
          style: TextStyle(
            color: color,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: fontSize,
          ),
        ),
      ],
    ),
  );

  Widget _buildStickyButton() => Container(
    padding: EdgeInsets.all(AppConstants.defaultPadding),
    color: Colors.white,
    child: ElevatedButton(
      onPressed: () {
        // 1. Chuyển hướng sang trang Trạng thái đơn hàng
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => OrderStatusScreen()),
        );
        // 2. Gọi lệnh Xóa sạch giỏ hàng vì đã mua xong
        Provider.of<CartProvider>(context, listen: false).clearCart();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryThis,
        minimumSize: Size(double.infinity, 55),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        ),
      ),
      child: Text(
        "ĐẶT HÀNG NGAY",
        style: TextStyle(
          color: const Color.fromARGB(255, 0, 0, 0),
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    ),
  );
}
