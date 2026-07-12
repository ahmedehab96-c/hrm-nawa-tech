import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/api/api_result.dart';
import '../../../core/repositories/ai_content_repository.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_strings.dart';

class AiCommandCenterScreen extends StatefulWidget {
  const AiCommandCenterScreen({super.key});

  @override
  State<AiCommandCenterScreen> createState() => _AiCommandCenterScreenState();
}

class _AiCommandCenterScreenState extends State<AiCommandCenterScreen> {
  final _jobTitleCtrl = TextEditingController();
  final _jobDeptCtrl = TextEditingController();
  final _jobLocationCtrl = TextEditingController();
  final _jobTypeCtrl = TextEditingController();
  final _jobRequirementsCtrl = TextEditingController();
  final _jobResponsibilitiesCtrl = TextEditingController();

  final _commPurposeCtrl = TextEditingController();
  final _commRecipientCtrl = TextEditingController();
  final _commEmployeeCtrl = TextEditingController();
  final _commDeptCtrl = TextEditingController();
  final _commPointsCtrl = TextEditingController();
  final _promptVersionLabelCtrl = TextEditingController();
  final _promptTextCtrl = TextEditingController();

  String _jobTone = 'professional';
  String _commTone = 'professional';
  String _commType = 'email';
  String _promptFeature = 'assistant_chat';

  bool _busyJob = false;
  bool _busyComm = false;
  bool _loadingUsage = false;
  bool _loadingObservability = false;
  bool _loadingCanary = false;
  bool _loadingPlaybooks = false;
  bool _loadingPrompts = false;
  bool _loadingSlo = false;
  bool _loadingCostAnomalies = false;
  bool _loadingAudit = false;
  bool _loadingEscalationState = false;
  bool _loadingQueueMonitor = false;
  bool _runningDigest = false;
  bool _savingPrompt = false;
  bool _applyingRemediation = false;
  bool _dispatchingEscalation = false;
  String _jobOutput = '';
  String _commOutput = '';
  String? _meta;
  AiUsageSummary? _usage;
  AiObservabilitySummary? _observability;
  AiCanarySummary? _canary;
  AiIncidentPlaybookBundle? _playbooks;
  List<AiPromptVersionItem> _promptVersions = const [];
  Map<String, dynamic>? _slo;
  Map<String, dynamic>? _costAnomalies;
  Map<String, dynamic>? _audit;
  Map<String, dynamic>? _escalationRunbooks;
  Map<String, dynamic>? _escalationNotifications;
  Map<String, dynamic>? _queueHealthMonitor;
  int _queueMonitorWindowMinutes = 1440;
  String _queueMonitorSeverity = 'all';
  Timer? _queueMonitorRefreshTimer;

  @override
  void initState() {
    super.initState();
    _loadUsage();
    _loadObservability();
    _loadCanary();
    _loadPlaybooks();
    _loadSlo();
    _loadCostAnomalies();
    _loadAuditTrail();
    _loadEscalationState();
    _loadQueueHealthMonitor();
    _loadPromptVersions();
    _startQueueMonitorAutoRefresh();
  }

  void _startQueueMonitorAutoRefresh() {
    _queueMonitorRefreshTimer?.cancel();
    _queueMonitorRefreshTimer = Timer.periodic(
      const Duration(seconds: 60),
      (_) {
        if (!mounted) return;
        _loadQueueHealthMonitor(silent: true);
      },
    );
  }

  @override
  void dispose() {
    _queueMonitorRefreshTimer?.cancel();
    _jobTitleCtrl.dispose();
    _jobDeptCtrl.dispose();
    _jobLocationCtrl.dispose();
    _jobTypeCtrl.dispose();
    _jobRequirementsCtrl.dispose();
    _jobResponsibilitiesCtrl.dispose();
    _commPurposeCtrl.dispose();
    _commRecipientCtrl.dispose();
    _commEmployeeCtrl.dispose();
    _commDeptCtrl.dispose();
    _commPointsCtrl.dispose();
    _promptVersionLabelCtrl.dispose();
    _promptTextCtrl.dispose();
    super.dispose();
  }

  bool get _isArabic => Localizations.localeOf(context).languageCode == 'ar';
  String _txt(String ar, String en) => _isArabic ? ar : en;

