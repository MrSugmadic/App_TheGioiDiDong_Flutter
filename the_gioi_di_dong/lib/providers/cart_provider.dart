import 'package:flutter/material.dart';

// Tạm thời định nghĩa 1 model Item đơn giản trong này luôn
class CartItem {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    this.quantity = 1,
  });
}

// Lớp CartProvider kế thừa ChangeNotifier để có thể phát thông báo khi dữ liệu đổi
class CartProvider extends ChangeNotifier {
  // Danh sách sản phẩm trong giỏ (Ban đầu trống)
  final Map<String, CartItem> _items = {};

  // Hàm lấy dữ liệu ra ngoài
  Map<String, CartItem> get items => _items;

  // Lấy tổng số lượng sản phẩm (để hiển thị lên cái chấm đỏ ở icon giỏ hàng)
  int get itemCount {
    int count = 0;
    _items.forEach((key, cartItem) {
      count += cartItem.quantity;
    });
    return count;
  }

  // Hàm Thêm sản phẩm vào giỏ
  void addItem(String productId, String name, double price, String imageUrl) {
    if (_items.containsKey(productId)) {
      // Nếu có rồi thì tăng số lượng
      _items[productId]!.quantity += 1;
    } else {
      // Nếu chưa có thì thêm mới
      _items.putIfAbsent(
        productId,
        () => CartItem(
          id: productId,
          name: name,
          price: price,
          imageUrl: imageUrl,
        ),
      );
    }
    // Lệnh quan trọng nhất: Hét lên "Dữ liệu đổi rồi, UI vẽ lại đi!"
    notifyListeners();
  }

  double get totalPrice {
    double total = 0;
    _items.forEach((key, item) {
      total += item.price * item.quantity;
    });
    return total;
  }

  // 2. Giảm số lượng (nếu < 1 thì xóa luôn khỏi giỏ)
  void decreaseItem(String productId) {
    if (!_items.containsKey(productId)) return;
    if (_items[productId]!.quantity > 1) {
      _items[productId]!.quantity -= 1;
    } else {
      _items.remove(productId);
    }
    notifyListeners();
  }

  // 3. Xóa sạch giỏ hàng (Dùng sau khi thanh toán xong)
  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
