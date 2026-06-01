import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_gioi_di_dong/core/app_colors.dart';
import 'package:the_gioi_di_dong/core/constants.dart';
import 'package:the_gioi_di_dong/providers/user_profile_provider.dart';
import 'package:the_gioi_di_dong/screens/admin/admin_management_screen.dart';
import 'package:the_gioi_di_dong/screens/auth/register_screen.dart';
import 'package:the_gioi_di_dong/screens/main/main_screen.dart';
import 'package:the_gioi_di_dong/screens/order/order_list_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String userEmail;

  const ProfileScreen({super.key, required this.userEmail});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

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

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final profileProvider = context.read<UserProfileProvider>();
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    await profileProvider.load();
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

  void _openOrders(String status) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => OrderListScreen(status: status)),
    );
  }

  void _showInfoDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _showProfileForm({bool addressOnly = false}) {
    final profile = context.read<UserProfileProvider>();
    _nameController.text = profile.name;
    _phoneController.text = profile.phone;
    _addressController.text = profile.address;

    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: AppConstants.defaultPadding,
            right: AppConstants.defaultPadding,
            top: AppConstants.defaultPadding,
            bottom:
                MediaQuery.of(sheetContext).viewInsets.bottom +
                AppConstants.defaultPadding,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        addressOnly ? 'Địa chỉ nhận hàng' : 'Thông tin cá nhân',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (!addressOnly) ...[
                  _buildInputField(
                    controller: _nameController,
                    label: 'Họ tên',
                    icon: Icons.person_outline,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Vui lòng nhập họ tên';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildInputField(
                    controller: _phoneController,
                    label: 'Số điện thoại',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: _validatePhone,
                  ),
                  const SizedBox(height: 12),
                ],
                _buildInputField(
                  controller: _addressController,
                  label: 'Địa chỉ nhận hàng',
                  icon: Icons.location_on_outlined,
                  maxLines: 2,
                  validator: (value) {
                    if (value == null || value.trim().length < 8) {
                      return 'Vui lòng nhập địa chỉ cụ thể';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),
                ElevatedButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    final navigator = Navigator.of(sheetContext);
                    final messenger = ScaffoldMessenger.of(context);
                    await context.read<UserProfileProvider>().saveProfile(
                      name: _nameController.text,
                      phone: _phoneController.text,
                      address: _addressController.text,
                    );
                    if (!mounted) return;
                    navigator.pop();
                    messenger.showSnackBar(
                      const SnackBar(content: Text('Đã lưu thông tin')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryThis,
                    minimumSize: const Size(double.infinity, 50),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppConstants.defaultRadius,
                      ),
                    ),
                  ),
                  child: const Text(
                    'Lưu thay đổi',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String? _validatePhone(String? value) {
    final phone = value?.trim() ?? '';
    if (phone.isEmpty) return 'Vui lòng nhập số điện thoại';
    if (!RegExp(r'^(0|\+84)[0-9]{9,10}$').hasMatch(phone)) {
      return 'Số điện thoại không hợp lệ';
    }
    return null;
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: const Color(0xFFF5F5F7),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
          borderSide: BorderSide.none,
        ),
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
            _buildSettingItem(
              Icons.shield_outlined,
              'Chính sách bảo hành',
              onTap: () => _showInfoDialog(
                'Chính sách bảo hành',
                'Sản phẩm được hỗ trợ bảo hành theo chính sách của cửa hàng.',
              ),
            ),
            _buildSettingItem(
              Icons.document_scanner_outlined,
              'Điều khoản sử dụng',
              onTap: () => _showInfoDialog(
                'Điều khoản sử dụng',
                'Vui lòng kiểm tra thông tin đơn hàng trước khi thanh toán.',
              ),
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
          _buildSettingsList(),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Consumer<UserProfileProvider>(
      builder: (context, profile, _) => Container(
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
              _isAdmin
                  ? (_userEmail.isNotEmpty ? _userEmail : 'Admin')
                  : (profile.name.isNotEmpty ? profile.name : _userEmail),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 4),
            Text(
              _userEmail.isNotEmpty ? _userEmail : widget.userEmail,
              style: const TextStyle(fontSize: 13, color: Colors.black54),
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
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Đơn hàng của tôi',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              TextButton(
                onPressed: () => _openOrders('Tất cả'),
                child: const Text('Xem tất cả'),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildOrderStatusItem(
                Icons.query_builder,
                'Chờ xác nhận',
                badgeCount: 3,
                onTap: () => _openOrders('Chờ xác nhận'),
              ),
              _buildOrderStatusItem(
                Icons.local_shipping_outlined,
                'Đang giao',
                badgeCount: 2,
                onTap: () => _openOrders('Đang giao'),
              ),
              _buildOrderStatusItem(
                Icons.inbox_outlined,
                'Đã hoàn tất',
                badgeCount: 1,
                onTap: () => _openOrders('Đã hoàn tất'),
              ),
              _buildOrderStatusItem(
                Icons.sync,
                'Đổi trả',
                onTap: () => _openOrders('Đổi trả'),
              ),
              _buildOrderStatusItem(
                Icons.star_outline,
                'Đánh giá',
                onTap: () => _showInfoDialog(
                  'Đánh giá',
                  'Chức năng đánh giá sẽ hiển thị sau khi đơn hàng hoàn tất.',
                ),
              ),
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
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 62,
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
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
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
            _buildSettingItem(
              Icons.person_outline,
              'Thông tin cá nhân',
              onTap: _showProfileForm,
            ),
            _buildSettingItem(
              Icons.favorite_outline,
              'Sản phẩm yêu thích',
              onTap: () => _showInfoDialog(
                'Sản phẩm yêu thích',
                'Danh sách yêu thích hiện chưa có sản phẩm nào.',
              ),
            ),
            _buildSettingItem(
              Icons.map_outlined,
              'Địa chỉ nhận hàng',
              onTap: () => _showProfileForm(addressOnly: true),
            ),
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
