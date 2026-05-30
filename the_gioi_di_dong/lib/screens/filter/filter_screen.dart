import 'package:flutter/material.dart';
import 'package:the_gioi_di_dong/core/app_colors.dart';
import 'package:the_gioi_di_dong/core/constants.dart';
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
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Lọc sản phẩm',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primaryThis,
        foregroundColor: AppColors.textPrimary,
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Đặt lại bộ lọc',
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
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  onChanged: (value) {
                    setState(() => _searchKeyword = value);
                  },
                  decoration: InputDecoration(
                    hintText: 'Nhập tên sản phẩm cần tìm...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    filled: true,
                    fillColor: AppColors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppConstants.defaultRadius,
                      ),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.32,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _FilterSection(
                        title: 'Hãng',
                        options: _brands,
                        selectedValue: _selectedBrand,
                        onSelected: (value) {
                          setState(() => _selectedBrand = value);
                        },
                      ),
                      _FilterSection(
                        title: 'Giá tiền',
                        options: _priceFilters
                            .map((filter) => filter.label)
                            .toList(),
                        selectedValue: _selectedPrice,
                        onSelected: (value) {
                          setState(() => _selectedPrice = value);
                        },
                      ),
                      _FilterSection(
                        title: 'Cấu hình',
                        options: _ramOptions,
                        selectedValue: _selectedRam,
                        onSelected: (value) {
                          setState(() => _selectedRam = value);
                        },
                      ),
                      _FilterSection(
                        title: 'CPU',
                        options: _cpuOptions,
                        selectedValue: _selectedCpu,
                        onSelected: (value) {
                          setState(() => _selectedCpu = value);
                        },
                      ),
                      _FilterSection(
                        title: 'Ổ cứng',
                        options: _storageOptions,
                        selectedValue: _selectedStorage,
                        onSelected: (value) {
                          setState(() => _selectedStorage = value);
                        },
                      ),
                      _FilterSection(
                        title: 'Thông số',
                        options: _specOptions,
                        selectedValue: _selectedSpec,
                        onSelected: (value) {
                          setState(() => _selectedSpec = value);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(
                  '${filteredProducts.length} sản phẩm phù hợp',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                child: filteredProducts.isEmpty
                    ? const Center(
                        child: Text(
                          'Không có sản phẩm phù hợp với bộ lọc.',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        itemCount: filteredProducts.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
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
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: options.map((option) {
                final isSelected = option == selectedValue;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(option),
                    selected: isSelected,
                    onSelected: (_) => onSelected(option),
                    selectedColor: AppColors.primaryThis.withValues(
                      alpha: 0.35,
                    ),
                    backgroundColor: AppColors.white,
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.primaryThis
                          : Colors.grey.shade300,
                    ),
                    labelStyle: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
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

    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
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
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  product.assetImagePath,
                  width: 76,
                  height: 76,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    width: 76,
                    height: 76,
                    color: AppColors.primaryThis.withValues(alpha: 0.12),
                    child: const Icon(
                      Icons.laptop_mac_rounded,
                      color: AppColors.primaryThis,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
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
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      AppUtils.formatCurrency(product.price),
                      style: const TextStyle(
                        color: AppColors.priceRed,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _buildSpecLine(detail),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }

  String _buildSpecLine(ProductDetailModel? detail) {
    if (detail == null) return 'Đang cập nhật cấu hình';
    return '${detail.cpu} | ${detail.ram} | ${detail.rom}';
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
