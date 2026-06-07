import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/utils.dart';
import '../../models/product_detail_model.dart';
import '../../models/product_model.dart';
import '../../services/api_service.dart';

class CompareScreen extends StatefulWidget {
  final Product firstProduct;
  final Product secondProduct;

  const CompareScreen({
    super.key,
    required this.firstProduct,
    required this.secondProduct,
  });

  @override
  State<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends State<CompareScreen> {
  late Future<List<_CompareProduct>> _compareFuture;

  @override
  void initState() {
    super.initState();
    _compareFuture = _loadCompareProducts();
  }

  Future<List<_CompareProduct>> _loadCompareProducts() async {
    final products = [widget.firstProduct, widget.secondProduct];
    return Future.wait(
      products.map((product) async {
        final detail = await ApiService.getProductDetail(product.id);
        return _CompareProduct(product: product, detail: detail);
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'So sánh chi tiết',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: AppColors.primaryThis,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: FutureBuilder<List<_CompareProduct>>(
        future: _compareFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryThis),
            );
          }

          final items = snapshot.data ?? [];
          if (items.length < 2) return const SizedBox();

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                // Phần Header hiển thị 2 ảnh sản phẩm và giá
                _buildProductHeaders(items[0], items[1]),

                const Divider(height: 1, thickness: 1),

                // Phần Body hiển thị thông số so sánh
                _buildSpecRow(
                  'Tồn kho',
                  '${items[0].product.stock} ${items[0].product.unit}',
                  '${items[1].product.stock} ${items[1].product.unit}',
                  isEven: true,
                ),
                _buildSpecRow(
                  'Vi xử lý (CPU)',
                  items[0].detail?.cpu,
                  items[1].detail?.cpu,
                  isEven: false,
                ),
                _buildSpecRow(
                  'Bộ nhớ RAM',
                  items[0].detail?.ram,
                  items[1].detail?.ram,
                  isEven: true,
                ),
                _buildSpecRow(
                  'Ổ cứng (ROM)',
                  items[0].detail?.rom,
                  items[1].detail?.rom,
                  isEven: false,
                ),
                _buildSpecRow(
                  'Màn hình',
                  items[0].detail?.screen,
                  items[1].detail?.screen,
                  isEven: true,
                ),
                _buildSpecRow(
                  'Card đồ họa (VGA)',
                  items[0].detail?.vga,
                  items[1].detail?.vga,
                  isEven: false,
                ),
                _buildSpecRow(
                  'Tính năng khác',
                  items[0].detail?.other,
                  items[1].detail?.other,
                  isEven: true,
                ),

                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  // Header 2 sản phẩm (Ảnh + Tên + Giá)
  Widget _buildProductHeaders(_CompareProduct p1, _CompareProduct p2) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildProductHeaderItem(p1)),
        Container(width: 1, height: 250, color: Colors.grey[200]), // Vách ngăn
        Expanded(child: _buildProductHeaderItem(p2)),
      ],
    );
  }

  Widget _buildProductHeaderItem(_CompareProduct item) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            height: 120,
            padding: const EdgeInsets.all(8),
            child: Image.asset(
              item.product.assetImagePath,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) =>
                  const Icon(Icons.laptop_mac, size: 60, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            item.product.name,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            AppUtils.formatCurrency(item.product.price),
            style: const TextStyle(
              color: AppColors.priceRed,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  // Dòng thông số (Zebra-striping)
  Widget _buildSpecRow(
    String title,
    String? val1,
    String? val2, {
    required bool isEven,
  }) {
    final v1 = (val1 == null || val1.trim().isEmpty) ? 'Đang cập nhật' : val1;
    final v2 = (val2 == null || val2.trim().isEmpty) ? 'Đang cập nhật' : val2;

    return Container(
      color: isEven ? Colors.grey[50] : Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tiêu đề thông số
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.grey[200],
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // Giá trị của 2 bên
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      v1,
                      style: const TextStyle(fontSize: 13, height: 1.4),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Container(width: 1, color: Colors.grey[200]),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      v2,
                      style: const TextStyle(fontSize: 13, height: 1.4),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CompareProduct {
  final Product product;
  final ProductDetailModel? detail;

  const _CompareProduct({required this.product, required this.detail});
}
