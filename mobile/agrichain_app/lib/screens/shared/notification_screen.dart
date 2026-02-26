import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/error_card.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  List<Map<String, dynamic>> _notifications = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final api = ref.read(apiServiceProvider);
    final result = await api.getNotifications();

    if (result.success && result.data != null) {
      final raw = result.data!;
      // Real API: {success, data: [...]}
      // Mock: {notifications: [...]}
      List<dynamic> list;
      if (raw['data'] is List) {
        list = raw['data'];
      } else if (raw['notifications'] is List) {
        list = raw['notifications'];
      } else {
        list = [];
      }
      setState(() {
        _notifications = List<Map<String, dynamic>>.from(list);
        _loading = false;
      });
    } else {
      setState(() {
        _error = result.error ?? 'Failed to load notifications';
        _loading = false;
      });
    }
  }

  String _typeIcon(String type) {
    switch (type) {
      case 'alert':
        return '⚠️';
      case 'price':
        return '💰';
      case 'harvest':
        return '🌾';
      case 'welcome':
        return '🎉';
      default:
        return '📢';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Notifications 🔔'),
        backgroundColor: Colors.white,
        foregroundColor: AgriChainTheme.darkText,
        elevation: 0,
      ),
      body: _loading
          ? const LoadingIndicator(message: 'Loading notifications...')
          : _error != null
          ? ErrorCard(
              message: ErrorCard.friendlyMessage(_error!),
              onRetry: _loadNotifications,
            )
          : _notifications.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: Text(
                  'No notifications yet 🔕',
                  style: TextStyle(
                    fontSize: 16,
                    color: AgriChainTheme.greyText,
                  ),
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final n = _notifications[i];
                final isUnread = n['read'] == false;
                final type = n['type'] ?? '';
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isUnread
                        ? Colors.blue.withValues(alpha: 0.04)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isUnread)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(top: 6, right: 8),
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                        )
                      else
                        const SizedBox(width: 16),
                      Text(
                        _typeIcon(type),
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              n['title'] ?? '',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isUnread
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              n['body'] ?? '',
                              style: const TextStyle(
                                fontSize: 14,
                                color: AgriChainTheme.greyText,
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              n['timestamp'] ?? n['time'] ?? '',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
