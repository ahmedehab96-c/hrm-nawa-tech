import 'dart:convert';

import '../api/api_client.dart';
import '../api/api_config.dart';
import '../api/api_result.dart';

class CompanySettings {
  CompanySettings({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.address,
    this.wifiSsid,
    this.status,
    this.aiPlan,
    this.aiEnabled,
    this.aiProvider,
    this.aiModel,
    this.aiRequestsPerMinute,
    this.aiMonthlyTokenLimit,
    this.aiFeatureFlags = const {},
    this.aiRolloutPercentage,
    this.aiSafetyLevel,
    this.aiAlertErrorRateThreshold,
    this.aiAlertP95LatencyMsThreshold,
    this.aiAlertQueueFailureThreshold,
    this.aiSloTargetSuccessRate,
    this.aiBurnRateAlertThreshold,
    this.aiCostAnomalyMultiplier,
    this.aiAlertChannels = const ['in_app'],
    this.aiEscalationMatrix = const {},
    this.aiAlertEmailFrom,
    this.aiSlackWebhookUrl,
    this.aiSilenceWindows = const [],
    this.aiRunbookLinks = const {},
    this.aiDigestEnabled,
    this.aiDigestWindowMinutes,
  });

  final String id;
  final String name;
  final String? email;
  final String? phone;
  final String? address;
  final String? wifiSsid;
  final String? status;
  final String? aiPlan;
  final bool? aiEnabled;
  final String? aiProvider;
  final String? aiModel;
  final int? aiRequestsPerMinute;
  final int? aiMonthlyTokenLimit;
  final Map<String, bool> aiFeatureFlags;
  final int? aiRolloutPercentage;
  final String? aiSafetyLevel;
  final double? aiAlertErrorRateThreshold;
  final int? aiAlertP95LatencyMsThreshold;
  final int? aiAlertQueueFailureThreshold;
  final double? aiSloTargetSuccessRate;
  final double? aiBurnRateAlertThreshold;
  final double? aiCostAnomalyMultiplier;
  final List<String> aiAlertChannels;
  final Map<String, dynamic> aiEscalationMatrix;
  final String? aiAlertEmailFrom;
  final String? aiSlackWebhookUrl;
  final List<Map<String, dynamic>> aiSilenceWindows;
  final Map<String, dynamic> aiRunbookLinks;
  final bool? aiDigestEnabled;
  final int? aiDigestWindowMinutes;

  factory CompanySettings.fromJson(Map<String, dynamic> json) =>
      CompanySettings(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        email: json['email']?.toString(),
        phone: json['phone']?.toString(),
        address: json['address']?.toString(),
        wifiSsid: json['wifi_ssid']?.toString(),
        status: json['status']?.toString(),
        aiPlan: json['ai_plan']?.toString(),
        aiEnabled: json['ai_enabled'] is bool
            ? json['ai_enabled'] as bool
            : json['ai_enabled']?.toString() == '1',
        aiProvider: json['ai_provider']?.toString(),
        aiModel: json['ai_model']?.toString(),
        aiRequestsPerMinute: (json['ai_requests_per_minute'] as num?)?.toInt(),
        aiMonthlyTokenLimit: (json['ai_monthly_token_limit'] as num?)?.toInt(),
        aiFeatureFlags:
            (json['ai_feature_flags'] as Map<String, dynamic>? ?? const {}).map(
              (k, v) => MapEntry(k, v == true),
            ),
        aiRolloutPercentage: (json['ai_rollout_percentage'] as num?)?.toInt(),
        aiSafetyLevel: json['ai_safety_level']?.toString(),
        aiAlertErrorRateThreshold:
            (json['ai_alert_error_rate_threshold'] as num?)?.toDouble(),
        aiAlertP95LatencyMsThreshold:
            (json['ai_alert_p95_latency_ms_threshold'] as num?)?.toInt(),
        aiAlertQueueFailureThreshold:
            (json['ai_alert_queue_failure_threshold'] as num?)?.toInt(),
        aiSloTargetSuccessRate:
            (json['ai_slo_target_success_rate'] as num?)?.toDouble(),
        aiBurnRateAlertThreshold:
            (json['ai_burn_rate_alert_threshold'] as num?)?.toDouble(),
        aiCostAnomalyMultiplier:
            (json['ai_cost_anomaly_multiplier'] as num?)?.toDouble(),
        aiAlertChannels:
            (json['ai_alert_channels'] as List<dynamic>? ?? const ['in_app'])
                .map((e) => e.toString())
                .toList(),
        aiEscalationMatrix:
            json['ai_escalation_matrix'] as Map<String, dynamic>? ?? const {},
        aiAlertEmailFrom: json['ai_alert_email_from']?.toString(),
        aiSlackWebhookUrl: json['ai_slack_webhook_url']?.toString(),
        aiSilenceWindows:
            (json['ai_silence_windows'] as List<dynamic>? ?? const [])
                .whereType<Map<String, dynamic>>()
                .toList(),
        aiRunbookLinks:
            json['ai_runbook_links'] as Map<String, dynamic>? ?? const {},
        aiDigestEnabled: json['ai_digest_enabled'] is bool
            ? json['ai_digest_enabled'] as bool
            : json['ai_digest_enabled']?.toString() == '1',
        aiDigestWindowMinutes:
            (json['ai_digest_window_minutes'] as num?)?.toInt(),
      );

