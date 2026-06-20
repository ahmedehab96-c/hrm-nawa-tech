import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/saas/subscription_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/hrm_logo.dart';
import '../../../l10n/app_localizations.dart';

// ─── AdminSidebar ─────────────────────────────────────────────────────────────
/// Animated sidebar for the admin panel. Collapses to icon-only mode.
/// الشريط الجانبي للوحة الأدمن. يتقلص إلى وضع الأيقونات فقط.
///
/// [collapsed] — Whether it is collapsed (72 px) or expanded (260 px).
///               هل هو مطوي (72px) أم موسّع (260px).
/// [onToggle]  — Callback to toggle the collapsed state.
///               callback لتغيير الحالة.
class AdminSidebar extends StatelessWidget {
  const AdminSidebar({
    super.key,
    required this.collapsed,
    required this.onToggle,
  });

  final bool          collapsed;
  final VoidCallback  onToggle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // All nav items defined in one place — add a new page by appending a single line here
    // تعريف عناصر الـ nav من مكان واحد — لإضافة صفحة جديدة: أضف سطراً هنا فقط
    final sub = SubscriptionController.instance;
    final items = <({IconData icon, String label, String path})>[
      (icon: Icons.dashboard_outlined,   label: l10n.dashboard,   path: '/admin'),
      (icon: Icons.people_outline,       label: l10n.employees,   path: '/admin/employees'),
      (icon: Icons.access_time,          label: l10n.attendance,  path: '/admin/attendance'),
      (icon: Icons.event_note_outlined,  label: l10n.leave,       path: '/admin/leave'),
      (icon: Icons.trending_up_outlined, label: _labelPerformance(context), path: '/admin/performance'),
      (icon: Icons.payments_outlined,    label: l10n.payroll,     path: '/admin/payroll'),
      if (sub.recruitmentEnabled)
        (icon: Icons.work_outline,       label: l10n.recruitment, path: '/admin/recruitment'),
      if (sub.aiCloudFeaturesEnabled)
        (icon: Icons.auto_awesome_outlined, label: l10n.aiPanelTitle, path: '/admin/ai'),
      if (sub.aiCloudFeaturesEnabled)
        (icon: Icons.analytics_outlined, label: _labelReports(context), path: '/admin/reports'),
    ];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve:    Curves.easeInOut,
      width:    collapsed ? 72 : 260,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end:   Alignment.bottomCenter,
          colors: [Color(0xFF1E293B), Color(0xFF131E30)],
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Sidebar header: logo + collapse toggle | رأس الـ sidebar: لوجو + زر الطي
          if (collapsed)
            Column(
              children: [
                const HrmLogoIcon(size: 32),
                IconButton(
                  icon: const Icon(Icons.menu_open, color: Colors.white70),
                  onPressed: onToggle,
                ),
              ],
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const HrmLogo(height: 36),
                  IconButton(
                    icon: const Icon(Icons.menu, color: Colors.white70),
                    onPressed: onToggle,
                  ),
                ],
              ),
            ),
          const SizedBox(height: 24),
          // Navigation items | عناصر التنقل
          Expanded(
            child: AnimatedBuilder(
              animation: SubscriptionController.instance,
              builder: (context, child) => ListView(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                children: [
                  for (final it in items)
                    _NavItem(
                      icon:      it.icon,
                      label:     it.label,
                      path:      it.path,
                      collapsed: collapsed,
                    ),
                  const Divider(color: Colors.white24, height: 32),
                  _NavItem(
                    icon:      Icons.settings_outlined,
                    label:     l10n.settings,
                    path:      '/admin/settings',
                    collapsed: collapsed,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _labelPerformance(BuildContext context) =>
    Localizations.localeOf(context).languageCode == 'ar'
        ? 'الأداء'
        : 'Performance';

String _labelReports(BuildContext context) =>
    Localizations.localeOf(context).languageCode == 'ar'
        ? 'التقارير'
        : 'Reports';

// ─── _NavItem ─────────────────────────────────────────────────────────────────
/// A single navigation item in the sidebar with hover animation and active highlight.
/// عنصر تنقل واحد في الـ sidebar يُضيف تأثير hover وتمييز للصفحة النشطة تلقائياً.
class _NavItem extends StatefulWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.path,
    required this.collapsed,
  });

  final IconData icon;
  final String   label;
  final String   path;
  final bool     collapsed;

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final isActive = GoRouterState.of(context).uri.path == widget.path;
    final color = isActive ? AppColors.sidebarActive : Colors.white70;

    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit:  (_) => setState(() => _hovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.sidebarActive.withValues(alpha: 0.20)
                : _hovered
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListTile(
            leading:  Icon(widget.icon, color: color, size: 22),
            title:    widget.collapsed
                ? null
                : Text(
                    widget.label,
                    style: TextStyle(
                      color:      color,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                      fontSize:   14,
                    ),
                  ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            minLeadingWidth: 20,
            contentPadding: widget.collapsed
                ? const EdgeInsets.symmetric(horizontal: 16)
                : const EdgeInsets.symmetric(horizontal: 12),
            onTap: () => context.go(widget.path),
          ),
        ),
      ),
    );
  }
}
