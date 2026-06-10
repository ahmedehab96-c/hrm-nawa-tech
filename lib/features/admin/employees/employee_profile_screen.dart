import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/api/api_result.dart';
import '../../../core/repositories/employees_repository.dart';
import '../../../l10n/app_localizations.dart';

class EmployeeDetailScreen extends StatefulWidget {
  const EmployeeDetailScreen({super.key, this.employeeId});

  final String? employeeId;

  @override
  State<EmployeeDetailScreen> createState() => _EmployeeDetailScreenState();
}

class _EmployeeDetailScreenState extends State<EmployeeDetailScreen> {
  bool _loading = true;
  EmployeeItem? _employee;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (widget.employeeId == null) {
      setState(() => _loading = false);
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    final res = await EmployeesRepository.getEmployee(widget.employeeId!);
    if (!mounted) return;

    if (res is ApiSuccess<EmployeeItem>) {
      setState(() {
        _employee = res.data;
        _loading = false;
      });
    } else {
      setState(() {
        _error = (res as ApiFailure<EmployeeItem>).message;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final name = _employee?.name ?? '';
    final avatarChar = name.trim().isEmpty ? '—' : name.trim()[0];
    final subtitleParts = <String>[];
    final position = _employee?.position?.trim();
    final department = _employee?.department?.trim();
    if (position != null && position.isNotEmpty) subtitleParts.add(position);
    if (department != null && department.isNotEmpty) subtitleParts.add(department);
    final subtitle = subtitleParts.isNotEmpty ? subtitleParts.join(' • ') : '—';
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
              Text(l10n.employeeProfile, style: AppTypography.h1),
              const Spacer(),
              FilledButton.icon(
                onPressed: widget.employeeId == null ? null : () => context.push('/admin/employees/${widget.employeeId}'),
                icon: const Icon(Icons.edit),
                label: Text(l10n.edit),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  if (_loading)
                    const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 48,
                          backgroundColor: AppColors.primary,
                          child: Text(
                            avatarChar,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(name.isEmpty ? '—' : name, style: AppTypography.h3),
                        Text(subtitle, style: AppTypography.bodySmall),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(l10n.active, style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 32),
                  _loading
                      ? const SizedBox.shrink()
                      : _InfoRow(icon: Icons.email, label: l10n.email, value: _employee?.email ?? '—'),
                  _loading
                      ? const SizedBox.shrink()
                      : _InfoRow(icon: Icons.phone, label: l10n.phone, value: _employee?.phone ?? '—'),
                  _loading
                      ? const SizedBox.shrink()
                      : _InfoRow(icon: Icons.calendar_today, label: l10n.hireDate, value: _employee?.hireDate ?? '—'),
                  _loading
                      ? const SizedBox.shrink()
                      : _InfoRow(icon: Icons.attach_money, label: l10n.baseSalaryLabel, value: _employee?.baseSalary ?? '—'),
                  const Divider(height: 24),
                  Text(l10n.insuranceInfo, style: AppTypography.h4),
                  const SizedBox(height: 8),
                  _loading
                      ? const SizedBox.shrink()
                      : _InfoRow(
                          icon: Icons.health_and_safety,
                          label: l10n.insuranceType,
                          value: _employee?.insuranceType ?? '—',
                        ),
                  _loading
                      ? const SizedBox.shrink()
                      : _InfoRow(
                          icon: Icons.badge_outlined,
                          label: l10n.policyNumber,
                          value: _employee?.insurancePolicyNumber ?? '—',
                        ),
                  _loading
                      ? const SizedBox.shrink()
                      : _InfoRow(
                          icon: Icons.business,
                          label: l10n.insuranceCompany,
                          value: _employee?.insuranceType ?? '—',
                        ),
                ],
              ),
            ),
          ),
          if (!_loading && _error != null)
            Padding(
              padding: const EdgeInsets.only(top: 12, left: 20, right: 20),
              child: Text(
                _error!,
                style: AppTypography.bodySmall.copyWith(color: AppColors.error),
              ),
            ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, size: 24, color: AppColors.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTypography.caption),
                Text(value, style: AppTypography.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
