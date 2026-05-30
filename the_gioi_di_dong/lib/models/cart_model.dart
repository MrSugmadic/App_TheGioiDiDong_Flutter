class CartModel {
  final int id;
  final String maTk;
  final String maSp;
  final int soLuong;

  CartModel({
    required this.id,
    required this.maTk,
    required this.maSp,
    required this.soLuong,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      id: json['id'] ?? 0,
      maTk: json['maTk'] ?? '',
      maSp: json['maSp'] ?? '',
      soLuong: json['soLuong'] ?? 1,
    );
  }
}