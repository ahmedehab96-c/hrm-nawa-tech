import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/text_direction_helper.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/services/wifi_attendance_service.dart';
import '../../../core/repositories/attendance_repository.dart';
import '../../../core/api/api_result.dart';
import '../../../core/utils/attendance_gate.dart';

class EmployeeAttendanceScreen extends StatefulWidget {
  const EmployeeAttendanceScreen({super.key});

  @override
  State<EmployeeAttendanceScreen> createState() => _EmployeeAttendanceScreenState();
}

class _EmployeeAttendanceScreenState extends State<EmployeeAttendanceScreen> {
  bool _isOnCompanyWifi = false;
  String? _wifiName;
  bool _isLoading = true;
  bool _loadingHistory = true;
  List<_AttendanceHistoryRow> _history = [];

  @override
  void initState() {
    super.initState();
    _checkWifiStatus();
    _loadHistory();
  }

  Future<void> _checkWifiStatus() async {
    setState(() => _isLoading = true);
    final result = await WifiAttendanceService.canRecordAttendance();
    setState(() {
      _isOnCompanyWifi = result.success;
      _wifiName = result.wifiName;
      _isLoading = false;
    });
  }

  Future<void> _loadHistory() async {
    setState(() => _loadingHistory = true);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dates = List.generate(
      7,
      (i) => today.subtract(Duration(days: 6 - i)),
    );

    String formatDate(DateTime d) {
      final y = d.year.toString().padLeft(4, '0');
      final m = d.month.toString().padLeft(2, '0');
      final day = d.day.toString().padLeft(2, '0');
      return '$y-$m-$day';
    }

    final futures = dates.map((d) => AttendanceRepository.getDailyAttendance(date: formatDate(d))).toList();
    final results = await Future.wait(futures);

    if (!mounted) return;

    final history = <_AttendanceHistoryRow>[];
    for (int i = 0; i < dates.length; i++) {
      final dateStr = formatDate(dates[i]);
      final res = results[i];
      if (res is ApiSuccess<List<AttendanceRecord>> && res.data.isNotEmpty) {
        final rawStatus = res.data.first.status;
        final s = rawStatus.trim().toLowerCase();
        final normalized = (s == 'late' || s.contains('late') || s == 'متأخر')
            ? 'late'
            : ((s == 'present' || s.contains('present') || s == 'حاضر') ? 'present' : 'absent');

        history.add(
          _AttendanceHistoryRow(
            date: dateStr,
            checkIn: res.data.first.checkIn ?? '—',
            checkOut: res.data.first.checkOut ?? '—',
            statusKey: normalized,
          ),
        );
      } else {
        history.add(
          _AttendanceHistoryRow(
            date: dateStr,
            checkIn: '—',
            checkOut: '—',
            statusKey: 'absent',
          ),
        );
      }
    }

    setState(() {
      _history = history;
      _loadingHistory = false;
    });
  }

  Future<void> _handleCheckIn() async {
    final l10n = AppLocalizations.of(context)!;
    if (await requireCompanyWifiForAttendance()) {
      final result = await WifiAttendanceService.canRecordAttendance();
      if (!result.success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message ?? l10n.wifiOffCompany),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }
    }
    final apiResult = await AttendanceRepository.recordCheckIn();
    if (!mounted) return;
    if (apiResult is ApiSuccess<void>) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.checkInRecorded),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text((apiResult as ApiFailure<void>).message),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _handleCheckOut() async {
    final l10n = AppLocalizations.of(context)!;
    if (await requireCompanyWifiForAttendance()) {
      final result = await WifiAttendanceService.canRecordAttendance();
      if (!result.success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message ?? l10n.wifiOffCompany),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }
    }
    final apiResult = await AttendanceRepository.recordCheckOut();
    if (!mounted) return;
    if (apiResult is ApiSuccess<void>) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.formSavedSuccess),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text((apiResult as ApiFailure<void>).message),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Directionality(
      textDirection: textDirectionForContext(context),
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.attendance),
        ),
        body: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // WiFi status
              Card(
                color: _isOnCompanyWifi
                    ? AppColors.success.withValues(alpha: 0.1)
                    : AppColors.warning.withValues(alpha: 0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        _isLoading ? Icons.hourglass_empty : (_isOnCompanyWifi ? Icons.wifi : Icons.wifi_off),
                        color: _isLoading ? AppColors.textMuted : (_isOnCompanyWifi ? AppColors.success : AppColors.warning),
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isLoading
                                  ? l10n.wifiChecking
                                  : (_isOnCompanyWifi ? l10n.wifiOnCompany : l10n.wifiOffCompany),
                              style: AppTypography.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                                color: _isOnCompanyWifi ? AppColors.success : AppColors.warning,
                              ),
                            ),
                            if (_wifiName != null)
                              Text(l10n.networkLabel(_wifiName!), style: AppTypography.caption),
                          ],
                        ),
                      ),
                      if (!_isLoading)
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: _checkWifiStatus,
                          tooltip: l10n.recheckWifi,
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Check-in / Check-out card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(Icons.access_time, size: 64, color: AppColors.primary),
                      const SizedBox(height: 16),
                      Text(l10n.attendanceTodayTitle, style: AppTypography.h4),
                      const SizedBox(height: 8),
                      Text(l10n.checkInTimeSample, style: AppTypography.h1.copyWith(color: AppColors.primary)),
                      Text(l10n.checkInRecorded, style: AppTypography.bodySmall),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _isLoading ? null : _handleCheckIn,
                          icon: const Icon(Icons.login),
                          label: Text(l10n.checkIn),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _isLoading ? null : _handleCheckOut,
                          icon: const Icon(Icons.logout),
                          label: Text(l10n.checkOut),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(l10n.attendanceLogLabel, style: AppTypography.h4),
              const SizedBox(height: 16),
              if (_loadingHistory)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                )
              else ..._history.map((h) {
                final statusLabel =
                    h.statusKey == 'late' ? l10n.late : (h.statusKey == 'present' ? l10n.present : l10n.absent);
                final statusColor = h.statusKey == 'late'
                    ? AppColors.warning
                    : (h.statusKey == 'present' ? AppColors.success : AppColors.error);
                return _AttendanceHistoryItem(
                  date: h.date,
                  checkIn: h.checkIn,
                  checkOut: h.checkOut,
                  statusLabel: statusLabel,
                  statusColor: statusColor,
                );
              }),
            ],
          ),
        ),
          ),
        ),
      ),
    );
  }
}

class _AttendanceHistoryRow {
  const _AttendanceHistoryRow({
    required this.date,
    required this.checkIn,
    required this.checkOut,
    required this.statusKey,
  });

  final String date;
  final String checkIn;
  final String checkOut;
  /// One of: `present`, `late`, `absent`
  final String statusKey;
}

class _AttendanceHistoryItem extends StatelessWidget {
  const _AttendanceHistoryItem({
    required this.date,
    required this.checkIn,
    required this.checkOut,
    required this.statusLabel,
    required this.statusColor,
  });

  final String date;
  final String checkIn;
  final String checkOut;
  final String statusLabel;
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(date, style: AppTypography.bodyMedium),
                Text('$checkIn - $checkOut', style: AppTypography.bodySmall),
              ],
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                statusLabel,
                style: TextStyle(color: statusColor, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
