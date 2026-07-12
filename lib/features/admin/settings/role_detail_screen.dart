import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_strings.dart';

class RoleDetailScreen extends StatelessWidget {
  const RoleDetailScreen({super.key, this.roleId});

  final String? roleId;

  String get _roleName {
    switch (roleId) {
      case 'admin':
        return 'مدير النظام';
      case 'hr':
        return 'مدير الموارد البشرية';
      case 'employee':
        return 'موظف';
      default:
        return 'الدور';
    }
  }

  String get _roleDesc {
    switch (roleId) {
      case 'admin':
        return 'صلاحيات كاملة - إدارة النظام والشركات والمستخدمين';
      case 'hr':
        return 'إدارة الموظفين، الحضور، الإجازات، الرواتب';
      case 'employee':
        return 'عرض بياناته فقط - الحضور، الإجازات، الرواتب';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppStrings.of(context);
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
              Text(l10n.roleDetailTitle, style: AppTypography.h1),
            ],
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                        child: Icon(Icons.security, color: AppColors.primary),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_roleName, style: AppTypography.h3),
                            const SizedBox(height: 4),
                            Text(_roleDesc, style: AppTypography.bodySmall),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(l10n.permissionsTitle, style: AppTypography.h4),
                  const SizedBox(height: 16),
                  _PermissionItem('لوحة التحكم', true),
                  _PermissionItem('إدارة الموظفين', roleId != 'employee'),
                  _PermissionItem('الحضور', true),
                  _PermissionItem('الإجازات', true),
                  _PermissionItem('الرواتب', roleId != 'employee'),
                  _PermissionItem('التوظيف', roleId == 'admin'),
                  _PermissionItem('الإعدادات', roleId == 'admin'),
                  const SizedBox(height: 24),
                  OutlinedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.rolePermissionsServer),
                          backgroundColor: AppColors.info,
                        ),
                      );
                    },
                    child: Text(l10n.editPermissionsButton),
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

class _PermissionItem extends StatelessWidget {
  const _PermissionItem(this.label, this.enabled);

  final String label;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            enabled ? Icons.check_circle : Icons.cancel,
            size: 20,
            color: enabled ? AppColors.success : AppColors.textMuted,
          ),
          const SizedBox(width: 12),
          Text(label, style: AppTypography.bodyMedium),
        ],
      ),
    );
  }
}
