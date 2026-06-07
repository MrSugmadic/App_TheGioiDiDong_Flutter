import 'package:flutter/material.dart';
import 'package:the_gioi_di_dong/core/app_colors.dart';
import 'package:the_gioi_di_dong/core/utils.dart';
import 'package:the_gioi_di_dong/models/product_detail_model.dart';
import 'package:the_gioi_di_dong/models/product_model.dart';
import 'package:the_gioi_di_dong/screens/category/product_detail_screen.dart';
import 'package:the_gioi_di_dong/services/api_service.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  late Future<List<_FilterProduct>> _productsFuture;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  String _searchKeyword = '';
  String _selectedBrand = 'Tất cả';
  String _selectedPrice = 'Tất cả';
  String _selectedRam = 'Tất cả';
  String _selectedCpu = 'Tất cả';
  String _selectedStorage = 'Tất cả';
  String _selectedSpec = 'Tất cả';

  static const List<_PriceFilter> _priceFilters = [
    _PriceFilter('Tất cả'),
    _PriceFilter('Dưới 10 triệu', max: 10000000),
    _PriceFilter('10 - 20 triệu', min: 10000000, max: 20000000),
    _PriceFilter('20 - 30 triệu', min: 20000000, max: 30000000),
    _PriceFilter('Trên 30 triệu', min: 30000000),
  ];

  static const List<String> _brands = [
    'Tất cả',
    'Dell',
    'HP',
    'Asus',
    'Acer',
    'Lenovo',
    'MSI',
    'Apple',
    'Gigabyte',
  ];

  static const List<String> _ramOptions = ['Tất cả', '8GB', '16GB', '32GB'];

  static const List<String> _cpuOptions = [
    'Tất cả',
    'Intel Core i3',
    'Intel Core i5',
    'Intel Core i7',
    'Intel Core i9',
    'AMD Ryzen 5',
    'AMD Ryzen 7',
    'Apple M',
  ];

  static const List<String> _storageOptions = [
    'Tất cả',
    '256GB',
    '512GB',
    '1TB',
  ];

  static const List<String> _specOptions = [
    'Tất cả',
    'Card rời',
    'Màn hình 14 inch',
    'Màn hình 15 inch',
    'Màn hình 16 inch',
  ];

  @override
  void initState() {
    super.initState();
    _productsFuture = _loadProducts();
    Future.delayed(const Duration(milliseconds: 360), () {
      if (mounted) {
        _searchFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<List<_FilterProduct>> _loadProducts() async {
    final products = await ApiService.fetchProducts();
    return Future.wait(
      products.map((product) async {
        final detail = await ApiService.getProductDetail(product.id);
        return _FilterProduct(product: product, detail: detail);
      }),
    );
  }

  List<_FilterProduct> _applyFilters(List<_FilterProduct> products) {
    final selectedPrice = _priceFilters.firstWhere(
      (filter) => filter.label == _selectedPrice,
    );

    return products.where((item) {
      final product = item.product;
      final detail = item.detail;

      if (_searchKeyword.trim().isNotEmpty &&
          !_normalize(product.name).contains(_normalize(_searchKeyword))) {
        return false;
      }

      if (_selectedBrand != 'Tất cả' &&
          !_normalize(product.name).contains(_normalize(_selectedBrand))) {
        return false;
      }

      if (!selectedPrice.matches(product.price)) {
        return false;
      }

      if (!_containsFilterValue(detail?.ram, _selectedRam)) {
        return false;
      }

      if (!_matchesCpu(detail?.cpu, _selectedCpu)) {
        return false;
      }

      if (!_containsFilterValue(detail?.rom, _selectedStorage)) {
        return false;
      }

      if (_selectedSpec == 'Card rời' &&
          !_normalize(detail?.vga ?? '').contains('vga') &&
          !_normalize(detail?.vga ?? '').contains('rtx') &&
          !_normalize(detail?.vga ?? '').contains('gtx')) {
        return false;
      }

      if (_selectedSpec.startsWith('Màn hình') &&
          !_normalize(
            detail?.screen ?? '',
          ).contains(_normalize(_selectedSpec.replaceFirst('Màn hình ', '')))) {
        return false;
      }

      return true;
    }).toList();
  }

  bool _containsFilterValue(String? source, String selectedValue) {
    if (selectedValue == 'Tất cả') return true;
    return _normalize(source ?? '').contains(_normalize(selectedValue));
  }

  bool _matchesCpu(String? source, String selectedValue) {
    if (selectedValue == 'Tất cả') return true;

    final normalizedSource = _normalize(source ?? '');
    final normalizedValue = _normalize(selectedValue);
    if (normalizedSource.contains(normalizedValue)) return true;

    final shortValue = normalizedValue
        .replaceFirst('intelcore', '')
        .replaceFirst('amdryzen', '')
        .replaceFirst('apple', '');
    return shortValue.isNotEmpty && normalizedSource.contains(shortValue);
  }

  String _normalize(String value) {
    return value.toLowerCase().replaceAll(' ', '');
  }

  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _searchKeyword = '';
      _selectedBrand = 'Tất cả';
      _selectedPrice = 'Tất cả';
      _selectedRam = 'Tất cả';
      _selectedCpu = 'Tất cả';
      _selectedStorage = 'Tất cả';
      _selectedSpec = 'Tất cả';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Tìm kiếm & Lọc',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: AppColors.primaryThis,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Đặt lại',
            onPressed: _resetFilters,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: FutureBuilder<List<_FilterProduct>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryThis),
            );
          }

          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }

          final products = snapshot.data ?? [];
          final filteredProducts = _applyFilters(products);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thanh tìm kiếm siêu mượt
              Container(
                color: AppColors.primaryThis,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    onChanged: (value) =>
                        setState(() => _searchKeyword = value),
                    decoration: InputDecoration(
                      hintText: 'Nhập tên sản phẩm cần tìm...',
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: Colors.grey[500],
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
              ),

              // Khu vực chọn bộ lọc (Có thể cuộn dọc)
              Container(
                color: Colors.white,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.35,
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _FilterSection(
                        title: 'Hãng sản xuất',
                        options: _brands,
                        selectedValue: _selectedBrand,
                        onSelected: (value) =>
                            setState(() => _selectedBrand = value),
                      ),
                      _FilterSection(
                        title: 'Mức giá',
                        options: _priceFilters
                            .map((filter) => filter.label)
                            .toList(),
                        selectedValue: _selectedPrice,
                        onSelected: (value) =>
                            setState(() => _selectedPrice = value),
                      ),
                      _FilterSection(
                        title: 'Bộ nhớ RAM',
                        options: _ramOptions,
                        selectedValue: _selectedRam,
                        onSelected: (value) =>
                            setState(() => _selectedRam = value),
                      ),
                      _FilterSection(
                        title: 'Dòng CPU',
                        options: _cpuOptions,
                        selectedValue: _selectedCpu,
                        onSelected: (value) =>
                            setState(() => _selectedCpu = value),
                      ),
                      _FilterSection(
                        title: 'Dung lượng ổ cứng',
                        options: _storageOptions,
                        selectedValue: _selectedStorage,
                        onSelected: (value) =>
                            setState(() => _selectedStorage = value),
                      ),
                      _FilterSection(
                        title: 'Thông số khác',
                        options: _specOptions,
                        selectedValue: _selectedSpec,
                        onSelected: (value) =>
                            setState(() => _selectedSpec = value),
                      ),
                    ],
                  ),
                ),
              ),

              // Header số lượng kết quả
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      size: 16,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Tìm thấy ${filteredProducts.length} sản phẩm phù hợp',
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              // Danh sách sản phẩm
              Expanded(
                child: filteredProducts.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off_rounded,
                              size: 60,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Không có sản phẩm nào khớp với bộ lọc.',
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        itemCount: filteredProducts.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          return _FilteredProductCard(
                            item: filteredProducts[index],
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FilterSection extends StatelessWidget {
  final String title;
  final List<String> options;
  final String selectedValue;
  final ValueChanged<String> onSelected;

  const _FilterSection({
    required this.title,
    required this.options,
    required this.selectedValue,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: options.map((option) {
                final isSelected = option == selectedValue;
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: ChoiceChip(
                    label: Text(option),
                    selected: isSelected,
                    onSelected: (_) => onSelected(option),
                    showCheckmark: false, // Ẩn dấu check mặc định
                    selectedColor: AppColors.primaryThis,
                    backgroundColor: Colors.grey[100],
                    elevation: 0,
                    side: BorderSide.none, // Bỏ viền cứng
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilteredProductCard extends StatelessWidget {
  final _FilterProduct item;

  const _FilteredProductCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final product = item.product;
    final detail = item.detail;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetailScreen(product: product),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Khu vực ảnh sản phẩm
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Image.asset(
                    product.assetImagePath,
                    width: 70,
                    height: 70,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => const Icon(
                      Icons.laptop_mac_rounded,
                      color: Colors.grey,
                      size: 50,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Khu vực thông tin
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        AppUtils.formatCurrency(product.price),
                        style: const TextStyle(
                          color: AppColors.priceRed,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Hiển thị dải thông số kỹ thuật dạng Tag
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _buildSpecLine(detail),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _buildSpecLine(ProductDetailModel? detail) {
    if (detail == null) return 'Đang cập nhật cấu hình';
    return '${detail.cpu} • ${detail.ram} • ${detail.rom}';
  }
}

class _FilterProduct {
  final Product product;
  final ProductDetailModel? detail;

  const _FilterProduct({required this.product, required this.detail});
}

class _PriceFilter {
  final String label;
  final double? min;
  final double? max;

  const _PriceFilter(this.label, {this.min, this.max});

  bool matches(double price) {
    final minValue = min;
    final maxValue = max;

    if (minValue != null && price < minValue) {
      return false;
    }
    if (maxValue != null && price >= maxValue) {
      return false;
    }
    return true;
  }
}