  Future<void> _loadUsage() async {
    setState(() => _loadingUsage = true);
    final result = await AiContentRepository.instance.getUsage();
    if (!mounted) return;
    setState(() => _loadingUsage = false);
    switch (result) {
      case ApiSuccess(:final data):
        setState(() => _usage = data);
      case ApiFailure(:final message):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: AppColors.error),
        );
    }
  }

  Future<void> _loadObservability() async {
    setState(() => _loadingObservability = true);
    final result = await AiContentRepository.instance.getObservability(
      days: 14,
    );
    if (!mounted) return;
    setState(() => _loadingObservability = false);
    switch (result) {
      case ApiSuccess(:final data):
        setState(() => _observability = data);
      case ApiFailure(:final message):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: AppColors.error),
        );
    }
  }

  Future<void> _loadPromptVersions() async {
    setState(() => _loadingPrompts = true);
    final result = await AiContentRepository.instance.getPromptVersions(
      featureKey: _promptFeature,
    );
    if (!mounted) return;
    setState(() => _loadingPrompts = false);
    switch (result) {
      case ApiSuccess(:final data):
        setState(() => _promptVersions = data);
      case ApiFailure(:final message):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: AppColors.error),
        );
    }
  }

  Future<void> _loadCanary() async {
    setState(() => _loadingCanary = true);
    final result = await AiContentRepository.instance.getCanary(days: 14);
    if (!mounted) return;
    setState(() => _loadingCanary = false);
    switch (result) {
      case ApiSuccess(:final data):
        setState(() => _canary = data);
      case ApiFailure(:final message):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: AppColors.error),
        );
    }
  }

  Future<void> _loadPlaybooks() async {
    setState(() => _loadingPlaybooks = true);
    final result = await AiContentRepository.instance.getIncidentPlaybooks(
      days: 14,
    );
    if (!mounted) return;
    setState(() => _loadingPlaybooks = false);
    switch (result) {
      case ApiSuccess(:final data):
        setState(() => _playbooks = data);
      case ApiFailure(:final message):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: AppColors.error),
        );
    }
  }

  Future<void> _loadSlo() async {
    setState(() => _loadingSlo = true);
    final result = await AiContentRepository.instance.getSloReport();
    if (!mounted) return;
    setState(() => _loadingSlo = false);
    switch (result) {
      case ApiSuccess(:final data):
        setState(() => _slo = data);
      case ApiFailure(:final message):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: AppColors.error),
        );
    }
  }

  Future<void> _loadCostAnomalies() async {
    setState(() => _loadingCostAnomalies = true);
    final result = await AiContentRepository.instance.getCostAnomalies(days: 35);
    if (!mounted) return;
    setState(() => _loadingCostAnomalies = false);
    switch (result) {
      case ApiSuccess(:final data):
        setState(() => _costAnomalies = data);
      case ApiFailure(:final message):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: AppColors.error),
        );
    }
  }

  Future<void> _loadAuditTrail() async {
    setState(() => _loadingAudit = true);
    final result = await AiContentRepository.instance.getAuditTrail(limit: 80);
    if (!mounted) return;
    setState(() => _loadingAudit = false);
    switch (result) {
      case ApiSuccess(:final data):
        setState(() => _audit = data);
      case ApiFailure(:final message):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: AppColors.error),
        );
    }
  }

  Future<void> _loadEscalationState() async {
    setState(() => _loadingEscalationState = true);
    final runbooks = await AiContentRepository.instance.getEscalationRunbooks();
    final notifications =
        await AiContentRepository.instance.getEscalationNotifications(limit: 30);
    if (!mounted) return;
    setState(() => _loadingEscalationState = false);

    switch (runbooks) {
      case ApiSuccess(:final data):
        _escalationRunbooks = data;
      case ApiFailure(:final message):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: AppColors.error),
        );
    }
    switch (notifications) {
      case ApiSuccess(:final data):
        _escalationNotifications = data;
      case ApiFailure(:final message):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: AppColors.error),
        );
    }
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadQueueHealthMonitor({
    int? windowMinutes,
    bool silent = false,
  }) async {
    final selectedWindow = windowMinutes ?? _queueMonitorWindowMinutes;
    if (!silent) {
      setState(() => _loadingQueueMonitor = true);
    }
    final result = await AiContentRepository.instance.getQueueHealthEvents(
      limit: 20,
      windowMinutes: selectedWindow,
    );
    if (!mounted) return;
    setState(() {
      if (!silent) {
        _loadingQueueMonitor = false;
      }
      _queueMonitorWindowMinutes = selectedWindow;
    });
    switch (result) {
      case ApiSuccess(:final data):
        setState(() => _queueHealthMonitor = data);
      case ApiFailure(:final message):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: AppColors.error),
        );
    }
  }

  List<Map<String, dynamic>> _filteredQueueMonitorEvents() {
    final raw = _queueHealthMonitor?['latest'] as List<dynamic>? ?? const [];
    final rows = raw.whereType<Map<String, dynamic>>();
    if (_queueMonitorSeverity == 'all') {
      return rows.toList();
    }

    return rows
        .where((r) => (r['severity']?.toString() ?? 'info') == _queueMonitorSeverity)
        .toList();
  }

  Future<void> _runDigest() async {
    if (_runningDigest) return;
    setState(() => _runningDigest = true);
    final result = await AiContentRepository.instance.runEscalationDigest(
      queue: true,
      dryRun: false,
    );
    if (!mounted) return;
    setState(() => _runningDigest = false);
    switch (result) {
      case ApiSuccess(:final data):
        final queued = data['queued'] == true;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              queued
                  ? _txt('تمت جدولة Digest', 'Digest has been queued')
                  : _txt('تم تنفيذ Digest', 'Digest executed'),
            ),
            backgroundColor: AppColors.success,
          ),
        );
        _loadEscalationState();
        _loadAuditTrail();
        _loadQueueHealthMonitor();
      case ApiFailure(:final message):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: AppColors.error),
        );
    }
  }

  Future<void> _dispatchEscalation({
    required String alertCode,
    String severity = 'warning',
  }) async {
    if (_dispatchingEscalation) return;
    setState(() => _dispatchingEscalation = true);
    final result = await AiContentRepository.instance.dispatchEscalation(
      alertCode: alertCode,
      severity: severity,
      channels: const ['email', 'in_app'],
      dryRun: false,
    );
    if (!mounted) return;
    setState(() => _dispatchingEscalation = false);
    switch (result) {
      case ApiSuccess(:final data):
        final level = data['level']?.toString() ?? 'n/a';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _txt(
                'تم التصعيد بنجاح - مستوى $level',
                'Escalation dispatched - level $level',
              ),
            ),
            backgroundColor: AppColors.success,
          ),
        );
        _loadAuditTrail();
        _loadEscalationState();
        _loadQueueHealthMonitor();
      case ApiFailure(:final message):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: AppColors.error),
        );
    }
  }

  Future<void> _applyRemediation(String actionId) async {
    if (_applyingRemediation) return;
    setState(() => _applyingRemediation = true);
    final result = await AiContentRepository.instance.applyRemediation(
      actionId: actionId,
      dryRun: false,
    );
    if (!mounted) return;
    setState(() => _applyingRemediation = false);
    switch (result) {
      case ApiSuccess():
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_txt('تم تطبيق المعالجة', 'Remediation applied')),
            backgroundColor: AppColors.success,
          ),
        );
        _loadUsage();
        _loadObservability();
        _loadPlaybooks();
        _loadSlo();
        _loadCostAnomalies();
        _loadAuditTrail();
        _loadEscalationState();
        _loadQueueHealthMonitor();
      case ApiFailure(:final message):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: AppColors.error),
        );
    }
  }

  Future<void> _runAutoRemediation() async {
    if (_applyingRemediation) return;
    setState(() => _applyingRemediation = true);
    final result = await AiContentRepository.instance.autoRemediate(
      days: 14,
      dryRun: false,
    );
    if (!mounted) return;
    setState(() => _applyingRemediation = false);
    switch (result) {
      case ApiSuccess(:final data):
        final actions = (data['actions'] as List<dynamic>? ?? const [])
            .map((e) => e.toString())
            .join(', ');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              actions.isEmpty
                  ? _txt(
                      'لا توجد إجراءات مطلوبة',
                      'No remediation actions needed',
                    )
                  : _txt('تم تنفيذ: $actions', 'Executed: $actions'),
            ),
            backgroundColor: AppColors.info,
          ),
        );
        _loadUsage();
        _loadObservability();
        _loadPlaybooks();
        _loadSlo();
        _loadCostAnomalies();
        _loadAuditTrail();
        _loadQueueHealthMonitor();
      case ApiFailure(:final message):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: AppColors.error),
        );
    }
  }

  Future<void> _createPromptVersion() async {
    if (_savingPrompt) return;
    final label = _promptVersionLabelCtrl.text.trim();
    final prompt = _promptTextCtrl.text.trim();
    if (label.isEmpty || prompt.isEmpty) {
      return;
    }
    setState(() => _savingPrompt = true);
    final result = await AiContentRepository.instance.createPromptVersion(
      featureKey: _promptFeature,
      versionLabel: label,
      systemPrompt: prompt,
      activate: true,
    );
    if (!mounted) return;
    setState(() => _savingPrompt = false);
    switch (result) {
      case ApiSuccess():
        _promptVersionLabelCtrl.clear();
        _promptTextCtrl.clear();
        _loadPromptVersions();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_txt('تم حفظ نسخة Prompt', 'Prompt version saved')),
            backgroundColor: AppColors.success,
          ),
        );
      case ApiFailure(:final message):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: AppColors.error),
        );
    }
  }

  Future<void> _activatePromptVersion(String id) async {
    final result = await AiContentRepository.instance.activatePromptVersion(id);
    if (!mounted) return;
    switch (result) {
      case ApiSuccess():
        _loadPromptVersions();
      case ApiFailure(:final message):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: AppColors.error),
        );
    }
  }

  Future<void> _generateJobDescription() async {
    if (_jobTitleCtrl.text.trim().isEmpty || _busyJob) return;
    setState(() => _busyJob = true);

    final result = await AiContentRepository.instance.generateJobDescription(
      jobTitle: _jobTitleCtrl.text.trim(),
      languageCode: Localizations.localeOf(context).languageCode,
      department: _jobDeptCtrl.text.trim(),
      location: _jobLocationCtrl.text.trim(),
      employmentType: _jobTypeCtrl.text.trim(),
      requirements: _jobRequirementsCtrl.text.trim(),
      responsibilities: _jobResponsibilitiesCtrl.text.trim(),
      tone: _jobTone,
    );

    if (!mounted) return;
    setState(() => _busyJob = false);

    switch (result) {
      case ApiSuccess(:final data):
        setState(() {
          _jobOutput = data.content;
          _meta = '${data.provider ?? '-'} • ${data.model ?? '-'}';
        });
        _loadUsage();
        _loadObservability();
        _loadCanary();
        _loadPlaybooks();
        _loadSlo();
        _loadCostAnomalies();
      case ApiFailure(:final message):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: AppColors.error),
        );
    }
  }

  Future<void> _generateCommunication() async {
    if (_commPurposeCtrl.text.trim().isEmpty || _busyComm) return;
    setState(() => _busyComm = true);

    final result = await AiContentRepository.instance.generateCommunication(
      type: _commType,
      purpose: _commPurposeCtrl.text.trim(),
      languageCode: Localizations.localeOf(context).languageCode,
      recipientName: _commRecipientCtrl.text.trim(),
      employeeName: _commEmployeeCtrl.text.trim(),
      department: _commDeptCtrl.text.trim(),
      keyPoints: _commPointsCtrl.text.trim(),
      tone: _commTone,
    );

    if (!mounted) return;
    setState(() => _busyComm = false);

    switch (result) {
      case ApiSuccess(:final data):
        setState(() {
          _commOutput = data.content;
          _meta = '${data.provider ?? '-'} • ${data.model ?? '-'}';
        });
        _loadUsage();
        _loadObservability();
        _loadCanary();
        _loadPlaybooks();
        _loadSlo();
        _loadCostAnomalies();
      case ApiFailure(:final message):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: AppColors.error),
        );
    }
  }

  Future<void> _copyText(String value) async {
    if (value.trim().isEmpty) return;
    await Clipboard.setData(ClipboardData(text: value));
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(_txt('تم نسخ النص', 'Text copied'))));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppStrings.of(context);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _txt('مركز أوامر الذكاء الاصطناعي', 'AI Command Center'),
            style: AppTypography.h1,
          ),
          const SizedBox(height: 8),
          Text(
            _txt(
              'توليد ذكي للوصف الوظيفي ورسائل الموارد البشرية',
              'Smart generation for job descriptions and HR communications',
            ),
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          if (_meta != null) ...[
            const SizedBox(height: 10),
            Chip(
              avatar: const Icon(Icons.memory_outlined, size: 16),
              label: Text(_meta!),
            ),
          ],
          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _txt('الحوكمة والاستهلاك', 'Governance & Usage'),
                          style: AppTypography.h4,
                        ),
                      ),
                      IconButton(
                        onPressed: _loadingUsage ? null : _loadUsage,
                        icon: const Icon(Icons.refresh),
                        tooltip: _txt('تحديث', 'Refresh'),
                      ),
                    ],
                  ),
                  if (_loadingUsage)
                    const Padding(
                      padding: EdgeInsets.all(12),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (_usage != null) ...[
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _UsageBadge(
                          label: _txt('الحد الشهري', 'Monthly quota'),
                          value:
                              '${_usage!.monthlyTokensUsed}/${_usage!.monthlyTokenLimit}',
                        ),
                        _UsageBadge(
                          label: _txt('الاستخدام', 'Usage'),
                          value:
                              '${_usage!.monthlyUsagePercent.toStringAsFixed(1)}%',
                        ),
                        _UsageBadge(
                          label: _txt('طلبات اليوم', 'Requests today'),
                          value: '${_usage!.requestsToday}',
                        ),
                        _UsageBadge(
                          label: _txt('أخطاء اليوم', 'Errors today'),
                          value: '${_usage!.errorsToday}',
                        ),
                        _UsageBadge(
                          label: _txt('حد الدقيقة', 'RPM limit'),
                          value: '${_usage!.requestsPerMinuteLimit}',
                        ),
                        _UsageBadge(
                          label: _txt('تكلفة اليوم', 'Today cost'),
                          value:
                              '\$${_usage!.estimatedCostTodayUsd.toStringAsFixed(3)}',
                        ),
                        _UsageBadge(
                          label: _txt('تكلفة الشهر', 'Month cost'),
                          value:
                              '\$${_usage!.estimatedCostMonthUsd.toStringAsFixed(3)}',
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (_usage!.featureFlags.isNotEmpty)
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: _usage!.featureFlags.entries.map((e) {
                          final active = e.value;
                          return Chip(
                            avatar: Icon(
                              active
                                  ? Icons.check_circle_outline
                                  : Icons.block_outlined,
                              size: 14,
                              color: active
                                  ? AppColors.success
                                  : AppColors.error,
                            ),
                            label: Text(e.key),
                          );
                        }).toList(),
                      ),
                    if (_usage!.byEndpoint.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        _txt('استهلاك حسب المسار', 'Usage by endpoint'),
                        style: AppTypography.label,
                      ),
                      const SizedBox(height: 6),
                      ..._usage!.byEndpoint.take(4).map((row) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            '${row.endpoint}: ${row.requests} req • ${row.tokens} tok',
                            style: AppTypography.caption,
                          ),
                        );
                      }),
                    ],
                    if (_usage!.costByProvider.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        _txt('تكلفة حسب المزود', 'Cost by provider'),
                        style: AppTypography.label,
                      ),
                      const SizedBox(height: 6),
                      ..._usage!.costByProvider.entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            '${entry.key}: \$${entry.value.toStringAsFixed(4)}',
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
          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _txt(
                            'Queue Self-Monitor Alerts',
                            'Queue Self-Monitor Alerts',
                          ),
                          style: AppTypography.h4,
                        ),
                      ),
                      IconButton(
                        onPressed: _loadingQueueMonitor
                            ? null
                            : () => _loadQueueHealthMonitor(),
                        icon: const Icon(Icons.refresh),
                      ),
                    ],
                  ),
                  Text(
                    _txt(
                      'تحديث تلقائي كل 60 ثانية',
                      'Auto-refresh every 60 seconds',
                    ),
                    style: AppTypography.caption.copyWith(
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                  if (_loadingQueueMonitor)
                    const Padding(
                      padding: EdgeInsets.all(12),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (_queueHealthMonitor != null) ...[
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SegmentedButton<int>(
                        showSelectedIcon: false,
                        segments: [
                          ButtonSegment(
                            value: 60,
                            label: Text(_txt('1h', '1h')),
                          ),
                          ButtonSegment(
                            value: 360,
                            label: Text(_txt('6h', '6h')),
                          ),
                          ButtonSegment(
                            value: 1440,
                            label: Text(_txt('24h', '24h')),
                          ),
                        ],
                        selected: {_queueMonitorWindowMinutes},
                        onSelectionChanged: (selection) {
                          if (selection.isEmpty) return;
                          _loadQueueHealthMonitor(windowMinutes: selection.first);
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _UsageBadge(
                          label: _txt('Alerts', 'Alerts'),
                          value:
                              '${(_queueHealthMonitor!['totals'] as Map<String, dynamic>? ?? const {})['alerts'] ?? 0}',
                        ),
                        _UsageBadge(
                          label: _txt('Critical', 'Critical'),
                          value:
                              '${(_queueHealthMonitor!['totals'] as Map<String, dynamic>? ?? const {})['critical'] ?? 0}',
                        ),
                        _UsageBadge(
                          label: _txt('Warning', 'Warning'),
                          value:
                              '${(_queueHealthMonitor!['totals'] as Map<String, dynamic>? ?? const {})['warning'] ?? 0}',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        FilterChip(
                          selected: _queueMonitorSeverity == 'all',
                          label: Text(_txt('All', 'All')),
                          onSelected: (_) {
                            setState(() => _queueMonitorSeverity = 'all');
                          },
                        ),
                        FilterChip(
                          selected: _queueMonitorSeverity == 'warning',
                          label: Text(_txt('Warning', 'Warning')),
                          onSelected: (_) {
                            setState(() => _queueMonitorSeverity = 'warning');
                          },
                        ),
                        FilterChip(
                          selected: _queueMonitorSeverity == 'critical',
                          label: Text(_txt('Critical', 'Critical')),
                          onSelected: (_) {
                            setState(() => _queueMonitorSeverity = 'critical');
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ..._filteredQueueMonitorEvents()
                        .take(4)
                        .map((row) {
                          final m = row;
                          final runbookUrl =
                              m['runbook_url']?.toString() ?? '';
                          return ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              '${m['alert_code'] ?? 'queue_failures_runtime'} • ${m['severity'] ?? 'warning'} • failures=${m['failed_total'] ?? 0}',
                            ),
                            subtitle: Text(
                              'threshold=${m['threshold'] ?? 0} • queued=${m['queued_notifications'] ?? 0} • ${m['event_at'] ?? '-'}',
                            ),
                            trailing: runbookUrl.trim().isEmpty
                                ? null
                                : OutlinedButton(
                                    onPressed: () => _copyText(runbookUrl),
                                    child: Text(
                                      _txt('Runbook', 'Runbook'),
                                    ),
                                  ),
                          );
                        }),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _txt(
                            'Silence Windows, Runbooks & Digests',
                            'Silence Windows, Runbooks & Digests',
                          ),
                          style: AppTypography.h4,
                        ),
                      ),
                      IconButton(
                        onPressed:
                            _loadingEscalationState ? null : _loadEscalationState,
                        icon: const Icon(Icons.refresh),
                      ),
                    ],
                  ),
                  if (_loadingEscalationState)
                    const Padding(
                      padding: EdgeInsets.all(12),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else ...[
                    if (_escalationRunbooks != null) ...[
                      Text(
                        _txt(
                          'Digest: ${((_escalationRunbooks!['digest'] as Map<String, dynamic>? ?? const {})['enabled'] == true) ? 'Enabled' : 'Disabled'} • ${(_escalationRunbooks!['digest'] as Map<String, dynamic>? ?? const {})['window_minutes'] ?? '-'} min',
                          'Digest: ${((_escalationRunbooks!['digest'] as Map<String, dynamic>? ?? const {})['enabled'] == true) ? 'Enabled' : 'Disabled'} • ${(_escalationRunbooks!['digest'] as Map<String, dynamic>? ?? const {})['window_minutes'] ?? '-'} min',
                        ),
                        style: AppTypography.caption,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _txt(
                          'Silence windows: ${(_escalationRunbooks!['silence_windows'] as List<dynamic>? ?? const []).length}',
                          'Silence windows: ${(_escalationRunbooks!['silence_windows'] as List<dynamic>? ?? const []).length}',
                        ),
                        style: AppTypography.caption,
                      ),
                    ],
                    const SizedBox(height: 8),
                    if (_escalationNotifications != null) ...[
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _UsageBadge(
                            label: _txt('Sent', 'Sent'),
                            value:
                                '${(_escalationNotifications!['status_counts'] as Map<String, dynamic>? ?? const {})['sent'] ?? 0}',
                          ),
                          _UsageBadge(
                            label: _txt('Failed', 'Failed'),
                            value:
                                '${(_escalationNotifications!['status_counts'] as Map<String, dynamic>? ?? const {})['failed'] ?? 0}',
                          ),
                          _UsageBadge(
                            label: _txt('Suppressed', 'Suppressed'),
                            value:
                                '${(_escalationNotifications!['status_counts'] as Map<String, dynamic>? ?? const {})['suppressed'] ?? 0}',
                          ),
                          _UsageBadge(
                            label: _txt('Queued', 'Queued'),
                            value:
                                '${(_escalationNotifications!['status_counts'] as Map<String, dynamic>? ?? const {})['queued'] ?? 0}',
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 10),
                    FilledButton.icon(
                      onPressed: _runningDigest ? null : _runDigest,
                      icon: _runningDigest
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.summarize_outlined),
                      label: Text(_txt('تشغيل Digest الآن', 'Run digest now')),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _txt(
                            'SLO Burn-Rate & Escalation',
                            'SLO Burn-Rate & Escalation',
                          ),
                          style: AppTypography.h4,
                        ),
                      ),
                      IconButton(
                        onPressed: _loadingSlo ? null : _loadSlo,
                        icon: const Icon(Icons.refresh),
                      ),
                    ],
                  ),
                  if (_loadingSlo)
                    const Padding(
                      padding: EdgeInsets.all(12),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (_slo != null) ...[
                    _UsageBadge(
                      label: _txt('SLO target', 'SLO target'),
                      value:
                          '${((_slo!['slo_target_success_rate'] as num?)?.toDouble() ?? 0).toStringAsFixed(2)}%',
                    ),
                    const SizedBox(height: 6),
                    _UsageBadge(
                      label: _txt('Burn threshold', 'Burn threshold'),
                      value:
                          '${((_slo!['burn_rate_threshold'] as num?)?.toDouble() ?? 0).toStringAsFixed(2)}x',
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _txt('نوافذ القياس', 'Measurement windows'),
                      style: AppTypography.label,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '1h burn: ${(((_slo!['windows'] as Map<String, dynamic>?)?['last_1h'] as Map<String, dynamic>?)?['burn_rate'] ?? 0).toString()}',
                      style: AppTypography.caption,
                    ),
                    Text(
                      '24h burn: ${(((_slo!['windows'] as Map<String, dynamic>?)?['last_24h'] as Map<String, dynamic>?)?['burn_rate'] ?? 0).toString()}',
                      style: AppTypography.caption,
                    ),
                    const SizedBox(height: 8),
                    if (((_slo!['alerts'] as List<dynamic>? ?? const []).isNotEmpty))
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children:
                            (_slo!['alerts'] as List<dynamic>? ?? const []).map((
                              item,
                            ) {
                              final m = item as Map<String, dynamic>;
                              final code = m['code']?.toString() ?? 'alert';
                              final severity =
                                  m['level']?.toString() ?? 'warning';
                              return OutlinedButton(
                                onPressed: _dispatchingEscalation
                                    ? null
                                    : () => _dispatchEscalation(
                                        alertCode: code,
                                        severity: severity,
                                      ),
                                child: Text(
                                  _txt('تصعيد $code', 'Escalate $code'),
                                ),
                              );
                            }).toList(),
                      ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _txt(
                            'Cost Anomaly Detection',
                            'Cost Anomaly Detection',
                          ),
                          style: AppTypography.h4,
                        ),
                      ),
                      IconButton(
                        onPressed: _loadingCostAnomalies
                            ? null
                            : _loadCostAnomalies,
                        icon: const Icon(Icons.refresh),
                      ),
                    ],
                  ),
                  if (_loadingCostAnomalies)
                    const Padding(
                      padding: EdgeInsets.all(12),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (_costAnomalies != null) ...[
                    Text(
                      _txt(
                        'Daily anomaly: ${((_costAnomalies!['daily'] as Map<String, dynamic>?)?['is_anomaly'] == true) ? 'Yes' : 'No'}',
                        'Daily anomaly: ${((_costAnomalies!['daily'] as Map<String, dynamic>?)?['is_anomaly'] == true) ? 'Yes' : 'No'}',
                      ),
                      style: AppTypography.caption,
                    ),
                    Text(
                      _txt(
                        'Weekly anomaly: ${((_costAnomalies!['weekly'] as Map<String, dynamic>?)?['is_anomaly'] == true) ? 'Yes' : 'No'}',
                        'Weekly anomaly: ${((_costAnomalies!['weekly'] as Map<String, dynamic>?)?['is_anomaly'] == true) ? 'Yes' : 'No'}',
                      ),
                      style: AppTypography.caption,
                    ),
                    const SizedBox(height: 6),
                    ...(_costAnomalies!['recommendations'] as List<dynamic>? ??
                            const [])
                        .take(3)
                        .map(
                          (r) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text('• ${r.toString()}'),
                          ),
                        ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _txt(
                            'Model Canary Analysis',
                            'Model Canary Analysis',
                          ),
                          style: AppTypography.h4,
                        ),
                      ),
                      IconButton(
                        onPressed: _loadingCanary ? null : _loadCanary,
                        icon: const Icon(Icons.refresh),
                      ),
                    ],
                  ),
                  if (_loadingCanary)
                    const Padding(
                      padding: EdgeInsets.all(12),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (_canary != null) ...[
                    if (_canary!.recommended != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          _txt(
                            'الموصى: ${_canary!.recommended!.provider}/${_canary!.recommended!.model}',
                            'Recommended: ${_canary!.recommended!.provider}/${_canary!.recommended!.model}',
                          ),
                          style: AppTypography.label,
                        ),
                      ),
                    ..._canary!.variants.take(4).map((v) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          '${v.provider}/${v.model}: ${v.successRatePercent.toStringAsFixed(1)}% • ${v.avgLatencyMs}ms • \$${v.avgCostUsd.toStringAsFixed(6)}',
                          style: AppTypography.caption,
                        ),
                      );
                    }),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _txt(
                            'Incident Playbooks & Auto-Remediation',
                            'Incident Playbooks & Auto-Remediation',
                          ),
                          style: AppTypography.h4,
                        ),
                      ),
                      IconButton(
                        onPressed: _loadingPlaybooks ? null : _loadPlaybooks,
                        icon: const Icon(Icons.refresh),
                      ),
                    ],
                  ),
                  if (_loadingPlaybooks)
                    const Padding(
                      padding: EdgeInsets.all(12),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (_playbooks != null) ...[
                    if (_playbooks!.alerts.isNotEmpty)
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: _playbooks!.alerts.map((a) {
                          return Chip(
                            label: Text(
                              '${a.code} (${a.value.toStringAsFixed(2)})',
                            ),
                          );
                        }).toList(),
                      ),
                    const SizedBox(height: 8),
                    ..._playbooks!.playbooks.map((p) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.title, style: AppTypography.label),
                            if (p.runbookUrl != null &&
                                p.runbookUrl!.trim().isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  'Runbook: ${p.runbookUrl}',
                                  style: AppTypography.caption,
                                ),
                              ),
                            const SizedBox(height: 4),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: p.actions.map((a) {
                                return OutlinedButton(
                                  onPressed: _applyingRemediation
                                      ? null
                                      : () => _applyRemediation(a),
                                  child: Text(a),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      );
                    }),
                    FilledButton.icon(
                      onPressed: _applyingRemediation
                          ? null
                          : _runAutoRemediation,
                      icon: _applyingRemediation
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.bolt_outlined),
                      label: Text(
                        _txt('تشغيل Auto-Remediation', 'Run Auto-Remediation'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _txt(
                            'المراقبة التشغيلية',
                            'Operational Observability',
                          ),
                          style: AppTypography.h4,
                        ),
                      ),
                      IconButton(
                        onPressed: _loadingObservability
                            ? null
                            : _loadObservability,
                        icon: const Icon(Icons.refresh),
                        tooltip: _txt('تحديث', 'Refresh'),
                      ),
                    ],
                  ),
                  if (_loadingObservability)
                    const Padding(
                      padding: EdgeInsets.all(12),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (_observability != null) ...[
                    Text(
                      _txt(
                        'آخر ${_observability!.rangeDays} يوم',
                        'Last ${_observability!.rangeDays} days',
                      ),
                      style: AppTypography.caption,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _UsageBadge(
                          label: _txt('Queue completed', 'Queue completed'),
                          value: '${_observability!.queue.completed}',
                        ),
                        _UsageBadge(
                          label: _txt('Queue failed', 'Queue failed'),
                          value: '${_observability!.queue.failed}',
                        ),
                        _UsageBadge(
                          label: _txt('Queue avg ms', 'Queue avg ms'),
                          value: '${_observability!.queue.avgDurationMs}',
                        ),
                      ],
                    ),
                    if (_observability!.latencyByEndpoint.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        _txt('Latency by endpoint', 'Latency by endpoint'),
                        style: AppTypography.label,
                      ),
                      const SizedBox(height: 4),
                      ..._observability!.latencyByEndpoint.take(4).map((p) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 3),
                          child: Text(
                            '${p.endpoint}: p95=${p.p95LatencyMs}ms • avg=${p.avgLatencyMs}ms',
                            style: AppTypography.caption,
                          ),
                        );
                      }),
                    ],
                    if (_observability!.blocked.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        _txt('Blocked requests', 'Blocked requests'),
                        style: AppTypography.label,
                      ),
                      const SizedBox(height: 4),
                      ..._observability!.blocked.entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 3),
                          child: Text(
                            '${entry.key}: ${entry.value}',
                            style: AppTypography.caption,
                          ),
                        );
                      }),
                    ],
                    if (_observability!.alerts.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        _txt('Active alerts', 'Active alerts'),
                        style: AppTypography.label,
                      ),
                      const SizedBox(height: 4),
                      ..._observability!.alerts.map((alert) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 3),
                          child: Text(
                            '${alert.code}: ${alert.value.toStringAsFixed(2)} > ${alert.threshold.toStringAsFixed(2)}',
                            style: AppTypography.caption.copyWith(
                              color: alert.level == 'critical'
                                  ? AppColors.error
                                  : AppColors.warning,
                            ),
                          ),
                        );
                      }),
                    ],
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _txt(
                            'Prompt Registry & Rollback',
                            'Prompt Registry & Rollback',
                          ),
                          style: AppTypography.h4,
                        ),
                      ),
                      IconButton(
                        onPressed: _loadingPrompts ? null : _loadPromptVersions,
                        icon: const Icon(Icons.refresh),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _promptFeature,
                          decoration: InputDecoration(
                            labelText: _txt('الميزة', 'Feature'),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'assistant_chat',
                              child: Text('assistant_chat'),
                            ),
                            DropdownMenuItem(
                              value: 'job_description',
                              child: Text('job_description'),
                            ),
                            DropdownMenuItem(
                              value: 'communication',
                              child: Text('communication'),
                            ),
                          ],
                          onChanged: (v) {
                            setState(
                              () => _promptFeature = v ?? 'assistant_chat',
                            );
                            _loadPromptVersions();
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _promptVersionLabelCtrl,
                    decoration: InputDecoration(
                      labelText: _txt('اسم النسخة', 'Version label'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _promptTextCtrl,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: _txt('System Prompt', 'System Prompt'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    onPressed: _savingPrompt ? null : _createPromptVersion,
                    icon: _savingPrompt
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.save_outlined),
                    label: Text(_txt('إنشاء وتفعيل', 'Create & activate')),
                  ),
                  const SizedBox(height: 8),
                  if (_loadingPrompts)
                    const Padding(
                      padding: EdgeInsets.all(8),
                      child: CircularProgressIndicator(),
                    )
                  else if (_promptVersions.isNotEmpty)
                    ..._promptVersions.take(6).map((item) {
                      return ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          '${item.versionLabel} (${item.featureKey})',
                        ),
                        subtitle: Text(
                          item.systemPrompt,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: item.isActive
                            ? Chip(label: Text(_txt('نشطة', 'Active')))
                            : OutlinedButton(
                                onPressed: () =>
                                    _activatePromptVersion(item.id),
                                child: Text(_txt('تفعيل', 'Activate')),
                              ),
                      );
                    }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _txt(
                            'AI Governance Audit Timeline',
                            'AI Governance Audit Timeline',
                          ),
                          style: AppTypography.h4,
                        ),
                      ),
                      IconButton(
                        onPressed: _loadingAudit ? null : _loadAuditTrail,
                        icon: const Icon(Icons.refresh),
                      ),
                    ],
                  ),
                  if (_loadingAudit)
                    const Padding(
                      padding: EdgeInsets.all(12),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (_audit != null) ...[
                    Text(
                      _txt(
                        'الإجمالي: ${_audit!['total'] ?? 0}',
                        'Total: ${_audit!['total'] ?? 0}',
                      ),
                      style: AppTypography.caption,
                    ),
                    const SizedBox(height: 6),
                    ...(_audit!['timeline'] as List<dynamic>? ?? const [])
                        .take(6)
                        .map((row) {
                          final m = row as Map<String, dynamic>;
                          final event = m['event_type']?.toString() ?? '-';
                          final severity = m['severity']?.toString() ?? 'info';
                          final diff = m['diff'] as List<dynamic>? ?? const [];
                          return ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            title: Text('$event ($severity)'),
                            subtitle: Text(
                              diff.isEmpty
                                  ? _txt('لا يوجد تغييرات', 'No config diff')
                                  : diff
                                        .take(2)
                                        .map(
                                          (d) =>
                                              (d as Map<String, dynamic>)['field']
                                                  ?.toString() ??
                                              '',
                                        )
                                        .where((e) => e.isNotEmpty)
                                        .join(' • '),
                            ),
                          );
                        }),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth > 1100;
              final job = _JobDescriptionCard(
                txt: _txt,
                l10n: l10n,
                busy: _busyJob,
                titleCtrl: _jobTitleCtrl,
                deptCtrl: _jobDeptCtrl,
                locationCtrl: _jobLocationCtrl,
                typeCtrl: _jobTypeCtrl,
                requirementsCtrl: _jobRequirementsCtrl,
                responsibilitiesCtrl: _jobResponsibilitiesCtrl,
                tone: _jobTone,
                onToneChanged: (v) => setState(() => _jobTone = v),
                output: _jobOutput,
                onGenerate: _generateJobDescription,
                onCopy: () => _copyText(_jobOutput),
              );
              final comm = _CommunicationCard(
                txt: _txt,
                l10n: l10n,
                busy: _busyComm,
                purposeCtrl: _commPurposeCtrl,
                recipientCtrl: _commRecipientCtrl,
                employeeCtrl: _commEmployeeCtrl,
                deptCtrl: _commDeptCtrl,
                pointsCtrl: _commPointsCtrl,
                type: _commType,
                tone: _commTone,
                onTypeChanged: (v) => setState(() => _commType = v),
                onToneChanged: (v) => setState(() => _commTone = v),
                output: _commOutput,
                onGenerate: _generateCommunication,
                onCopy: () => _copyText(_commOutput),
              );

              if (wide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: job),
                    const SizedBox(width: 16),
                    Expanded(child: comm),
                  ],
                );
              }
              return Column(children: [job, const SizedBox(height: 16), comm]);
            },
          ),
        ],
      ),
    );
  }
}

