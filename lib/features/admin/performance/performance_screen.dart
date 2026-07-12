import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/api/api_result.dart';
import '../../../core/repositories/ai_tasks_repository.dart';
import '../../../core/repositories/employees_repository.dart';
import '../../../core/repositories/performance_repository.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_strings.dart';

class PerformanceScreen extends StatefulWidget {
  const PerformanceScreen({super.key});

  @override
  State<PerformanceScreen> createState() => _PerformanceScreenState();
}

class _PerformanceScreenState extends State<PerformanceScreen> {
  List<PerformanceReviewItem> _reviews = const [];
  List<EmployeeItem> _employees = const [];
  bool _loading = true;
  bool _saving = false;
  String? _loadError;
  String? _selectedEmployeeId;
  String _period =
      '${DateTime.now().year}-Q${((DateTime.now().month - 1) ~/ 3) + 1}';
  int _rating = 3;
  final _goalsCtrl = TextEditingController();
  final _strengthsCtrl = TextEditingController();
  final _improvementCtrl = TextEditingController();
  final _managerCtrl = TextEditingController();
  final Set<String> _analyzing = <String>{};
  bool _useAsyncAi = true;
  String? _runningTaskId;
  Timer? _taskPoller;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _taskPoller?.cancel();
    _goalsCtrl.dispose();
    _strengthsCtrl.dispose();
    _improvementCtrl.dispose();
    _managerCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    final employeesRes = await EmployeesRepository.getEmployees();
    final reviewsRes = await PerformanceRepository.instance.getReviews(
      period: _period,
    );
    if (!mounted) return;

    final errors = <String>[];
    if (employeesRes case ApiSuccess(:final data)) {
      _employees = data;
      _selectedEmployeeId ??= _employees.isNotEmpty
          ? _employees.first.id
          : null;
    } else if (employeesRes case ApiFailure(:final message)) {
      errors.add(message);
    }
    if (reviewsRes case ApiSuccess(:final data)) {
      _reviews = data;
    } else if (reviewsRes case ApiFailure(:final message)) {
      errors.add(message);
    }

