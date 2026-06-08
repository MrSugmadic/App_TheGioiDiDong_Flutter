class OrderItemModel {
  final String maSp;
  final String tenSp;
  final double donGia;
  final int soLuong;
  final double thanhTien;

  OrderItemModel({
    required this.maSp,
    required this.tenSp,
    required this.donGia,
    required this.soLuong,
    required this.thanhTien,
  });

  Map<String, dynamic> toJson() {
    return {
      'maSp': maSp,
      'tenSp': tenSp,
      'donGia': donGia,
      'soLuong': soLuong,
      'thanhTien': thanhTien,
    };
  }

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    final rawQty = json['soLuong']?.toString() ?? '1';
    return OrderItemModel(
      maSp: json['maSp']?.toString() ?? '',
      tenSp: json['tenSp']?.toString() ?? 'Sản phẩm',
      donGia: (json['donGia'] as num?)?.toDouble() ?? 0,
      soLuong: int.tryParse(rawQty) ?? 1,
      thanhTien: (json['thanhTien'] as num?)?.toDouble() ?? 0,
    );
  }
}

class OrderModel {
  final String maHd;
  final String? maTk;
  final String? maKh;
  final String? hoTen;
  final String? soDienThoai;
  final String? diaChi;
  final String? phuongThucThanhToan;
  final String? maGiamGia;
  final double tongTien;
  final double giamGia;
  final double thanhTien;
  final String trangThai;
  final String? ngayLap;
  final List<OrderItemModel> items;

  OrderModel({
    required this.maHd,
    this.maTk,
    this.maKh,
    this.hoTen,
    this.soDienThoai,
    this.diaChi,
    this.phuongThucThanhToan,
    this.maGiamGia,
    required this.tongTien,
    required this.giamGia,
    required this.thanhTien,
    required this.trangThai,
    this.ngayLap,
    this.items = const [],
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    return OrderModel(
      maHd: json['maHd']?.toString() ?? '',
      maTk: json['maTk']?.toString(),
      maKh: json['maKh']?.toString(),
      hoTen: json['hoTen']?.toString(),
      soDienThoai: json['soDienThoai']?.toString(),
      diaChi: json['diaChi']?.toString(),
      phuongThucThanhToan: json['phuongThucThanhToan']?.toString(),
      maGiamGia: json['maGiamGia']?.toString(),
      tongTien: (json['tongTien'] as num?)?.toDouble() ?? 0,
      giamGia: (json['giamGia'] as num?)?.toDouble() ?? 0,
      thanhTien: (json['thanhTien'] as num?)?.toDouble() ?? 0,
      trangThai: json['trangThai']?.toString() ?? 'Chờ xác nhận',
      ngayLap: json['ngayLap']?.toString(),
      items: rawItems is List
          ? rawItems
                .map(
                  (e) => OrderItemModel.fromJson(Map<String, dynamic>.from(e)),
                )
                .toList()
          : const [],
    );
  }
}
