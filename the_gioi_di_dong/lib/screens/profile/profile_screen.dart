import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_gioi_di_dong/core/app_colors.dart';
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
          message,
          style: const TextStyle(fontSize: 15, height: 1.4),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryThis,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Đã hiểu',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
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
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  addressOnly ? 'Cập nhật địa chỉ' : 'Sửa thông tin cá nhân',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                if (!addressOnly) ...[
                  _buildInputField(
                    controller: _nameController,
                    label: 'Họ tên',
                    icon: Icons.person_outline,
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Vui lòng nhập họ tên'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  _buildInputField(
                    controller: _phoneController,
                    label: 'Số điện thoại',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: _validatePhone,
                  ),
                  const SizedBox(height: 16),
                ],
                _buildInputField(
                  controller: _addressController,
                  label: 'Địa chỉ nhận hàng',
                  icon: Icons.location_on_outlined,
                  maxLines: 2,
                  validator: (value) => value == null || value.trim().length < 8
                      ? 'Vui lòng nhập địa chỉ cụ thể'
                      : null,
                ),
                const SizedBox(height: 24),
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
                      const SnackBar(
                        content: Text('Cập nhật thành công!'),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryThis,
                    minimumSize: const Size(double.infinity, 55),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'LƯU THAY ĐỔI',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
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
    if (!RegExp(r'^(0|\+84)[0-9]{9,10}$').hasMatch(phone))
      return 'Số điện thoại không hợp lệ';
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
        prefixIcon: Icon(icon, color: Colors.grey[600]),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.primaryThis,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Nền xám nhạt hiện đại
      appBar: AppBar(
        title: const Text(
          'Tài khoản',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: AppColors.primaryThis,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryThis),
            )
          : _isLoggedIn
          ? _buildLoggedInBody()
          : _buildGuestBody(),
    );
  }

  // --- GIAO DIỆN KHI CHƯA ĐĂNG NHẬP ---
  Widget _buildGuestBody() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primaryThis.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_off_outlined,
                    size: 60,
                    color: AppColors.primaryThis,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Chào khách hàng mới!',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Đăng nhập để theo dõi đơn hàng, lưu danh sách yêu thích và nhận nhiều ưu đãi hấp dẫn.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, height: 1.4),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegisterScreen(),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryThis,
                    foregroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'ĐĂNG NHẬP / ĐĂNG KÝ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildSettingsGroup([
            _buildSettingItem(
              Icons.verified_user_outlined,
              'Chính sách bảo hành',
              onTap: () => _showInfoDialog(
                'Chính sách bảo hành',
                'Sản phẩm được hỗ trợ bảo hành chính hãng lên đến 24 tháng.',
              ),
            ),
            _buildSettingItem(
              Icons.article_outlined,
              'Điều khoản sử dụng',
              isLast: true,
              onTap: () => _showInfoDialog(
                'Điều khoản',
                'Cam kết bảo mật thông tin và quyền lợi khách hàng tuyệt đối.',
              ),
            ),
          ]),
        ],
      ),
    );
  }

  // --- GIAO DIỆN KHI ĐÃ ĐĂNG NHẬP ---
  Widget _buildLoggedInBody() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          _buildProfileHeader(),
          const SizedBox(height: 16),
          if (_isAdmin) _buildAdminManagementList(),
          if (!_isAdmin) _buildOrderStatusCard(),
          _buildSettingsList(),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // 1. Header Tràn viền
  Widget _buildProfileHeader() {
    return Consumer<UserProfileProvider>(
      builder: (context, profile, _) => Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
        decoration: const BoxDecoration(
          color: AppColors.primaryThis,
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: CircleAvatar(
                radius: 36,
                backgroundColor: Colors.grey[200],
                child: Icon(
                  _isAdmin ? Icons.admin_panel_settings : Icons.person,
                  size: 40,
                  color: Colors.grey[600],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isAdmin
                        ? (_userEmail.isNotEmpty ? _userEmail : 'Admin')
                        : (profile.name.isNotEmpty ? profile.name : _userEmail),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _isAdmin
                          ? 'Bảng điều khiển Admin'
                          : 'Khách hàng thành viên',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 2. Menu Admin
  Widget _buildAdminManagementList() {
    return _buildSettingsGroup([
      _buildGroupTitle('Quản trị hệ thống'),
      _buildSettingItem(
        Icons.inventory_2_outlined,
        'Quản lý sản phẩm',
        iconColor: Colors.blue,
        onTap: () =>
            _openAdminManagement('Sản phẩm', Icons.inventory_2_outlined),
      ),
      _buildSettingItem(
        Icons.category_outlined,
        'Quản lý danh mục',
        iconColor: Colors.orange,
        onTap: () => _openAdminManagement('Danh mục', Icons.category_outlined),
      ),
      _buildSettingItem(
        Icons.receipt_long_outlined,
        'Quản lý đơn hàng',
        iconColor: Colors.green,
        onTap: () =>
            _openAdminManagement('Đơn hàng', Icons.receipt_long_outlined),
      ),
      _buildSettingItem(
        Icons.people_outline,
        'Quản lý người dùng',
        iconColor: Colors.purple,
        onTap: () => _openAdminManagement('Người dùng', Icons.people_outline),
      ),
      _buildSettingItem(
        Icons.notifications_active_outlined,
        'Quản lý thông báo',
        iconColor: Colors.redAccent,
        isLast: true,
        onTap: () => _openAdminManagement(
          'Thông báo',
          Icons.notifications_active_outlined,
        ),
      ),
    ]);
  }

  // 3. Card Đơn hàng
  Widget _buildOrderStatusCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Đơn hàng của tôi',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              GestureDetector(
                onTap: () => _openOrders('Tất cả'),
                child: const Text(
                  'Xem lịch sử >',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildOrderStatusItem(
                Icons.wallet_outlined,
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
                Icons.inventory_2_outlined,
                'Hoàn tất',
                badgeCount: 1,
                onTap: () => _openOrders('Đã hoàn tất'),
              ),
              _buildOrderStatusItem(
                Icons.star_outline,
                'Đánh giá',
                onTap: () => _showInfoDialog(
                  'Đánh giá',
                  'Chức năng đánh giá sẽ hiển thị trên đơn hàng đã hoàn tất.',
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
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.black87, size: 24),
              ),
              if (badgeCount > 0)
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: Text(
                      '$badgeCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  // 4. Menu Cài đặt chung
  Widget _buildSettingsList() {
    return Column(
      children: [
        if (!_isAdmin) ...[
          _buildSettingsGroup([
            _buildGroupTitle('Thiết lập tài khoản'),
            _buildSettingItem(
              Icons.person_outline,
              'Hồ sơ cá nhân',
              iconColor: Colors.blue,
              onTap: _showProfileForm,
            ),
            _buildSettingItem(
              Icons.location_on_outlined,
              'Sổ địa chỉ',
              iconColor: Colors.green,
              onTap: () => _showProfileForm(addressOnly: true),
            ),
            _buildSettingItem(
              Icons.favorite_border,
              'Đã thích',
              iconColor: Colors.redAccent,
              isLast: true,
              onTap: () =>
                  _showInfoDialog('Trống', 'Bạn chưa lưu sản phẩm nào.'),
            ),
          ]),
        ],
        _buildSettingsGroup([
          _buildSettingItem(
            Icons.headset_mic_outlined,
            'Trung tâm hỗ trợ',
            iconColor: Colors.orange,
          ),
          _buildSettingItem(
            Icons.logout_rounded,
            'Đăng xuất',
            textColor: Colors.redAccent,
            iconColor: Colors.redAccent,
            isLast: true,
            onTap: _handleLogout,
          ),
        ]),
      ],
    );
  }

  // --- WIDGET TIỆN ÍCH DÀNH CHO MENU CARD ---
  Widget _buildSettingsGroup(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildGroupTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildSettingItem(
    IconData icon,
    String label, {
    Color textColor = Colors.black87,
    Color iconColor = Colors.grey,
    bool isLast = false,
    VoidCallback? onTap,
  }) {
    return Column(
      children: [
        ListTile(
          onTap: onTap,
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          title: Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            size: 14,
            color: Colors.grey,
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            indent: 56,
            endIndent: 16,
            color: Colors.grey[200],
          ),
      ],
    );
  }
}