    setState(() {
      _loading = false;
      _loadError = errors.isEmpty ? null : errors.first;
    });
  }

  Future<void> _saveReview() async {
    if (_selectedEmployeeId == null || _saving) return;
    final l10n = AppStrings.of(context);
    setState(() => _saving = true);
    final result = await PerformanceRepository.instance.saveReview(
      employeeId: _selectedEmployeeId!,
      periodLabel: _period,
      rating: _rating,
      goalsSummary: _goalsCtrl.text.trim(),
      strengths: _strengthsCtrl.text.trim(),
      improvementAreas: _improvementCtrl.text.trim(),
      managerComment: _managerCtrl.text.trim(),
    );
    if (!mounted) return;
    setState(() => _saving = false);

    switch (result) {
      case ApiSuccess():
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.reviewSaved),
            backgroundColor: AppColors.success,
          ),
        );
        _goalsCtrl.clear();
        _strengthsCtrl.clear();
        _improvementCtrl.clear();
        _managerCtrl.clear();
        _load();
      case ApiFailure(:final message):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: AppColors.error),
        );
    }
  }

  Future<void> _analyze(String reviewId) async {
    if (_analyzing.contains(reviewId)) return;
    final l10n = AppStrings.of(context);
    setState(() => _analyzing.add(reviewId));
    final localeCode = Localizations.localeOf(context).languageCode;
    if (_useAsyncAi) {
      final queueRes = await PerformanceRepository.instance.queueAnalyzeReview(
        reviewId,
        languageCode: localeCode,
      );
      if (!mounted) return;
      setState(() => _analyzing.remove(reviewId));
      switch (queueRes) {
        case ApiSuccess(:final data):
          setState(() => _runningTaskId = data);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.analysisQueued),
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

    final result = await PerformanceRepository.instance.analyzeReview(
      reviewId,
      languageCode: localeCode,
    );
    if (!mounted) return;
    setState(() => _analyzing.remove(reviewId));

    switch (result) {
      case ApiSuccess():
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.aiAnalysisGenerated),
            backgroundColor: AppColors.success,
          ),
        );
        _load();
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
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.aiAnalysisCompleted),
                backgroundColor: AppColors.success,
              ),
            );
            _load();
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
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(l10n.performanceTitle, style: AppTypography.h1),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.asyncMode, style: AppTypography.caption),
                  Switch(
                    value: _useAsyncAi,
                    onChanged: (v) => setState(() => _useAsyncAi = v),
                  ),
                ],
              ),
              if (_runningTaskId != null)
                Text(
                  l10n.processing,
                  style: AppTypography.caption.copyWith(color: AppColors.info),
                ),
              IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
            ],
          ),
          if (_loadError != null) ...[
            const SizedBox(height: 12),
            MaterialBanner(
              backgroundColor: AppColors.warning.withValues(alpha: 0.12),
              content: Text(_loadError!, style: AppTypography.bodySmall),
              leading: const Icon(Icons.warning_amber_rounded, color: AppColors.warning),
              actions: [
                TextButton(onPressed: _load, child: Text(l10n.retryAction)),
              ],
            ),
          ],
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(l10n.performanceNewReview, style: AppTypography.h4),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _selectedEmployeeId,
                          decoration: InputDecoration(labelText: l10n.employees),
                          items: _employees
                              .map(
                                (e) => DropdownMenuItem(
                                  value: e.id,
                                  child: Text(e.name),
                                ),
                              )
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _selectedEmployeeId = v),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          initialValue: _period,
                          decoration: InputDecoration(labelText: l10n.periodLabel),
                          onChanged: (v) => _period = v.trim(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          initialValue: _rating,
                          decoration: InputDecoration(labelText: l10n.ratingLabel),
                          items: List.generate(5, (i) => i + 1)
                              .map(
                                (e) => DropdownMenuItem(
                                  value: e,
                                  child: Text('$e/5'),
                                ),
                              )
                              .toList(),
                          onChanged: (v) => setState(() => _rating = v ?? 3),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _goalsCtrl,
                    maxLines: 2,
                    decoration: InputDecoration(labelText: l10n.goalsSummary),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _strengthsCtrl,
                    maxLines: 2,
                    decoration: InputDecoration(labelText: l10n.strengths),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _improvementCtrl,
                    maxLines: 2,
                    decoration: InputDecoration(labelText: l10n.improvementAreas),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _managerCtrl,
                    maxLines: 2,
                    decoration: InputDecoration(labelText: l10n.managerComment),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: _saving ? null : _saveReview,
                    icon: _saving
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.save_outlined),
                    label: Text(l10n.saveReview),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_loading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            )
          else
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: [
                      DataColumn(label: Text(l10n.employees)),
                      DataColumn(label: Text(l10n.periodLabel)),
                      DataColumn(label: Text(l10n.ratingLabel)),
                      DataColumn(label: Text(l10n.aiSummaryCol)),
                      DataColumn(label: Text(l10n.actions)),
                    ],
                    rows: _reviews.map((r) {
                      return DataRow(
                        cells: [
                          DataCell(Text(r.employeeName)),
                          DataCell(Text(r.periodLabel)),
                          DataCell(Text(r.rating?.toString() ?? '—')),
                          DataCell(
                            SizedBox(
                              width: 360,
                              child: Text(
                                r.aiSummary?.isNotEmpty == true
                                    ? r.aiSummary!
                                    : l10n.noAnalysisYet,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          DataCell(
                            FilledButton.tonal(
                              onPressed: _analyzing.contains(r.id)
                                  ? null
                                  : () => _analyze(r.id),
                              child: Text(
                                _analyzing.contains(r.id)
                                    ? l10n.analyzing
                                    : _useAsyncAi
                                    ? l10n.queueAiAnalysis
                                    : l10n.analyzeAi,
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
