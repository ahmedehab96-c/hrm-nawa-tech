import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/locale/locale_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_scope.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/ai/ai_assistant_panel.dart';
import '../../../core/repositories/auth_repository.dart';
import '../../../core/api/current_user.dart';

class AdminTopBar extends StatelessWidget {
  const AdminTopBar({
    super.key,
    required this.onMenuTap,
  });

  final VoidCallback onMenuTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final themeNotifier = ThemeScope.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: onMenuTap,
          ),
          const SizedBox(width: 16),
          // Company switcher
          PopupMenuButton<String>(
            offset: const Offset(0, 48),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: colorScheme.outline),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.business, size: 20),
                  const SizedBox(width: 8),
                  Text(l10n.demoCompanyLabel, style: AppTypography.bodyMedium),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_drop_down, size: 24),
                ],
              ),
            ),
            itemBuilder: (context) => [
              PopupMenuItem(value: '1', child: Text(l10n.demoCompanyLabel)),
              PopupMenuItem(value: '2', child: Text(l10n.addCompanyTitle)),
            ],
            onSelected: (value) {
              if (value == '2') context.push('/admin/companies/add');
            },
          ),
          const Spacer(),
          // أدوات الذكاء الاصطناعي
          PopupMenuButton<String>(
            tooltip: l10n.aiPanelTitle,
            offset: const Offset(0, 44),
            icon: const Icon(Icons.smart_toy_outlined),
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'chat',
                child: Text(Localizations.localeOf(context).languageCode == 'ar'
                    ? 'محادثة المساعد'
                    : 'Assistant chat'),
              ),
              PopupMenuItem(
                value: 'center',
                child: Text(Localizations.localeOf(context).languageCode == 'ar'
                    ? 'مركز أوامر AI'
                    : 'AI command center'),
              ),
            ],
            onSelected: (value) {
              if (value == 'chat') {
                showDialog(
                  context: context,
                  builder: (context) => Dialog(
                    backgroundColor: Colors.transparent,
                    child: AiAssistantPanel(),
                  ),
                );
                return;
              }
              context.push('/admin/ai');
            },
          ),
          const SizedBox(width: 8),
          // Language toggle: AR ↔ EN
          Builder(builder: (ctx) {
            final locale = Localizations.localeOf(ctx);
            final isAr   = locale.languageCode == 'ar';
            return Tooltip(
              message: l10n.language,
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => LocaleController.instance.setLocale(
                    isAr ? const Locale('en') : const Locale('ar')),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(color: colorScheme.outline),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isAr ? 'EN' : 'AR',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ),
            );
          }),
          const SizedBox(width: 4),
          // Dark / Light mode toggle | الوضع الليلي / النهاري
          IconButton(
            icon: Icon(
              themeNotifier.isDark ? Icons.light_mode : Icons.dark_mode,
              color: colorScheme.onSurface,
            ),
            onPressed: () => themeNotifier.toggle(),
            tooltip: themeNotifier.isDark ? l10n.lightMode : l10n.darkMode,
          ),
          const SizedBox(width: 8),
          // Notifications
          IconButton(
            icon: Badge(
              label: const Text('3'),
              child: const Icon(Icons.notifications_outlined),
            ),
            onPressed: () => context.push('/admin/notifications'),
          ),
          const SizedBox(width: 8),
          // User profile
          PopupMenuButton<String>(
            offset: const Offset(0, 48),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  backgroundColor: colorScheme.primary,
                  child: FutureBuilder<String?>(
                    future: currentUserDisplayName(),
                    builder: (context, snapshot) {
                      final name = (snapshot.data ?? '').trim();
                      final char = name.isEmpty ? '—' : name[0];
                      return Text(char, style: const TextStyle(color: Colors.white));
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppLocalizations.of(context)!.sampleAdminName, style: AppTypography.bodyMedium),
                    Text(AppLocalizations.of(context)!.sampleAdminRole, style: AppTypography.caption),
                  ],
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
            itemBuilder: (context) {
              final l10n = AppLocalizations.of(context)!;
              return [
                PopupMenuItem(value: 'profile', child: Text(l10n.adminProfileMenu)),
                PopupMenuItem(value: 'settings', child: Text(l10n.settings)),
                PopupMenuItem(value: 'logout', child: Text(l10n.logout)),
              ];
            },
            onSelected: (value) async {
              if (value == 'profile') context.push('/admin/profile');
              if (value == 'settings') context.push('/admin/settings');
              if (value == 'logout') {
                await AuthRepository.logout();
                if (context.mounted) context.go('/login');
              }
            },
          ),
        ],
      ),
    );
  }
}
