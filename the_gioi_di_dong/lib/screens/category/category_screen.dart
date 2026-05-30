import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/category_model.dart';
import '../../core/app_colors.dart';
import 'products_by_category_screen.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh mục sản phẩm', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryThis,
        foregroundColor: Colors.black,
        centerTitle: true,
      ),
      backgroundColor: Colors.grey[100],
      // DÙNG FUTURE BUILDER ĐỂ LOAD API
      body: FutureBuilder<List<CategoryModel>>(
        future: ApiService.getCategories(),
        builder: (context, snapshot) {
          // 1. Đang tải dữ liệu
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          // 2. Lỗi mạng hoặc lỗi code
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }

          // 3. Không có dữ liệu
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Chưa có danh mục nào trong Database.'));
          }

          // 4. Có dữ liệu -> Vẽ ra màn hình
          final categories = snapshot.data!;
          
          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: GridView.builder(
              itemCount: categories.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, 
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.1,
              ),
              itemBuilder: (context, index) {
                final cat = categories[index];
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      // Thay cái SnackBar cũ bằng đoạn này:
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProductsByCategoryScreen(
                            categoryId: cat.id,       // truyền id
                            categoryName: cat.name,   // truyền tên
                          ),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(15),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha: 0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha: 0.1), // Cố định 1 màu nền
                              shape: BoxShape.circle,
                            ),
                            // Dùng icon mặc định do DB chưa lưu tên Icon
                            child: const Icon(Icons.category, size: 45, color: Colors.blue),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            cat.name, // LẤY TÊN TỪ DATABASE RA ĐÂY
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}