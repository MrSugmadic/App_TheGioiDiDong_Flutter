import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_gioi_di_dong/core/app_colors.dart';
import 'package:the_gioi_di_dong/screens/auth/login_screen.dart';
import 'package:the_gioi_di_dong/screens/promotion/promotion_screen.dart';
import 'package:the_gioi_di_dong/screens/chatbot/chatbot_screen.dart';
import 'package:the_gioi_di_dong/screens/home/home_screen.dart';
import 'package:the_gioi_di_dong/screens/notification/notification_screen.dart';
import 'package:the_gioi_di_dong/screens/profile/profile_screen.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;

  const MainScreen({super.key, this.initialIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _selectedIndex;
  late PageController _pageController;

  bool _isLoggedIn = false;
  String _userEmail = '';

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _checkLoginStatus();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    setState(() {
      _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      _userEmail = prefs.getString('userEmail') ?? '';
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      const HomeScreen(),
      const PromotionScreen(),
      const NotificationScreen(),
      _isLoggedIn ? ProfileScreen(userEmail: _userEmail) : const LoginScreen(),
    ];

    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: screens,
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
        type: BottomNavigationBarType.fixed,
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
            icon: Icon(Icons.local_offer_outlined),
            activeIcon: Icon(Icons.local_offer),
            label: 'Khuyến mãi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            activeIcon: Icon(Icons.notifications),
            label: 'Thông báo',
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
