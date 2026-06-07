import 'package:flutter/material.dart';

class PromotionScreen extends StatelessWidget {
  const PromotionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Khuyến mãi & Voucher',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(
          0xFF1DD782,
        ), // Thay bằng màu xanh của app ông
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. BANNER QUẢNG CÁO ĐỈNH TRANG ---
            Container(
              width: double.infinity,
              height: 160,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: [Color(0xFF1DD782), Color(0xFF00BFA5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '🔥 SIÊU SALE CÔNG NGHỆ 🔥',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Giảm trực tiếp đến 50%',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),

            // --- 2. TIÊU ĐỀ DANH SÁCH VOUCHER ---
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                'Mã giảm giá dành cho bạn',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            // --- 3. DANH SÁCH CÁC THẺ VOUCHER ---
            _buildVoucherCard(
              title: 'Miễn phí vận chuyển',
              subtitle: 'Áp dụng cho đơn hàng từ 0đ',
              date: 'HSD: 30/06/2026',
              icon: Icons.local_shipping,
              color: Colors.blue,
            ),
            _buildVoucherCard(
              title: 'Giảm 500.000 đ',
              subtitle: 'Áp dụng khi mua Laptop Gaming',
              date: 'HSD: 15/07/2026',
              icon: Icons.laptop_mac,
              color: Colors.redAccent,
            ),
            _buildVoucherCard(
              title: 'Giảm 10%',
              subtitle: 'Tối đa 100k cho phụ kiện',
              date: 'HSD: 31/12/2026',
              icon: Icons.headphones,
              color: Colors.orange,
            ),

            const SizedBox(height: 20), // Khoảng trống dưới cùng cho thoáng
          ],
        ),
      ),
    );
  }

  // --- HÀM VẼ GIAO DIỆN TỪNG CÁI VOUCHER ---
  Widget _buildVoucherCard({
    required String title,
    required String subtitle,
    required String date,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon đặc trưng bên trái
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(width: 16),

          // Thông tin Text ở giữa
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 6),
                Text(
                  date,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                ),
              ],
            ),
          ),

          // Nút "Lưu" bên phải
          ElevatedButton(
            onPressed: () {
              // Thêm logic lưu voucher hoặc copy mã ở đây
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }
}
