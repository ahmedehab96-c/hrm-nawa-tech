import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_config.dart';
import '../../../core/api/api_result.dart';
import '../../../core/auth/auth_session.dart';
import '../../../core/locale/locale_controller.dart';
import '../../../core/repositories/settings_repository.dart';
import '../../../core/saas/subscription_controller.dart';
import '../../../core/saas/company_context.dart';
import '../../../core/services/wifi_attendance_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_scope.dart';
import '../../../l10n/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _companyController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _wifiSsidController;
  late final TextEditingController _apiBaseUrlController;
  late final TextEditingController _aiRpmController;
  late final TextEditingController _aiMonthlyTokensController;
  late final TextEditingController _aiRolloutController;
  late final TextEditingController _aiErrorRateThresholdController;
  late final TextEditingController _aiP95LatencyThresholdController;
  late final TextEditingController _aiQueueFailureThresholdController;
  late final TextEditingController _aiSloTargetController;
  late final TextEditingController _aiBurnRateController;
  late final TextEditingController _aiCostAnomalyController;
  late final TextEditingController _aiAlertChannelsController;
  late final TextEditingController _aiEscalationMatrixController;
  late final TextEditingController _aiAlertEmailFromController;
  late final TextEditingController _aiSlackWebhookController;
  late final TextEditingController _aiSilenceWindowsController;
  late final TextEditingController _aiRunbookLinksController;
  late final TextEditingController _aiDigestWindowController;
  late final TextEditingController _aiModelController;
  bool _useApi = false;
  bool _savingCompany = false;
  bool _savingWifi = false;
  bool _savingAiGovernance = false;
  bool _loadingSettings = false;
  bool _aiEnabled = true;
  bool _aiDigestEnabled = true;
  String _aiProvider = 'openai';
  String _aiPlan = 'enterprise';
  String _aiSafetyLevel = 'standard';
  final Map<String, bool> _aiFeatureFlags = {
    'assistant_chat': true,
    'job_description': true,
    'communication': true,
    'recruitment_parse': true,
    'recruitment_match': true,
    'attendance_insights': true,
    'attendance_alerts': true,
    'leave_recommendation': true,
    'performance_analyze': true,
    'reports_summary': true,
  };

  bool get _isArabic => Localizations.localeOf(context).languageCode == 'ar';
  String _txt(String ar, String en) => _isArabic ? ar : en;

  @override
  void initState() {
    super.initState();
    _companyController = TextEditingController(text: 'شركة النخبة — عرض Nawa Tech');
    _emailController = TextEditingController(text: 'info@company.com');
    _phoneController = TextEditingController(text: '+966 50 123 4567');
    _addressController = TextEditingController(
      text: 'الرياض، المملكة العربية السعودية',
    );
    _wifiSsidController = TextEditingController(
      text: WifiAttendanceService.companyWifiSsid,
    );
    _apiBaseUrlController = TextEditingController(
      text: ApiConfig.baseUrl ?? '',
    );
    _aiRpmController = TextEditingController(text: '60');
    _aiMonthlyTokensController = TextEditingController(text: '500000');
    _aiRolloutController = TextEditingController(text: '100');
    _aiErrorRateThresholdController = TextEditingController(text: '5');
    _aiP95LatencyThresholdController = TextEditingController(text: '2500');
    _aiQueueFailureThresholdController = TextEditingController(text: '3');
    _aiSloTargetController = TextEditingController(text: '99.5');
    _aiBurnRateController = TextEditingController(text: '2');
    _aiCostAnomalyController = TextEditingController(text: '2');
    _aiAlertChannelsController = TextEditingController(text: 'in_app,email');
    _aiAlertEmailFromController = TextEditingController(
      text: 'alerts@company.local',
    );
    _aiSlackWebhookController = TextEditingController();
    _aiSilenceWindowsController = TextEditingController(
      text:
          '[{"name":"night_window","days":[1,2,3,4,5],"start":"23:00","end":"06:00"}]',
    );
    _aiRunbookLinksController = TextEditingController(
      text:
          '{"high_error_rate":"https://runbooks.example.com/ai/high-error-rate","high_p95_latency":"https://runbooks.example.com/ai/high-latency","queue_failures":"https://runbooks.example.com/ai/queue-failures","default":"https://runbooks.example.com/ai/general"}',
    );
    _aiDigestWindowController = TextEditingController(text: '60');
    _aiEscalationMatrixController = TextEditingController(
      text:
          '{"l1":{"policy":"notify_in_5m","recipients":["hr-oncall@company.local"]},"l2":{"policy":"notify_now","recipients":["engineering-oncall@company.local"]},"l3":{"policy":"page_immediately","recipients":["cto@company.local"]}}',
    );
    _aiModelController = TextEditingController();
    _useApi = ApiConfig.useApi;
    _loadCompanySettings();
  }

  Future<void> _loadCompanySettings() async {
    setState(() => _loadingSettings = true);
    final result = await SettingsRepository.instance.getSettings();
    if (!mounted) return;
    setState(() => _loadingSettings = false);
    if (result is ApiSuccess<CompanySettings>) {
      final s = result.data;
      _companyController.text = s.name;
      _emailController.text = s.email ?? '';
      _phoneController.text = s.phone ?? '';
      _addressController.text = s.address ?? '';
      if (s.wifiSsid != null && s.wifiSsid!.isNotEmpty) {
        _wifiSsidController.text = s.wifiSsid!;
        WifiAttendanceService.setCompanyWifiSsid(s.wifiSsid!);
      }
      _aiEnabled = s.aiEnabled ?? true;
      _aiProvider = (s.aiProvider == 'gemini') ? 'gemini' : 'openai';
      _aiPlan = switch (s.aiPlan) {
        'starter' => 'starter',
        'growth' => 'growth',
        _ => 'enterprise',
      };
      _aiModelController.text = s.aiModel ?? '';
      _aiRpmController.text = '${s.aiRequestsPerMinute ?? 60}';
      _aiMonthlyTokensController.text = '${s.aiMonthlyTokenLimit ?? 500000}';
      _aiRolloutController.text = '${s.aiRolloutPercentage ?? 100}';
      _aiSafetyLevel = s.aiSafetyLevel == 'strict' ? 'strict' : 'standard';
      _aiErrorRateThresholdController.text =
          '${s.aiAlertErrorRateThreshold ?? 5}';
      _aiP95LatencyThresholdController.text =
          '${s.aiAlertP95LatencyMsThreshold ?? 2500}';
      _aiQueueFailureThresholdController.text =
          '${s.aiAlertQueueFailureThreshold ?? 3}';
      _aiSloTargetController.text = '${s.aiSloTargetSuccessRate ?? 99.5}';
      _aiBurnRateController.text = '${s.aiBurnRateAlertThreshold ?? 2}';
      _aiCostAnomalyController.text = '${s.aiCostAnomalyMultiplier ?? 2}';
      _aiAlertChannelsController.text = s.aiAlertChannels.join(',');
      _aiAlertEmailFromController.text = s.aiAlertEmailFrom ?? '';
      _aiSlackWebhookController.text = s.aiSlackWebhookUrl ?? '';
      _aiDigestEnabled = s.aiDigestEnabled ?? true;
      _aiDigestWindowController.text = '${s.aiDigestWindowMinutes ?? 60}';
      _aiSilenceWindowsController.text =
          s.aiSilenceWindows.isEmpty ? '[]' : jsonEncode(s.aiSilenceWindows);
      _aiRunbookLinksController.text =
          s.aiRunbookLinks.isEmpty ? '{}' : jsonEncode(s.aiRunbookLinks);
      _aiEscalationMatrixController.text =
          s.aiEscalationMatrix.isEmpty ? '{}' : jsonEncode(s.aiEscalationMatrix);
      if (s.aiFeatureFlags.isNotEmpty) {
        for (final key in _aiFeatureFlags.keys.toList()) {
          _aiFeatureFlags[key] = s.aiFeatureFlags[key] ?? _aiFeatureFlags[key]!;
        }
      }
    }
  }

  @override
  void dispose() {
    _companyController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _wifiSsidController.dispose();
    _apiBaseUrlController.dispose();
    _aiRpmController.dispose();
    _aiMonthlyTokensController.dispose();
    _aiRolloutController.dispose();
    _aiErrorRateThresholdController.dispose();
    _aiP95LatencyThresholdController.dispose();
    _aiQueueFailureThresholdController.dispose();
    _aiSloTargetController.dispose();
    _aiBurnRateController.dispose();
    _aiCostAnomalyController.dispose();
    _aiAlertChannelsController.dispose();
    _aiEscalationMatrixController.dispose();
    _aiAlertEmailFromController.dispose();
    _aiSlackWebhookController.dispose();
    _aiSilenceWindowsController.dispose();
    _aiRunbookLinksController.dispose();
    _aiDigestWindowController.dispose();
    _aiModelController.dispose();
    super.dispose();
  }

  String? _validateApiUrl(AppLocalizations l10n, String url) {
    if (!_useApi) return null;
    if (url.isEmpty) return l10n.apiUrlRequired;
    final err = ApiConfig.validateBaseUrl(url);
    if (err == 'needs_https') return l10n.apiHttpsRequired;
    if (err == 'invalid') return l10n.invalidApiUrl;
    return null;
  }

  Future<void> _applyServerSwitch(AppLocalizations l10n, bool enable) async {
    final url = _apiBaseUrlController.text.trim();
    if (enable) {
      if (url.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.apiUrlRequired),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
      final err = ApiConfig.validateBaseUrl(url);
      if (err == 'needs_https') {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.apiHttpsRequired),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
      if (err == 'invalid') {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.invalidApiUrl),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
    }
    await ApiConfig.setBaseUrl(url.isEmpty ? null : url);
    await ApiConfig.setUseApi(enable);
    AuthSession.instance.notifyEnvironmentChanged();
    if (!mounted) return;
    setState(() => _useApi = enable);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(enable ? l10n.serverEnabled : l10n.serverDisabled),
        backgroundColor: AppColors.success,
      ),
    );
  }

  Future<void> _saveCompanySettings(AppLocalizations l10n) async {
    setState(() => _savingCompany = true);
    final result = await SettingsRepository.instance.saveSettings(
      name: _companyController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
    );
    if (!mounted) return;
    setState(() => _savingCompany = false);
    switch (result) {
      case ApiSuccess(:final data):
        CompanyContext.instance.apply(data);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.formSavedSuccess),
            backgroundColor: AppColors.success,
          ),
        );
      case ApiFailure(:final message):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: AppColors.error),
        );
    }
  }

  Future<void> _saveWifiSettings(AppLocalizations l10n) async {
    final ssid = _wifiSsidController.text.trim();
    setState(() => _savingWifi = true);
    WifiAttendanceService.setCompanyWifiSsid(ssid);
    final result = await SettingsRepository.instance.saveSettings(
      wifiSsid: ssid,
    );
    if (!mounted) return;
    setState(() => _savingWifi = false);
    switch (result) {
      case ApiSuccess():
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.wifiSettingsSaved),
            backgroundColor: AppColors.success,
          ),
        );
      case ApiFailure(:final message):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: AppColors.error),
        );
    }
  }

  Future<void> _saveServerSettings(AppLocalizations l10n) async {
    final url = _apiBaseUrlController.text.trim();
    if (_useApi) {
      final msg = _validateApiUrl(l10n, url);
      if (msg != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: AppColors.error),
        );
        return;
      }
    }
    await ApiConfig.setBaseUrl(url.isEmpty ? null : url);
    await ApiConfig.setUseApi(_useApi);
    AuthSession.instance.notifyEnvironmentChanged();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.serverSettingsSaved),
        backgroundColor: AppColors.success,
      ),
    );
  }

  Future<void> _saveAiGovernanceSettings() async {
    setState(() => _savingAiGovernance = true);
    final rpm = int.tryParse(_aiRpmController.text.trim()) ?? 60;
    final monthlyLimit =
        int.tryParse(_aiMonthlyTokensController.text.trim()) ?? 500000;
    final rollout = int.tryParse(_aiRolloutController.text.trim()) ?? 100;
    final errorRateThreshold =
        double.tryParse(_aiErrorRateThresholdController.text.trim()) ?? 5;
    final p95Threshold =
        int.tryParse(_aiP95LatencyThresholdController.text.trim()) ?? 2500;
    final queueFailureThreshold =
        int.tryParse(_aiQueueFailureThresholdController.text.trim()) ?? 3;
    final sloTarget = double.tryParse(_aiSloTargetController.text.trim()) ?? 99.5;
    final burnRate = double.tryParse(_aiBurnRateController.text.trim()) ?? 2.0;
    final costAnomaly =
        double.tryParse(_aiCostAnomalyController.text.trim()) ?? 2.0;
    final digestWindow =
        int.tryParse(_aiDigestWindowController.text.trim()) ?? 60;
    final alertChannels = _aiAlertChannelsController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    Map<String, dynamic>? escalationMatrix;
    List<Map<String, dynamic>>? silenceWindows;
    Map<String, dynamic>? runbookLinks;
    final escalationRaw = _aiEscalationMatrixController.text.trim();
    final silenceRaw = _aiSilenceWindowsController.text.trim();
    final runbookRaw = _aiRunbookLinksController.text.trim();
    if (escalationRaw.isNotEmpty) {
      try {
        final parsed = jsonDecode(escalationRaw);
        if (parsed is Map<String, dynamic>) {
          escalationMatrix = parsed;
        } else {
          if (!mounted) return;
          setState(() => _savingAiGovernance = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _txt(
                  'صيغة escalation matrix غير صحيحة (JSON object مطلوب)',
                  'Invalid escalation matrix JSON object',
                ),
              ),
              backgroundColor: AppColors.error,
            ),
          );
          return;
        }
      } catch (_) {
        if (!mounted) return;
        setState(() => _savingAiGovernance = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _txt(
                'صيغة escalation matrix غير صحيحة (JSON object مطلوب)',
                'Invalid escalation matrix JSON object',
              ),
            ),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
    }
    if (silenceRaw.isNotEmpty) {
      try {
        final parsed = jsonDecode(silenceRaw);
        if (parsed is List) {
          silenceWindows = parsed
              .whereType<Map<String, dynamic>>()
              .toList();
        } else {
          throw const FormatException('Silence windows must be JSON list');
        }
      } catch (_) {
        if (!mounted) return;
        setState(() => _savingAiGovernance = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _txt(
                'صيغة silence windows غير صحيحة (JSON list مطلوب)',
                'Invalid silence windows JSON list',
              ),
            ),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
    }
    if (runbookRaw.isNotEmpty) {
      try {
        final parsed = jsonDecode(runbookRaw);
        if (parsed is Map<String, dynamic>) {
          runbookLinks = parsed;
        } else {
          throw const FormatException('Runbook links must be JSON object');
        }
      } catch (_) {
        if (!mounted) return;
        setState(() => _savingAiGovernance = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _txt(
                'صيغة runbook links غير صحيحة (JSON object مطلوب)',
                'Invalid runbook links JSON object',
              ),
            ),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
    }
    final result = await SettingsRepository.instance.saveSettings(
      aiPlan: _aiPlan,
      aiEnabled: _aiEnabled,
      aiProvider: _aiProvider,
      aiModel: _aiModelController.text.trim().isEmpty
          ? null
          : _aiModelController.text.trim(),
      aiRequestsPerMinute: rpm,
      aiMonthlyTokenLimit: monthlyLimit,
      aiRolloutPercentage: rollout.clamp(0, 100),
      aiSafetyLevel: _aiSafetyLevel,
      aiAlertErrorRateThreshold: errorRateThreshold,
      aiAlertP95LatencyMsThreshold: p95Threshold,
      aiAlertQueueFailureThreshold: queueFailureThreshold,
      aiSloTargetSuccessRate: sloTarget,
      aiBurnRateAlertThreshold: burnRate,
      aiCostAnomalyMultiplier: costAnomaly,
      aiAlertChannels: alertChannels,
      aiEscalationMatrix: escalationMatrix,
      aiSilenceWindows: silenceWindows,
      aiRunbookLinks: runbookLinks,
      aiDigestEnabled: _aiDigestEnabled,
      aiDigestWindowMinutes: digestWindow,
      aiAlertEmailFrom: _aiAlertEmailFromController.text.trim().isEmpty
          ? null
          : _aiAlertEmailFromController.text.trim(),
      aiSlackWebhookUrl: _aiSlackWebhookController.text.trim().isEmpty
          ? null
          : _aiSlackWebhookController.text.trim(),
      aiFeatureFlags: Map<String, bool>.from(_aiFeatureFlags),
    );
    if (!mounted) return;
    setState(() => _savingAiGovernance = false);

    switch (result) {
      case ApiSuccess():
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _txt('تم حفظ حوكمة الذكاء الاصطناعي', 'AI governance saved'),
            ),
            backgroundColor: AppColors.success,
          ),
        );
      case ApiFailure(:final message):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: AppColors.error),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);

    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.settings, style: AppTypography.h1),
            const SizedBox(height: 32),
            _SectionCard(
              title: l10n.appearance,
              icon: Icons.palette_outlined,
              child: Row(
                children: [
                  Icon(
                    ThemeScope.of(context).isDark
                        ? Icons.dark_mode
                        : Icons.light_mode,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.darkMode, style: AppTypography.bodyMedium),
                        Text(
                          ThemeScope.of(context).isDark
                              ? l10n.darkModeOn
                              : l10n.darkModeOff,
                          style: AppTypography.caption,
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: ThemeScope.of(context).isDark,
                    onChanged: (v) {
                      ThemeScope.of(
                        context,
                      ).setMode(v ? ThemeMode.dark : ThemeMode.light);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _SectionCard(
              title: l10n.languageTitle,
              icon: Icons.language,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.language, style: AppTypography.bodyMedium),
                        Text(
                          locale.languageCode == 'ar'
                              ? l10n.arabic
                              : l10n.english,
                          style: AppTypography.caption,
                        ),
                      ],
                    ),
                  ),
                  SegmentedButton<String>(
                    segments: [
                      ButtonSegment(value: 'ar', label: Text(l10n.arabic)),
                      ButtonSegment(value: 'en', label: Text(l10n.english)),
                    ],
                    selected: {locale.languageCode == 'en' ? 'en' : 'ar'},
                    onSelectionChanged: (s) {
                      final code = s.first;
                      LocaleController.instance.setLocale(Locale(code));
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _SectionCard(
              title: l10n.serverBindingTitle,
              icon: Icons.cloud_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.serverBindingDescription,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _apiBaseUrlController,
                    decoration: InputDecoration(
                      labelText: l10n.baseUrlLabel,
                      hintText: l10n.baseUrlHint,
                      prefixIcon: const Icon(Icons.link),
                    ),
                    keyboardType: TextInputType.url,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.useServer,
                              style: AppTypography.bodyMedium,
                            ),
                            Text(
                              _useApi
                                  ? l10n.dataFromServer
                                  : l10n.dataLocalDemo,
                              style: AppTypography.caption,
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _useApi,
                        onChanged: (v) => _applyServerSwitch(l10n, v),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () => _saveServerSettings(l10n),
                    child: Text(l10n.save),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _SectionCard(
              title: _txt('حوكمة الذكاء الاصطناعي', 'AI Governance'),
              icon: Icons.tune,
              child: _loadingSettings
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _txt(
                                      'تفعيل خدمات AI',
                                      'Enable AI services',
                                    ),
                                    style: AppTypography.bodyMedium,
                                  ),
                                  Text(
                                    _aiEnabled
                                        ? _txt(
                                            'مفعل للشركة',
                                            'Enabled for company',
                                          )
                                        : _txt(
                                            'متوقف حالياً',
                                            'Currently disabled',
                                          ),
                                    style: AppTypography.caption,
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: _aiEnabled,
                              onChanged: (v) => setState(() => _aiEnabled = v),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                initialValue: _aiPlan,
                                decoration: InputDecoration(
                                  labelText: _txt('خطة AI', 'AI plan'),
                                ),
                                items: [
                                  DropdownMenuItem(
                                    value: 'starter',
                                    child: Text(_txt('بداية', 'Starter')),
                                  ),
                                  DropdownMenuItem(
                                    value: 'growth',
                                    child: Text(_txt('نمو', 'Growth')),
                                  ),
                                  DropdownMenuItem(
                                    value: 'enterprise',
                                    child: Text(_txt('مؤسسات', 'Enterprise')),
                                  ),
                                ],
                                onChanged: (v) =>
                                    setState(() => _aiPlan = v ?? 'enterprise'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                initialValue: _aiProvider,
                                decoration: InputDecoration(
                                  labelText: _txt('مزود AI', 'AI provider'),
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'openai',
                                    child: Text('OpenAI'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'gemini',
                                    child: Text('Gemini'),
                                  ),
                                ],
                                onChanged: (v) =>
                                    setState(() => _aiProvider = v ?? 'openai'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _aiModelController,
                          decoration: InputDecoration(
                            labelText: _txt(
                              'اسم الموديل (اختياري)',
                              'Model name (optional)',
                            ),
                            hintText: _txt(
                              'مثال: gpt-4o-mini',
                              'e.g. gpt-4o-mini',
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                initialValue: _aiSafetyLevel,
                                decoration: InputDecoration(
                                  labelText: _txt(
                                    'مستوى الأمان',
                                    'Safety level',
                                  ),
                                ),
                                items: [
                                  DropdownMenuItem(
                                    value: 'standard',
                                    child: Text(_txt('قياسي', 'Standard')),
                                  ),
                                  DropdownMenuItem(
                                    value: 'strict',
                                    child: Text(_txt('مشدد', 'Strict')),
                                  ),
                                ],
                                onChanged: (v) => setState(
                                  () => _aiSafetyLevel = v ?? 'standard',
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                controller: _aiRolloutController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: _txt(
                                    'نسبة التفعيل التدريجي %',
                                    'Rollout percentage %',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _aiErrorRateThresholdController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                decoration: InputDecoration(
                                  labelText: _txt(
                                    'عتبة نسبة الخطأ %',
                                    'Error-rate threshold %',
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                controller: _aiP95LatencyThresholdController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: _txt(
                                    'عتبة p95 latency ms',
                                    'P95 latency threshold ms',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _aiQueueFailureThresholdController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: _txt(
                              'حد فشل الـ Queue',
                              'Queue failure threshold',
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _aiSloTargetController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                decoration: InputDecoration(
                                  labelText: _txt(
                                    'SLO success target %',
                                    'SLO success target %',
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                controller: _aiBurnRateController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                decoration: InputDecoration(
                                  labelText: _txt(
                                    'Burn-rate threshold',
                                    'Burn-rate threshold',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _aiCostAnomalyController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            labelText: _txt(
                              'Cost anomaly multiplier',
                              'Cost anomaly multiplier',
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _aiAlertChannelsController,
                          decoration: InputDecoration(
                            labelText: _txt(
                              'Alert channels (comma separated)',
                              'Alert channels (comma separated)',
                            ),
                            hintText: 'in_app,email,slack',
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _aiAlertEmailFromController,
                          decoration: InputDecoration(
                            labelText: _txt(
                              'Alert sender email',
                              'Alert sender email',
                            ),
                            hintText: 'alerts@company.com',
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _aiSlackWebhookController,
                          decoration: InputDecoration(
                            labelText: _txt(
                              'Slack webhook URL',
                              'Slack webhook URL',
                            ),
                            hintText: 'https://hooks.slack.com/services/...',
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Switch(
                                    value: _aiDigestEnabled,
                                    onChanged: (v) =>
                                        setState(() => _aiDigestEnabled = v),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _txt(
                                        'Enable escalation digest',
                                        'Enable escalation digest',
                                      ),
                                      style: AppTypography.bodyMedium,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            SizedBox(
                              width: 180,
                              child: TextFormField(
                                controller: _aiDigestWindowController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: _txt(
                                    'Digest window (min)',
                                    'Digest window (min)',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _aiSilenceWindowsController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            labelText: _txt(
                              'Silence windows JSON',
                              'Silence windows JSON',
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _aiRunbookLinksController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            labelText: _txt(
                              'Runbook links JSON',
                              'Runbook links JSON',
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _aiEscalationMatrixController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            labelText: _txt(
                              'Escalation matrix JSON',
                              'Escalation matrix JSON',
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _aiRpmController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: _txt(
                                    'حد الطلبات/دقيقة',
                                    'Requests per minute',
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                controller: _aiMonthlyTokensController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: _txt(
                                    'حد التوكنز الشهري',
                                    'Monthly token limit',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          _txt('Feature Flags', 'Feature Flags'),
                          style: AppTypography.label,
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _aiFeatureFlags.entries.map((entry) {
                            return FilterChip(
                              selected: entry.value,
                              label: Text(entry.key),
                              onSelected: (selected) {
                                setState(
                                  () => _aiFeatureFlags[entry.key] = selected,
                                );
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 14),
                        FilledButton.icon(
                          onPressed: _savingAiGovernance
                              ? null
                              : _saveAiGovernanceSettings,
                          icon: _savingAiGovernance
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.save_outlined),
                          label: Text(
                            _txt('حفظ إعدادات AI', 'Save AI settings'),
                          ),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 24),
            _SectionCard(
              title: l10n.companyInfo,
              icon: Icons.business,
              child: _loadingSettings
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : Column(
                      children: [
                        TextFormField(
                          controller: _companyController,
                          decoration: InputDecoration(
                            labelText: l10n.companyName,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(labelText: l10n.email),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _phoneController,
                          decoration: InputDecoration(labelText: l10n.phone),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _addressController,
                          decoration: InputDecoration(labelText: l10n.address),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 24),
                        FilledButton(
                          onPressed: _savingCompany
                              ? null
                              : () => _saveCompanySettings(l10n),
                          child: _savingCompany
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(l10n.save),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 24),
            _SectionCard(
              title: l10n.wifiAttendanceTitle,
              icon: Icons.wifi,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.wifiAttendanceBody,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _wifiSsidController,
                    decoration: InputDecoration(
                      labelText: l10n.wifiSsidLabel,
                      prefixIcon: const Icon(Icons.wifi),
                      hintText: l10n.wifiSsidHint,
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _savingWifi
                        ? null
                        : () => _saveWifiSettings(l10n),
                    child: _savingWifi
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(l10n.save),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _SectionCard(
              title: l10n.rolesPermissions,
              icon: Icons.security,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    leading: const Icon(Icons.admin_panel_settings),
                    title: Text(l10n.roleAdminTitle),
                    subtitle: Text(l10n.roleAdminSubtitle),
                    trailing: const Icon(Icons.chevron_left),
                    onTap: () => context.push('/admin/settings/role/admin'),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.people),
                    title: Text(l10n.roleHrTitle),
                    subtitle: Text(l10n.roleHrSubtitle),
                    trailing: const Icon(Icons.chevron_left),
                    onTap: () => context.push('/admin/settings/role/hr'),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(l10n.roleEmployeeTitle),
                    subtitle: Text(l10n.roleEmployeeSubtitle),
                    trailing: const Icon(Icons.chevron_left),
                    onTap: () => context.push('/admin/settings/role/employee'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            AnimatedBuilder(
              animation: SubscriptionController.instance,
              builder: (context, _) {
                final sub = SubscriptionController.instance;
                return _SectionCard(
                  title: l10n.subscriptionBilling,
                  icon: Icons.credit_card,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.saasPlanSection, style: AppTypography.label),
                      const SizedBox(height: 8),
                      SegmentedButton<String>(
                        showSelectedIcon: false,
                        segments: [
                          ButtonSegment(
                            value: 'starter',
                            label: Text(l10n.planStarter),
                          ),
                          ButtonSegment(
                            value: 'growth',
                            label: Text(l10n.planGrowth),
                          ),
                          ButtonSegment(
                            value: 'enterprise',
                            label: Text(l10n.planEnterprise),
                          ),
                        ],
                        selected: {sub.planId},
                        onSelectionChanged: (s) async {
                          if (s.isEmpty) return;
                          await sub.setPlan(s.first);
                        },
                      ),
                      const SizedBox(height: 8),
                      Text(
                        sub.planId == 'enterprise'
                            ? l10n.planEnterpriseDesc
                            : sub.planId == 'growth'
                            ? l10n.planGrowthDesc
                            : l10n.planStarterDesc,
                        style: AppTypography.caption,
                      ),
                      const SizedBox(height: 12),
                      Card(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: AppColors.primary,
                                size: 40,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      sub.planId == 'enterprise'
                                          ? l10n.planEnterprise
                                          : sub.planId == 'growth'
                                          ? l10n.planGrowth
                                          : l10n.planStarter,
                                      style: AppTypography.h4,
                                    ),
                                    Text(
                                      sub.planId == 'enterprise'
                                          ? l10n.planEnterpriseDesc
                                          : sub.planId == 'growth'
                                          ? l10n.planGrowthDesc
                                          : l10n.planStarterDesc,
                                      style: AppTypography.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              OutlinedButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(l10n.paymentPortalLater),
                                      backgroundColor: AppColors.info,
                                    ),
                                  );
                                },
                                child: Text(l10n.upgradePlan),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _FeatureChip(l10n.featureEmployees, true),
                          _FeatureChip(l10n.featureAttendance, true),
                          _FeatureChip(l10n.featureLeave, true),
                          _FeatureChip(l10n.featurePayroll, true),
                          _FeatureChip(
                            l10n.featureRecruitment,
                            sub.recruitmentEnabled,
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary),
                const SizedBox(width: 12),
                Text(title, style: AppTypography.h4),
              ],
            ),
            const SizedBox(height: 20),
            child,
          ],
        ),
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  const _FeatureChip(this.label, this.enabled);

  final String label;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Chip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              enabled ? Icons.check_circle : Icons.cancel,
              size: 16,
              color: enabled ? AppColors.success : AppColors.textMuted,
            ),
            const SizedBox(width: 4),
            Text(label),
          ],
        ),
      ),
    );
  }
}
