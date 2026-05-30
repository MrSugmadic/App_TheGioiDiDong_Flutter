import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 1. THÊM IMPORT NÀY
import 'package:the_gioi_di_dong/core/app_colors.dart';
import 'package:the_gioi_di_dong/screens/home/home_screen.dart';
import 'package:the_gioi_di_dong/screens/notification/notification_screen.dart';
import 'package:the_gioi_di_dong/screens/profile/profile_screen.dart';
import 'package:the_gioi_di_dong/screens/category/category_screen.dart';
import 'package:the_gioi_di_dong/screens/auth/login_screen.dart'; // 2. IMPORT TRANG ĐĂNG NHẬP
import '../chatbot/chatbot_screen.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex; // Thêm dòng này để nhận yêu cầu từ bên ngoài

  // Thêm 'this.initialIndex = 0' (Mặc định không nói gì thì mở trang 0 - Home)
  const MainScreen({super.key, this.initialIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _selectedIndex; // Thêm chữ 'late' vì mình sẽ gán giá trị ở initState
  late PageController _pageController; // Thêm chữ 'late'

  bool _isLoggedIn = false;
  @override
  void initState() {
    super.initState();
    // 1. Gán tab hiện tại bằng số truyền vào từ bên ngoài
    _selectedIndex = widget.initialIndex;

    // 2. Ép cái PageView hiển thị đúng trang đó luôn
    _pageController = PageController(initialPage: widget.initialIndex);
    _checkLoginStatus();
  }

  // 5. HÀM KIỂM TRA BỘ NHỚ
  String _userEmail = '';

  // Sửa _checkLoginStatus() để đọc thêm email
  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      _userEmail = prefs.getString('userEmail') ?? '';
    });
  }

  // Trong screens list, truyền email xuống

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Chuyển trang có hiệu ứng animation mượt
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    // 6. CHUYỂN DANH SÁCH MÀN HÌNH VÀO TRONG NÀY ĐỂ CẬP NHẬT ĐỘNG
    final List<Widget> screens = [
      const HomeScreen(),
      const CategoryScreen(),
      const NotificationScreen(),
      // THÊM _isCheckingLogin vào đây
      _isLoggedIn
          ? ProfileScreen(userEmail: _userEmail) // TRUYỀN EMAIL VÀO ĐÂY
          : const LoginScreen(),
    ];

    return Scaffold(
      // PageView cho phép vuốt tay để chuyển tab
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: screens, // Dùng danh sách screens vừa khởi tạo ở trên
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryThis,
        child: const Icon(Icons.chat, color: Colors.black),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ChatBotScreen()),
          );
        },
      ),

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // Giữ icon không bị nhảy khi chọn
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.primaryThis,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_outlined),
            activeIcon: Icon(Icons.grid_view_rounded),
            label: 'Danh mục',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.headphones_battery),
            activeIcon: Icon(Icons.notifications),
            label: 'Thông báo', // Đổi chữ thường thành chữ Hoa cho đẹp
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Cá nhân',
          ),
        ],
      ),
    );
  }
}
