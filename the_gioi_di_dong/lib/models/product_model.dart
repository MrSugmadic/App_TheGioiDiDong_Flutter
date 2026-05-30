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

  factory Product.fromJson(Map<String, dynamic> json) {
    final id = json['maSp']?.toString() ?? '';
    final name = json['tenSp']?.toString() ?? 'San pham chua co ten';

    return Product(
      id: id,
      name: name,
      price: (json['donGia'] ?? 0).toDouble(),
      unit: json['donVt']?.toString() ?? 'Cai',
      stock: json['soLuongTon'] ?? 0,
      imageUrl: json['hinhAnh']?.toString() ?? _fallbackImageFile(id, name),
    );
  }

  String get assetImagePath => imageAssetPath(imageUrl);

  static String imageAssetPath(String? imageFileName) {
    final fileName = imageFileName == null || imageFileName.trim().isEmpty
        ? _defaultImageFile
        : imageFileName.trim();

    if (fileName.startsWith('assets/')) {
      return fileName;
    }
    return 'assets/images/$fileName';
  }

  static const String _defaultImageFile = 'hp_pavilion_15_1.jpg';

  static String _fallbackImageFile(String id, String name) {
    switch (id) {
      case 'SP001':
        return 'dell_precision_5570_1.jpg';
      case 'SP002':
        return 'macbook_pro_14_m3_1.jpg';
      case 'SP003':
        return 'asus_zephyrus_g14_1.jpg';
      case 'SP004':
        return 'hp_pavilion_15_1.jpg';
      case 'SP005':
        return 'lenovo_ideacentre_3_1.jpg';
      case 'SP006':
        return 'asus_rog_strix_g15_1.jpg';
      case 'SP007':
        return 'aio_hp_24_1.jpg';
      case 'SP008':
        return 'dell_precision_5570_1.jpg';
      case 'SP009':
        return 'hp_z2_g9_1.jpg';
      case 'SP010':
        return 'lenovo_legion_5_pro_1.jpg';
    }

    final normalizedName = name.toLowerCase();
    if (normalizedName.contains('macbook')) return 'macbook_pro_14_m3_1.jpg';
    if (normalizedName.contains('zephyrus')) return 'asus_zephyrus_g14_1.jpg';
    if (normalizedName.contains('rog')) return 'asus_rog_strix_g15_1.jpg';
    if (normalizedName.contains('precision')) {
      return 'dell_precision_5570_1.jpg';
    }
    if (normalizedName.contains('dell')) return 'dell_precision_5570_1.jpg';
    if (normalizedName.contains('pavilion')) return 'hp_pavilion_15_1.jpg';
    if (normalizedName.contains('z2')) return 'hp_z2_g9_1.jpg';
    if (normalizedName.contains('aio')) return 'aio_hp_24_1.jpg';
    if (normalizedName.contains('legion')) return 'lenovo_legion_5_pro_1.jpg';
    if (normalizedName.contains('lenovo')) return 'lenovo_ideacentre_3_1.jpg';
    return _defaultImageFile;
  }
}
