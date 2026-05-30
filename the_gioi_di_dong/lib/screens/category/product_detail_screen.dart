import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import '../../models/product_detail_model.dart';
import '../../services/api_service.dart';
import '../../core/app_colors.dart';
import 'package:the_gioi_di_dong/core/utils.dart'; // Giả sử AppUtils nằm đây
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chi tiết sản phẩm',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primaryThis,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Khu vực hình ảnh sản phẩm
            Container(
              height: 250,
              width: double.infinity,
              color: Colors.white,
              child: Image.asset(
                product.imageUrl ??
                    'assets/images/laptop.png', // Fallback image
                fit: BoxFit.contain,
              ),
            ),
            const Divider(height: 1),

            // Khu vực thông tin cơ bản
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppUtils.formatCurrency(product.price),
                    style: const TextStyle(
                      color: AppColors.priceRed,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Kho còn: ${product.stock} ${product.unit}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 20),

                  // Khu vực thông số kỹ thuật chi tiết
                  const Text(
                    'Thông số kỹ thuật',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  FutureBuilder<ProductDetailModel?>(
                    future: ApiService.getProductDetail(product.id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data == null) {
                        return const Text(
                          'Không có thông tin cấu hình chi tiết cho sản phẩm này.',
                        );
                      }

                      final detail = snapshot.data!;
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Table(
                          border: TableBorder.symmetric(
                            inside: BorderSide(color: Colors.grey[300]!),
                          ),
                          children: [
                            _buildTableRow('CPU', detail.cpu),
                            _buildTableRow('RAM', detail.ram),
                            _buildTableRow('Ổ cứng (ROM)', detail.rom),
                            _buildTableRow('Màn hình', detail.screen),
                            _buildTableRow('Card đồ họa', detail.vga),
                            if (detail.other.isNotEmpty)
                              _buildTableRow('Tính năng khác', detail.other),
                          ],
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

      // Thanh mua hàng dưới đáy - Đã được sửa thành nút Thêm vào giỏ hàng
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(12), // Tạo khoảng cách xung quanh nút
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, -2), // Bóng lên phía trên
            ),
          ],
        ),
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryThis, // Màu nền nút
            foregroundColor: Colors.white, // Màu chữ và icon
            minimumSize: const Size(
              double.infinity,
              50,
            ), // Chiều rộng tối đa, chiều cao 50
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8), // Bo góc
            ),
          ),
          icon: const Icon(Icons.add_shopping_cart), // Icon thêm vào giỏ
          label: const Text(
            'THÊM VÀO GIỎ HÀNG',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          onPressed: () async {
            // Gọi ApiService để thêm sản phẩm vào giỏ hàng
            final customerId = 'TK_KH001'; // Placeholder
            final quantity = 1;
            final success = await ApiService.addToCart(
              customerId,
              product.id,
              quantity,
            );

            if (context.mounted) {
              if (success) {
                // CHÍNH LÀ DÒNG NÀY ĐÂY: Hét lên cho app biết là có hàng mới!
                context.read<CartProvider>().addItem(
                  product.id,
                  product.name,
                  product.price,
                  product.imageUrl ?? 'laptop.jpg',
                );

                // Hiển thị thông báo thành công
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Đã thêm ${product.name} vào giỏ hàng.'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                // Hiển thị thông báo lỗi
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Lỗi khi thêm vào giỏ hàng. Vui lòng thử lại.',
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
        ),
      ),
    );
  }

  // Hàm helper để tạo một dòng trong bảng thông số kỹ thuật
  TableRow _buildTableRow(String title, String value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
        ),
        Padding(padding: const EdgeInsets.all(12.0), child: Text(value)),
      ],
    );
  }
}
