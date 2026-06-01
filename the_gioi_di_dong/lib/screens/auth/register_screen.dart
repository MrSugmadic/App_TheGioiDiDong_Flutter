import 'package:flutter/material.dart';
import 'package:the_gioi_di_dong/screens/auth/login_screen.dart';
import 'package:the_gioi_di_dong/core/app_colors.dart';
import 'package:the_gioi_di_dong/core/constants.dart';
import 'package:the_gioi_di_dong/services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Controller để lấy dữ liệu từ các ô nhập liệu
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Biến để ẩn/hiện mật khẩu
  bool _isPasswordVisible = false;
  // Thêm biến trạng thái loading để làm mượt giao diện
  bool _isLoading = false;

  Future<void> _handleRegister() async {
    // Lấy dữ liệu từ các ô nhập liệu
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPass = _confirmPasswordController.text.trim();

    // ==========================================
    // BƯỚC 1: KIỂM TRA THÔNG TIN (VALIDATION)
    // ==========================================

    // 1.1 Kiểm tra không được để trống
    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng điền đầy đủ thông tin!")),
      );
      return; // Dừng lại luôn, không làm tiếp
    }

    // 1.2 Kiểm tra mật khẩu có khớp nhau không
    if (password != confirmPass) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mật khẩu nhập lại không khớp!")),
      );
      return; // Dừng lại luôn
    }

    // 1.3 Kiểm tra định dạng Email (tùy chọn nhưng nên có)
    if (!email.contains('@')) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Email không hợp lệ!")));
      return;
    }

    // ==========================================
    // BƯỚC 2: GỬI LÊN SERVER (DATABASE)
    // ==========================================

    setState(() => _isLoading = true); // Hiện vòng quay loading

    // Gọi hàm API (ông thay bằng hàm gọi API thực tế của ông nhé)
    final isSuccess = await ApiService.register(email, password, hoTen: name);

    if (mounted) setState(() => _isLoading = false); // Tắt loading

    // ==========================================
    // BƯỚC 3: XỬ LÝ KẾT QUẢ VÀ CHUYỂN TRANG
    // ==========================================

    if (isSuccess == "SUCCESS") {
      // Nếu Server báo lưu thành công
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Đăng ký thành công! Vui lòng đăng nhập."),
            backgroundColor: Colors.green,
          ),
        );

        // CHUYỂN SANG TRANG ĐĂNG NHẬP LUÔN TẠI ĐÂY
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } else {
      // Nếu Server báo lỗi (VD: Trùng email)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Lỗi: $isSuccess"), // In ra lỗi từ server
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryThis,
        title: const Text(
          "Đăng ký tài khoản",
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Icon(
                Icons.app_registration,
                size: 80,
                color: AppColors.primaryThis,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Tạo tài khoản mới",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text("Vui lòng điền thông tin để tham gia cùng chúng tôi."),
            const SizedBox(height: 30),

            // Ô nhập Họ tên
            _buildTextField(
              controller: _nameController,
              label: "Họ và tên",
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 15),

            // Ô nhập Số điện thoại/Email
            _buildTextField(
              controller: _emailController,
              label: "Số điện thoại / Email",
              icon: Icons.phone_android_outlined,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 15),

            // Ô nhập Mật khẩu
            _buildPasswordField(
              controller: _passwordController,
              label: "Mật khẩu",
            ),
            const SizedBox(height: 15),

            // Ô nhập Lại mật khẩu
            _buildPasswordField(
              controller: _confirmPasswordController,
              label: "Xác nhận mật khẩu",
            ),
            const SizedBox(height: 30),

            // Nút Đăng ký
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                // 1. Cập nhật onPressed ở đây:
                // Nếu _isLoading là true thì gán bằng null (vô hiệu hóa nút)
                // Nếu _isLoading là false thì trỏ đến hàm _handleRegister
                onPressed: _isLoading ? null : _handleRegister,

                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryThis,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppConstants.defaultRadius,
                    ),
                  ),
                ),

                // 2. Cập nhật child ở đây:
                // Đang load thì hiện vòng quay, không thì hiện chữ "ĐĂNG KÝ NGAY"
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.black,
                          strokeWidth: 2, // Cho viền mỏng lại cho tinh tế
                        ),
                      )
                    : const Text(
                        "ĐĂNG KÝ NGAY",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
            ),

            // Quay lại Đăng nhập
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
                child: const Text(
                  "Đã có tài khoản? Đăng nhập ngay",
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Hàm bổ trợ tạo ô nhập liệu thường
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        ),
      ),
    );
  }

  // Hàm bổ trợ tạo ô nhập mật khẩu
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
  }) {
    return TextField(
      controller: controller,
      obscureText: !_isPasswordVisible, // Ẩn hiện mật khẩu
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () =>
              setState(() => _isPasswordVisible = !_isPasswordVisible),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        ),
      ),
    );
  }
}
