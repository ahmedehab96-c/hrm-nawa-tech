import 'package:flutter/material.dart';

import '../../../core/api/api_result.dart';
import '../../../core/api/current_user.dart';
import '../../../core/api/api_config.dart';
import 'package:hrm_saas/features/employee/payslip/data/payroll_repository.dart';
import '../../../core/services/payslip_pdf_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/text_direction_helper.dart';
import '../../../core/widgets/responsive_page.dart';
import '../../../l10n/app_strings.dart';

class EmployeePayslipScreen extends StatefulWidget {
  const EmployeePayslipScreen({super.key});

  @override
  State<EmployeePayslipScreen> createState() => _EmployeePayslipScreenState();
}

class _EmployeePayslipScreenState extends State<EmployeePayslipScreen> {
  bool _loading = true;
  bool _generatingPdf = false;
  String? _error;
  String _month = '';
  List<String> _monthChoices = [];
  PayslipItem? _slip;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final thisM = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    final prev = DateTime(now.year, now.month - 1, 1);
    final prevM = '${prev.year}-${prev.month.toString().padLeft(2, '0')}';
    _month = thisM;
    _monthChoices = [thisM, prevM];
    _load();
  }

  Future<void> _downloadPdf() async {
    if (_slip == null) return;
    setState(() => _generatingPdf = true);
    try {
      final data = PayslipPdfData.fromSlip(_slip!, month: _month);
      await PayslipPdfService.sharePayslip(data);
    } finally {
      if (mounted) setState(() => _generatingPdf = false);
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    await ApiConfig.load();
    final res = await PayrollRepository.getPayroll(_month);

    PayslipItem? slip;
    String? error;
    if (res is ApiSuccess<List<PayslipItem>>) {
      // Backend scopes payroll to the authenticated employee's own records,
      // so the first item is always the current user's payslip.
      // Fuzzy name matching is only used in demo mode as a fallback.
      if (ApiConfig.useApi && ApiConfig.baseUrl != null && ApiConfig.baseUrl!.isNotEmpty) {
        slip = res.data.isNotEmpty ? res.data.first : null;
      } else {
        final name = await currentUserDisplayName();
        for (final p in res.data) {
          if (name != null &&
              (p.employeeName.toLowerCase().contains(name.toLowerCase()) ||
                  name.toLowerCase().contains(p.employeeName.toLowerCase()))) {
            slip = p;
            break;
          }
        }
        slip ??= res.data.isNotEmpty ? res.data.first : null;
      }
    } else if (res is ApiFailure<List<PayslipItem>>) {
      error = res.message;
    }

    if (!mounted) return;
    final l10n = AppStrings.of(context);
    setState(() {
      _loading = false;
      _slip = slip;
      _error = error ?? (slip == null ? l10n.payslipNotFound : null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppStrings.of(context);
    final s = _slip;

    return Directionality(
      textDirection: textDirectionForContext(context),
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.payslip),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loading ? null : _load,
              tooltip: l10n.refreshAction,
            ),
            if (_generatingPdf)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: SizedBox(
                  width: 20, height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else
              IconButton(
                icon: const Icon(Icons.download),
                tooltip: l10n.download,
                onPressed: _slip == null ? null : _downloadPdf,
              ),
          ],
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : ResponsivePage(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<String>(
                      key: ValueKey(_month),
                      isExpanded: true,
                      initialValue:
                          _monthChoices.contains(_month) ? _month : _monthChoices.first,
                      decoration: InputDecoration(
                        labelText: l10n.payslipMonthField,
                        prefixIcon: const Icon(Icons.calendar_month),
                      ),
                      items: _monthChoices
                          .map(
                            (m) => DropdownMenuItem(
                              value: m,
                              child: Text(m),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v != null) {
                          setState(() => _month = v);
                          _load();
                        }
                      },
                    ),
                    const SizedBox(height: 24),
                    if (_error != null)
                      Card(
                        color: AppColors.error.withValues(alpha: 0.08),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, color: AppColors.error),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _error!,
                                  style: AppTypography.bodySmall.copyWith(color: AppColors.error),
                                ),
                              ),
                              TextButton(onPressed: _load, child: Text(l10n.retryAction)),
                            ],
                          ),
                        ),
                      )
                    else if (s == null)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Center(
                            child: Text(
                              l10n.payslipNotFound,
                              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                            ),
                          ),
                        ),
                      )
                    else
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Column(
                                  children: [
                                    Text(l10n.payslip, style: AppTypography.h4),
                                    Text(_month, style: AppTypography.bodySmall),
                                  ],
                                ),
                              ),
                              const Divider(height: 32),
                              LabeledValueRow(
                                label: l10n.breakdownBase,
                                value: s.baseSalary,
                                labelStyle: AppTypography.bodyMedium,
                                valueStyle: AppTypography.bodyMedium,
                              ),
                              LabeledValueRow(
                                label: l10n.breakdownAllowances,
                                value: s.allowances,
                                labelStyle: AppTypography.bodyMedium,
                                valueStyle: AppTypography.bodyMedium,
                              ),
                              LabeledValueRow(
                                label: l10n.colNetSalary,
                                value: s.netSalary,
                                labelStyle: AppTypography.bodyMedium,
                                valueStyle: AppTypography.bodyMedium,
                              ),
                              const Divider(height: 24),
                              LabeledValueRow(
                                label: l10n.breakdownDeductions,
                                value: s.deductions,
                                labelStyle: AppTypography.bodyMedium,
                                valueStyle: AppTypography.bodyMedium,
                              ),
                              const Divider(height: 24),
                              LabeledValueRow(
                                label: l10n.breakdownNet,
                                value: s.netSalary,
                                labelStyle: AppTypography.h4,
                                valueStyle: AppTypography.h3.copyWith(color: AppColors.success),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}
