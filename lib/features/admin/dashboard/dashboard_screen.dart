import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_result.dart';
import '../../../core/repositories/attendance_repository.dart';
import '../../../core/repositories/employees_repository.dart';
import '../../../core/repositories/leave_repository.dart';
import '../../../core/repositories/notifications_repository.dart';
import '../../../core/repositories/payroll_repository.dart';
import '../../../core/repositories/reports_repository.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/leave_status_util.dart';
import '../../../core/widgets/animations.dart';
import '../../../core/widgets/stat_card.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../l10n/app_strings.dart';

// ─── DashboardScreen ──────────────────────────────────────────────────────────
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool   _loading = true;
  String? _loadWarning;
  int    _employeesCount    = 0;
  int    _present = 0, _late = 0, _absent = 0;
  int    _pendingLeaveCount = 0;
  String _payrollMonthLabel = '';
  List<_LeaveRow>    _pendingRows = [];
  List<_ActivityRow> _activities  = [];
  String? _aiBriefing;
  bool _aiBriefingLoading = false;
  String? _aiBriefingError;

  @override
  void initState() {
    super.initState();
    _load();
  }

  // Fetch all data in parallel to minimize wait time | تحميل البيانات بالتوازي
  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadWarning = null;
    });

    final month = '${DateTime.now().year}-'
        '${DateTime.now().month.toString().padLeft(2, '0')}';

    final results = await Future.wait([
      EmployeesRepository.getEmployees(),
      AttendanceRepository.getDailyAttendance(),
      LeaveRepository.getLeaveRequests(),
      PayrollRepository.getPayroll(month),
      NotificationsRepository.getEmployeeNotifications(),
    ]);

    if (!mounted) return;

    final warnings = <String>[];
    void collectFailure(dynamic result) {
      if (result is ApiFailure<dynamic>) warnings.add(result.message);
    }
    for (final r in results) {
      collectFailure(r);
    }

    // Employee count | الموظفون
    final empCount = results[0] is ApiSuccess<List<EmployeeItem>>
        ? (results[0] as ApiSuccess<List<EmployeeItem>>).data.length
        : 0;

    // Attendance breakdown | الحضور
    var p = 0, l = 0, a = 0;
    if (results[1] is ApiSuccess<List<AttendanceRecord>>) {
      for (final r in (results[1] as ApiSuccess<List<AttendanceRecord>>).data) {
        final s = r.status.toLowerCase();
        if      (s.contains('غائب') || s == 'absent') { a++; }
        else if (s.contains('متأخر') || s == 'late')  { l++; }
        else                                            { p++; }
      }
    }

    // Pending leave requests | الإجازات المعلقة
    final pending = <_LeaveRow>[];
    var pc = 0;
    if (results[2] is ApiSuccess<List<LeaveRequestItem>>) {
      for (final r in (results[2] as ApiSuccess<List<LeaveRequestItem>>).data) {
        if (isPendingLeaveStatus(r.status)) {
          pc++;
          pending.add(_LeaveRow(id: r.id, name: r.employeeName, date: '${r.from} → ${r.to}', type: r.type));
        }
      }
    }

    // Recent activity from notifications | النشاط الأخير
    final activities = <_ActivityRow>[];
    if (results[4] is ApiSuccess<List<EmployeeNotificationItem>>) {
      for (final n in (results[4] as ApiSuccess<List<EmployeeNotificationItem>>).data.take(5)) {
        activities.add(_ActivityRow(icon: Icons.notifications_outlined, title: n.title, time: n.timeLabel.isNotEmpty ? n.timeLabel : '—'));
      }
    }

    setState(() {
      _loading           = false;
      _loadWarning       = warnings.isEmpty ? null : warnings.first;
      _employeesCount    = empCount;
      _present = p; _late = l; _absent = a;
      _pendingLeaveCount = pc;
      _pendingRows       = pending.take(8).toList();
      _payrollMonthLabel = month;
      _activities        = activities;
    });
  }

  String _fmtDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _generateAiBriefing() async {
    setState(() {
      _aiBriefingLoading = true;
      _aiBriefingError = null;
    });
    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 30));
    final lang = Localizations.localeOf(context).languageCode;
    final res = await ReportsRepository.instance.generateSummary(
      periodStart: _fmtDate(start),
      periodEnd: _fmtDate(now),
      languageCode: lang,
    );
    if (!mounted) return;
    switch (res) {
      case ApiSuccess(:final data):
        setState(() {
          _aiBriefing = data.narrative;
          _aiBriefingLoading = false;
        });
      case ApiFailure(:final message):
        setState(() {
          _aiBriefingError = message;
          _aiBriefingLoading = false;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppStrings.of(context);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Page title | العنوان
          FadeSlideIn(child: Text(l10n.dashboard, style: AppTypography.h1)),
          FadeSlideIn(
            delay: const Duration(milliseconds: 60),
            child: Text(l10n.dashboardOverview,
                style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
          ),
          const SizedBox(height: 32),

          if (_loadWarning != null) ...[
            FadeSlideIn(
              child: MaterialBanner(
                backgroundColor: AppColors.warning.withValues(alpha: 0.12),
                content: Text(
                  l10n.dashboardPartialLoadError,
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary),
                ),
                leading: const Icon(Icons.warning_amber_rounded, color: AppColors.warning),
                actions: [
                  TextButton(onPressed: _load, child: Text(l10n.retryAction)),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Stat cards — fade transition between loading skeleton and real data
          // بطاقات الإحصاء مع fade حين تتغير من loading → data
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _loading
                ? const _LoadingPlaceholder()
                : _StatGrid(
                    key:               const ValueKey('stats'),
                    employeesCount:    _employeesCount,
                    present:           _present,
                    late:              _late,
                    absent:            _absent,
                    pendingLeaveCount: _pendingLeaveCount,
                    payrollMonthLabel: _payrollMonthLabel,
                  ),
          ),

          if (!_loading) ...[
            const SizedBox(height: 24),
            FadeSlideIn(
              delay: const Duration(milliseconds: 200),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.auto_awesome, color: AppColors.primary),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(l10n.aiBriefingTitle, style: AppTypography.h4),
                                Text(
                                  l10n.aiBriefingSubtitle,
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          FilledButton.tonalIcon(
                            onPressed: _aiBriefingLoading ? null : _generateAiBriefing,
                            icon: _aiBriefingLoading
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.refresh),
                            label: Text(l10n.generateBriefing),
                          ),
                        ],
                      ),
                      if (_aiBriefingError != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          _aiBriefingError!,
                          style: AppTypography.bodySmall.copyWith(color: AppColors.error),
                        ),
                      ],
                      if (_aiBriefing != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          _aiBriefing!,
                          style: AppTypography.bodyMedium.copyWith(height: 1.5),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],

          // Bottom section: pending leaves + recent activity | إجازات معلقة + نشاط أخير
          if (!_loading) ...[
            const SizedBox(height: 32),
            LayoutBuilder(
              builder: (context, c) {
                final isWide     = c.maxWidth > 900;
                final leaveCard  = _PendingLeavesCard(rows: _pendingRows, onRefresh: _load);
                final activityCard = _RecentActivityCard(activities: _activities, onRefresh: _load);

                return FadeSlideIn(
                  delay: const Duration(milliseconds: 300),
                  child: isWide
                      ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Expanded(flex: 2, child: leaveCard),
                          const SizedBox(width: 24),
                          Expanded(flex: 1, child: activityCard),
                        ])
                      : Column(children: [leaveCard, const SizedBox(height: 24), activityCard]),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

// ─── _StatGrid ────────────────────────────────────────────────────────────────
/// Responsive grid of stat cards — each card fades in with a staggered delay.
/// شبكة البطاقات الأربع — كل بطاقة تظهر بتأخير متصاعد (stagger).
/// To add a card: append one entry to the [cards] list below.
/// لإضافة بطاقة جديدة: أضف عنصراً لقائمة [cards] أدناه فقط.
class _StatGrid extends StatelessWidget {
  const _StatGrid({
    super.key,
    required this.employeesCount,
    required this.present,
    required this.late,
    required this.absent,
    required this.pendingLeaveCount,
    required this.payrollMonthLabel,
  });

  final int    employeesCount, present, late, absent, pendingLeaveCount;
  final String payrollMonthLabel;

  @override
  Widget build(BuildContext context) {
    final l10n        = AppStrings.of(context);
    final attSubtitle = '${l10n.present}: $present • ${l10n.late}: $late • ${l10n.absent}: $absent';

    final cards = [
      StatCard(title: l10n.employeesCount,  value: '$employeesCount',           subtitle: l10n.ofSeats,            icon: Icons.people_outline,      iconColor: AppColors.primary),
      StatCard(title: l10n.todayAttendance, value: '${present + late + absent}', subtitle: attSubtitle,             icon: Icons.access_time,         iconColor: AppColors.secondary),
      StatCard(title: l10n.pendingLeaves,   value: '$pendingLeaveCount',          subtitle: l10n.needsReview,        icon: Icons.event_note_outlined, iconColor: AppColors.warning),
      StatCard(title: l10n.payrollStatus,   value: l10n.payrollDone,
               subtitle: payrollMonthLabel.isEmpty ? l10n.payrollMonthSample : payrollMonthLabel,
               icon: Icons.payments_outlined, iconColor: AppColors.success),
    ];

    return LayoutBuilder(
      builder: (context, c) => GridView.builder(
        shrinkWrap: true,
        physics:   const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount:   c.maxWidth > 1200 ? 4 : 2,
          mainAxisSpacing:  16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.5,
        ),
        itemCount:   cards.length,
        itemBuilder: (_, i) => FadeSlideIn(
          delay: Duration(milliseconds: 80 * i),
          child: cards[i],
        ),
      ),
    );
  }
}

// ─── _LoadingPlaceholder ──────────────────────────────────────────────────────
class _LoadingPlaceholder extends StatelessWidget {
  const _LoadingPlaceholder();
  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.symmetric(vertical: 64),
        child:   Center(child: CircularProgressIndicator()),
      );
}

// ─── _PendingLeavesCard ───────────────────────────────────────────────────────
class _PendingLeavesCard extends StatefulWidget {
  const _PendingLeavesCard({required this.rows, required this.onRefresh});
  final List<_LeaveRow> rows;
  final VoidCallback    onRefresh;
  @override
  State<_PendingLeavesCard> createState() => _PendingLeavesCardState();
}

class _PendingLeavesCardState extends State<_PendingLeavesCard> {
  // Approve or reject — unified logic via a single method | موافقة أو رفض — نفس المنطق بدالة واحدة
  Future<void> _act(String id, Future<ApiResult<void>> Function(String) action, bool isApprove) async {
    final res = await action(id);
    if (!mounted) return;
    final l10n = AppStrings.of(context);
    final ok   = res is ApiSuccess<void>;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content:         Text(ok ? (isApprove ? l10n.leaveApproved : l10n.leaveRejected) : (res as ApiFailure<void>).message),
      backgroundColor: ok ? (isApprove ? AppColors.success : AppColors.info) : AppColors.error,
    ));
    if (ok) widget.onRefresh();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppStrings.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(l10n.pendingLeaves, style: AppTypography.h4),
              Row(children: [
                IconButton(icon: const Icon(Icons.refresh), onPressed: widget.onRefresh, tooltip: l10n.refreshAction),
                TextButton(onPressed: () => context.push('/admin/leave'), child: Text(l10n.viewAll)),
              ]),
            ]),
            const SizedBox(height: 16),
            if (widget.rows.isEmpty)
              Text('—', style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary))
            else
              Table(
                columnWidths: const {0: FlexColumnWidth(2), 1: FlexColumnWidth(1), 2: FlexColumnWidth(1), 3: FlexColumnWidth(1)},
                children: [
                  TableRow(children: [_TH(l10n.name), _TH(l10n.date), _TH(l10n.leaveType), _TH(l10n.actions)]),
                  ...widget.rows.map((r) => TableRow(children: [
                    _TD(Text(r.name, style: AppTypography.bodyMedium)),
                    _TD(Text(r.date, style: AppTypography.bodySmall)),
                    _TD(StatusBadge(label: r.type, status: StatusType.info)),
                    _TD(Wrap(spacing: 4, children: [
                      TextButton(onPressed: () => _act(r.id, LeaveRepository.approveLeave, true),  child: Text(l10n.approve, style: const TextStyle(color: AppColors.success, fontSize: 12))),
                      TextButton(onPressed: () => _act(r.id, LeaveRepository.rejectLeave,  false), child: Text(l10n.reject,  style: const TextStyle(color: AppColors.error,   fontSize: 12))),
                    ])),
                  ])),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

// ─── _RecentActivityCard ──────────────────────────────────────────────────────
class _RecentActivityCard extends StatelessWidget {
  const _RecentActivityCard({required this.activities, required this.onRefresh});
  final List<_ActivityRow> activities;
  final VoidCallback       onRefresh;

  @override
  Widget build(BuildContext context) {
    final l10n = AppStrings.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(l10n.notificationsTitle, style: AppTypography.h4),
              IconButton(icon: const Icon(Icons.refresh), onPressed: onRefresh, tooltip: l10n.refreshAction),
            ]),
            const SizedBox(height: 16),
            if (activities.isEmpty)
              Text(l10n.noNotifications, style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary))
            else
              for (final a in activities)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(children: [
                    CircleAvatar(radius: 20, backgroundColor: AppColors.primary.withValues(alpha: 0.1), child: Icon(a.icon, size: 20, color: AppColors.primary)),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(a.title, style: AppTypography.bodyMedium),
                      Text(a.time,  style: AppTypography.caption),
                    ])),
                  ]),
                ),
          ],
        ),
      ),
    );
  }
}

// ─── Data models ──────────────────────────────────────────────────────────────

class _LeaveRow {
  const _LeaveRow({required this.id, required this.name, required this.date, required this.type});
  final String id, name, date, type;
}

class _ActivityRow {
  const _ActivityRow({required this.icon, required this.title, required this.time});
  final IconData icon;
  final String   title, time;
}

// ─── Table cell helpers — header and data cell wrappers ───────────────────────

class _TH extends StatelessWidget {
  const _TH(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child:   Text(text, style: AppTypography.label),
      );
}

class _TD extends StatelessWidget {
  const _TD(this.child);
  final Widget child;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child:   child,
      );
}
