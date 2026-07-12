import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_strings.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../core/repositories/leave_repository.dart';
import '../../../core/api/api_result.dart';
import '../../../core/utils/leave_status_util.dart';

class LeaveScreen extends StatefulWidget {
  const LeaveScreen({super.key});

  @override
  State<LeaveScreen> createState() => _LeaveScreenState();
}

class _LeaveScreenState extends State<LeaveScreen> {
  List<LeaveRequestItem> _requests = [];
  List<LeaveBalanceItem> _balances = [];
  bool _loading = true;
  bool _loadingMore = false;
  int _currentPage = 1;
  int _lastPage = 1;
  int _total = 0;
  // null = all, 'pending', 'approved', 'rejected'
  String? _statusFilter;
  final Set<String> _recommending = <String>{};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool reset = true}) async {
    if (reset) {
      setState(() { _loading = true; _currentPage = 1; _requests = []; });
    }
    final reqResult = await LeaveRepository.getLeaveRequestsPaged(
      page: _currentPage,
      status: _statusFilter,
    );
    // تحميل الأرصدة فقط في أول تحميل
    if (reset && _balances.isEmpty) {
      final bal = await LeaveRepository.getLeaveBalances();
      if (mounted && bal is ApiSuccess<List<LeaveBalanceItem>>) {
        _balances = bal.data;
      }
    }
    if (!mounted) return;
    switch (reqResult) {
      case ApiSuccess(:final data):
        setState(() {
          _requests = reset ? data.items : [..._requests, ...data.items];
          _currentPage = data.currentPage;
          _lastPage = data.lastPage;
          _total = data.total;
          _loading = false;
          _loadingMore = false;
        });
      case ApiFailure():
        setState(() { _loading = false; _loadingMore = false; });
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore || _currentPage >= _lastPage) return;
    setState(() { _loadingMore = true; _currentPage++; });
    await _load(reset: false);
  }

  void _setFilter(String? status) {
    setState(() => _statusFilter = status);
    _load();
  }

  Future<void> _approve(String id) async {
    final l10n = AppStrings.of(context);
    final res = await LeaveRepository.approveLeave(id);
    if (!mounted) return;
    if (res is ApiSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.leaveApproveSuccess), backgroundColor: AppColors.success),
      );
      _load();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text((res as ApiFailure).message), backgroundColor: AppColors.error));
    }
  }

  Future<void> _reject(String id) async {
    final l10n = AppStrings.of(context);
    final res = await LeaveRepository.rejectLeave(id);
    if (!mounted) return;
    if (res is ApiSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.leaveRejectSuccess), backgroundColor: AppColors.info),
      );
      _load();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text((res as ApiFailure).message), backgroundColor: AppColors.error));
    }
  }

  Future<void> _recommend(String id) async {
    if (_recommending.contains(id)) return;
    setState(() => _recommending.add(id));
    final res = await LeaveRepository.getRecommendation(id);
    if (!mounted) return;
    setState(() => _recommending.remove(id));

    switch (res) {
      case ApiSuccess(:final data):
        final ar = Localizations.localeOf(context).languageCode == 'ar';
        final action = switch (data.recommendedAction) {
          'approve' => ar ? 'موافقة' : 'Approve',
          'reject' => ar ? 'رفض' : 'Reject',
          _ => ar ? 'مراجعة' : 'Review',
        };
        final decision = await showDialog<String>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(ar ? 'توصية الإجازة' : 'Leave recommendation'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${ar ? 'الإجراء المقترح' : 'Suggested action'}: $action'),
                const SizedBox(height: 6),
                Text('${ar ? 'درجة الثقة' : 'Confidence'}: ${data.confidenceScore}%'),
                const SizedBox(height: 6),
                Text(data.reason),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, 'close'), child: Text(ar ? 'إغلاق' : 'Close')),
              TextButton(onPressed: () => Navigator.pop(ctx, 'reject'), child: Text(AppStrings.of(context).reject)),
              FilledButton(onPressed: () => Navigator.pop(ctx, 'approve'), child: Text(AppStrings.of(context).approve)),
            ],
          ),
        );
        if (decision == 'approve') {
          await _approve(id);
        } else if (decision == 'reject') {
          await _reject(id);
        }
      case ApiFailure(:final message):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: AppColors.error),
        );
    }
  }

  String _leaveTypeLabel(AppStrings l10n, String raw) {
    final t = raw.trim().toLowerCase();
    if (t == 'annual') return l10n.annualShort;
    if (t == 'sick') return l10n.sickShort;
    if (t == 'emergency') return l10n.emergencyShort;
    return raw;
  }

  String _leaveStatusLabel(AppStrings l10n, String status) {
    if (isPendingLeaveStatus(status)) return l10n.leaveStatusPending;
    if (isApprovedLeaveStatus(status)) return l10n.leaveStatusApproved;
    return l10n.leaveStatusRejected;
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.leaveRequests, style: AppTypography.h1),
                    if (_total > 0)
                      Text('$_total ${l10n.leaveRequests}', style: AppTypography.caption),
                  ],
                ),
              ),
              IconButton(
                onPressed: _loading ? null : _load,
                icon: const Icon(Icons.refresh),
                tooltip: l10n.refreshAction,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l10n.leaveAdminSubtitle,
            style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            children: [
              _FilterChip(
                label: l10n.filterAll,
                selected: _statusFilter == null,
                onTap: () => _setFilter(null),
              ),
              _FilterChip(
                label: l10n.filterPendingShort,
                selected: _statusFilter == 'pending',
                onTap: () => _setFilter('pending'),
              ),
              _FilterChip(
                label: l10n.filterApprovedShort,
                selected: _statusFilter == 'approved',
                onTap: () => _setFilter('approved'),
              ),
              _FilterChip(
                label: l10n.filterRejectedShort,
                selected: _statusFilter == 'rejected',
                onTap: () => _setFilter('rejected'),
              ),
            ],
          ),
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
                              DataColumn(label: Text(l10n.leaveType)),
                              DataColumn(label: Text(l10n.leaveColFrom)),
                              DataColumn(label: Text(l10n.leaveColTo)),
                              DataColumn(label: Text(l10n.leaveColDays)),
                              DataColumn(label: Text(l10n.leaveColBalanceLeft)),
                              DataColumn(label: Text(l10n.colStatus)),
                              DataColumn(label: Text(l10n.actions)),
                            ],
                            rows: _requests.map((r) => _dataRow(context, r, r.id)).toList(),
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
                                    label: Text('${l10n.viewAll} (${_requests.length}/$_total)'),
                                  ),
                          ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 32),
          Text(l10n.leaveBalancePerEmployee, style: AppTypography.h4),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Table(
                children: [
                  TableRow(
                    decoration: BoxDecoration(color: AppColors.surfaceVariant),
                    children: [
                      _Th(l10n.colEmployee),
                      _Th(l10n.annualShort),
                      _Th(l10n.sickShort),
                      _Th(l10n.emergencyShort),
                    ],
                  ),
                  ..._balances.map((b) => _balanceRow(b.employeeName, b.annual, b.sick, b.emergency)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  DataRow _dataRow(
    BuildContext context,
    LeaveRequestItem r,
    String id,
  ) {
    final l10n = AppStrings.of(context);
    final typeLabel = _leaveTypeLabel(l10n, r.type);
    final statusLabel = _leaveStatusLabel(l10n, r.status);
    return DataRow(
      cells: [
        DataCell(Text(r.employeeName, style: AppTypography.bodyMedium)),
        DataCell(Text(typeLabel, style: AppTypography.bodySmall)),
        DataCell(Text(r.from, style: AppTypography.bodySmall)),
        DataCell(Text(r.to, style: AppTypography.bodySmall)),
        DataCell(Text(r.days, style: AppTypography.bodySmall)),
        DataCell(Text(r.balance ?? '—', style: AppTypography.bodySmall)),
        DataCell(StatusBadge(
          label: statusLabel,
          status: isApprovedLeaveStatus(r.status)
              ? StatusType.success
              : (isPendingLeaveStatus(r.status) ? StatusType.warning : StatusType.error),
        )),
        DataCell(Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isPendingLeaveStatus(r.status)) ...[
              TextButton(
                onPressed: _recommending.contains(id) ? null : () => _recommend(id),
                child: Text(
                  _recommending.contains(id)
                      ? (Localizations.localeOf(context).languageCode == 'ar' ? 'جاري التحليل…' : 'Analyzing…')
                      : (Localizations.localeOf(context).languageCode == 'ar' ? 'توصية AI' : 'AI Recommend'),
                  style: TextStyle(color: AppColors.info),
                ),
              ),
              TextButton(
                onPressed: () => _approve(id),
                child: Text(l10n.approve, style: TextStyle(color: AppColors.success)),
              ),
              TextButton(
                onPressed: () => _reject(id),
                child: Text(l10n.reject, style: TextStyle(color: AppColors.error)),
              ),
            ],
          ],
        )),
      ],
    );
  }

  TableRow _balanceRow(String name, String a, String b, String c) {
    return TableRow(
      children: [
        Padding(padding: const EdgeInsets.all(12), child: Text(name)),
        Padding(padding: const EdgeInsets.all(12), child: Text(a)),
        Padding(padding: const EdgeInsets.all(12), child: Text(b)),
        Padding(padding: const EdgeInsets.all(12), child: Text(c)),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onTap != null ? (_) => onTap!() : null,
    );
  }
}

class _Th extends StatelessWidget {
  const _Th(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(text, style: AppTypography.label),
    );
  }
}
