import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_result.dart';
import '../../../core/repositories/notifications_repository.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_strings.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _loading = true;
  List<EmployeeNotificationItem> _items = [];
  String? _error;

  int get _unreadCount => _items.where((n) => !n.isRead).length;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    final res = await NotificationsRepository.getNotifications();
    if (!mounted) return;
    switch (res) {
      case ApiSuccess(:final data):
        setState(() { _items = data; _loading = false; });
      case ApiFailure(:final message):
        setState(() { _error = message; _loading = false; });
    }
  }

  Future<void> _markRead(EmployeeNotificationItem item) async {
    if (item.isRead) return;
    // Optimistic update
    setState(() {
      _items = _items.map((n) => n.id == item.id ? n.copyWith(isRead: true) : n).toList();
    });
    await NotificationsRepository.markAsRead(item.id);
  }

  Future<void> _markAllRead() async {
    setState(() {
      _items = _items.map((n) => n.copyWith(isRead: true)).toList();
    });
    await NotificationsRepository.markAllRead();
  }

  Future<void> _delete(EmployeeNotificationItem item) async {
    setState(() => _items.removeWhere((n) => n.id == item.id));
    await NotificationsRepository.deleteNotification(item.id);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppStrings.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Row(
                children: [
                  Text(l10n.notificationsTitle, style: AppTypography.h1),
                  if (_unreadCount > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$_unreadCount',
                        style: AppTypography.caption.copyWith(color: Colors.white),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (_unreadCount > 0)
              TextButton.icon(
                onPressed: _markAllRead,
                icon: const Icon(Icons.done_all, size: 18),
                label: Text(l10n.markAllRead),
              ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loading ? null : _load,
              tooltip: l10n.refreshAction,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? Center(child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 48, color: AppColors.error),
                        const SizedBox(height: 12),
                        Text(_error!, style: AppTypography.bodyMedium),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: _load,
                          icon: const Icon(Icons.refresh),
                          label: Text(l10n.retryAction),
                        ),
                      ],
                    ))
                  : _items.isEmpty
                      ? Center(child: Text(
                          l10n.noNotifications,
                          style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                        ))
                      : ListView.builder(
                          itemCount: _items.length,
                          itemBuilder: (context, i) {
                            final n = _items[i];
                            return _NotificationTile(
                              item: n,
                              onTap: () => _markRead(n),
                              onDelete: () => _delete(n),
                            );
                          },
                        ),
        ),
      ],
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.item,
    required this.onTap,
    required this.onDelete,
  });

  final EmployeeNotificationItem item;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  (IconData, Color) get _style => switch (item.category) {
        'leave'      => (Icons.event_available, AppColors.success),
        'payroll'    => (Icons.payments_outlined, AppColors.secondary),
        'attendance' => (Icons.schedule, AppColors.info),
        'policy'     => (Icons.campaign_outlined, AppColors.warning),
        _            => (Icons.notifications_outlined, AppColors.primary),
      };

  @override
  Widget build(BuildContext context) {
    final (icon, color) = _style;
    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppColors.error.withValues(alpha: 0.1),
        child: Icon(Icons.delete_outline, color: AppColors.error),
      ),
      onDismissed: (_) => onDelete(),
      child: Card(
        margin: const EdgeInsets.only(bottom: 10),
        color: item.isRead ? null : AppColors.primary.withValues(alpha: 0.04),
        child: ListTile(
          onTap: onTap,
          leading: CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.12),
            child: Icon(icon, color: color),
          ),
          title: Text(
            item.title,
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: item.isRead ? FontWeight.normal : FontWeight.w600,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 3),
              Text(item.body, style: AppTypography.bodySmall),
              const SizedBox(height: 3),
              Text(item.timeLabel, style: AppTypography.caption),
            ],
          ),
          isThreeLine: true,
          trailing: item.isRead
              ? null
              : Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
        ),
      ),
    );
  }
}
