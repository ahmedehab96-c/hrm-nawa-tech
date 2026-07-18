import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_result.dart';
import 'package:hrm_saas/features/employee/notifications/data/notifications_repository.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/text_direction_helper.dart';
import '../../../core/widgets/responsive_page.dart';
import '../../../l10n/app_strings.dart';

class EmployeeNotificationsScreen extends StatefulWidget {
  const EmployeeNotificationsScreen({super.key});

  @override
  State<EmployeeNotificationsScreen> createState() =>
      _EmployeeNotificationsScreenState();
}

class _EmployeeNotificationsScreenState
    extends State<EmployeeNotificationsScreen> {
  List<EmployeeNotificationItem> _items = [];
  bool _loading = true;
  String? _error;

  int get _unreadCount => _items.where((n) => !n.isRead).length;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    final result = await NotificationsRepository.getNotifications();
    if (!mounted) return;
    switch (result) {
      case ApiSuccess(:final data):
        setState(() { _items = data; _loading = false; });
      case ApiFailure(:final message):
        setState(() { _error = message; _loading = false; });
    }
  }

  Future<void> _markRead(EmployeeNotificationItem item) async {
    if (item.isRead) return;
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
    return Directionality(
      textDirection: textDirectionForContext(context),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          title: Text(
            l10n.employeeNotificationsTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          actions: [
            if (_unreadCount > 0)
              IconButton(
                onPressed: _markAllRead,
                tooltip: l10n.markAllRead,
                icon: Badge(
                  label: Text('$_unreadCount'),
                  child: const Icon(Icons.done_all),
                ),
              ),
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: l10n.refreshTooltip,
              onPressed: _loading ? null : _load,
            ),
          ],
        ),
        body: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final l10n = AppStrings.of(context);

    if (_loading) return const Center(child: CircularProgressIndicator());

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 16),
              Text(_error!, textAlign: TextAlign.center, style: AppTypography.bodyMedium),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _load,
                icon: const Icon(Icons.refresh),
                label: Text(l10n.retryAction),
              ),
            ],
          ),
        ),
      );
    }

    if (_items.isEmpty) {
      return ResponsivePage(
        scrollable: false,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.notifications_none, size: 64,
                  color: AppColors.textSecondary.withValues(alpha: 0.5)),
              const SizedBox(height: 16),
              Text(
                l10n.noNotifications,
                style: AppTypography.h4,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      );
    }

    final r = context.responsive;
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: r.pageMaxWidth),
        child: ListView.builder(
          padding: EdgeInsets.symmetric(
            horizontal: r.horizontalPadding,
            vertical: 16,
          ),
          itemCount: _items.length,
          itemBuilder: (context, i) {
            final item = _items[i];
            final (icon, color) = _styleForCategory(item.category);
            return Dismissible(
              key: ValueKey(item.id),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: AlignmentDirectional.centerEnd,
                padding: const EdgeInsetsDirectional.only(end: 20),
                color: AppColors.error.withValues(alpha: 0.1),
                child: Icon(Icons.delete_outline, color: AppColors.error),
              ),
              onDismissed: (_) => _delete(item),
              child: Card(
                margin: const EdgeInsets.only(bottom: 12),
                color: item.isRead
                    ? null
                    : AppColors.primary.withValues(alpha: 0.04),
                child: ListTile(
                  onTap: () => _markRead(item),
                  leading: CircleAvatar(
                    backgroundColor: color.withValues(alpha: 0.15),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  title: Text(
                    item.title,
                    style: AppTypography.bodyLarge.copyWith(
                      fontWeight:
                          item.isRead ? FontWeight.normal : FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        item.body,
                        style: AppTypography.bodySmall,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.timeLabel.isEmpty ? '—' : item.timeLabel,
                        style: AppTypography.caption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  isThreeLine: true,
                  trailing: item.isRead
                      ? null
                      : Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  (IconData, Color) _styleForCategory(String? category) => switch (category) {
        'leave'      => (Icons.event_available, AppColors.success),
        'payroll'    => (Icons.payments_outlined, AppColors.secondary),
        'attendance' => (Icons.schedule, AppColors.info),
        'policy'     => (Icons.campaign_outlined, AppColors.warning),
        _            => (Icons.notifications_outlined, AppColors.info),
      };
}
