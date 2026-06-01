import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';
import '../models/cart_model.dart';
import '../models/notification_model.dart';
import '../models/order_model.dart';
import '../models/product_detail_model.dart';

class ApiService {
  // Thay port 8081 bằng port ông đang chạy Java nhé
  static String get _backendHost {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return '10.0.2.2';
    }
    return 'localhost';
  }

  static String get baseUrl => 'http://$_backendHost:8081/api';
  static String notificationWsUrl({String? maTk}) {
    final query = maTk == null || maTk.isEmpty
        ? ''
        : '?maTk=${Uri.encodeQueryComponent(maTk)}';
    return 'ws://$_backendHost:8081/ws/notifications$query';
  }

  //SAN PHAM
  static Future<List<Product>> fetchProducts() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/products'));

      if (response.statusCode == 200) {
        // Giải mã tiếng Việt (UTF-8)
        List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
        List<Product> products = body
            .map((item) => Product.fromJson(item))
            .toList();
        return products;
      } else {
        throw Exception("Lỗi server: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Không thể kết nối Backend: $e");
    }
  }

  //DANG NHAP
  static Future<Map<String, dynamic>?> login(
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return null; // Đăng nhập thất bại
    }
  }

  //KTRA TAI KHOAN
  static Future<String?> register(
    String email,
    String password, {
    String? hoTen,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
          if (hoTen != null && hoTen.trim().isNotEmpty) "hoTen": hoTen.trim(),
        }),
      );

      if (response.statusCode == 200) {
        return "SUCCESS"; // Thành công
      } else {
        return response
            .body; // Trả về câu chửi của Backend (vd: "Email đã được sử dụng")
      }
    } catch (e) {
      return "Lỗi kết nối: $e";
    }
  }

  static Future<Map<String, dynamic>?> fetchUserProfile(String maTk) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/auth/profile/$maTk'));
      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<Map<String, dynamic>?> updateUserProfile({
    required String maTk,
    required String hoTen,
    required String soDienThoai,
    required String diaChi,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/auth/profile/$maTk'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'hoTen': hoTen,
          'soDienThoai': soDienThoai,
          'diaChi': diaChi,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  //DANH MUC
  static Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/categories'));

      if (response.statusCode == 200) {
        // utf8.decode để chống lỗi font chữ tiếng Việt (bị mất dấu)
        List<dynamic> jsonResponse = json.decode(
          utf8.decode(response.bodyBytes),
        );
        return jsonResponse
            .map((data) => CategoryModel.fromJson(data))
            .toList();
      } else {
        throw Exception('Lỗi khi tải danh mục: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Không thể kết nối Server: $e');
    }
  }

  // 1. Thêm sản phẩm vào giỏ hàng
  static Future<bool> addToCart(String maTk, String maSp, int soLuong) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/cart/add'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'maTk': maTk, 'maSp': maSp, 'soLuong': soLuong}),
      );
      // HTTP 200 hoặc 201 đều là thành công
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Lỗi thêm giỏ hàng: $e');
      return false;
    }
  }

  // 2. Lấy danh sách giỏ hàng của User
  static Future<List<CartModel>> getCartByUser(String maTk) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/cart/$maTk'));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return data.map((json) => CartModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Lỗi lấy giỏ hàng: $e');
      return [];
    }
  }

  //SAN PHAM THEO DANH MUC
  static Future<List<Product>> getProductsByCategory(String categoryId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products/category/$categoryId'),
      );

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
        return body.map((item) => Product.fromJson(item)).toList();
      } else {
        throw Exception('Lỗi server: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Không thể kết nối Backend: $e');
    }
  }

  static Future<ProductDetailModel?> getProductDetail(String maSp) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products/detail/$maSp'),
      );
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        return ProductDetailModel.fromJson(
          json.decode(utf8.decode(response.bodyBytes)),
        );
      }
      return null;
    } catch (e) {
      print('Lỗi lấy chi tiết SP: $e');
      return null;
    }
  }

  static Future<List<AppNotification>> fetchNotifications({
    String? maTk,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/notifications').replace(
        queryParameters: maTk == null || maTk.isEmpty ? null : {'maTk': maTk},
      );
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
        return body.map((item) => AppNotification.fromJson(item)).toList();
      }

      throw Exception('Loi server: ${response.statusCode}');
    } catch (e) {
      throw Exception('Khong the tai thong bao: $e');
    }
  }

  static Future<void> sendDemoNotification() async {
    final prefs = await SharedPreferences.getInstance();
    final maTk = prefs.getString('maTk');

    final response = await http.post(
      Uri.parse('$baseUrl/notifications/demo'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': 'Khuyen mai moi',
        'content': 'San pham hot vua co uu dai, mo app de xem ngay.',
        'type': 'PROMOTION',
        if (maTk != null && maTk.isNotEmpty) 'maTk': maTk,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Loi server: ${response.statusCode}');
    }
  }

  static Future<List<Map<String, dynamic>>> fetchAdminOrders() async {
    final response = await http.get(Uri.parse('$baseUrl/admin/orders'));

    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      return body.whereType<Map<String, dynamic>>().toList();
    }

    throw Exception('Loi server: ${response.statusCode}');
  }

  static Future<List<Map<String, dynamic>>> fetchAdminAccounts() async {
    final response = await http.get(Uri.parse('$baseUrl/admin/accounts'));

    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      return body.whereType<Map<String, dynamic>>().toList();
    }

    throw Exception('Loi server: ${response.statusCode}');
  }

  static Future<void> adminPatch(String path, Map<String, dynamic> data) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/admin/$path'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Loi server: ${response.statusCode}');
    }
  }

  static Future<void> adminDelete(String path) async {
    final response = await http.delete(Uri.parse('$baseUrl/admin/$path'));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Loi server: ${response.statusCode}');
    }
  }

  static Future<OrderModel?> createOrder({
    required String maTk,
    required String hoTen,
    required String soDienThoai,
    required String diaChi,
    required String phuongThucThanhToan,
    required String maGiamGia,
    required double tongTien,
    required double giamGia,
    required double thanhTien,
    required List<OrderItemModel> items,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/orders/create'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'maTk': maTk,
          'hoTen': hoTen,
          'soDienThoai': soDienThoai,
          'diaChi': diaChi,
          'phuongThucThanhToan': phuongThucThanhToan,
          'maGiamGia': maGiamGia,
          'tongTien': tongTien,
          'giamGia': giamGia,
          'thanhTien': thanhTien,
          'items': items.map((item) => item.toJson()).toList(),
        }),
      );

      if (response.statusCode == 200) {
        return OrderModel.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<void> clearCartOnServer(String maTk) async {
    if (maTk.isEmpty) return;
    await http.delete(Uri.parse('$baseUrl/cart/$maTk'));
  }

  static Future<Map<String, dynamic>> fetchAdminOrderDetail(String maHd) async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/orders/${Uri.encodeComponent(maHd)}'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    }

    throw Exception('Loi server: ${response.statusCode}');
  }
}
