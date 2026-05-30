import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_gioi_di_dong/core/app_colors.dart';
import 'package:the_gioi_di_dong/models/notification_model.dart';
import 'package:the_gioi_di_dong/services/api_service.dart';
import 'package:the_gioi_di_dong/services/local_notification_service.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final List<AppNotification> _notifications = [];
  WebSocket? _socket;
  StreamSubscription<dynamic>? _socketSubscription;
  bool _loading = true;
  bool _connected = false;
  String? _error;
  String? _maTk;

  @override
  void initState() {
    super.initState();
    _initNotifications();
  }

  Future<void> _initNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    _maTk = prefs.getString('maTk');
    await _loadNotifications();
    await _connectWebSocket();
  }

  Future<void> _loadNotifications() async {
    try {
      final notifications = await ApiService.fetchNotifications(maTk: _maTk);
      if (!mounted) return;
      setState(() {
        _notifications
          ..clear()
          ..addAll(notifications);
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _connectWebSocket() async {
    try {
      final socket = await WebSocket.connect(
        ApiService.notificationWsUrl(maTk: _maTk),
      );
      _socket = socket;
      if (!mounted) return;
      setState(() {
        _connected = true;
        _error = null;
      });

      _socketSubscription = socket.listen(
        _handleSocketMessage,
        onDone: _handleSocketDisconnected,
        onError: (_) => _handleSocketDisconnected(),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _connected = false;
        _error = 'Khong ket noi duoc WebSocket: $e';
      });
    }
  }

  void _handleSocketMessage(dynamic message) {
    final data = jsonDecode(message.toString()) as Map<String, dynamic>;
    final notification = AppNotification.fromJson(data);

    if (!mounted) return;
    setState(() {
      _notifications.removeWhere((item) => item.id == notification.id);
      _notifications.insert(0, notification);
    });
    LocalNotificationService.show(notification);
  }

  void _handleSocketDisconnected() {
    if (!mounted) return;
    setState(() {
      _connected = false;
    });
  }

  Future<void> _sendDemoNotification() async {
    try {
      await ApiService.sendDemoNotification();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Khong gui duoc thong bao demo: $e')),
      );
    }
  }

  @override
  void dispose() {
    _socketSubscription?.cancel();
    _socket?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: AppColors.primaryThis,
        title: const Text(
          'Thong bao',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Gui thong bao demo',
            onPressed: _sendDemoNotification,
            icon: const Icon(Icons.bolt),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: _connected ? Colors.green[50] : Colors.orange[50],
            child: Row(
              children: [
                Icon(
                  _connected ? Icons.wifi : Icons.wifi_off,
                  size: 18,
                  color: _connected ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 8),
                Text(
                  _connected ? 'Dang nhan realtime' : 'Mat ket noi realtime',
                  style: TextStyle(
                    color: _connected ? Colors.green[800] : Colors.orange[800],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            ),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_notifications.isEmpty) {
      return const Center(
        child: Text('Chua co thong bao', style: TextStyle(color: Colors.grey)),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadNotifications,
      child: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: _notifications.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final notification = _notifications[index];
          return _NotificationTile(notification: notification);
        },
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotification notification;

  const _NotificationTile({required this.notification});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primaryThis.withValues(alpha: 0.2),
            child: const Icon(
              Icons.notifications,
              color: AppColors.primaryThis,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  notification.content,
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                ),
                const SizedBox(height: 8),
                Text(
                  _formatTime(notification.createdAt),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    return '$hour:$minute $day/$month/${value.year}';
  }
}
