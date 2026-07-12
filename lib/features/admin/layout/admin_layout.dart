import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/text_direction_helper.dart';
import '../../../core/saas/company_context.dart';
import '../../../l10n/app_strings.dart';
import '../sidebar/admin_sidebar.dart';
import '../topbar/admin_topbar.dart';

class AdminLayout extends StatefulWidget {
  const AdminLayout({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<AdminLayout> createState() => _AdminLayoutState();
}

class _AdminLayoutState extends State<AdminLayout> {
  bool _sidebarCollapsed = false;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  static const _compactBreakpoint = 900.0;

  @override
  void initState() {
    super.initState();
    CompanyContext.instance.load();
    CompanyContext.instance.addListener(_onCompany);
  }

  void _onCompany() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    CompanyContext.instance.removeListener(_onCompany);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isCompact = width < _compactBreakpoint;
    final contentPadding = isCompact ? 16.0 : 28.0;
    final l10n = AppStrings.of(context);
    final company = CompanyContext.instance;

    return Directionality(
      textDirection: textDirectionForContext(context),
      child: Scaffold(
        key: _scaffoldKey,
        drawer: isCompact
            ? Drawer(
                child: AdminSidebar(
                  collapsed: false,
                  onToggle: () => Navigator.of(context).pop(),
                ),
              )
            : null,
        body: Row(
          children: [
            if (!isCompact)
              AdminSidebar(
                collapsed: _sidebarCollapsed,
                onToggle: () => setState(() => _sidebarCollapsed = !_sidebarCollapsed),
              ),
            Expanded(
              child: Column(
                children: [
                  AdminTopBar(
                    compact: isCompact,
                    onMenuTap: () {
                      if (isCompact) {
                        _scaffoldKey.currentState?.openDrawer();
                        return;
                      }
                      setState(() => _sidebarCollapsed = !_sidebarCollapsed);
                    },
                  ),
                  if (company.isTrialExpired)
                    Material(
                      color: AppColors.error.withValues(alpha: 0.12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                l10n.trialExpiredBanner,
                                style: AppTypography.bodySmall.copyWith(color: AppColors.error),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (company.isTrialPlan && company.trialDaysRemaining != null)
                    Material(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          children: [
                            Icon(Icons.schedule, color: AppColors.primary, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                l10n.trialDaysLeft(company.trialDaysRemaining!),
                                style: AppTypography.caption.copyWith(color: AppColors.primary),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  Expanded(
                    child: ColoredBox(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      child: Padding(
                        padding: EdgeInsets.all(contentPadding),
                        child: widget.child,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
