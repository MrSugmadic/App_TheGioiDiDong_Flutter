import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_gioi_di_dong/screens/auth/register_screen.dart';
import 'package:the_gioi_di_dong/screens/main/main_screen.dart';
import 'package:the_gioi_di_dong/core/app_colors.dart';
import 'package:the_gioi_di_dong/core/constants.dart';
import 'package:the_gioi_di_dong/screens/order/order_detail_screen.dart';
import 'package:the_gioi_di_dong/screens/order/order_list_screen.dart';

// -------------------------------------------------------------

class ProfileScreen extends StatefulWidget {
  final String userEmail; // NHẬN TỪ NGOÀI VÀO

  const ProfileScreen({super.key, required this.userEmail});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoggedIn = false;
  bool _isLoading = true; // Tránh flicker khi đọc SharedPreferences
  String _userEmail = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Đọc trạng thái đăng nhập thật từ SharedPreferences
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      _userEmail = prefs.getString('userEmail') ?? '';
      _isLoading = false;
    });
  }

  // Xóa SharedPreferences rồi về MainScreen (tab Cá nhân sẽ tự hiện LoginScreen)
  Future<void> _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await prefs.remove('userEmail');
    await prefs.remove('maTk');
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen(initialIndex: 3)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F1F1),
      appBar: AppBar(
        title: const Text("Trang cá nhân"),
        backgroundColor: AppColors.primaryThis,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _isLoggedIn
          ? _buildLoggedInBody()
          : _buildGuestBody(),
    );
  }

  // --- TRƯỜNG HỢP 1: GIAO DIỆN CHƯA ĐĂNG NHẬP (GUEST) ---
  Widget _buildGuestBody() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.account_circle, size: 100, color: Colors.grey),
            const SizedBox(height: 20),
            const Text(
              "Chào bạn, vui lòng đăng nhập để hưởng ưu đãi riêng biệt",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegisterScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryThis,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppConstants.defaultRadius,
                    ),
                  ),
                ),
                child: const Text(
                  "ĐĂNG NHẬP / ĐĂNG KÝ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 15),
            _buildSettingItem(Icons.shield_outlined, "Chính sách bảo hành"),
            _buildSettingItem(
              Icons.document_scanner_outlined,
              "Điều khoản sử dụng",
            ),
          ],
        ),
      ),
    );
  }

  // --- TRƯỜNG HỢP 2: GIAO DIỆN ĐÃ ĐĂNG NHẬP (USER) ---

  // ĐÃ SỬA: Thêm onTap vào hàm này để cho phép bấm
  Widget _buildOrderStatusItem(
    IconData icon,
    String label, {
    int badgeCount = 0,
    VoidCallback? onTap, // <--- Thêm tham số này
  }) {
    // Bao bọc bởi InkWell để tạo hiệu ứng bấm và nhận sự kiện
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(icon, color: Colors.black87, size: 28),
                if (badgeCount > 0)
                  Positioned(
                    right: -5,
                    top: -5,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '$badgeCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoggedInBody() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header thông tin User
          Container(
            color: AppColors.primaryThis,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 50),
                ),
                const SizedBox(height: 10),
                Text(
                  _userEmail.isNotEmpty ? _userEmail : "Người dùng",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 5),
                TextButton(
                  onPressed: _handleLogout,
                  child: const Text(
                    "Thoát tài khoản",
                    style: TextStyle(color: Colors.black54, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),

          // Khối đơn hàng
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Đơn hàng của tôi",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildOrderStatusItem(
                      Icons.query_builder,
                      "Chờ xác nhận",
                      badgeCount: 3,
                      // ĐÃ SỬA: Chèn sự kiện chuyển trang vào Icon Chờ Xác Nhận
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OrderDetailScreen(
                              order: MockOrder(
                                orderId: 'DH100234',
                                status: 'Chờ xác nhận',
                                orderDate: '20:30 - 30/05/2026',
                                customerName: 'Anh Long',
                                phone: '0987654321',
                                address:
                                    '123 Đường Điện Biên Phủ, Phường 25, Quận Bình Thạnh, TP.HCM',
                                shippingFee: 30000,
                                totalAmount: 28030000,
                                items: [
                                  MockOrderItem(
                                    name: 'MacBook Pro M2 2022',
                                    imageUrl: 'assets/images/laptop.png',
                                    quantity: 1,
                                    price: 28000000,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    _buildOrderStatusItem(
                      Icons.local_shipping_outlined,
                      "Đang giao",
                      badgeCount: 2,
                      // Thêm sự kiện chuyển trang vào đây:
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const OrderListScreen(status: 'Đang giao'),
                          ),
                        );
                      },
                    ),
                    _buildOrderStatusItem(
                      Icons.inbox_outlined,
                      "Đã hoàn tất",
                      badgeCount: 1,
                    ),
                    _buildOrderStatusItem(Icons.sync, "Đổi trả"),
                    _buildOrderStatusItem(Icons.star_outline, "Đánh giá"),
                  ],
                ),
              ],
            ),
          ),

          _buildOrderCard(),
          _buildSettingsList(),
        ],
      ),
    );
  }

  Widget _buildOrderCard() {
    return Container(/* Code khối đơn hàng của bạn ở đây */);
  }

  Widget _buildSettingsList() {
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
      ),
      child: Column(
        children: [
          _buildSettingItem(Icons.favorite_outline, "Sản phẩm yêu thích"),
          _buildSettingItem(Icons.map_outlined, "Địa chỉ nhận hàng"),
          _buildSettingItem(
            Icons.exit_to_app,
            "Đăng xuất",
            textColor: Colors.red,
            iconColor: Colors.red,
            onTap: _handleLogout,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(
    IconData icon,
    String label, {
    Color textColor = Colors.black87,
    Color iconColor = Colors.grey,
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: iconColor),
      title: Text(label, style: TextStyle(color: textColor, fontSize: 14)),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      ),
    );
  }
}
