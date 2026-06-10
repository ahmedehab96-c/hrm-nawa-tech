import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/saas/subscription_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/widgets/hrm_logo.dart';

class AdminSidebar extends StatelessWidget {
  const AdminSidebar({
    super.key,
    required this.collapsed,
    required this.onToggle,
  });

  final bool collapsed;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: collapsed ? 72 : 260,
      color: AppColors.sidebarBg,
      child: Column(
        children: [
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: collapsed ? MainAxisAlignment.center : MainAxisAlignment.spaceBetween,
            children: [
              if (!collapsed)
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: const HrmLogo(height: 36),
                ),
              IconButton(
                icon: Icon(
                  collapsed ? Icons.menu_open : Icons.menu,
                  color: Colors.white70,
                ),
                onPressed: onToggle,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: AnimatedBuilder(
              animation: SubscriptionController.instance,
              builder: (context, _) {
                final sub = SubscriptionController.instance;
                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: [
                    _NavItem(
                      icon: Icons.dashboard_outlined,
                      label: l10n.dashboard,
                      path: '/admin',
                      collapsed: collapsed,
                    ),
                    _NavItem(
                      icon: Icons.people_outline,
                      label: l10n.employees,
                      path: '/admin/employees',
                      collapsed: collapsed,
                    ),
                    _NavItem(
                      icon: Icons.access_time,
                      label: l10n.attendance,
                      path: '/admin/attendance',
                      collapsed: collapsed,
                    ),
                    _NavItem(
                      icon: Icons.event_note_outlined,
                      label: l10n.leave,
                      path: '/admin/leave',
                      collapsed: collapsed,
                    ),
                    _NavItem(
                      icon: Icons.payments_outlined,
                      label: l10n.payroll,
                      path: '/admin/payroll',
                      collapsed: collapsed,
                    ),
                    if (sub.recruitmentEnabled)
                      _NavItem(
                        icon: Icons.work_outline,
                        label: l10n.recruitment,
                        path: '/admin/recruitment',
                        collapsed: collapsed,
                      ),
                    const Divider(color: Colors.white24, height: 32),
                    _NavItem(
                      icon: Icons.settings_outlined,
                      label: l10n.settings,
                      path: '/admin/settings',
                      collapsed: collapsed,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.path,
    required this.collapsed,
  });

  final IconData icon;
  final String label;
  final String path;
  final bool collapsed;

  @override
  Widget build(BuildContext context) {
    final isActive = GoRouterState.of(context).uri.path == path;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        leading: Icon(
          icon,
          color: isActive ? AppColors.sidebarActive : Colors.white70,
          size: 24,
        ),
        title: collapsed
            ? null
            : Text(
                label,
                style: TextStyle(
                  color: isActive ? AppColors.sidebarActive : Colors.white70,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        selected: isActive,
        selectedTileColor: AppColors.sidebarActive.withValues(alpha: 0.2),
        onTap: () => context.go(path),
      ),
    );
  }
}
