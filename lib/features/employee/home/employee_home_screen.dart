import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_result.dart';
import '../../../core/repositories/attendance_repository.dart';
import '../../../core/services/wifi_attendance_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/attendance_gate.dart';
import '../../../core/utils/text_direction_helper.dart';
import '../../../core/widgets/animations.dart';
import '../../../l10n/app_localizations.dart';

class EmployeeHomeScreen extends StatefulWidget {
  const EmployeeHomeScreen({super.key});

  @override
  State<EmployeeHomeScreen> createState() => _EmployeeHomeScreenState();
}

class _EmployeeHomeScreenState extends State<EmployeeHomeScreen> {
  bool    _isOnCompanyWifi = false;
  String? _wifiName;
  bool    _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkWifiStatus();
  }

  Future<void> _checkWifiStatus() async {
    setState(() => _isLoading = true);
    final result = await WifiAttendanceService.canRecordAttendance();
    setState(() {
      _isOnCompanyWifi = result.success;
      _wifiName        = result.wifiName;
      _isLoading       = false;
    });
  }

  Future<void> _handleCheckIn() async {
    final l10n = AppLocalizations.of(context)!;
    if (await requireCompanyWifiForAttendance()) {
      final result = await WifiAttendanceService.canRecordAttendance();
      if (!result.success) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(result.message ?? l10n.wifiOffCompany),
          backgroundColor: AppColors.error,
        ));
        return;
      }
    }
    final res = await AttendanceRepository.recordCheckIn();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
          res is ApiSuccess<void> ? l10n.checkInRecorded : (res as ApiFailure<void>).message),
      backgroundColor: res is ApiSuccess<void> ? AppColors.success : AppColors.error,
    ));
  }

  Future<void> _handleCheckOut() async {
    final l10n = AppLocalizations.of(context)!;
    if (await requireCompanyWifiForAttendance()) {
      final result = await WifiAttendanceService.canRecordAttendance();
      if (!result.success) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(result.message ?? l10n.wifiOffCompany),
          backgroundColor: AppColors.error,
        ));
        return;
      }
    }
    final res = await AttendanceRepository.recordCheckOut();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
          res is ApiSuccess<void> ? l10n.formSavedSuccess : (res as ApiFailure<void>).message),
      backgroundColor: res is ApiSuccess<void> ? AppColors.success : AppColors.error,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Directionality(
      textDirection: textDirectionForContext(context),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primaryDark,
          elevation: 0,
          title: Text(l10n.employeeNavHome,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined, color: Colors.white),
              onPressed: () => context.push('/employee/notifications'),
              tooltip: l10n.notificationsTooltip,
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Gradient header with greeting + WiFi chip ─────────────
              _HeaderBanner(
                greeting: l10n.greetingWithName('محمد'),
                date: l10n.homeDateSample,
                isLoading: _isLoading,
                isOnCompanyWifi: _isOnCompanyWifi,
                wifiName: _wifiName,
                onRefresh: _checkWifiStatus,
              ),

              // ── Attendance card ────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: FadeSlideIn(
                  delay: const Duration(milliseconds: 80),
                  child: _AttendanceCard(
                    isLoading: _isLoading,
                    onCheckIn: _handleCheckIn,
                    onCheckOut: _handleCheckOut,
                  ),
                ),
              ),

              // ── Quick actions ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                child: FadeSlideIn(
                  delay: const Duration(milliseconds: 160),
                  child: Text(l10n.quickActionsTitle, style: AppTypography.h4),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.35,
                  children: [
                    FadeSlideIn(delay: const Duration(milliseconds: 200),
                      child: _QuickActionCard(icon: Icons.event_note_outlined, label: l10n.requestLeave,      iconColor: AppColors.warning,   onTap: () => context.go('/employee/leave'))),
                    FadeSlideIn(delay: const Duration(milliseconds: 240),
                      child: _QuickActionCard(icon: Icons.receipt_long,         label: l10n.payslip,           iconColor: AppColors.success,   onTap: () => context.go('/employee/payslip'))),
                    FadeSlideIn(delay: const Duration(milliseconds: 280),
                      child: _QuickActionCard(icon: Icons.access_time,           label: l10n.attendanceLogLabel, iconColor: AppColors.primary,   onTap: () => context.go('/employee/attendance'))),
                    FadeSlideIn(delay: const Duration(milliseconds: 320),
                      child: _QuickActionCard(icon: Icons.person_outline,        label: l10n.profileQuickLabel,  iconColor: AppColors.secondary, onTap: () => context.go('/employee/profile'))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Header Banner ────────────────────────────────────────────────────────────
/// Gradient top section that continues visually from the AppBar.
class _HeaderBanner extends StatelessWidget {
  const _HeaderBanner({
    required this.greeting,
    required this.date,
    required this.isLoading,
    required this.isOnCompanyWifi,
    this.wifiName,
    required this.onRefresh,
  });

  final String   greeting, date;
  final bool     isLoading, isOnCompanyWifi;
  final String?  wifiName;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final l10n      = AppLocalizations.of(context)!;
    final wifiColor = isOnCompanyWifi ? AppColors.success : AppColors.warning;
    final wifiIcon  = isOnCompanyWifi ? Icons.wifi_rounded : Icons.wifi_off_rounded;
    final wifiLabel = isLoading
        ? l10n.wifiCheckingHome
        : (isOnCompanyWifi
            ? (wifiName != null ? l10n.networkLabel(wifiName!) : l10n.wifiOnCompany)
            : l10n.wifiNotOnCompanyHome);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryDark, AppColors.primary],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft:  Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(greeting,
              style: AppTypography.h2.copyWith(
                  color: Colors.white, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(date,
              style: AppTypography.caption.copyWith(color: Colors.white60)),
          const SizedBox(height: 16),
          // WiFi chip — tap to refresh
          GestureDetector(
            onTap: onRefresh,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isLoading
                    ? Colors.white12
                    : wifiColor.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: isLoading
                        ? Colors.white24
                        : wifiColor.withValues(alpha: 0.5)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  isLoading
                      ? const SizedBox(
                          width: 14, height: 14,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white54))
                      : Icon(wifiIcon, color: wifiColor, size: 14),
                  const SizedBox(width: 6),
                  Text(wifiLabel,
                      style: TextStyle(
                          color: isLoading ? Colors.white54 : wifiColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Attendance Card ──────────────────────────────────────────────────────────
class _AttendanceCard extends StatelessWidget {
  const _AttendanceCard({
    required this.isLoading,
    required this.onCheckIn,
    required this.onCheckOut,
  });

  final bool         isLoading;
  final VoidCallback onCheckIn, onCheckOut;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          // Tinted header strip
          Container(
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.07),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.attendanceTodayTitle, style: AppTypography.h4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color:  AppColors.success.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.success.withValues(alpha: 0.35)),
                  ),
                  child: Text(l10n.present,
                      style: const TextStyle(
                          color: AppColors.success, fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),

          // Times row
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Row(
              children: [
                Expanded(
                    child: _TimeItem(
                        l10n.checkIn, '08:00', Icons.login, AppColors.primary)),
                Container(height: 40, width: 1, color: AppColors.border),
                Expanded(
                    child: _TimeItem(
                        l10n.checkOut, '--:--', Icons.logout, AppColors.textMuted)),
              ],
            ),
          ),

          // Action buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isLoading ? null : onCheckIn,
                    icon: const Icon(Icons.login, size: 18),
                    label: Text(l10n.checkIn),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: isLoading ? null : onCheckOut,
                    icon: const Icon(Icons.logout, size: 18),
                    label: Text(l10n.checkOut),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Time Item ────────────────────────────────────────────────────────────────
class _TimeItem extends StatelessWidget {
  const _TimeItem(this.label, this.time, this.icon, this.color);

  final String  label, time;
  final IconData icon;
  final Color   color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(height: 6),
        Text(label, style: AppTypography.caption),
        const SizedBox(height: 2),
        Text(time, style: AppTypography.h4),
      ],
    );
  }
}

// ─── Quick Action Card ────────────────────────────────────────────────────────
class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.onTap,
  });

  final IconData     icon;
  final String       label;
  final Color        iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 50, height: 50,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, size: 26, color: iconColor),
              ),
              const SizedBox(height: 10),
              Text(label,
                  style: AppTypography.bodyMedium
                      .copyWith(fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }
}
