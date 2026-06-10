import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_result.dart';
import '../../../core/api/current_user.dart';
import '../../../core/api/api_config.dart';
import '../../../core/repositories/leave_repository.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/leave_status_util.dart';
import '../../../core/utils/text_direction_helper.dart';
import '../../../l10n/app_localizations.dart';

class EmployeeLeaveScreen extends StatefulWidget {
  const EmployeeLeaveScreen({super.key});

  @override
  State<EmployeeLeaveScreen> createState() => _EmployeeLeaveScreenState();
}

class _EmployeeLeaveScreenState extends State<EmployeeLeaveScreen> {
  bool _loading = true;
  String _annual = '—';
  String _annualTot = '—';
  String _sick = '—';
  String _sickTot = '—';
  String _emergency = '—';
  String _emergencyTot = '—';
  List<LeaveRequestItem> _requests = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    await ApiConfig.load();
    final name = await currentUserDisplayName();
    final bal = await LeaveRepository.getLeaveBalances();
    final req = await LeaveRepository.getLeaveRequests();

    if (!mounted) return;

    LeaveBalanceItem? mine;
    if (bal is ApiSuccess<List<LeaveBalanceItem>>) {
      if (name != null && name.isNotEmpty) {
        for (final b in bal.data) {
          if (b.employeeName.contains(name) || name.contains(b.employeeName)) {
            mine = b;
            break;
          }
        }
      }
      mine ??= bal.data.isNotEmpty ? bal.data.first : null;
      if (mine != null) {
        _annual = mine.annual;
        _sick = mine.sick;
        _emergency = mine.emergency;
        _annualTot = mine.annualTotal;
        _sickTot = mine.sickTotal;
        _emergencyTot = mine.emergencyTotal;
      }
    }

    var list = <LeaveRequestItem>[];
    if (req is ApiSuccess<List<LeaveRequestItem>>) {
      list = req.data;
      if (name != null && name.isNotEmpty) {
        list = req.data
            .where(
              (r) =>
                  r.employeeName.toLowerCase().contains(name.toLowerCase()) ||
                  name.toLowerCase().contains(r.employeeName.toLowerCase()),
            )
            .toList();
        if (list.isEmpty) {
          list = req.data;
        }
      }
    }

    setState(() {
      _loading = false;
      _requests = list;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Directionality(
      textDirection: textDirectionForContext(context),
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.leave),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loading ? null : _load,
              tooltip: l10n.refreshAction,
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => context.push('/employee/leave/request'),
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
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l10n.leaveBalance, style: AppTypography.h4),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _BalanceItem(l10n.annualShort, _annual, _annualTot),
                                _BalanceItem(l10n.sickShort, _sick, _sickTot),
                                _BalanceItem(l10n.emergencyShort, _emergency, _emergencyTot),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () => context.push('/employee/leave/request'),
                      icon: const Icon(Icons.add),
                      label: Text(l10n.requestLeave),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(l10n.leaveRequests, style: AppTypography.h4),
                    const SizedBox(height: 16),
                    if (_requests.isEmpty)
                      Text(
                        '—',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                      )
                    else
                      ..._requests.map(
                        (r) => _LeaveRequestItem(
                          type: _leaveTypeLabel(l10n, r.type),
                          from: r.from,
                          to: r.to,
                          days: int.tryParse(r.days) ?? 0,
                          status: isPendingLeaveStatus(r.status)
                              ? l10n.leaveStatusPending
                              : isApprovedLeaveStatus(r.status)
                                  ? l10n.leaveStatusApproved
                                  : l10n.leaveStatusRejected,
                          statusColor: isPendingLeaveStatus(r.status)
                              ? AppColors.warning
                              : isApprovedLeaveStatus(r.status)
                                  ? AppColors.success
                                  : AppColors.error,
                        ),
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}

String _leaveTypeLabel(AppLocalizations l10n, String raw) {
  final t = raw.trim().toLowerCase();
  if (t == 'annual') return l10n.annualShort;
  if (t == 'sick') return l10n.sickShort;
  if (t == 'emergency') return l10n.emergencyShort;
  return raw;
}

class _BalanceItem extends StatelessWidget {
  const _BalanceItem(this.type, this.remaining, this.total);

  final String type;
  final String remaining;
  final String total;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(type, style: AppTypography.caption),
        Text('$remaining / $total', style: AppTypography.h4),
      ],
    );
  }
}

class _LeaveRequestItem extends StatelessWidget {
  const _LeaveRequestItem({
    required this.type,
    required this.from,
    required this.to,
    required this.days,
    required this.status,
    required this.statusColor,
  });

  final String type;
  final String from;
  final String to;
  final int days;
  final String status;
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(type),
        subtitle: Text('$from → $to'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('$days', style: AppTypography.h4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(status, style: TextStyle(color: statusColor, fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }
}
