import 'package:flutter/material.dart';
import 'package:the_gioi_di_dong/screens/auth/register_screen.dart';
import 'package:the_gioi_di_dong/screens/main/main_screen.dart';
import 'package:the_gioi_di_dong/services/api_service.dart';
import 'package:the_gioi_di_dong/core/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _accountController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  static const Color primaryThis = Color.fromARGB(255, 54, 236, 148);

  // Hàm xử lý đăng nhập
  Future<void> _handleLogin() async {
    final email = _accountController.text.trim();
    final password = _passwordController.text.trim();

    if (!mounted) return;

    // 1. Kiểm tra rỗng sơ bộ
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Vui lòng nhập đầy đủ email và mật khẩu!"),
        ),
      );
      return;
    }

    setState(() => _isLoading = true); // Bắt đầu load

    try {
      // 2. Gọi API Login từ Service
      final userData = await ApiService.login(email, password);

      if (userData != null) {
        // 3. Đăng nhập THÀNH CÔNG
        // userData lúc này chứa thông tin từ bảng TAIKHOAN (id, role, email...)
        // ignore: unnecessary_null_comparison
        if (userData != null) {
          if (mounted) {
            // ---- THÊM ĐOẠN NÀY VÀO ĐÂY ----
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool('isLoggedIn', true); // Đánh dấu là đã đăng nhập
            await prefs.setString(
              'userEmail',
              email,
            ); // Lưu luôn email để lát hiện lên Profile
            await prefs.setString('maTk', userData['id']?.toString() ?? '');
            // -------------------------------
            if (!mounted) return;

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Chào mừng ${userData['email']}!")),
            );

            // Chuyển về trang có BottomNavigationBar (VD: MainScreen)
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                // THÊM THAM SỐ initialIndex: 3 VÀO ĐÂY NÈ ÔNG!
                builder: (context) => const MainScreen(initialIndex: 3),
              ),
            );
          }
        }
      } else {
        // 4. Đăng nhập THẤT BẠI
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Email hoặc mật khẩu không chính xác!"),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Lỗi kết nối: $e")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false); // Tắt load
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryThis,
        elevation: 0,
        title: const Text("Đăng nhập", style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Icon(Icons.laptop_mac_rounded, size: 100, color: primaryThis),
            const SizedBox(height: 40),

            TextField(
              controller: _accountController,
              decoration: InputDecoration(
                labelText: "Email",
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    AppConstants.defaultRadius,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                labelText: "Mật khẩu",
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () =>
                      setState(() => _isPasswordVisible = !_isPasswordVisible),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    AppConstants.defaultRadius,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Nút Đăng nhập với vòng quay loading
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : _handleLogin, // Đang load thì vô hiệu hóa nút
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryThis,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppConstants.defaultRadius,
                    ),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Text(
                        "ĐĂNG NHẬP",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 20), // Tạo khoảng cách một chút

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Chưa có tài khoản? "),
                TextButton(
                  onPressed: () {
                    // Chuyển sang trang Đăng ký
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegisterScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    "Đăng ký ngay",
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration
                          .underline, // Thêm gạch chân cho giống link
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
