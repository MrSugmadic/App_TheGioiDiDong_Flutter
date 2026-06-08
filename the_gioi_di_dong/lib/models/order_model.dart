class OrderItemModel {
  final String maSp;
  final String tenSp;
  final double donGia;
  final int soLuong;
  final double thanhTien;
  final String? hinhAnh;

  const OrderItemModel({
    required this.maSp,
    required this.tenSp,
    required this.donGia,
    required this.soLuong,
    required this.thanhTien,
    this.hinhAnh,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    final price = _toDouble(json['donGia']);
    final quantity = _toInt(json['soLuong']);
    return OrderItemModel(
      maSp: json['maSp']?.toString() ?? '',
      tenSp: json['tenSp']?.toString() ?? 'Sản phẩm',
      donGia: price,
      soLuong: quantity,
      thanhTien: _toDouble(json['thanhTien'] ?? price * quantity),
      hinhAnh: json['hinhAnh']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'maSp': maSp,
      'tenSp': tenSp,
      'donGia': donGia,
      'soLuong': soLuong,
      'thanhTien': thanhTien,
    };
  }
}

class OrderModel {
  final String maHd;
  final String maTk;
  final String maKh;
  final String hoTen;
  final String soDienThoai;
  final String diaChi;
  final String phuongThucThanhToan;
  final String maGiamGia;
  final double tongTien;
  final double giamGia;
  final double thanhTien;
  final String trangThai;
  final String ngayLap;
  final List<OrderItemModel> items;

  const OrderModel({
    required this.maHd,
    required this.maTk,
    required this.maKh,
    required this.hoTen,
    required this.soDienThoai,
    required this.diaChi,
    required this.phuongThucThanhToan,
    required this.maGiamGia,
    required this.tongTien,
    required this.giamGia,
    required this.thanhTien,
    required this.trangThai,
    required this.ngayLap,
    required this.items,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final items = (json['items'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(OrderItemModel.fromJson)
        .toList();
    final thanhTien = _toDouble(json['thanhTien']);

    return OrderModel(
      maHd: json['maHd']?.toString() ?? '',
      maTk: json['maTk']?.toString() ?? '',
      maKh: json['maKh']?.toString() ?? '',
      hoTen: json['hoTen']?.toString() ?? '',
      soDienThoai: json['soDienThoai']?.toString() ?? '',
      diaChi: json['diaChi']?.toString() ?? '',
      phuongThucThanhToan: json['phuongThucThanhToan']?.toString() ?? '',
      maGiamGia: json['maGiamGia']?.toString() ?? '',
      tongTien: _toDouble(json['tongTien'] ?? thanhTien),
      giamGia: _toDouble(json['giamGia']),
      thanhTien: thanhTien,
      trangThai: json['trangThai']?.toString() ?? 'Chờ xác nhận',
      ngayLap: json['ngayLap']?.toString() ?? '',
      items: items,
    );
  }
}

double _toDouble(Object? value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

int _toInt(Object? value) {
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

