import 'package:flutter/material.dart';
import 'package:the_gioi_di_dong/core/app_colors.dart';
import 'package:the_gioi_di_dong/core/constants.dart';
import 'package:the_gioi_di_dong/core/utils.dart';
import 'package:the_gioi_di_dong/providers/cart_provider.dart';
import 'package:provider/provider.dart';
import 'package:the_gioi_di_dong/screens/cart/cart_screen.dart';
import 'package:the_gioi_di_dong/models/product_model.dart';
import 'package:the_gioi_di_dong/services/api_service.dart';
import 'package:the_gioi_di_dong/screens/category/product_detail_screen.dart';
import 'package:the_gioi_di_dong/screens/filter/filter_screen.dart';
import '../../models/category_model.dart';
import '../../screens/category/products_by_category_screen.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: CustomScrollView(
        slivers: [
          // 1. App Bar với thanh tìm kiếm (Pinned)
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
                        onTap: () {
                          _openFilterScreen(context);
                        },
                        decoration: const InputDecoration(
                          hintText: "Bạn tìm gì...",
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
                    onTap: () {
                      // Mở trang Giỏ Hàng khi bấm vào icon
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CartScreen(),
                        ),
                      );
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        const Icon(
                          Icons.shopping_cart_outlined,
                          color: Colors.black,
                          size: 24,
                        ),

                        // Hiển thị số lượng từ Nhà kho (CartProvider)
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

          // 2. Banner Khuyến mãi
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

          // 3. Quick Categories (Lấy từ API Database)
          SliverToBoxAdapter(
            child: Container(
              height: 100,
              padding: const EdgeInsets.symmetric(vertical: 10),
              color: Colors.white,
              child: FutureBuilder<List<CategoryModel>>(
                future: ApiService.getCategories(),
                builder: (context, snapshot) {
                  // Đang tải
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // Bị lỗi hoặc không có dữ liệu
                  if (snapshot.hasError ||
                      !snapshot.hasData ||
                      snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        "Chưa có danh mục",
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  final categories = snapshot.data!;

                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final cat = categories[index];

                      // 👉 Mẹo "nảy số" Icon: Tìm từ khóa trong tên danh mục để gán Icon tương ứng
                      IconData iconData = Icons.category; // Icon mặc định
                      String catName = cat.name.toLowerCase();

                      if (catName.contains('laptop') ||
                          catName.contains('máy tính')) {
                        iconData = Icons.laptop_mac;
                      } else if (catName.contains('phụ kiện') ||
                          catName.contains('chuột')) {
                        iconData = Icons.mouse;
                      } else if (catName.contains('màn hình')) {
                        iconData = Icons.monitor;
                      } else if (catName.contains('máy in')) {
                        iconData = Icons.print;
                      } else if (catName.contains('linh kiện') ||
                          catName.contains('ram')) {
                        iconData = Icons.memory;
                      } else if (catName.contains('tai nghe') ||
                          catName.contains('âm thanh')) {
                        iconData = Icons.headset;
                      }

                      return GestureDetector(
                        onTap: () {
                          // 👉 Bấm vào đây cũng bay thẳng sang trang Sản phẩm theo loại
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductsByCategoryScreen(
                                categoryId: cat.id,
                                categoryName: cat.name,
                              ),
                            ),
                          );
                        },
                        child: SizedBox(
                          width: 80,
                          child: Column(
                            children: [
                              CircleAvatar(
                                backgroundColor:
                                    Colors.grey[100], // Màu nền nhạt cho đẹp
                                radius: 24,
                                child: Icon(
                                  iconData,
                                  color: Colors.black87,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                cat.name,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1, // Tránh chữ dài quá bị rớt dòng
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
                "MÁY TÍNH BÁN CHẠY",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),

          // 5. Grid Sản phẩm - LẤY TỪ JAVA API
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
                  child: Center(child: Text("Lỗi: ${snapshot.error}")),
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
                    final item = products[index];
                    return _buildProductCard(context, item);
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

  // 👉 Đổi tham số nhận vào là 1 object Product
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
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name, // Lấy tên
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 5),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppUtils.formatCurrency(product.price), // Lấy giá
                        style: const TextStyle(
                          color: AppColors.priceRed,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),

                      // Nút bấm thêm vào giỏ
                      GestureDetector(
                        onTap: () {
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
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryThis.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Icon(
                            Icons.add_shopping_cart,
                            color: AppColors.primaryThis,
                            size: 20,
                          ),
                        ),
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
