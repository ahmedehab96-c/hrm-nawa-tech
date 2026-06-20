import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../core/repositories/attendance_repository.dart';
import '../../../core/api/api_result.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  List<AttendanceRecord> _records = [];
  AttendanceInsight? _insights;
  bool _loading = true;
  bool _loadingInsights = false;
  DateTime _selectedDate = DateTime.now();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final dateStr =
        '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';
    final result = await AttendanceRepository.getDailyAttendance(date: dateStr);
    if (!mounted) return;
    switch (result) {
      case ApiSuccess(:final data):
        setState(() { _records = data; _loading = false; });
      case ApiFailure(:final message):
        setState(() => _loading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message), backgroundColor: AppColors.error),
          );
        }
    }
    await _loadInsights();
  }

  Future<void> _loadInsights() async {
    setState(() => _loadingInsights = true);
    final result = await AttendanceRepository.getInsights(days: 30);
    if (!mounted) return;
    switch (result) {
      case ApiSuccess(:final data):
        setState(() {
          _insights = data;
          _loadingInsights = false;
        });
      case ApiFailure():
        setState(() => _loadingInsights = false);
    }
  }

  Future<void> _runAlerts() async {
    final result = await AttendanceRepository.runAlerts(days: 30);
    if (!mounted) return;
    switch (result) {
      case ApiSuccess(:final data):
        final ar = Localizations.localeOf(context).languageCode == 'ar';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(ar
              ? 'تم إنشاء $data تنبيهات حضور'
              : 'Generated $data attendance alerts'),
          backgroundColor: AppColors.success,
        ));
        _loadInsights();
      case ApiFailure(:final message):
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(message),
          backgroundColor: AppColors.error,
        ));
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
      _load();
    }
  }

  Future<void> _openEditDialog(AttendanceRecord record) async {
    final l10n = AppLocalizations.of(context)!;
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => _EditAttendanceDialog(record: record, date: _selectedDate),
    );
    if (result == true) {
      _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(l10n.formSavedSuccess),
          backgroundColor: AppColors.success,
        ));
      }
    }
  }

  String _workHours(String? checkIn, String? checkOut) {
    if (checkIn == null || checkOut == null) return '—';
    final inParts  = checkIn.split(':');
    final outParts = checkOut.split(':');
    if (inParts.length != 2 || outParts.length != 2) return '—';
    final inMin  = (int.tryParse(inParts[0])  ?? 0) * 60 + (int.tryParse(inParts[1])  ?? 0);
    final outMin = (int.tryParse(outParts[0]) ?? 0) * 60 + (int.tryParse(outParts[1]) ?? 0);
    final diff = outMin - inMin;
    if (diff <= 0) return '—';
    final h = diff / 60.0;
    return h % 1 == 0 ? h.toStringAsFixed(0) : h.toStringAsFixed(2);
  }

  List<AttendanceRecord> get _filtered {
    final q = _searchController.text.trim().toLowerCase();
    if (q.isEmpty) return _records;
    return _records.where((r) => r.employeeName.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n  = AppLocalizations.of(context)!;
    final dateLabel =
        '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';
    final filtered = _filtered;
    final ar = Localizations.localeOf(context).languageCode == 'ar';
    String tr(String arText, String enText) => ar ? arText : enText;

    // إحصائيات سريعة
    final presentCount = filtered.where((r) {
      final s = r.status.toLowerCase();
      return s == 'present' || s == 'حاضر';
    }).length;
    final lateCount = filtered.where((r) {
      final s = r.status.toLowerCase();
      return s == 'late' || s == 'متأخر';
    }).length;
    final absentCount = filtered.length - presentCount - lateCount;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────────
          LayoutBuilder(builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 640;
            final actions = [
              IconButton(
                onPressed: _loading ? null : _load,
                icon: const Icon(Icons.refresh),
                tooltip: l10n.refreshAction,
              ),
              OutlinedButton.icon(
                onPressed: () => _exportDemo(excel: true, l10n: l10n),
                icon: const Icon(Icons.file_download),
                label: Text(l10n.exportExcel),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () => _exportDemo(excel: false, l10n: l10n),
                icon: const Icon(Icons.picture_as_pdf),
                label: Text(l10n.exportPdf),
              ),
            ];
            if (isNarrow) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.dailyAttendance, style: AppTypography.h1),
                  const SizedBox(height: 12),
                  Wrap(spacing: 4, runSpacing: 8, children: actions),
                ],
              );
            }
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.dailyAttendance, style: AppTypography.h1),
                Row(children: actions),
              ],
            );
          }),
          const SizedBox(height: 24),

          // ── Stats Row ────────────────────────────────────────────────────
          if (!_loading)
            Row(
              children: [
                _StatChip(label: l10n.present,  count: presentCount, color: AppColors.success),
                const SizedBox(width: 8),
                _StatChip(label: l10n.late,     count: lateCount,    color: AppColors.warning),
                const SizedBox(width: 8),
                _StatChip(label: l10n.absent,   count: absentCount,  color: AppColors.error),
              ],
            ),
          const SizedBox(height: 16),

          // ── AI Insights ───────────────────────────────────────────────────
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.insights_outlined, color: AppColors.info),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          tr('تحليلات الحضور الذكية', 'AI Attendance Insights'),
                          style: AppTypography.h4,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _loadingInsights ? null : _runAlerts,
                        icon: const Icon(Icons.notifications_active_outlined, size: 18),
                        label: Text(tr('تشغيل التنبيهات', 'Run alerts')),
                      ),
                    ],
                  ),
                  if (_loadingInsights)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (_insights != null) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _InfoBadge(
                          label: tr('معدل التأخير', 'Late rate'),
                          value: '${_insights!.lateRate.toStringAsFixed(1)}%',
                          color: AppColors.warning,
                        ),
                        _InfoBadge(
                          label: tr('معدل الغياب', 'Absence rate'),
                          value: '${_insights!.absenceRate.toStringAsFixed(1)}%',
                          color: AppColors.error,
                        ),
                        _InfoBadge(
                          label: tr('موظفون عاليو المخاطر', 'Risk employees'),
                          value: '${_insights!.riskEmployees.length}',
                          color: AppColors.info,
                        ),
                      ],
                    ),
                    if (_insights!.latestAlerts.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      ..._insights!.latestAlerts.take(3).map((alert) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(
                            '• ${alert.employeeName ?? '—'}: ${alert.message}',
                            style: AppTypography.caption,
                          ),
                        );
                      }),
                    ],
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Filters ──────────────────────────────────────────────────────
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Date picker
                      InkWell(
                        onTap: _pickDate,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.textMuted.withValues(alpha: 0.4)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 18),
                              const SizedBox(width: 8),
                              Text(dateLabel, style: AppTypography.bodyMedium),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_drop_down, size: 18),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Search
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: l10n.search,
                            prefixIcon: const Icon(Icons.search),
                            isDense: true,
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, size: 18),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {});
                                    },
                                  )
                                : null,
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (_loading)
                    const Padding(padding: EdgeInsets.all(32), child: Center(child: CircularProgressIndicator()))
                  else if (filtered.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        l10n.noNotifications,
                        style: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
                      ),
                    )
                  else
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: [
                          DataColumn(label: Text(l10n.colEmployee)),
                          DataColumn(label: Text(l10n.colCheckIn)),
                          DataColumn(label: Text(l10n.colCheckOut)),
                          DataColumn(label: Text(l10n.colStatus)),
                          DataColumn(label: Text(l10n.colWorkHours)),
                          DataColumn(label: Text(l10n.actions)),
                        ],
                        rows: filtered.map((r) => _dataRow(r, l10n)).toList(),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  DataRow _dataRow(AttendanceRecord r, AppLocalizations l10n) {
    final s = r.status.toLowerCase();
    final isLate    = s == 'late';
    final isPresent = s == 'present';
    final statusLabel = isLate ? l10n.late : (isPresent ? l10n.present : l10n.absent);
    final checkIn  = (r.checkIn  == null || r.checkIn!.isEmpty)  ? '—' : r.checkIn!;
    final checkOut = (r.checkOut == null || r.checkOut!.isEmpty) ? '—' : r.checkOut!;

    return DataRow(
      cells: [
        DataCell(Text(r.employeeName, style: AppTypography.bodyMedium)),
        DataCell(Text(checkIn,  style: AppTypography.bodySmall)),
        DataCell(Text(checkOut, style: AppTypography.bodySmall)),
        DataCell(StatusBadge(
          label: statusLabel,
          status: isPresent
              ? StatusType.success
              : isLate
                  ? StatusType.warning
                  : StatusType.error,
        )),
        DataCell(Text(_workHours(r.checkIn, r.checkOut), style: AppTypography.bodySmall)),
        DataCell(IconButton(
          icon: const Icon(Icons.edit_outlined, size: 20),
          tooltip: l10n.edit,
          onPressed: () => _openEditDialog(r),
        )),
      ],
    );
  }

  void _exportDemo({required bool excel, required AppLocalizations l10n}) {
    final label = excel ? l10n.formatExcel : l10n.formatPdf;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(l10n.exportPrepared(label)),
      backgroundColor: AppColors.success,
    ));
  }
}