  static CompanySettings get demo => CompanySettings(
    id: '1',
    name: 'شركة النخبة — عرض Nawa Tech',
    email: 'showcase@nawatech.com',
    phone: '+966 11 234 5678',
    address: 'الرياض، المملكة العربية السعودية',
    wifiSsid: '',
    status: 'active',
    aiPlan: 'enterprise',
    aiEnabled: true,
    aiProvider: 'openai',
    aiModel: null,
    aiRequestsPerMinute: 60,
    aiMonthlyTokenLimit: 500000,
    aiRolloutPercentage: 100,
    aiSafetyLevel: 'standard',
    aiAlertErrorRateThreshold: 5,
    aiAlertP95LatencyMsThreshold: 2500,
    aiAlertQueueFailureThreshold: 3,
    aiSloTargetSuccessRate: 99.5,
    aiBurnRateAlertThreshold: 2.0,
    aiCostAnomalyMultiplier: 2.0,
    aiAlertChannels: const ['in_app', 'email'],
    aiAlertEmailFrom: 'alerts@company.local',
    aiSlackWebhookUrl: '',
    aiSilenceWindows: const [
      {
        'name': 'night_window',
        'days': [1, 2, 3, 4, 5],
        'start': '23:00',
        'end': '06:00',
      },
    ],
    aiRunbookLinks: const {
      'high_error_rate': 'https://runbooks.example.com/ai/high-error-rate',
      'high_p95_latency': 'https://runbooks.example.com/ai/high-latency',
      'queue_failures': 'https://runbooks.example.com/ai/queue-failures',
      'default': 'https://runbooks.example.com/ai/general',
    },
    aiDigestEnabled: true,
    aiDigestWindowMinutes: 60,
    aiEscalationMatrix: const {
      'l1': {
        'policy': 'notify_in_5m',
        'recipients': ['hr-oncall@company.local'],
      },
      'l2': {
        'policy': 'notify_now',
        'recipients': ['engineering-oncall@company.local'],
      },
      'l3': {
        'policy': 'page_immediately',
        'recipients': ['cto@company.local'],
      },
    },
    aiFeatureFlags: const {
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
    },
  );
}

class SettingsRepository {
  SettingsRepository._();
  static final instance = SettingsRepository._();

  Future<ApiResult<CompanySettings>> getSettings() async {
    if (!ApiConfig.useApi) return ApiSuccess(CompanySettings.demo);

    final res = await ApiClient.get('company');
    return switch (res) {
      ApiFailure(:final message, :final statusCode) => ApiFailure(
        message,
        statusCode: statusCode,
      ),
      ApiSuccess(:final data) => () {
        try {
          final map = jsonDecode(data.body);
          final raw = map is Map<String, dynamic>
              ? (map['data'] as Map<String, dynamic>? ?? map)
              : map as Map<String, dynamic>;
          return ApiSuccess(CompanySettings.fromJson(raw));
        } catch (e) {
          return ApiFailure<CompanySettings>('Could not parse settings: $e');
        }
      }(),
    };
  }

