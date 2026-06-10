import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/text_direction_helper.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/services/wifi_attendance_service.dart';
import '../../../core/repositories/attendance_repository.dart';
import '../../../core/api/api_result.dart';
import '../../../core/utils/attendance_gate.dart';

class EmployeeHomeScreen extends StatefulWidget {
  const EmployeeHomeScreen({super.key});

  @override
  State<EmployeeHomeScreen> createState() => _EmployeeHomeScreenState();
}

class _EmployeeHomeScreenState extends State<EmployeeHomeScreen> {
  bool _isOnCompanyWifi = false;
  String? _wifiName;
  bool _isLoading = true;

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
      _wifiName = result.wifiName;
      _isLoading = false;
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
          title: Text(l10n.employeeNavHome),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () => context.push('/employee/notifications'),
              tooltip: l10n.notificationsTooltip,
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.greetingWithName('محمد'),
                style: AppTypography.h2,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.homeDateSample,
                style: AppTypography.bodySmall,
              ),
              const SizedBox(height: 24),
              // WiFi status banner
              _WifiStatusBanner(
                isOnCompanyWifi: _isOnCompanyWifi,
                wifiName: _wifiName,
                isLoading: _isLoading,
                onRefresh: _checkWifiStatus,
              ),
              const SizedBox(height: 16),
              // Today attendance status
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(l10n.attendanceTodayTitle, style: AppTypography.h4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              l10n.present,
                              style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _TimeItem(l10n.checkIn, '08:00', Icons.login),
                          _TimeItem(l10n.checkOut, '--:--', Icons.logout),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _isLoading ? null : _handleCheckIn,
                              icon: const Icon(Icons.login),
                              label: Text(l10n.checkIn),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: _isLoading ? null : _handleCheckOut,
                              icon: const Icon(Icons.logout),
                              label: Text(l10n.checkOut),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Quick actions
              Text(l10n.quickActionsTitle, style: AppTypography.h4),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.3,
                children: [
                  _QuickActionCard(
                    icon: Icons.event_note_outlined,
                    label: l10n.requestLeave,
                    onTap: () => context.go('/employee/leave'),
                  ),
                  _QuickActionCard(
                    icon: Icons.receipt_long,
                    label: l10n.payslip,
                    onTap: () => context.go('/employee/payslip'),
                  ),
                  _QuickActionCard(
                    icon: Icons.access_time,
                    label: l10n.attendanceLogLabel,
                    onTap: () => context.go('/employee/attendance'),
                  ),
                  _QuickActionCard(
                    icon: Icons.person_outline,
                    label: l10n.profileQuickLabel,
                    onTap: () => context.go('/employee/profile'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WifiStatusBanner extends StatelessWidget {
  const _WifiStatusBanner({
    required this.isOnCompanyWifi,
    required this.wifiName,
    required this.isLoading,
    required this.onRefresh,
  });

  final bool isOnCompanyWifi;
  final String? wifiName;
  final bool isLoading;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (isLoading) {
      return Card(
        color: AppColors.surfaceVariant,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 12),
              Text(l10n.wifiCheckingHome, style: AppTypography.bodySmall),
            ],
          ),
        ),
      );
    }
    return Card(
      color: isOnCompanyWifi
          ? AppColors.success.withValues(alpha: 0.1)
          : AppColors.warning.withValues(alpha: 0.1),
      child: InkWell(
        onTap: onRefresh,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                isOnCompanyWifi ? Icons.wifi : Icons.wifi_off,
                color: isOnCompanyWifi ? AppColors.success : AppColors.warning,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isOnCompanyWifi ? l10n.wifiOnCompany : l10n.wifiNotOnCompanyHome,
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isOnCompanyWifi ? AppColors.success : AppColors.warning,
                      ),
                    ),
                    if (wifiName != null)
                      Text(
                        l10n.networkLabel(wifiName!),
                        style: AppTypography.caption,
                      ),
                    if (!isOnCompanyWifi)
                      Text(
                        l10n.attendanceOnlyWifiHint,
                        style: AppTypography.caption,
                      ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: onRefresh,
                tooltip: l10n.recheckWifi,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimeItem extends StatelessWidget {
  const _TimeItem(this.label, this.time, this.icon);

  final String label;
  final String time;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(height: 8),
        Text(label, style: AppTypography.caption),
        Text(time, style: AppTypography.h4),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 36, color: AppColors.primary),
              const SizedBox(height: 12),
              Text(label, style: AppTypography.bodyMedium, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
