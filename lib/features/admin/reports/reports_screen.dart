import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/api/api_result.dart';
import '../../../core/repositories/ai_tasks_repository.dart';
import '../../../core/repositories/reports_repository.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_strings.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  DateTime _start = DateTime.now().subtract(const Duration(days: 30));
  DateTime _end = DateTime.now();
  bool _loading = false;
  bool _useAsyncAi = true;
  String? _runningTaskId;
  Timer? _taskPoller;
  ReportSummaryResult? _summary;

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  void dispose() {
    _taskPoller?.cancel();
    super.dispose();
  }

  Future<void> _pickStart() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _start,
      firstDate: DateTime(2020),
      lastDate: _end,
    );
    if (picked != null) setState(() => _start = picked);
  }

  Future<void> _pickEnd() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _end,
      firstDate: _start,
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _end = picked);
  }

  Future<void> _generate() async {
    final l10n = AppStrings.of(context);
    setState(() => _loading = true);
    final localeCode = Localizations.localeOf(context).languageCode;
    if (_useAsyncAi) {
      final queueResult = await ReportsRepository.instance.queueSummary(
        periodStart: _fmt(_start),
        periodEnd: _fmt(_end),
        languageCode: localeCode,
        reportType: 'hr_overview',
      );
      if (!mounted) return;
      setState(() => _loading = false);
      switch (queueResult) {
        case ApiSuccess(:final data):
          setState(() => _runningTaskId = data);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.reportQueued),
              backgroundColor: AppColors.info,
            ),
          );
          _startTaskPolling(data);
        case ApiFailure(:final message):
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message), backgroundColor: AppColors.error),
          );
      }
      return;
    }

    final result = await ReportsRepository.instance.generateSummary(
      periodStart: _fmt(_start),
      periodEnd: _fmt(_end),
      languageCode: localeCode,
      reportType: 'hr_overview',
    );
    if (!mounted) return;
    setState(() => _loading = false);
    switch (result) {
      case ApiSuccess(:final data):
        setState(() => _summary = data);
      case ApiFailure(:final message):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: AppColors.error),
        );
    }
  }

  void _startTaskPolling(String taskId) {
    final l10n = AppStrings.of(context);
    _taskPoller?.cancel();
    _taskPoller = Timer.periodic(const Duration(seconds: 2), (_) async {
      final statusRes = await AiTasksRepository.instance.getTaskStatus(taskId);
      if (!mounted) return;
      switch (statusRes) {
        case ApiSuccess(:final data):
          if (data.isCompleted) {
            _taskPoller?.cancel();
            setState(() => _runningTaskId = null);
            final result = data.result ?? const <String, dynamic>{};
            setState(() {
              _summary = ReportSummaryResult(
                id: result['id']?.toString() ?? '',
                metrics: result['metrics'] as Map<String, dynamic>? ?? const {},
                narrative: result['narrative']?.toString() ?? '',
                provider: result['provider']?.toString(),
                model: result['model']?.toString(),
                status: result['status']?.toString(),
              );
            });
          } else if (data.isFailed) {
            _taskPoller?.cancel();
            setState(() => _runningTaskId = null);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(data.errorMessage ?? l10n.taskFailed),
                backgroundColor: AppColors.error,
              ),
            );
          }
        case ApiFailure():
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppStrings.of(context);
    final metrics = _summary?.metrics ?? const <String, dynamic>{};
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.reportsTitle, style: AppTypography.h1),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: _pickStart,
                    icon: const Icon(Icons.calendar_month_outlined),
                    label: Text('${l10n.fromDate}: ${_fmt(_start)}'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _pickEnd,
                    icon: const Icon(Icons.calendar_month),
                    label: Text('${l10n.toDate}: ${_fmt(_end)}'),
                  ),
                  FilledButton.icon(
                    onPressed: _loading ? null : _generate,
                    icon: _loading
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.auto_graph_outlined),
                    label: Text(l10n.generateSummary),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(l10n.asyncMode, style: AppTypography.caption),
                      Switch(
                        value: _useAsyncAi,
                        onChanged: (v) => setState(() => _useAsyncAi = v),
                      ),
                      if (_runningTaskId != null)
                        Text(
                          l10n.processing,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.info,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_summary != null) ...[
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: metrics.entries.map((entry) {
                return _MetricCard(label: entry.key, value: '${entry.value}');
              }).toList(),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.executiveNarrative, style: AppTypography.h4),
                    const SizedBox(height: 8),
                    SelectableText(
                      _summary!.narrative,
                      style: AppTypography.bodyMedium.copyWith(height: 1.45),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SizedBox(
        width: 220,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTypography.caption),
              const SizedBox(height: 6),
              Text(value, style: AppTypography.h4),
            ],
          ),
        ),
      ),
    );
  }
}
