import 'package:flutter/material.dart';

import '../../../core/utils/text_direction_helper.dart';
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

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: textDirectionForContext(context),
      child: Scaffold(
        body: Row(
          children: [
            AdminSidebar(
              collapsed: _sidebarCollapsed,
              onToggle: () => setState(() => _sidebarCollapsed = !_sidebarCollapsed),
            ),
            Expanded(
              child: Column(
                children: [
                  AdminTopBar(
                    onMenuTap: () =>
                        setState(() => _sidebarCollapsed = !_sidebarCollapsed),
                  ),
                  Expanded(
                    child: ColoredBox(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      child: Padding(
                        padding: const EdgeInsets.all(28),
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
