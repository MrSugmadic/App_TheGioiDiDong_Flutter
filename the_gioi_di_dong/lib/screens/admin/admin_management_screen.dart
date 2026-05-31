import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/utils.dart';
import '../../models/category_model.dart';
import '../../models/notification_model.dart';
import '../../models/product_model.dart';
import '../../services/api_service.dart';

class AdminManagementScreen extends StatefulWidget {
  final String title;
  final IconData icon;

  const AdminManagementScreen({
    super.key,
    required this.title,
    required this.icon,
  });

  @override
  State<AdminManagementScreen> createState() => _AdminManagementScreenState();
}

class _AdminManagementScreenState extends State<AdminManagementScreen> {
  late Future<List<_AdminItem>> _itemsFuture;

  @override
  void initState() {
    super.initState();
    _itemsFuture = _loadItems();
  }

  Future<List<_AdminItem>> _loadItems() async {
    if (widget.title.contains('sản phẩm')) {
      final products = await ApiService.fetchProducts();
      return products.map(_productItem).toList();
    }
    if (widget.title.contains('danh mục')) {
      final categories = await ApiService.getCategories();
      return categories.map(_categoryItem).toList();
    }
    if (widget.title.contains('đơn hàng')) {
      final orders = await ApiService.fetchAdminOrders();
      return orders.map(_orderItem).toList();
    }
    if (widget.title.contains('người dùng')) {
      final accounts = await ApiService.fetchAdminAccounts();
      return accounts.map(_accountItem).toList();
    }
    if (widget.title.contains('thông báo')) {
      final notifications = await ApiService.fetchNotifications();
      return notifications.map(_notificationItem).toList();
    }
    return [];
  }

  void _reload() {
    setState(() {
      _itemsFuture = _loadItems();
    });
  }

  _AdminItem _productItem(Product product) {
    return _AdminItem(
      type: _AdminType.product,
      id: product.id,
      title: product.name,
      subtitle:
          '${AppUtils.formatCurrency(product.price)} • Còn ${product.stock ?? 0} ${product.unit ?? ''}',
      leading: Icons.laptop_mac,
      badge: product.id,
      data: {
        'tenSp': product.name,
        'donGia': product.price,
        'soLuongTon': product.stock ?? 0,
      },
    );
  }

  _AdminItem _categoryItem(CategoryModel category) {
    return _AdminItem(
      type: _AdminType.category,
      id: category.id,
      title: category.name,
      subtitle: 'Mã danh mục: ${category.id}',
      leading: Icons.category_outlined,
      badge: category.id,
      data: {'tenLoai': category.name},
    );
  }

  _AdminItem _orderItem(Map<String, dynamic> order) {
    final id = order['maHd']?.toString() ?? '';
    return _AdminItem(
      type: _AdminType.order,
      id: id,
      title: 'Đơn hàng $id',
      subtitle:
          '${order['trangThai'] ?? 'Chưa rõ'} • ${AppUtils.formatCurrency(_toDouble(order['thanhTien']))}',
      leading: Icons.receipt_long_outlined,
      badge: order['maKh']?.toString() ?? '',
      data: {'trangThai': order['trangThai']?.toString() ?? ''},
    );
  }

  _AdminItem _accountItem(Map<String, dynamic> account) {
    final id = account['id']?.toString() ?? '';
    return _AdminItem(
      type: _AdminType.account,
      id: id,
      title: account['email']?.toString() ?? 'Chưa có email',
      subtitle: 'Vai trò: ${account['role'] ?? ''}',
      leading: Icons.person_outline,
      badge: id,
      data: {'role': account['role']?.toString() ?? ''},
    );
  }

  _AdminItem _notificationItem(AppNotification notification) {
    return _AdminItem(
      type: _AdminType.notification,
      id: '${notification.id}',
      title: notification.title,
      subtitle: '${notification.type} • ${notification.content}',
      leading: notification.read
          ? Icons.notifications_none
          : Icons.notifications_active_outlined,
      badge: '#${notification.id}',
      data: {
        'title': notification.title,
        'content': notification.content,
        'type': notification.type,
      },
    );
  }

