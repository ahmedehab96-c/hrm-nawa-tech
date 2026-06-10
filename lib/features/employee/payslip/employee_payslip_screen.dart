import 'package:flutter/material.dart';

import '../../../core/api/api_result.dart';
import '../../../core/api/current_user.dart';
import '../../../core/api/api_config.dart';
import '../../../core/repositories/payroll_repository.dart';
import '../../../core/services/payslip_pdf_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/text_direction_helper.dart';
import '../../../l10n/app_localizations.dart';

class EmployeePayslipScreen extends StatefulWidget {
  const EmployeePayslipScreen({super.key});

  @override
  State<EmployeePayslipScreen> createState() => _EmployeePayslipScreenState();
}

class _EmployeePayslipScreenState extends State<EmployeePayslipScreen> {
  bool _loading = true;
  bool _generatingPdf = false;
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
    setState(() => _loading = true);
    await ApiConfig.load();
    final name = await currentUserDisplayName();
    final res = await PayrollRepository.getPayroll(_month);

    PayslipItem? slip;
    if (res is ApiSuccess<List<PayslipItem>>) {
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

    if (!mounted) return;
    setState(() {
      _loading = false;
      _slip = slip;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<String>(
                      key: ValueKey(_month),
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
                    if (s == null)
                      Text(
                        '—',
                        style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
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
                              _PayslipRow(l10n.breakdownBase, s.baseSalary),
                              _PayslipRow(l10n.breakdownAllowances, s.allowances),
                              _PayslipRow(l10n.colNetSalary, s.netSalary),
                              const Divider(height: 24),
                              _PayslipRow(l10n.breakdownDeductions, s.deductions),
                              const Divider(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(l10n.breakdownNet, style: AppTypography.h4),
                                  Text(
                                    s.netSalary,
                                    style: AppTypography.h3.copyWith(color: AppColors.success),
                                  ),
                                ],
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

class _PayslipRow extends StatelessWidget {
  const _PayslipRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.bodyMedium),
          Text(value, style: AppTypography.bodyMedium),
        ],
      ),
    );
  }
}
