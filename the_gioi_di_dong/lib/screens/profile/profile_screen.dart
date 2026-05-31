import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_gioi_di_dong/core/app_colors.dart';
import 'package:the_gioi_di_dong/core/constants.dart';
import 'package:the_gioi_di_dong/screens/admin/admin_management_screen.dart';
import 'package:the_gioi_di_dong/screens/auth/register_screen.dart';
import 'package:the_gioi_di_dong/screens/main/main_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String userEmail;

  const ProfileScreen({super.key, required this.userEmail});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoggedIn = false;
  bool _isLoading = true;
  String _userEmail = '';
  String _userRole = 'KhachHang';

  bool get _isAdmin => _userRole.toLowerCase() == 'admin';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    setState(() {
      _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      _userEmail = prefs.getString('userEmail') ?? widget.userEmail;
      _userRole = prefs.getString('userRole') ?? 'KhachHang';
      _isLoading = false;
    });
  }

  Future<void> _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await prefs.remove('userEmail');
    await prefs.remove('userRole');
    await prefs.remove('maTk');
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen(initialIndex: 3)),
      );
    }
  }

  void _openAdminManagement(String title, IconData icon) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminManagementScreen(title: title, icon: icon),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F1F1),
      appBar: AppBar(
        title: const Text('Trang cá nhân'),
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
              'Chào bạn, vui lòng đăng nhập để hưởng ưu đãi riêng biệt',
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
                  'ĐĂNG NHẬP / ĐĂNG KÝ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 15),
            _buildSettingItem(Icons.shield_outlined, 'Chính sách bảo hành'),
            _buildSettingItem(
              Icons.document_scanner_outlined,
              'Điều khoản sử dụng',
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
          _buildProfileHeader(),
          if (_isAdmin) _buildAdminManagementList(),
          if (!_isAdmin) _buildOrderStatusCard(),
          _buildOrderCard(),
          _buildSettingsList(),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      color: AppColors.primaryThis,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white,
            child: Icon(
              _isAdmin ? Icons.admin_panel_settings : Icons.person,
              size: 50,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _userEmail.isNotEmpty ? _userEmail : 'Người dùng',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _isAdmin ? 'Admin' : 'Khách hàng',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 5),
          TextButton(
            onPressed: _handleLogout,
            child: const Text(
              'Thoát tài khoản',
              style: TextStyle(color: Colors.black54, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminManagementList() {
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 14, 16, 6),
            child: Text(
              'Quản lý admin',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          _buildSettingItem(
            Icons.inventory_2_outlined,
            'Quản lý sản phẩm',
            onTap: () => _openAdminManagement(
              'Quản lý sản phẩm',
              Icons.inventory_2_outlined,
            ),
          ),
          _buildSettingItem(
            Icons.category_outlined,
            'Quản lý danh mục',
            onTap: () => _openAdminManagement(
              'Quản lý danh mục',
              Icons.category_outlined,
            ),
          ),
          _buildSettingItem(
            Icons.receipt_long_outlined,
            'Quản lý đơn hàng',
            onTap: () => _openAdminManagement(
              'Quản lý đơn hàng',
              Icons.receipt_long_outlined,
            ),
          ),
          _buildSettingItem(
            Icons.people_outline,
            'Quản lý người dùng',
            onTap: () => _openAdminManagement(
              'Quản lý người dùng',
              Icons.people_outline,
            ),
          ),
          _buildSettingItem(
            Icons.notifications_active_outlined,
            'Quản lý thông báo',
            onTap: () => _openAdminManagement(
              'Quản lý thông báo',
              Icons.notifications_active_outlined,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderStatusCard() {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Đơn hàng của tôi',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildOrderStatusItem(
                Icons.query_builder,
                'Chờ xác nhận',
                badgeCount: 3,
              ),
              _buildOrderStatusItem(
                Icons.local_shipping_outlined,
                'Đang giao',
                badgeCount: 2,
              ),
              _buildOrderStatusItem(
                Icons.inbox_outlined,
                'Đã hoàn tất',
                badgeCount: 1,
              ),
              _buildOrderStatusItem(Icons.sync, 'Đổi trả'),
              _buildOrderStatusItem(Icons.star_outline, 'Đánh giá'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderStatusItem(
    IconData icon,
    String label, {
    int badgeCount = 0,
  }) {
    return Column(
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
    );
  }

  Widget _buildOrderCard() {
    return const SizedBox.shrink();
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
          if (!_isAdmin) ...[
            _buildSettingItem(Icons.favorite_outline, 'Sản phẩm yêu thích'),
            _buildSettingItem(Icons.map_outlined, 'Địa chỉ nhận hàng'),
          ],
          _buildSettingItem(
            Icons.exit_to_app,
            'Đăng xuất',
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
