import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/notification_service.dart';
import '../utils/app_colors.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: AppColors.darkBrown,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.darkBrown),
        actions: [
          Consumer<NotificationService>(
            builder: (context, svc, _) {
              if (svc.notifications.isEmpty) return const SizedBox.shrink();
              return TextButton(
                onPressed: svc.markAllRead,
                child: const Text(
                  'Mark all read',
                  style: TextStyle(color: AppColors.rust, fontSize: 13),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<NotificationService>(
        builder: (context, svc, _) {
          final items = svc.notifications;
          if (items.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.notifications_none, size: 64, color: AppColors.subtext),
                  SizedBox(height: 12),
                  Text(
                    'No notifications yet',
                    style: TextStyle(color: AppColors.subtext, fontSize: 16),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Order updates will appear here',
                    style: TextStyle(color: AppColors.subtext, fontSize: 13),
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
            itemBuilder: (context, index) {
              final n = items[index];
              return _NotificationTile(notification: n);
            },
          );
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
    final n = notification;
    return InkWell(
      onTap: () => context.read<NotificationService>().markRead(n.id),
      child: Container(
        color: n.isRead ? Colors.transparent : AppColors.rust.withValues(alpha: 0.05),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: _iconBg(n.title),
                shape: BoxShape.circle,
              ),
              child: Icon(_icon(n.title), color: Colors.white, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          n.title,
                          style: TextStyle(
                            fontWeight: n.isRead ? FontWeight.w500 : FontWeight.w700,
                            color: AppColors.darkBrown,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      if (!n.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.rust,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    n.body,
                    style: const TextStyle(color: AppColors.subtext, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _timeAgo(n.time),
                    style: const TextStyle(color: AppColors.subtext, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _icon(String title) {
    if (title.contains('ready')) return Icons.check_circle_outline;
    if (title.contains('prepar') || title.contains('Prepar')) return Icons.restaurant;
    if (title.contains('placed')) return Icons.receipt_long_outlined;
    if (title.contains('complet') || title.contains('Complet')) return Icons.done_all;
    if (title.contains('cancel') || title.contains('Cancel')) return Icons.cancel_outlined;
    return Icons.notifications_outlined;
  }

  Color _iconBg(String title) {
    if (title.contains('ready')) return Colors.green;
    if (title.contains('prepar') || title.contains('Prepar')) return AppColors.orange;
    if (title.contains('placed')) return AppColors.rust;
    if (title.contains('complet') || title.contains('Complet')) return Colors.blueGrey;
    if (title.contains('cancel') || title.contains('Cancel')) return Colors.red;
    return AppColors.darkBrown;
  }

  String _timeAgo(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