class _JobDescriptionCard extends StatelessWidget {
  const _JobDescriptionCard({
    required this.txt,
    required this.l10n,
    required this.busy,
    required this.titleCtrl,
    required this.deptCtrl,
    required this.locationCtrl,
    required this.typeCtrl,
    required this.requirementsCtrl,
    required this.responsibilitiesCtrl,
    required this.tone,
    required this.onToneChanged,
    required this.output,
    required this.onGenerate,
    required this.onCopy,
  });

  final String Function(String ar, String en) txt;
  final AppStrings l10n;
  final bool busy;
  final TextEditingController titleCtrl;
  final TextEditingController deptCtrl;
  final TextEditingController locationCtrl;
  final TextEditingController typeCtrl;
  final TextEditingController requirementsCtrl;
  final TextEditingController responsibilitiesCtrl;
  final String tone;
  final ValueChanged<String> onToneChanged;
  final String output;
  final VoidCallback onGenerate;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.badge_outlined),
                const SizedBox(width: 8),
                Text(
                  txt('مولد الوصف الوظيفي', 'AI Job Description Generator'),
                  style: AppTypography.h4,
                ),
              ],
            ),
            const SizedBox(height: 14),
            TextField(
              controller: titleCtrl,
              decoration: InputDecoration(labelText: l10n.jobTitleField),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: deptCtrl,
              decoration: InputDecoration(labelText: l10n.department),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: locationCtrl,
                    decoration: InputDecoration(
                      labelText: l10n.jobLocationField,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: typeCtrl,
                    decoration: InputDecoration(
                      labelText: txt('نوع التوظيف', 'Employment type'),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              initialValue: tone,
              decoration: InputDecoration(labelText: txt('النبرة', 'Tone')),
              items: const [
                DropdownMenuItem(
                  value: 'professional',
                  child: Text('Professional'),
                ),
                DropdownMenuItem(value: 'concise', child: Text('Concise')),
                DropdownMenuItem(value: 'friendly', child: Text('Friendly')),
                DropdownMenuItem(value: 'formal', child: Text('Formal')),
              ],
              onChanged: (v) => onToneChanged(v ?? 'professional'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: requirementsCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: txt('المتطلبات', 'Requirements'),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: responsibilitiesCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: txt('المهام والمسؤوليات', 'Responsibilities'),
              ),
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: busy ? null : onGenerate,
              icon: busy
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.auto_awesome_outlined),
              label: Text(txt('توليد الوصف', 'Generate description')),
            ),
            const SizedBox(height: 12),
            _OutputBox(
              title: txt('الناتج', 'Output'),
              value: output,
              placeholder: txt(
                'سيظهر الوصف الوظيفي هنا',
                'Generated job description appears here',
              ),
              onCopy: onCopy,
            ),
          ],
        ),
      ),
    );
  }
}

