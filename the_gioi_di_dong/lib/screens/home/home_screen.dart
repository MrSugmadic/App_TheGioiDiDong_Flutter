import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_gioi_di_dong/core/app_colors.dart';
import 'package:the_gioi_di_dong/core/constants.dart';
import 'package:the_gioi_di_dong/core/utils.dart';
import 'package:the_gioi_di_dong/models/category_model.dart';
import 'package:the_gioi_di_dong/models/product_model.dart';
import 'package:the_gioi_di_dong/providers/cart_provider.dart';
import 'package:the_gioi_di_dong/screens/cart/cart_screen.dart';
import 'package:the_gioi_di_dong/screens/category/product_detail_screen.dart';
import 'package:the_gioi_di_dong/screens/category/products_by_category_screen.dart';
import 'package:the_gioi_di_dong/screens/compare/compare_picker_screen.dart';
import 'package:the_gioi_di_dong/screens/filter/filter_screen.dart';
import 'package:the_gioi_di_dong/services/api_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openFilterScreen(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 320),
        reverseTransitionDuration: const Duration(milliseconds: 220),
        pageBuilder: (_, _, _) => const FilterScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );

          return FadeTransition(
            opacity: curvedAnimation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.04),
                end: Offset.zero,
              ).animate(curvedAnimation),
              child: child,
            ),
          );
        },
      ),
    );
  }

  void _openCart(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CartScreen()),
    );
  }

  void _openComparePicker(BuildContext context, Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ComparePickerScreen(baseProduct: product),
      ),
    );
  }

  void _addToCart(BuildContext context, Product product) {
    context.read<CartProvider>().addItem(
      product.id,
      product.name,
      product.price,
      product.imageUrl ?? 'hp_pavilion_15_1.jpg',
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã thêm ${product.name} vào giỏ!'),
        duration: const Duration(seconds: 1),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.primaryThis,
            expandedHeight: 100,
            floating: true,
            pinned: true,
            elevation: 0,
            centerTitle: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(color: AppColors.primaryThis),
              titlePadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              title: Row(
                children: [
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          AppConstants.defaultRadius,
                        ),
                      ),
                      child: TextField(
                        readOnly: true,
                        onTap: () => _openFilterScreen(context),
                        decoration: const InputDecoration(
                          hintText: 'Bạn tìm gì...',
                          hintStyle: TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.grey,
                            size: 20,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.only(top: 0),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => _openCart(context),
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        const Icon(
                          Icons.shopping_cart_outlined,
                          color: Colors.black,
                          size: 24,
                        ),
                        Consumer<CartProvider>(
                          builder: (context, cart, child) {
                            if (cart.itemCount == 0) return const SizedBox();

                            return Positioned(
                              right: -5,
                              top: 5,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '${cart.itemCount}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(12),
              height: 160,
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
                image: const DecorationImage(
                  image: NetworkImage(
                    'https://cdn.tgdd.vn/Files/2016/11/18/915169/2209a8e7cb17f54fc6e9a0ee207a027d9c04a18292f560f201pimgpsh_fullsize_distr_800x300.png',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              height: 100,
              padding: const EdgeInsets.symmetric(vertical: 10),
              color: Colors.white,
              child: FutureBuilder<List<CategoryModel>>(
                future: ApiService.getCategories(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError ||
                      !snapshot.hasData ||
                      snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        'Chưa có danh mục',
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  final categories = snapshot.data!;

                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final iconData = _categoryIcon(category.name);

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductsByCategoryScreen(
                                categoryId: category.id,
                                categoryName: category.name,
                              ),
                            ),
                          );
                        },
                        child: SizedBox(
                          width: 80,
                          child: Column(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.grey[100],
                                radius: 24,
                                child: Icon(
                                  iconData,
                                  color: Colors.black87,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                category.name,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(AppConstants.defaultPadding),
              child: Text(
                'MÁY TÍNH BÁN CHẠY',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
          FutureBuilder<List<Product>>(
            future: ApiService.fetchProducts(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(50),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                );
              }

              if (snapshot.hasError) {
                return SliverToBoxAdapter(
                  child: Center(child: Text('Lỗi: ${snapshot.error}')),
                );
              }

              final products = snapshot.data ?? [];

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.75,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    return _buildProductCard(context, products[index]);
                  }, childCount: products.length),
                ),
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }

  IconData _categoryIcon(String name) {
    final normalizedName = name.toLowerCase();
    if (normalizedName.contains('laptop') ||
        normalizedName.contains('máy tính')) {
      return Icons.laptop_mac;
    }
    if (normalizedName.contains('phụ kiện') ||
        normalizedName.contains('chuột')) {
      return Icons.mouse;
    }
    if (normalizedName.contains('màn hình')) return Icons.monitor;
    if (normalizedName.contains('máy in')) return Icons.print;
    if (normalizedName.contains('linh kiện') ||
        normalizedName.contains('ram')) {
      return Icons.memory;
    }
    if (normalizedName.contains('tai nghe') ||
        normalizedName.contains('âm thanh')) {
      return Icons.headset;
    }
    return Icons.category;
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(8),
                ),
                child: Image.asset(
                  product.assetImagePath,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: const Icon(
                        Icons.laptop_mac,
                        size: 50,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          AppUtils.formatCurrency(product.price),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.priceRed,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      _IconActionButton(
                        icon: Icons.compare_arrows,
                        color: Colors.blue,
                        tooltip: 'So sánh',
                        onTap: () => _openComparePicker(context, product),
                      ),
                      const SizedBox(width: 6),
                      _IconActionButton(
                        icon: Icons.add_shopping_cart,
                        color: AppColors.primaryThis,
                        tooltip: 'Thêm vào giỏ',
                        onTap: () => _addToCart(context, product),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  const _IconActionButton({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
      ),
    );
  }
}
