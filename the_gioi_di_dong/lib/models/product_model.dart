class Product {
  final String id;
  final String name;
  final double price;
  final String? unit;
  final int? stock;
  final String? imageUrl; 

  Product({
    required this.id,
    required this.name,
    required this.price,
    this.unit,
    this.stock,
    this.imageUrl,
  });

  // Hàm chuyển từ JSON (Java trả về) sang Object (Flutter dùng)
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['maSp']?.toString() ?? '', 
      name: json['tenSp']?.toString() ?? 'Sản phẩm chưa có tên',
      price: (json['donGia'] ?? 0).toDouble(),
      unit: json['donVt']?.toString() ?? 'Cái',
      stock: json['soLuongTon'] ?? 0,
      imageUrl: json['hinhAnh']?.toString() ?? 'laptop.jpg',
    );
  }
}