import 'package:flutter/material.dart';
import 'package:the_gioi_di_dong/core/app_colors.dart';
import 'package:the_gioi_di_dong/core/utils.dart';
import 'package:the_gioi_di_dong/models/product_detail_model.dart';
import 'package:the_gioi_di_dong/models/product_model.dart';
import 'package:the_gioi_di_dong/screens/compare/compare_picker_screen.dart';
import 'package:the_gioi_di_dong/services/api_service.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  void _openComparePicker(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ComparePickerScreen(baseProduct: product),
      ),
    );
  }

  Future<void> _addToCart(BuildContext context) async {
    final success = await ApiService.addToCart('TK_KH001', product.id, 1);
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Đã thêm vào giỏ hàng!' : 'Lỗi thêm vào giỏ!'),
      ),
    );
  }

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
            Container(
              height: 250,
              width: double.infinity,
              color: Colors.white,
              child: Image.asset(
                product.assetImagePath,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.image_not_supported_outlined,
                    size: 80,
                    color: Colors.grey,
                  );
                },
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
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
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(12),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black87,
                  minimumSize: const Size(double.infinity, 50),
                  side: const BorderSide(color: AppColors.primaryThis),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.compare_arrows),
                label: const Text(
                  'SO SÁNH',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                onPressed: () => _openComparePicker(context),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryThis,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text(
                  'THÊM VÀO GIỎ',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                onPressed: () => _addToCart(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  TableRow _buildTableRow(String title, String value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
        ),
        Padding(padding: const EdgeInsets.all(12), child: Text(value)),
      ],
    );
  }
}
