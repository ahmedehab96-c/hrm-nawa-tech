import 'package:flutter/material.dart';

import '../../../core/utils/text_direction_helper.dart';
import '../../../core/saas/company_context.dart';
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
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isCompact = width < _compactBreakpoint;
    final contentPadding = isCompact ? 16.0 : 28.0;

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