  Future<void> _editItem(_AdminItem item) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => _AdminEditDialog(item: item),
    );
    if (result == null) return;

    try {
      await ApiService.adminPatch(_patchPath(item), result);
      if (!mounted) return;
      _reload();
      _showMessage('Đã cập nhật ${item.title}');
    } catch (e) {
      if (!mounted) return;
      _showMessage('Lỗi cập nhật: $e');
    }
  }

  Future<void> _deleteItem(_AdminItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa dữ liệu?'),
        content: Text('Bạn chắc chắn muốn xóa "${item.title}" không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await ApiService.adminDelete(_deletePath(item));
      if (!mounted) return;
      _reload();
      _showMessage('Đã xóa ${item.title}');
    } catch (e) {
      if (!mounted) return;
      _showMessage('Lỗi xóa: $e');
    }
  }

  String _patchPath(_AdminItem item) {
    switch (item.type) {
      case _AdminType.product:
        return 'products/${Uri.encodeComponent(item.id)}';
      case _AdminType.category:
        return 'categories/${Uri.encodeComponent(item.id)}';
      case _AdminType.order:
        return 'orders/${Uri.encodeComponent(item.id)}/status';
      case _AdminType.account:
        return 'accounts/${Uri.encodeComponent(item.id)}/role';
      case _AdminType.notification:
        return 'notifications/${Uri.encodeComponent(item.id)}';
    }
  }

  String _deletePath(_AdminItem item) {
    switch (item.type) {
      case _AdminType.product:
        return 'products/${Uri.encodeComponent(item.id)}';
      case _AdminType.category:
        return 'categories/${Uri.encodeComponent(item.id)}';
      case _AdminType.order:
        return 'orders/${Uri.encodeComponent(item.id)}';
      case _AdminType.account:
        return 'accounts/${Uri.encodeComponent(item.id)}';
      case _AdminType.notification:
        return 'notifications/${Uri.encodeComponent(item.id)}';
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  double _toDouble(Object? value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F1F1),
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primaryThis,
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Tải lại',
            onPressed: _reload,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<List<_AdminItem>>(
        future: _itemsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _AdminEmptyState(
              icon: Icons.wifi_off,
              title: 'Không tải được dữ liệu',
              message: '${snapshot.error}',
            );
          }

          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return _AdminEmptyState(
              icon: widget.icon,
              title: 'Chưa có dữ liệu',
              message: 'Mục này hiện chưa có bản ghi để hiển thị.',
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _reload(),
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = items[index];
                return _AdminListTile(
                  item: item,
                  onEdit: () => _editItem(item),
                  onDelete: () => _deleteItem(item),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _AdminEditDialog extends StatefulWidget {
  final _AdminItem item;

  const _AdminEditDialog({required this.item});

  @override
  State<_AdminEditDialog> createState() => _AdminEditDialogState();
}

class _AdminEditDialogState extends State<_AdminEditDialog> {
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    for (final field in _fields) {
      _controllers[field.key] = TextEditingController(
        text: widget.item.data[field.key]?.toString() ?? '',
      );
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  List<_EditField> get _fields {
    switch (widget.item.type) {
      case _AdminType.product:
        return const [
          _EditField('tenSp', 'Tên sản phẩm'),
          _EditField('donGia', 'Đơn giá', isNumber: true),
          _EditField('soLuongTon', 'Số lượng tồn', isNumber: true),
        ];
      case _AdminType.category:
        return const [_EditField('tenLoai', 'Tên danh mục')];
      case _AdminType.order:
        return const [_EditField('trangThai', 'Trạng thái')];
      case _AdminType.account:
        return const [_EditField('role', 'Vai trò')];
      case _AdminType.notification:
        return const [
          _EditField('title', 'Tiêu đề'),
          _EditField('content', 'Nội dung'),
          _EditField('type', 'Loại'),
        ];
    }
  }

  Map<String, dynamic> _buildPayload() {
    final payload = <String, dynamic>{};
    for (final field in _fields) {
      final text = _controllers[field.key]!.text.trim();
      payload[field.key] = field.isNumber ? num.tryParse(text) ?? 0 : text;
    }
    return payload;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Sửa ${widget.item.title}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: _fields.map((field) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TextField(
                controller: _controllers[field.key],
                keyboardType: field.isNumber ? TextInputType.number : null,
                decoration: InputDecoration(
                  labelText: field.label,
                  border: const OutlineInputBorder(),
                ),
              ),
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _buildPayload()),
          child: const Text('Lưu'),
        ),
      ],
    );
  }
}

class _AdminListTile extends StatelessWidget {
  final _AdminItem item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AdminListTile({
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryThis.withValues(alpha: 0.2),
          child: Icon(item.leading, color: Colors.black87),
        ),
        title: Text(
          item.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            item.subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'Sửa',
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined),
            ),
            IconButton(
              tooltip: 'Xóa',
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _AdminEmptyState({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 72, color: Colors.black54),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

enum _AdminType { product, category, order, account, notification }

class _EditField {
  final String key;
  final String label;
  final bool isNumber;

  const _EditField(this.key, this.label, {this.isNumber = false});
}

class _AdminItem {
  final _AdminType type;
  final String id;
  final String title;
  final String subtitle;
  final IconData leading;
  final String badge;
  final Map<String, dynamic> data;

  const _AdminItem({
    required this.type,
    required this.id,
    required this.title,
    required this.subtitle,
    required this.leading,
    required this.badge,
    required this.data,
  });
}