class _CommunicationCard extends StatelessWidget {
  const _CommunicationCard({
    required this.txt,
    required this.l10n,
    required this.busy,
    required this.purposeCtrl,
    required this.recipientCtrl,
    required this.employeeCtrl,
    required this.deptCtrl,
    required this.pointsCtrl,
    required this.type,
    required this.tone,
    required this.onTypeChanged,
    required this.onToneChanged,
    required this.output,
    required this.onGenerate,
    required this.onCopy,
  });

  final String Function(String ar, String en) txt;
  final AppStrings l10n;
  final bool busy;
  final TextEditingController purposeCtrl;
  final TextEditingController recipientCtrl;
  final TextEditingController employeeCtrl;
  final TextEditingController deptCtrl;
  final TextEditingController pointsCtrl;
  final String type;
  final String tone;
  final ValueChanged<String> onTypeChanged;
  final ValueChanged<String> onToneChanged;
  final String output;
  final VoidCallback onGenerate;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.mail_outline),
                const SizedBox(width: 8),
                Text(
                  txt('مولد البريد والخطابات', 'AI Email & Letter Generator'),
                  style: AppTypography.h4,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: type,
                    decoration: InputDecoration(
                      labelText: txt('نوع المستند', 'Type'),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: 'email',
                        child: Text(txt('بريد إلكتروني', 'Email')),
                      ),
                      DropdownMenuItem(
                        value: 'letter',
                        child: Text(txt('خطاب', 'Letter')),
                      ),
                    ],
                    onChanged: (v) => onTypeChanged(v ?? 'email'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: tone,
                    decoration: InputDecoration(
                      labelText: txt('النبرة', 'Tone'),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'professional',
                        child: Text('Professional'),
                      ),
                      DropdownMenuItem(
                        value: 'friendly',
                        child: Text('Friendly'),
                      ),
                      DropdownMenuItem(value: 'formal', child: Text('Formal')),
                      DropdownMenuItem(value: 'strict', child: Text('Strict')),
                    ],
                    onChanged: (v) => onToneChanged(v ?? 'professional'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: purposeCtrl,
              decoration: InputDecoration(
                labelText: txt('الغرض', 'Purpose'),
                hintText: txt(
                  'مثال: إشعار تحديث سياسة الحضور',
                  'Ex: Notify attendance policy update',
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: recipientCtrl,
              decoration: InputDecoration(
                labelText: txt('اسم المستلم', 'Recipient name'),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: employeeCtrl,
                    decoration: InputDecoration(
                      labelText: txt('اسم الموظف', 'Employee name'),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: deptCtrl,
                    decoration: InputDecoration(labelText: l10n.department),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: pointsCtrl,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: txt('نقاط أساسية', 'Key points'),
              ),
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: busy ? null : onGenerate,
              icon: busy
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.auto_fix_high_outlined),
              label: Text(txt('توليد الرسالة', 'Generate message')),
            ),
            const SizedBox(height: 12),
            _OutputBox(
              title: txt('الناتج', 'Output'),
              value: output,
              placeholder: txt(
                'سيظهر النص المولد هنا',
                'Generated communication appears here',
              ),
              onCopy: onCopy,
            ),
          ],
        ),
      ),
    );
  }
}

class _OutputBox extends StatelessWidget {
  const _OutputBox({
    required this.title,
    required this.value,
    required this.placeholder,
    required this.onCopy,
  });

  final String title;
  final String value;
  final String placeholder;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    final hasData = value.trim().isNotEmpty;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Text(title, style: AppTypography.label),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.copy_all_outlined, size: 18),
                  onPressed: hasData ? onCopy : null,
                  tooltip: 'Copy',
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(12),
            child: SelectableText(
              hasData ? value : placeholder,
              style: AppTypography.bodySmall.copyWith(
                color: hasData ? null : AppColors.textSecondary,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UsageBadge extends StatelessWidget {
  const _UsageBadge({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: AppTypography.label),
          const SizedBox(width: 6),
          Text(label, style: AppTypography.caption),
        ],
      ),
    );
  }
}
