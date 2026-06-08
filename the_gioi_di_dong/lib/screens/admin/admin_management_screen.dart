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
    if (widget.icon == Icons.inventory_2_outlined) {
      final products = await ApiService.fetchProducts();
      return products.map(_productItem).toList();
    }
    if (widget.icon == Icons.category_outlined) {
      final categories = await ApiService.getCategories();
      return categories.map(_categoryItem).toList();
    }
    if (widget.icon == Icons.receipt_long_outlined) {
      final orders = await ApiService.fetchAdminOrders();
      return orders.map(_orderItem).toList();
    }
    if (widget.icon == Icons.people_outline) {
      final accounts = await ApiService.fetchAdminAccounts();
      return accounts.map(_accountItem).toList();
    }
    if (widget.icon == Icons.notifications_active_outlined) {
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
      title: 'Đơn hàng #$id',
      subtitle:
          '${order['trangThai'] ?? 'Chưa rõ'} • ${AppUtils.formatCurrency(_toDouble(order['thanhTien']))}',
      leading: Icons.receipt_long_outlined,
      badge: order['maKh']?.toString() ?? '',
      data: {
        'trangThai': order['trangThai']?.toString() ?? '',
        'hoTen': order['hoTen']?.toString() ?? '',
        'soDienThoai': order['soDienThoai']?.toString() ?? '',
        'diaChi': order['diaChi']?.toString() ?? '',
        'ngayLap': order['ngayLap']?.toString() ?? '',
        'thanhTien': _toDouble(order['thanhTien']),
      },
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
    if (item.type == _AdminType.order) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AdminOrderProcessScreen(orderId: item.id),
        ),
      );
      if (mounted) _reload();
      return;
    }

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => _AdminEditDialog(item: item),
    );
    if (result == null) return;

    try {
      await ApiService.adminPatch(_patchPath(item), result);
      if (!mounted) return;
      _reload();
      _showMessage('Đã cập nhật ${item.title}', isSuccess: true);
    } catch (e) {
      if (!mounted) return;
      _showMessage('Lỗi cập nhật: $e', isError: true);
    }
  }

  Future<void> _deleteItem(_AdminItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
            SizedBox(width: 8),
            Text('Xóa dữ liệu?', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'Bạn chắc chắn muốn xóa "${item.title}" không?',
          style: const TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Hủy',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Xóa ngay'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await ApiService.adminDelete(_deletePath(item));
      if (!mounted) return;
      _reload();
      _showMessage('Đã xóa ${item.title}', isSuccess: true);
    } catch (e) {
      if (!mounted) return;
      _showMessage('Lỗi xóa: $e', isError: true);
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

  void _showMessage(
    String message, {
    bool isSuccess = false,
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess
            ? Colors.green
            : (isError ? Colors.red : Colors.black87),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  double _toDouble(Object? value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: AppColors.primaryThis,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Tải lại',
            onPressed: _reload,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: FutureBuilder<List<_AdminItem>>(
        future: _itemsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryThis),
            );
          }
          if (snapshot.hasError) {
            return _AdminEmptyState(
              icon: Icons.wifi_off_rounded,
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
            color: AppColors.primaryThis,
            onRefresh: () async => _reload(),
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = items[index];
                return _AdminListTile(
                  item: item,
                  onTap: item.type == _AdminType.order
                      ? () => _editItem(item)
                      : null,
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

class AdminOrderProcessScreen extends StatefulWidget {
  final String orderId;

  const AdminOrderProcessScreen({super.key, required this.orderId});

  @override
  State<AdminOrderProcessScreen> createState() =>
      _AdminOrderProcessScreenState();
}

class _AdminOrderProcessScreenState extends State<AdminOrderProcessScreen> {
  static const _statuses = [
    'Chờ xác nhận',
    'Đã xác nhận',
    'Đang chuẩn bị hàng',
    'Đang giao hàng',
    'Hoàn tất',
  ];

  late Future<Map<String, dynamic>> _orderFuture;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _orderFuture = ApiService.fetchAdminOrderDetail(widget.orderId);
  }

  void _reload() {
    setState(() {
      _orderFuture = ApiService.fetchAdminOrderDetail(widget.orderId);
    });
  }

  Future<void> _updateStatus(String status) async {
    setState(() => _isUpdating = true);
    try {
      await ApiService.adminPatch(
        'orders/${Uri.encodeComponent(widget.orderId)}/status',
        {'trangThai': status},
      );
      if (!mounted) return;
      _reload();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã cập nhật: $status'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi cập nhật: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  String _nextStatus(String current) {
    final index = _statuses.indexOf(current);
    if (index < 0) return _statuses.first;
    if (index >= _statuses.length - 1) return current;
    return _statuses[index + 1];
  }

  bool _isReached(String current, String status) {
    if (current == 'Đã hủy') return false;
    final currentIndex = _statuses.indexOf(current);
    final statusIndex = _statuses.indexOf(status);
    return currentIndex >= statusIndex && currentIndex >= 0 && statusIndex >= 0;
  }

  double _toDouble(Object? value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Xử lý đơn #${widget.orderId}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: AppColors.primaryThis,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _orderFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryThis),
            );
          }
          if (snapshot.hasError ||
              snapshot.data == null ||
              snapshot.data!.isEmpty) {
            return _AdminEmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'Không tải được đơn hàng',
              message: '${snapshot.error ?? 'Đơn hàng không tồn tại'}',
            );
          }

          final order = snapshot.data!;
          final status = order['trangThai']?.toString() ?? 'Chờ xác nhận';
          final items = (order['items'] as List<dynamic>? ?? []);
          final nextStatus = _nextStatus(status);
          final canAdvance = status != 'Đã hủy' && nextStatus != status;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _infoCard(order),
                const SizedBox(height: 16),
                _processCard(status),
                const SizedBox(height: 16),
                _itemsCard(items),
                const SizedBox(height: 24),
                Row(
                  children: [
                    if (canAdvance)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isUpdating
                              ? null
                              : () => _updateStatus(nextStatus),
                          icon: const Icon(
                            Icons.arrow_forward_rounded,
                            size: 20,
                          ),
                          label: Text(
                            'Chuyển "$nextStatus"',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryThis,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                    if (canAdvance) const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isUpdating
                            ? null
                            : () => _updateStatus('Đã hủy'),
                        icon: const Icon(Icons.cancel_outlined, size: 20),
                        label: const Text(
                          'Hủy đơn',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.redAccent,
                          side: const BorderSide(color: Colors.redAccent),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _infoCard(Map<String, dynamic> order) {
    return _adminCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.receipt_long, color: AppColors.primaryThis),
              const SizedBox(width: 8),
              Text(
                'Mã đơn: #${order['maHd'] ?? widget.orderId}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          _infoRow(Icons.person_outline, '${order['hoTen'] ?? 'Chưa rõ'}'),
          _infoRow(
            Icons.phone_outlined,
            '${order['soDienThoai'] ?? 'Chưa rõ'}',
          ),
          _infoRow(
            Icons.location_on_outlined,
            '${order['diaChi'] ?? 'Chưa rõ'}',
          ),
          _infoRow(Icons.calendar_today_outlined, '${order['ngayLap'] ?? ''}'),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tổng thanh toán:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              Text(
                AppUtils.formatCurrency(_toDouble(order['thanhTien'])),
                style: const TextStyle(
                  color: AppColors.priceRed,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _processCard(String currentStatus) {
    return _adminCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Trục thời gian xử lý',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),
          ..._statuses.asMap().entries.map((entry) {
            final index = entry.key;
            final status = entry.value;
            final reached = _isReached(currentStatus, status);
            final isLast = index == _statuses.length - 1;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: reached
                            ? AppColors.primaryThis
                            : Colors.grey[300],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check,
                        size: 12,
                        color: reached ? Colors.white : Colors.transparent,
                      ),
                    ),
                    if (!isLast)
                      Container(
                        width: 2,
                        height: 30,
                        color: reached
                            ? AppColors.primaryThis
                            : Colors.grey[300],
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 1),
                    child: Text(
                      status,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: reached
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: reached ? Colors.black87 : Colors.grey,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
          if (currentStatus == 'Đã hủy')
            Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 12, color: Colors.white),
                ),
                const SizedBox(width: 16),
                const Text(
                  'Đã hủy',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _itemsCard(List<dynamic> items) {
    return _adminCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sản phẩm',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          if (items.isEmpty)
            const Text(
              'Chưa có chi tiết sản phẩm',
              style: TextStyle(color: Colors.grey),
            ),
          ...items.whereType<Map<String, dynamic>>().map((item) {
            final image = item['hinhAnh']?.toString();
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Image.asset(
                      Product.imageAssetPath(image),
                      width: 48,
                      height: 48,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => const Icon(
                        Icons.laptop_mac,
                        size: 40,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['tenSp']?.toString() ?? 'Sản phẩm',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'x${item['soLuong'] ?? 0} • ${AppUtils.formatCurrency(_toDouble(item['thanhTien']))}',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _adminCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        'Sửa thông tin',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.item.title,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 16),
            ..._fields.map((field) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TextField(
                  controller: _controllers[field.key],
                  keyboardType: field.isNumber ? TextInputType.number : null,
                  decoration: InputDecoration(
                    labelText: field.label,
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.primaryThis,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Hủy',
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _buildPayload()),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryThis,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
          ),
          child: const Text(
            'Lưu thay đổi',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

class _AdminListTile extends StatelessWidget {
  final _AdminItem item;
  final VoidCallback? onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AdminListTile({
    required this.item,
    this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryThis.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    item.leading,
                    color: AppColors.primaryThis,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.grey[700], fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  children: [
                    IconButton(
                      tooltip: item.type == _AdminType.order
                          ? 'Xử lý đơn'
                          : 'Sửa',
                      onPressed: onEdit,
                      icon: Icon(
                        item.type == _AdminType.order
                            ? Icons.manage_history_outlined
                            : Icons.edit_outlined,
                        color: Colors.blueGrey,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Xóa',
                      onPressed: onDelete,
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.redAccent,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 60, color: Colors.grey[400]),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                height: 1.4,
                fontSize: 14,
              ),
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