// ─── Edit Dialog ──────────────────────────────────────────────────────────────

class _EditAttendanceDialog extends StatefulWidget {
  const _EditAttendanceDialog({required this.record, required this.date});

  final AttendanceRecord record;
  final DateTime date;

  @override
  State<_EditAttendanceDialog> createState() => _EditAttendanceDialogState();
}

class _EditAttendanceDialogState extends State<_EditAttendanceDialog> {
  late final TextEditingController _checkInCtrl;
  late final TextEditingController _checkOutCtrl;
  late String _status;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _checkInCtrl  = TextEditingController(text: widget.record.checkIn  ?? '');
    _checkOutCtrl = TextEditingController(text: widget.record.checkOut ?? '');
    _status = _normalizeStatus(widget.record.status);
  }

  @override
  void dispose() {
    _checkInCtrl.dispose();
    _checkOutCtrl.dispose();
    super.dispose();
  }

  String _normalizeStatus(String raw) {
    final s = raw.toLowerCase();
    if (s == 'late'    || s == 'متأخر')  return 'late';
    if (s == 'absent'  || s == 'غائب')   return 'absent';
    return 'present';
  }

  Future<void> _pickTime(TextEditingController ctrl) async {
    final parts = ctrl.text.split(':');
    final initial = TimeOfDay(
      hour:   int.tryParse(parts.isNotEmpty ? parts[0] : '8') ?? 8,
      minute: int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0,
    );
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked != null) {
      ctrl.text =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);

    ApiResult result;
    final checkIn  = _checkInCtrl.text.trim().isEmpty  ? null : _checkInCtrl.text.trim();
    final checkOut = _checkOutCtrl.text.trim().isEmpty ? null : _checkOutCtrl.text.trim();

    if (widget.record.id != null) {
      // تحديث سجل موجود
      result = await AttendanceRepository.updateRecord(
        recordId: widget.record.id!,
        checkIn:  checkIn,
        checkOut: checkOut,
        status:   _status,
      );
    } else {
      // إنشاء سجل جديد (موظف غائب لم يُسجَّل بعد)
      final dateStr =
          '${widget.date.year}-${widget.date.month.toString().padLeft(2, '0')}-${widget.date.day.toString().padLeft(2, '0')}';
      result = await AttendanceRepository.upsertRecord(
        employeeId: widget.record.employeeId,
        date:       dateStr,
        checkIn:    checkIn,
        checkOut:   checkOut,
        status:     _status,
      );
    }

    if (!mounted) return;
    setState(() => _saving = false);

    switch (result) {
      case ApiSuccess():
        Navigator.of(context).pop(true);
      case ApiFailure(:final message):
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(message),
          backgroundColor: AppColors.error,
        ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text('${l10n.editAttendance} — ${widget.record.employeeName}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Check-in
            TextField(
              controller: _checkInCtrl,
              readOnly: true,
              decoration: InputDecoration(
                labelText: l10n.checkIn,
                prefixIcon: const Icon(Icons.login),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.access_time),
                  onPressed: () => _pickTime(_checkInCtrl),
                ),
              ),
              onTap: () => _pickTime(_checkInCtrl),
            ),
            const SizedBox(height: 16),
            // Check-out
            TextField(
              controller: _checkOutCtrl,
              readOnly: true,
              decoration: InputDecoration(
                labelText: l10n.checkOut,
                prefixIcon: const Icon(Icons.logout),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.access_time),
                  onPressed: () => _pickTime(_checkOutCtrl),
                ),
              ),
              onTap: () => _pickTime(_checkOutCtrl),
            ),
            const SizedBox(height: 16),
            // Status
            DropdownButtonFormField<String>(
              key: ValueKey(_status),
              initialValue: _status,
              decoration: InputDecoration(
                labelText: l10n.status,
                prefixIcon: const Icon(Icons.flag_outlined),
              ),
              items: [
                DropdownMenuItem(value: 'present', child: Text(l10n.present)),
                DropdownMenuItem(value: 'late',    child: Text(l10n.late)),
                DropdownMenuItem(value: 'absent',  child: Text(l10n.absent)),
              ],
              onChanged: (v) => setState(() => _status = v ?? 'present'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  width: 20, height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : Text(l10n.save),
        ),
      ],
    );
  }
}

// ─── Stat Chip ────────────────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.count, required this.color});

  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$count',
            style: AppTypography.h4.copyWith(color: color),
          ),
          const SizedBox(width: 6),
          Text(label, style: AppTypography.caption.copyWith(color: color)),
        ],
      ),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  const _InfoBadge({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: AppTypography.label.copyWith(color: color)),
          const SizedBox(width: 6),
          Text(label, style: AppTypography.caption),
        ],
      ),
    );
  }
}
