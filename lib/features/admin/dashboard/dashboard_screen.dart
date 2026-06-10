import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_result.dart';
import '../../../core/repositories/attendance_repository.dart';
import '../../../core/repositories/employees_repository.dart';
import '../../../core/repositories/leave_repository.dart';
import '../../../core/repositories/notifications_repository.dart';
import '../../../core/repositories/payroll_repository.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/leave_status_util.dart';
import '../../../core/widgets/stat_card.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../l10n/app_localizations.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _loading = true;
  int _employeesCount = 0;
  int _present = 0;
  int _late = 0;
  int _absent = 0;
  int _pendingLeaveCount = 0;
  String _payrollMonthLabel = '';
  List<_PendingLeaveRow> _pendingRows = [];
  List<_ActivityRow> _activities = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final emp = await EmployeesRepository.getEmployees();
    final att = await AttendanceRepository.getDailyAttendance();
    final leaves = await LeaveRepository.getLeaveRequests();
    final month =
        '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}';
    await PayrollRepository.getPayroll(month);
    final notif = await NotificationsRepository.getEmployeeNotifications();

    if (!mounted) return;

    var ec = 0;
    if (emp is ApiSuccess<List<EmployeeItem>>) {
      ec = emp.data.length;
    }

    var p = 0, l = 0, a = 0;
    if (att is ApiSuccess<List<AttendanceRecord>>) {
      for (final r in att.data) {
        final s = r.status.toLowerCase();
        if (s.contains('غائب') || s == 'absent') {
          a++;
        } else if (s.contains('متأخر') || s == 'late') {
          l++;
        } else {
          p++;
        }
      }
    }

    final pending = <_PendingLeaveRow>[];
    var pc = 0;
    if (leaves is ApiSuccess<List<LeaveRequestItem>>) {
      for (final r in leaves.data) {
        if (isPendingLeaveStatus(r.status)) {
          pc++;
          pending.add(
            _PendingLeaveRow(
              id: r.id,
              name: r.employeeName,
              date: '${r.from} → ${r.to}',
              type: r.type,
            ),
          );
        }
      }
    }

    final payrollLabel = month;

    final activities = <_ActivityRow>[];
    if (notif is ApiSuccess<List<EmployeeNotificationItem>>) {
      for (final n in notif.data.take(5)) {
        activities.add(
          _ActivityRow(
            icon: Icons.notifications_outlined,
            title: n.title,
            time: n.timeLabel.isNotEmpty ? n.timeLabel : '—',
          ),
        );
      }
    }

    setState(() {
      _loading = false;
      _employeesCount = ec;
      _present = p;
      _late = l;
      _absent = a;
      _pendingLeaveCount = pc;
      _pendingRows = pending.take(8).toList();
      _payrollMonthLabel = payrollLabel;
      _activities = activities;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final attSubtitle =
        '${l10n.present}: $_present • ${l10n.late}: $_late • ${l10n.absent}: $_absent';

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.dashboard, style: AppTypography.h1),
          const SizedBox(height: 8),
          Text(
            l10n.dashboardOverview,
            style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 32),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth > 1200 ? 4 : 2;
                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.5,
                  children: [
                    StatCard(
                      title: l10n.employeesCount,
                      value: '$_employeesCount',
                      subtitle: l10n.ofSeats,
                      icon: Icons.people_outline,
                      iconColor: AppColors.primary,
                    ),
                    StatCard(
                      title: l10n.todayAttendance,
                      value: '${_present + _late + _absent}',
                      subtitle: attSubtitle,
                      icon: Icons.access_time,
                      iconColor: AppColors.secondary,
                    ),
                    StatCard(
                      title: l10n.pendingLeaves,
                      value: '$_pendingLeaveCount',
                      subtitle: l10n.needsReview,
                      icon: Icons.event_note_outlined,
                      iconColor: AppColors.warning,
                    ),
                    StatCard(
                      title: l10n.payrollStatus,
                      value: l10n.payrollDone,
                      subtitle: _payrollMonthLabel.isEmpty ? l10n.payrollMonthSample : _payrollMonthLabel,
                      icon: Icons.payments_outlined,
                      iconColor: AppColors.success,
                    ),
                  ],
                );
              },
            ),
          if (!_loading) ...[
            const SizedBox(height: 32),
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 900;
                return isWide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: _PendingLeavesCard(
                              rows: _pendingRows,
                              onRefresh: _load,
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            flex: 1,
                            child: _RecentActivityCard(
                              activities: _activities,
                              onRefresh: _load,
                            ),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          _PendingLeavesCard(
                            rows: _pendingRows,
                            onRefresh: _load,
                          ),
                          const SizedBox(height: 24),
                          _RecentActivityCard(
                            activities: _activities,
                            onRefresh: _load,
                          ),
                        ],
                      );
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _PendingLeavesCard extends StatefulWidget {
  const _PendingLeavesCard({
    required this.rows,
    required this.onRefresh,
  });

  final List<_PendingLeaveRow> rows;
  final VoidCallback onRefresh;

  @override
  State<_PendingLeavesCard> createState() => _PendingLeavesCardState();
}

