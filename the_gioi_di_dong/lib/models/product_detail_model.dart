class ProductDetailModel {
  final String ram;
  final String cpu;
  final String rom;
  final String screen;
  final String vga;
  final String other;

  ProductDetailModel({
    required this.ram,
    required this.cpu,
    required this.rom,
    required this.screen,
    required this.vga,
    required this.other,
  });

  factory ProductDetailModel.fromJson(Map<String, dynamic> json) {
    return ProductDetailModel(
      ram: json['ram'] ?? 'Đang cập nhật',
      cpu: json['cpu'] ?? 'Đang cập nhật',
      rom: json['rom'] ?? 'Đang cập nhật',
      screen: json['manHinh'] ?? 'Đang cập nhật',
      vga: json['vga'] ?? 'Đang cập nhật',
      other: json['khac'] ?? '',
    );
  }
}