  Future<ApiResult<CompanySettings>> saveSettings({
    String? name,
    String? email,
    String? phone,
    String? address,
    String? wifiSsid,
    String? aiPlan,
    bool? aiEnabled,
    String? aiProvider,
    String? aiModel,
    int? aiRequestsPerMinute,
    int? aiMonthlyTokenLimit,
    Map<String, bool>? aiFeatureFlags,
    int? aiRolloutPercentage,
    String? aiSafetyLevel,
    double? aiAlertErrorRateThreshold,
    int? aiAlertP95LatencyMsThreshold,
    int? aiAlertQueueFailureThreshold,
    double? aiSloTargetSuccessRate,
    double? aiBurnRateAlertThreshold,
    double? aiCostAnomalyMultiplier,
    List<String>? aiAlertChannels,
    Map<String, dynamic>? aiEscalationMatrix,
    String? aiAlertEmailFrom,
    String? aiSlackWebhookUrl,
    List<Map<String, dynamic>>? aiSilenceWindows,
    Map<String, dynamic>? aiRunbookLinks,
    bool? aiDigestEnabled,
    int? aiDigestWindowMinutes,
  }) async {
    if (!ApiConfig.useApi) return ApiSuccess(CompanySettings.demo);

    final body = <String, dynamic>{};
    if (name != null && name.isNotEmpty) body['name'] = name;
    if (email != null) body['email'] = email;
    if (phone != null) body['phone'] = phone;
    if (address != null) body['address'] = address;
    if (wifiSsid != null) body['wifi_ssid'] = wifiSsid;
    if (aiPlan != null) body['ai_plan'] = aiPlan;
    if (aiEnabled != null) body['ai_enabled'] = aiEnabled;
    if (aiProvider != null) body['ai_provider'] = aiProvider;
    if (aiModel != null) body['ai_model'] = aiModel;
    if (aiRequestsPerMinute != null) {
      body['ai_requests_per_minute'] = aiRequestsPerMinute;
    }
    if (aiMonthlyTokenLimit != null) {
      body['ai_monthly_token_limit'] = aiMonthlyTokenLimit;
    }
    if (aiFeatureFlags != null) body['ai_feature_flags'] = aiFeatureFlags;
    if (aiRolloutPercentage != null) {
      body['ai_rollout_percentage'] = aiRolloutPercentage;
    }
    if (aiSafetyLevel != null) body['ai_safety_level'] = aiSafetyLevel;
    if (aiAlertErrorRateThreshold != null) {
      body['ai_alert_error_rate_threshold'] = aiAlertErrorRateThreshold;
    }
    if (aiAlertP95LatencyMsThreshold != null) {
      body['ai_alert_p95_latency_ms_threshold'] = aiAlertP95LatencyMsThreshold;
    }
    if (aiAlertQueueFailureThreshold != null) {
      body['ai_alert_queue_failure_threshold'] = aiAlertQueueFailureThreshold;
    }
    if (aiSloTargetSuccessRate != null) {
      body['ai_slo_target_success_rate'] = aiSloTargetSuccessRate;
    }
    if (aiBurnRateAlertThreshold != null) {
      body['ai_burn_rate_alert_threshold'] = aiBurnRateAlertThreshold;
    }
    if (aiCostAnomalyMultiplier != null) {
      body['ai_cost_anomaly_multiplier'] = aiCostAnomalyMultiplier;
    }
    if (aiAlertChannels != null) body['ai_alert_channels'] = aiAlertChannels;
    if (aiEscalationMatrix != null) {
      body['ai_escalation_matrix'] = aiEscalationMatrix;
    }
    if (aiAlertEmailFrom != null) {
      body['ai_alert_email_from'] = aiAlertEmailFrom;
    }
    if (aiSlackWebhookUrl != null) {
      body['ai_slack_webhook_url'] = aiSlackWebhookUrl;
    }
    if (aiSilenceWindows != null) body['ai_silence_windows'] = aiSilenceWindows;
    if (aiRunbookLinks != null) body['ai_runbook_links'] = aiRunbookLinks;
    if (aiDigestEnabled != null) body['ai_digest_enabled'] = aiDigestEnabled;
    if (aiDigestWindowMinutes != null) {
      body['ai_digest_window_minutes'] = aiDigestWindowMinutes;
    }

    final res = await ApiClient.put('company', body: body);
    return switch (res) {
      ApiFailure(:final message, :final statusCode) => ApiFailure(
        message,
        statusCode: statusCode,
      ),
      ApiSuccess(:final data) => () {
        try {
          final map = jsonDecode(data.body) as Map<String, dynamic>;
          final raw = map['data'] as Map<String, dynamic>? ?? map;
          return ApiSuccess(CompanySettings.fromJson(raw));
        } catch (e) {
          return ApiSuccess(CompanySettings.demo);
        }
      }(),
    };
  }
}
