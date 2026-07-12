import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_config.dart';
import '../../../core/repositories/auth_repository.dart';
import '../../../core/saas/company_context.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_strings.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  Map<String, dynamic>? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
    CompanyContext.instance.load();
  }

  Future<void> _loadUser() async {
    final user = await ApiConfig.getUser();
    if (!mounted) return;
    setState(() => _user = user);
  }

  static String _avatarInitial(String name) {
    final t = name.trim();
    if (t.isEmpty) return '?';
    return t.substring(0, 1);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppStrings.of(context);
    final name = _user?['name']?.toString() ?? l10n.sampleAdminName;
    final email = _user?['email']?.toString() ?? 'admin@demo.com';

    return ListenableBuilder(
      listenable: CompanyContext.instance,
      builder: (context, _) {
        final company = CompanyContext.instance;
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => context.pop(),
                  ),
                  const SizedBox(width: 8),
                  Text(l10n.adminProfileMenu, style: AppTypography.h1),
                ],
              ),
              const SizedBox(height: 32),
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: AppColors.primary,
                      child: Text(
                        _avatarInitial(name),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(name, style: AppTypography.h3),
                    Text(l10n.sampleAdminRole, style: AppTypography.bodySmall),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Card(
                child: Column(
                  children: [
                    _ProfileRow(icon: Icons.email, label: l10n.email, value: email),
                    const Divider(height: 1),
                    _ProfileRow(
                      icon: Icons.phone,
                      label: l10n.phone,
                      value: company.phone.isNotEmpty ? company.phone : '—',
                    ),
                    const Divider(height: 1),
                    _ProfileRow(
                      icon: Icons.business,
                      label: l10n.companyLabelRow,
                      value: company.displayName,
                    ),
                    const Divider(height: 1),
                    _ProfileRow(icon: Icons.badge, label: l10n.roleLabelRow, value: l10n.roleAdminTitle),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => context.push('/admin/settings'),
                      icon: const Icon(Icons.settings),
                      label: Text(l10n.settings),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () async {
                        await AuthRepository.logout();
                        if (context.mounted) context.go('/login');
                      },
                      icon: const Icon(Icons.logout),
                      label: Text(l10n.logout),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(label, style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
      subtitle: Text(value, style: AppTypography.bodyMedium),
    );
  }
}
