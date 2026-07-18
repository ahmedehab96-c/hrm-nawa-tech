import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hrm_saas/core/api/api_result.dart';
import 'package:hrm_saas/core/widgets/responsive_helper.dart';
import 'package:hrm_saas/features/employee/notifications/data/notifications_repository.dart';
import 'package:hrm_saas/l10n/app_strings.dart';

class EmployeeShell extends StatefulWidget {
  const EmployeeShell({super.key, required this.child});
  final Widget child;

  @override
  State<EmployeeShell> createState() => _EmployeeShellState();
}

class _EmployeeShellState extends State<EmployeeShell> {
  int _unreadNotifications = 0;

  static const _paths = [
    '/employee',
    '/employee/attendance',
    '/employee/leave',
    '/employee/payslip',
    '/employee/notifications',
    '/employee/profile',
  ];

  @override
  void initState() {
    super.initState();
    _loadUnreadCount();
  }

  Future<void> _loadUnreadCount() async {
    final result = await NotificationsRepository.getNotifications();
    if (!mounted) return;
    if (result is ApiSuccess<List<EmployeeNotificationItem>>) {
      setState(() {
        _unreadNotifications = result.data.where((item) => !item.isRead).length;
      });
    }
  }

  int _selectedIndex(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    for (var i = _paths.length - 1; i > 0; i--) {
      if (path.startsWith(_paths[i])) return i;
    }
    return 0;
  }

  void _onSelect(int i) {
    context.go(_paths[i]);
    if (i == 4) {
      _loadUnreadCount();
    }
  }

  Widget _notificationIcon({required bool selected}) {
    final icon = Icon(
      selected ? Icons.notifications : Icons.notifications_outlined,
    );
    if (_unreadNotifications <= 0) {
      return icon;
    }

    return Badge(
      label: Text('$_unreadNotifications'),
      child: icon,
    );
  }

  List<_NavItem> _items(AppStrings l10n) => [
        _NavItem(
          icon: Icons.home_outlined,
          selectedIcon: Icons.home,
          label: l10n.employeeNavHome,
        ),
        _NavItem(
          icon: Icons.access_time_outlined,
          selectedIcon: Icons.access_time,
          label: l10n.employeeNavAttendance,
        ),
        _NavItem(
          icon: Icons.event_note_outlined,
          selectedIcon: Icons.event_note,
          label: l10n.employeeNavLeave,
        ),
        _NavItem(
          icon: Icons.receipt_long_outlined,
          selectedIcon: Icons.receipt_long,
          label: l10n.employeeNavPayroll,
        ),
        _NavItem(
          icon: Icons.notifications_outlined,
          selectedIcon: Icons.notifications,
          label: l10n.employeeNavNotifications,
          iconBuilder: _notificationIcon,
        ),
        _NavItem(
          icon: Icons.person_outline,
          selectedIcon: Icons.person,
          label: l10n.employeeNavProfile,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppStrings.of(context);
    final r = ResponsiveHelper.of(context);
    final selected = _selectedIndex(context);
    final items = _items(l10n);

    switch (r.navLayout) {
      case NavLayout.bottomBar:
        return Scaffold(
          body: SafeArea(top: false, child: widget.child),
          bottomNavigationBar: NavigationBar(
            selectedIndex: selected,
            labelBehavior: r.width < Breakpoints.compactNav
                ? NavigationDestinationLabelBehavior.onlyShowSelected
                : NavigationDestinationLabelBehavior.alwaysShow,
            onDestinationSelected: _onSelect,
            destinations: [
              for (final item in items)
                NavigationDestination(
                  icon: item.iconBuilder?.call(selected: false) ??
                      Icon(item.icon),
                  selectedIcon: item.iconBuilder?.call(selected: true) ??
                      Icon(item.selectedIcon),
                  label: item.label,
                ),
            ],
          ),
        );
      case NavLayout.navigationRail:
        return Scaffold(
          body: SafeArea(
            child: Row(
              children: [
                NavigationRail(
                  selectedIndex: selected,
                  onDestinationSelected: _onSelect,
                  labelType: r.railShowAllLabels
                      ? NavigationRailLabelType.all
                      : NavigationRailLabelType.selected,
                  destinations: [
                    for (final item in items)
                      NavigationRailDestination(
                        icon: item.iconBuilder?.call(selected: false) ??
                            Icon(item.icon),
                        selectedIcon: item.iconBuilder?.call(selected: true) ??
                            Icon(item.selectedIcon),
                        label: Text(
                          item.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
                const VerticalDivider(width: 1),
                Expanded(child: widget.child),
              ],
            ),
          ),
        );
      case NavLayout.sideNav:
        return Scaffold(
          body: SafeArea(
            child: Row(
              children: [
                _SideNav(
                  selectedIndex: selected,
                  items: items,
                  onSelect: _onSelect,
                  width: r.sideNavWidth,
                ),
                const VerticalDivider(width: 1),
                Expanded(child: widget.child),
              ],
            ),
          ),
        );
    }
  }
}

class _NavItem {
  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    this.iconBuilder,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final Widget Function({required bool selected})? iconBuilder;
}

class _SideNav extends StatelessWidget {
  const _SideNav({
    required this.selectedIndex,
    required this.items,
    required this.onSelect,
    required this.width,
  });

  final int selectedIndex;
  final List<_NavItem> items;
  final ValueChanged<int> onSelect;
  final double width;

  @override
  Widget build(BuildContext context) {
    final l10n = AppStrings.of(context);
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surfaceContainerLow,
      child: SizedBox(
        width: width,
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
              child: Text(
                l10n.employeeAppSubtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            for (var i = 0; i < items.length; i++)
              ListTile(
                selected: i == selectedIndex,
                selectedTileColor:
                    theme.colorScheme.primary.withValues(alpha: 0.12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                leading: items[i].iconBuilder?.call(selected: i == selectedIndex) ??
                    Icon(
                      i == selectedIndex
                          ? items[i].selectedIcon
                          : items[i].icon,
                    ),
                title: Text(
                  items[i].label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () => onSelect(i),
              ),
          ],
        ),
      ),
    );
  }
}
