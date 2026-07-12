import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_strings.dart';
import '../../../core/repositories/payroll_repository.dart';
import '../../../core/api/api_result.dart';

class PayrollScreen extends StatefulWidget {
  const PayrollScreen({super.key});

  @override
  State<PayrollScreen> createState() => _PayrollScreenState();
}

class _PayrollScreenState extends State<PayrollScreen> {
  String _month = '';
  List<PayslipItem> _items = [];
  bool _loading = true;
  bool _loadingMore = false;
  int _currentPage = 1;
  int _lastPage = 1;
  int _total = 0;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    _load();
  }

  Future<void> _load({bool reset = true}) async {
    if (reset) {
      setState(() { _loading = true; _currentPage = 1; _items = []; });
    }
    final result = await PayrollRepository.getPayrollPaged(_month, page: _currentPage);
    if (!mounted) return;
    switch (result) {
      case ApiSuccess(:final data):
        setState(() {
          _items = reset ? data.items : [..._items, ...data.items];
          _currentPage = data.currentPage;
          _lastPage = data.lastPage;
          _total = data.total;
          _loading = false;
          _loadingMore = false;
        });
      case ApiFailure(:final message):
        setState(() { _loading = false; _loadingMore = false; });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message), backgroundColor: AppColors.error),
          );
        }
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore || _currentPage >= _lastPage) return;
    setState(() { _loadingMore = true; _currentPage++; });
    await _load(reset: false);
  }

  void _generatePayslips() {
    final l10n = AppStrings.of(context);
    PayrollRepository.generatePayroll(_month).then((result) {
      if (!mounted) return;
      if (result is ApiSuccess<void>) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.payrollGenerateDemo),
            backgroundColor: AppColors.success,
          ),
        );
        _load();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text((result as ApiFailure<void>).message),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });
  }

  // Last 12 months in YYYY-MM format, most recent first
  static List<String> get _availableMonths {
    final now = DateTime.now();
    return List.generate(12, (i) {
      final d = DateTime(now.year, now.month - i);
      return '${d.year}-${d.month.toString().padLeft(2, '0')}';
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppStrings.of(context);
    final months = _availableMonths;
    // Clamp to a valid month in case state has a value not in the list
    final safeMonth = months.contains(_month) ? _month : months.first;

    final dropdown = DropdownButton<String>(
      value: safeMonth,
      items: months
          .map((m) => DropdownMenuItem(value: m, child: Text(m)))
          .toList(),
      onChanged: (v) {
        if (v != null) {
          setState(() => _month = v);
          _load();
        }
      },
    );
    final refreshBtn = IconButton(
      onPressed: _loading ? null : _load,
      icon: const Icon(Icons.refresh),
      tooltip: l10n.refreshAction,
    );
    final generateBtn = FilledButton.icon(
      onPressed: _loading ? null : _generatePayslips,
      icon: const Icon(Icons.receipt_long),
      label: Text(l10n.generatePayslip),
    );

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 640;
            if (isNarrow) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.monthlyPayroll, style: AppTypography.h1),
                  if (_total > 0)
                    Text('$_total ${l10n.employees}', style: AppTypography.caption),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [dropdown, refreshBtn, generateBtn],
                  ),
                ],
              );
            }
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.monthlyPayroll, style: AppTypography.h1),
                    if (_total > 0)
                      Text('$_total ${l10n.employees}', style: AppTypography.caption),
                  ],
                ),
                Row(children: [dropdown, const SizedBox(width: 8), refreshBtn, generateBtn]),
              ],
            );
          }),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: _loading
                  ? const Padding(padding: EdgeInsets.all(32), child: Center(child: CircularProgressIndicator()))
                  : Column(
                      children: [
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columns: [
                              DataColumn(label: Text(l10n.colEmployee)),
                              DataColumn(label: Text(l10n.colBaseSalary)),
                              DataColumn(label: Text(l10n.colAllowances)),
                              DataColumn(label: Text(l10n.colDeductions)),
                              DataColumn(label: Text(l10n.colNetSalary)),
                              DataColumn(label: Text(l10n.colStatus)),
                              DataColumn(label: Text(l10n.actions)),
                            ],
                            rows: _items
                                .map((p) => _dataRow(context, p.employeeName, p.baseSalary,
                                    p.allowances, p.deductions, p.netSalary, p.status, p.employeeId))
                                .toList(),
                          ),
                        ),
                        if (_currentPage < _lastPage)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: _loadingMore
                                ? const CircularProgressIndicator()
                                : OutlinedButton.icon(
                                    onPressed: _loadMore,
                                    icon: const Icon(Icons.expand_more),
                                    label: Text('${l10n.viewAll} (${_items.length}/$_total)'),
                                  ),
                          ),
                      ],
                    ),
            ),
          ),
        const SizedBox(height: 32),
        Text(l10n.salaryBreakdown, style: AppTypography.h4),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final loc = AppStrings.of(context);
                final isWide = constraints.maxWidth > 600;
                final items = [
                  _BreakdownItem(loc.breakdownBase, '8,000', AppColors.primary),
                  _BreakdownItem(loc.breakdownAllowances, '1,500', AppColors.secondary),
                  _BreakdownItem(loc.breakdownDeductions, '-200', AppColors.error),
                  _BreakdownItem(loc.breakdownNet, '9,300', AppColors.success),
                ];
                return isWide
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: items,
                      )
                    : Wrap(
                        spacing: 24,
                        runSpacing: 16,
                        alignment: WrapAlignment.center,
                        children: items,
                      );
              },
            ),
          ),
        ),
      ],
      ),
    );
  }

  DataRow _dataRow(BuildContext context, String name, String base, String allowances, String deductions, String net, String status, String employeeId) {
    return DataRow(
      cells: [
        DataCell(Text(name, style: AppTypography.bodyMedium)),
        DataCell(Text(base, style: AppTypography.bodySmall)),
        DataCell(Text(allowances, style: AppTypography.bodySmall)),
        DataCell(Text(deductions, style: AppTypography.bodySmall)),
        DataCell(Text(net, style: AppTypography.bodyMedium)),
        DataCell(Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: status == 'تم' ? AppColors.success.withValues(alpha: 0.1) : AppColors.warning.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(status, style: AppTypography.bodySmall),
        )),
        DataCell(TextButton(
          onPressed: () => context.push('/admin/payroll/payslip/$employeeId'),
          child: Text(AppStrings.of(context).payslip),
        )),
      ],
    );
  }
}

class _BreakdownItem extends StatelessWidget {
  const _BreakdownItem(this.label, this.value, this.color);

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: AppTypography.caption),
        const SizedBox(height: 4),
        Text(value, style: AppTypography.h3.copyWith(color: color)),
      ],
    );
  }
}
