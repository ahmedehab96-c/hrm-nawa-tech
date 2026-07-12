import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/api/api_result.dart';
import '../../../core/repositories/employees_repository.dart';
import '../../../core/repositories/payroll_repository.dart';
import '../../../core/services/payslip_pdf_service.dart';
import '../../../l10n/app_strings.dart';

class PayslipDetailScreen extends StatefulWidget {
  const PayslipDetailScreen({super.key, this.employeeId, this.month});

  final String? employeeId;
  final String? month;

  @override
  State<PayslipDetailScreen> createState() => _PayslipDetailScreenState();
}

class _PayslipDetailScreenState extends State<PayslipDetailScreen> {
  bool _loading = true;
  bool _generatingPdf = false; // ignore: prefer_final_fields
  String? _month;
  PayslipItem? _slip;
  EmployeeItem? _employee;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  String _defaultMonth() {
    final now = DateTime.now();
    final m = now.month.toString().padLeft(2, '0');
    return '${now.year}-$m';
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final month = widget.month ?? _defaultMonth();
    _month = month;

    final payrollRes = await PayrollRepository.getPayroll(month);
    if (!mounted) return;

    if (payrollRes is ApiSuccess<List<PayslipItem>>) {
      final list = payrollRes.data;
      if (list.isNotEmpty) {
        if (widget.employeeId != null) {
          final matches = list.where((x) => x.employeeId == widget.employeeId).toList();
          if (matches.isNotEmpty) _slip = matches.first;
        } else {
          _slip = list.first;
        }
      }
    } else {
      _error = (payrollRes as ApiFailure<List<PayslipItem>>).message;
    }

    if (widget.employeeId != null && _employee == null) {
      final empRes = await EmployeesRepository.getEmployee(widget.employeeId!);
      if (!mounted) return;
      if (empRes is ApiSuccess<EmployeeItem>) {
        _employee = empRes.data;
      }
    }

    if (!mounted) return;
    setState(() { _loading = false; });
  }

  Future<void> _downloadPdf() async {
    if (_slip == null) return;
    setState(() => _generatingPdf = true);
    try {
      final data = PayslipPdfData.fromSlip(
        _slip!,
        department: _employee?.department ?? '',
        position: _employee?.position ?? '',
        month: _month ?? '',
      );
      await PayslipPdfService.sharePayslip(data);
    } finally {
      if (mounted) setState(() => _generatingPdf = false);
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
              Text(l10n.payslip, style: AppTypography.h1),
              const Spacer(),
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
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Column(
                      children: [
                        Text(_month ?? '—', style: AppTypography.h4),
                        const SizedBox(height: 6),
                        Text(l10n.payslip, style: AppTypography.bodySmall),
                      ],
                    ),
                  ),
                  const Divider(height: 32),
                  if (_loading)
                    const Center(child: CircularProgressIndicator())
                  else ...[
                    _PayslipSection(
                      title: l10n.payslipEmployeeSection,
                      items: [
                        _PayslipRow(l10n.name, _employee?.name ?? _slip?.employeeName ?? '—'),
                        _PayslipRow(l10n.department, _employee?.department ?? '—'),
                        _PayslipRow(l10n.position, _employee?.position ?? '—'),
                      ],
                    ),
                    const Divider(height: 24),
                    _PayslipSection(
                      title: l10n.payslipEarningsSection,
                      items: [
                        _PayslipRow(l10n.breakdownBase, _slip?.baseSalary ?? '—'),
                        _PayslipRow(l10n.breakdownAllowances, _slip?.allowances ?? '—'),
                      ],
                    ),
                    const Divider(height: 24),
                    _PayslipSection(
                      title: l10n.payslipDeductionsSection,
                      items: [
                        _PayslipRow(l10n.breakdownDeductions, _slip?.deductions ?? '—'),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(l10n.breakdownNet, style: AppTypography.h4),
                        Text(
                          _slip?.netSalary ?? '—',
                          style: AppTypography.h3.copyWith(color: AppColors.success),
                        ),
                      ],
                    ),
                  ],
                  if (!_loading && _error != null) ...[
                    const SizedBox(height: 12),
                    Text(_error!, style: AppTypography.bodySmall.copyWith(color: AppColors.error)),
                  ]
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PayslipSection extends StatelessWidget {
  const _PayslipSection({
    required this.title,
    required this.items,
  });

  final String title;
  final List<Widget> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTypography.h4),
        const SizedBox(height: 12),
        ...items,
      ],
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
      padding: const EdgeInsets.symmetric(vertical: 6),
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