class _PendingLeavesCardState extends State<_PendingLeavesCard> {
  Future<void> _approve(String id) async {
    final res = await LeaveRepository.approveLeave(id);
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    if (res is ApiSuccess<void>) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.leaveApproved),
          backgroundColor: AppColors.success,
        ),
      );
      widget.onRefresh();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text((res as ApiFailure<void>).message),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _reject(String id) async {
    final res = await LeaveRepository.rejectLeave(id);
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    if (res is ApiSuccess<void>) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.leaveRejected),
          backgroundColor: AppColors.info,
        ),
      );
      widget.onRefresh();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text((res as ApiFailure<void>).message),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final rows = widget.rows;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.pendingLeaves, style: AppTypography.h4),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: widget.onRefresh,
                      tooltip: l10n.refreshAction,
                    ),
                    TextButton(
                      onPressed: () => context.push('/admin/leave'),
                      child: Text(l10n.viewAll),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (rows.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  '—',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                ),
              )
            else
              Table(
                columnWidths: const {
                  0: FlexColumnWidth(2),
                  1: FlexColumnWidth(1),
                  2: FlexColumnWidth(1),
                  3: FlexColumnWidth(1),
                },
                children: [
                  TableRow(
                    children: [
                      _TableHeader(l10n.name),
                      _TableHeader(l10n.date),
                      _TableHeader(l10n.leaveType),
                      _TableHeader(l10n.actions),
                    ],
                  ),
                  ...rows.map((r) => TableRow(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(r.name, style: AppTypography.bodyMedium),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(r.date, style: AppTypography.bodySmall),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: StatusBadge(label: r.type, status: StatusType.info),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Wrap(
                              spacing: 4,
                              children: [
                                TextButton(
                                  onPressed: () => _approve(r.id),
                                  child: Text(
                                    l10n.approve,
                                    style: TextStyle(color: AppColors.success, fontSize: 12),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => _reject(r.id),
                                  child: Text(
                                    l10n.reject,
                                    style: TextStyle(color: AppColors.error, fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _PendingLeaveRow {
  const _PendingLeaveRow({
    required this.id,
    required this.name,
    required this.date,
    required this.type,
  });
  final String id;
  final String name;
  final String date;
  final String type;
}

class _TableHeader extends StatelessWidget {
  const _TableHeader(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: AppTypography.label,
      ),
    );
  }
}

class _ActivityRow {
  const _ActivityRow({
    required this.icon,
    required this.title,
    required this.time,
  });
  final IconData icon;
  final String title;
  final String time;
}

class _RecentActivityCard extends StatelessWidget {
  const _RecentActivityCard({
    required this.activities,
    required this.onRefresh,
  });

  final List<_ActivityRow> activities;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.notificationsTitle, style: AppTypography.h4),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: onRefresh,
                  tooltip: l10n.refreshAction,
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (activities.isEmpty)
              Text(
                l10n.noNotifications,
                style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
              )
            else
              ...activities.map(
                (a) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                        child: Icon(a.icon, size: 20, color: AppColors.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(a.title, style: AppTypography.bodyMedium),
                            Text(a.time, style: AppTypography.caption),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
