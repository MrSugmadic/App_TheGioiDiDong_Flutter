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
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'So sánh sản phẩm',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primaryThis,
      ),
      body: FutureBuilder<List<_CompareProduct>>(
        future: _compareFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final items = snapshot.data ?? [];
          return SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: _CompareTable(items: items),
            ),
          );
        },
      ),
    );
  }
}

class _CompareTable extends StatelessWidget {
  final List<_CompareProduct> items;

  const _CompareTable({required this.items});

  @override
  Widget build(BuildContext context) {
    return Table(
      defaultColumnWidth: const FixedColumnWidth(170),
      border: TableBorder.all(color: Colors.grey.shade300),
      children: [
        _row('Sản phẩm', items.map(_productCell).toList(), height: 170),
        _row(
          'Giá',
          items
              .map(
                (item) =>
                    _textCell(AppUtils.formatCurrency(item.product.price)),
              )
              .toList(),
        ),
        _row(
          'Tồn kho',
          items
              .map(
                (item) => _textCell(
                  '${item.product.stock ?? 0} ${item.product.unit ?? ''}',
                ),
              )
              .toList(),
        ),
        _row('CPU', items.map((item) => _textCell(item.detail?.cpu)).toList()),
        _row('RAM', items.map((item) => _textCell(item.detail?.ram)).toList()),
        _row(
          'Ổ cứng',
          items.map((item) => _textCell(item.detail?.rom)).toList(),
        ),
        _row(
          'Màn hình',
          items.map((item) => _textCell(item.detail?.screen)).toList(),
        ),
        _row('VGA', items.map((item) => _textCell(item.detail?.vga)).toList()),
        _row(
          'Khác',
          items.map((item) => _textCell(item.detail?.other)).toList(),
        ),
      ],
    );
  }

  TableRow _row(String title, List<Widget> cells, {double height = 82}) {
    return TableRow(children: [_titleCell(title, height), ...cells]);
  }

  Widget _titleCell(String text, double height) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(10),
      color: AppColors.primaryThis.withValues(alpha: 0.16),
      alignment: Alignment.centerLeft,
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _textCell(String? text) {
    return Container(
      height: 82,
      padding: const EdgeInsets.all(10),
      color: Colors.white,
      alignment: Alignment.centerLeft,
      child: Text(
        text == null || text.trim().isEmpty ? 'Đang cập nhật' : text,
        style: const TextStyle(fontSize: 13, height: 1.3),
      ),
    );
  }

  Widget _productCell(_CompareProduct item) {
    return Container(
      height: 170,
      padding: const EdgeInsets.all(10),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Center(
              child: Image.asset(
                item.product.assetImagePath,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const Icon(
                  Icons.image_not_supported_outlined,
                  size: 42,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.product.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
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
