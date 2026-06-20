import 'dart:convert';

import '../api/api_client.dart';
import '../api/api_config.dart';
import '../api/api_result.dart';

class AiGeneratedContent {
  AiGeneratedContent({
    required this.content,
    this.id,
    this.provider,
    this.model,
    this.latencyMs,
    this.status,
  });

  final String content;
  final String? id;
  final String? provider;
  final String? model;
  final int? latencyMs;
  final String? status;

  factory AiGeneratedContent.fromJson(Map<String, dynamic> json) {
    return AiGeneratedContent(
      content: json['content']?.toString() ?? '',
      id: json['id']?.toString(),
      provider: json['provider']?.toString(),
      model: json['model']?.toString(),
      latencyMs: (json['latency_ms'] as num?)?.toInt(),
      status: json['status']?.toString(),
    );
  }
}

class AiUsageSummary {
  AiUsageSummary({
    required this.monthlyTokensUsed,
    required this.monthlyTokenLimit,
    required this.monthlyUsagePercent,
    required this.requestsToday,
    required this.errorsToday,
    required this.estimatedCostMonthUsd,
    required this.estimatedCostTodayUsd,
    required this.requestsPerMinuteLimit,
    required this.featureFlags,
    required this.byEndpoint,
    required this.costByProvider,
    required this.costByModel,
  });

  final int monthlyTokensUsed;
  final int monthlyTokenLimit;
  final double monthlyUsagePercent;
  final int requestsToday;
  final int errorsToday;
  final double estimatedCostMonthUsd;
  final double estimatedCostTodayUsd;
  final int requestsPerMinuteLimit;
  final Map<String, bool> featureFlags;
  final List<AiUsageEndpointItem> byEndpoint;
  final Map<String, double> costByProvider;
  final Map<String, double> costByModel;
}

class AiUsageEndpointItem {
  AiUsageEndpointItem({
    required this.endpoint,
    required this.requests,
    required this.tokens,
  });

  final String endpoint;
  final int requests;
  final int tokens;
}

class AiObservabilitySummary {
  AiObservabilitySummary({
    required this.rangeDays,
    required this.daily,
    required this.latencyByEndpoint,
    required this.queue,
    required this.blocked,
    required this.alerts,
    required this.policies,
  });

  final int rangeDays;
  final List<AiObservabilityDailyPoint> daily;
  final List<AiEndpointLatencyPoint> latencyByEndpoint;
  final AiQueueStats queue;
  final Map<String, int> blocked;
  final List<AiObservabilityAlert> alerts;
  final AiObservabilityPolicies policies;
}

class AiObservabilityDailyPoint {
  AiObservabilityDailyPoint({
    required this.date,
    required this.requests,
    required this.errors,
    required this.blocked,
    required this.avgLatencyMs,
  });

  final String date;
  final int requests;
  final int errors;
  final int blocked;
  final int avgLatencyMs;
}

class AiEndpointLatencyPoint {
  AiEndpointLatencyPoint({
    required this.endpoint,
    required this.p95LatencyMs,
    required this.avgLatencyMs,
  });

  final String endpoint;
  final int p95LatencyMs;
  final int avgLatencyMs;
}

class AiQueueStats {
  AiQueueStats({
    required this.queued,
    required this.processing,
    required this.completed,
    required this.failed,
    required this.avgDurationMs,
  });

  final int queued;
  final int processing;
  final int completed;
  final int failed;
  final int avgDurationMs;
}

class AiObservabilityAlert {
  AiObservabilityAlert({
    required this.code,
    required this.level,
    required this.value,
    required this.threshold,
    required this.message,
  });

  final String code;
  final String level;
  final double value;
  final double threshold;
  final String message;
}

class AiObservabilityPolicies {
  AiObservabilityPolicies({
    required this.errorRateThreshold,
    required this.p95LatencyMsThreshold,
    required this.queueFailureThreshold,
  });

  final double errorRateThreshold;
  final int p95LatencyMsThreshold;
  final int queueFailureThreshold;
}

class AiPromptVersionItem {
  AiPromptVersionItem({
    required this.id,
    required this.featureKey,
    required this.versionLabel,
    required this.systemPrompt,
    required this.isActive,
  });

  final String id;
  final String featureKey;
  final String versionLabel;
  final String systemPrompt;
  final bool isActive;
}

class AiCanaryVariant {
  AiCanaryVariant({
    required this.provider,
    required this.model,
    required this.requests,
    required this.successRatePercent,
    required this.avgLatencyMs,
    required this.avgCostUsd,
  });

  final String provider;
  final String model;
  final int requests;
  final double successRatePercent;
  final int avgLatencyMs;
  final double avgCostUsd;
}

class AiCanarySummary {
  AiCanarySummary({
    required this.rangeDays,
    required this.variants,
    this.recommended,
  });

  final int rangeDays;
  final List<AiCanaryVariant> variants;
  final AiCanaryVariant? recommended;
}

class AiIncidentPlaybook {
  AiIncidentPlaybook({
    required this.id,
    required this.title,
    required this.actions,
    this.runbookUrl,
  });

  final String id;
  final String title;
  final List<String> actions;
  final String? runbookUrl;
}

class AiIncidentPlaybookBundle {
  AiIncidentPlaybookBundle({required this.alerts, required this.playbooks});

  final List<AiObservabilityAlert> alerts;
  final List<AiIncidentPlaybook> playbooks;
}

class AiRemediationResult {
  AiRemediationResult({
    required this.actionId,
    required this.dryRun,
    required this.before,
    required this.after,
  });

  final String actionId;
  final bool dryRun;
  final Map<String, dynamic> before;
  final Map<String, dynamic> after;
}

class AiContentRepository {
  AiContentRepository._();
  static final instance = AiContentRepository._();

  Future<ApiResult<AiGeneratedContent>> generateJobDescription({
    required String jobTitle,
    required String languageCode,
    String? department,
    String? location,
    String? employmentType,
    String? requirements,
    String? responsibilities,
    String tone = 'professional',
  }) async {
    if (!ApiConfig.useApi) {
      return const ApiFailure('API is disabled');
    }

    final result = await ApiClient.post(
      'ai/job-descriptions/generate',
      body: {
        'job_title': jobTitle,
        'language_code': languageCode,
        if (department != null && department.isNotEmpty)
          'department': department,
        if (location != null && location.isNotEmpty) 'location': location,
        if (employmentType != null && employmentType.isNotEmpty)
          'employment_type': employmentType,
        if (requirements != null && requirements.isNotEmpty)
          'requirements': requirements,
        if (responsibilities != null && responsibilities.isNotEmpty)
          'responsibilities': responsibilities,
        'tone': tone,
      },
    );

    return _parse(result);
  }

  Future<ApiResult<AiGeneratedContent>> generateCommunication({
    required String type,
    required String purpose,
    required String languageCode,
    String? recipientName,
    String? employeeName,
    String? department,
    String? keyPoints,
    String tone = 'professional',
  }) async {
    if (!ApiConfig.useApi) {
      return const ApiFailure('API is disabled');
    }

    final result = await ApiClient.post(
      'ai/communications/generate',
      body: {
        'type': type,
        'purpose': purpose,
        'language_code': languageCode,
        if (recipientName != null && recipientName.isNotEmpty)
          'recipient_name': recipientName,
        if (employeeName != null && employeeName.isNotEmpty)
          'employee_name': employeeName,
        if (department != null && department.isNotEmpty)
          'department': department,
        if (keyPoints != null && keyPoints.isNotEmpty) 'key_points': keyPoints,
        'tone': tone,
      },
    );

    return _parse(result);
  }

  ApiResult<AiGeneratedContent> _parse(ApiResult result) {
    return switch (result) {
      ApiFailure(:final message, :final statusCode) => ApiFailure(
        message,
        statusCode: statusCode,
      ),
      ApiSuccess(:final data) => () {
        try {
          final map = jsonDecode(data.body) as Map<String, dynamic>;
          final raw = map['data'] as Map<String, dynamic>? ?? map;
          return ApiSuccess(AiGeneratedContent.fromJson(raw));
        } catch (e) {
          return ApiFailure<AiGeneratedContent>(
            'Could not parse AI content response: $e',
          );
        }
      }(),
    };
  }

  Future<ApiResult<AiUsageSummary>> getUsage() async {
    if (!ApiConfig.useApi) {
      return ApiSuccess(
        AiUsageSummary(
          monthlyTokensUsed: 12000,
          monthlyTokenLimit: 500000,
          monthlyUsagePercent: 2.4,
          requestsToday: 14,
          errorsToday: 1,
          estimatedCostMonthUsd: 3.42,
          estimatedCostTodayUsd: 0.31,
          requestsPerMinuteLimit: 60,
          featureFlags: const {
            'assistant_chat': true,
            'job_description': true,
            'communication': true,
            'reports_summary': true,
          },
          byEndpoint: [
            AiUsageEndpointItem(endpoint: 'ai/chat', requests: 8, tokens: 5000),
            AiUsageEndpointItem(
              endpoint: 'ai/job-descriptions/generate',
              requests: 4,
              tokens: 4200,
            ),
            AiUsageEndpointItem(
              endpoint: 'ai/communications/generate',
              requests: 2,
              tokens: 2800,
            ),
          ],
          costByProvider: const {'openai': 3.42},
          costByModel: const {'gpt-4o-mini': 3.42},
        ),
      );
    }

    final result = await ApiClient.get('ai/usage');
    return switch (result) {
      ApiFailure(:final message, :final statusCode) => ApiFailure(
        message,
        statusCode: statusCode,
      ),
      ApiSuccess(:final data) => () {
        try {
          final map = jsonDecode(data.body) as Map<String, dynamic>;
          final raw = map['data'] as Map<String, dynamic>? ?? map;
          final flagsRaw =
              raw['feature_flags'] as Map<String, dynamic>? ?? const {};
          final byEndpointRaw =
              raw['by_endpoint'] as List<dynamic>? ?? const [];
          final costByProviderRaw =
              raw['cost_by_provider'] as Map<String, dynamic>? ?? const {};
          final costByModelRaw =
              raw['cost_by_model'] as Map<String, dynamic>? ?? const {};
          return ApiSuccess(
            AiUsageSummary(
              monthlyTokensUsed:
                  (raw['monthly_tokens_used'] as num?)?.toInt() ?? 0,
              monthlyTokenLimit:
                  (raw['monthly_token_limit'] as num?)?.toInt() ?? 0,
              monthlyUsagePercent:
                  (raw['monthly_usage_percent'] as num?)?.toDouble() ?? 0,
              requestsToday: (raw['requests_today'] as num?)?.toInt() ?? 0,
              errorsToday: (raw['errors_today'] as num?)?.toInt() ?? 0,
              estimatedCostMonthUsd:
                  (raw['estimated_cost_month_usd'] as num?)?.toDouble() ?? 0,
              estimatedCostTodayUsd:
                  (raw['estimated_cost_today_usd'] as num?)?.toDouble() ?? 0,
              requestsPerMinuteLimit:
                  (raw['requests_per_minute_limit'] as num?)?.toInt() ?? 0,
              featureFlags: flagsRaw.map((k, v) => MapEntry(k, v == true)),
              byEndpoint: byEndpointRaw.map((e) {
                final m = e as Map<String, dynamic>;
                return AiUsageEndpointItem(
                  endpoint: m['endpoint']?.toString() ?? '',
                  requests: (m['requests'] as num?)?.toInt() ?? 0,
                  tokens: (m['tokens'] as num?)?.toInt() ?? 0,
                );
              }).toList(),
              costByProvider: costByProviderRaw.map(
                (k, v) => MapEntry(k, (v as num?)?.toDouble() ?? 0),
              ),
              costByModel: costByModelRaw.map(
                (k, v) => MapEntry(k, (v as num?)?.toDouble() ?? 0),
              ),
            ),
          );
        } catch (e) {
          return ApiFailure<AiUsageSummary>(
            'Could not parse AI usage response: $e',
          );
        }
      }(),
    };
  }

  Future<ApiResult<AiObservabilitySummary>> getObservability({
    int days = 14,
  }) async {
    if (!ApiConfig.useApi) {
      return ApiSuccess(
        AiObservabilitySummary(
          rangeDays: days,
          daily: [
            AiObservabilityDailyPoint(
              date: '2026-06-16',
              requests: 21,
              errors: 1,
              blocked: 2,
              avgLatencyMs: 820,
            ),
            AiObservabilityDailyPoint(
              date: '2026-06-17',
              requests: 18,
              errors: 0,
              blocked: 1,
              avgLatencyMs: 760,
            ),
          ],
          latencyByEndpoint: [
            AiEndpointLatencyPoint(
              endpoint: 'ai/chat',
              p95LatencyMs: 1200,
              avgLatencyMs: 700,
            ),
          ],
          queue: AiQueueStats(
            queued: 0,
            processing: 1,
            completed: 12,
            failed: 0,
            avgDurationMs: 4600,
          ),
          blocked: const {'blocked_safety': 2, 'blocked_rpm_quota': 1},
          alerts: const [],
          policies: AiObservabilityPolicies(
            errorRateThreshold: 5,
            p95LatencyMsThreshold: 2500,
            queueFailureThreshold: 3,
          ),
        ),
      );
    }

    final result = await ApiClient.get('ai/observability?days=$days');
    return switch (result) {
      ApiFailure(:final message, :final statusCode) => ApiFailure(
        message,
        statusCode: statusCode,
      ),
      ApiSuccess(:final data) => () {
        try {
          final map = jsonDecode(data.body) as Map<String, dynamic>;
          final raw = map['data'] as Map<String, dynamic>? ?? map;
          final dailyRaw = raw['daily'] as List<dynamic>? ?? const [];
          final latencyRaw =
              raw['latency_by_endpoint'] as List<dynamic>? ?? const [];
          final queueRaw = raw['queue'] as Map<String, dynamic>? ?? const {};
          final blockedRaw =
              raw['blocked'] as Map<String, dynamic>? ?? const {};
          final alertsRaw = raw['alerts'] as List<dynamic>? ?? const [];
          final policiesRaw =
              raw['policies'] as Map<String, dynamic>? ?? const {};

          return ApiSuccess(
            AiObservabilitySummary(
              rangeDays: (raw['range_days'] as num?)?.toInt() ?? days,
              daily: dailyRaw.map((e) {
                final m = e as Map<String, dynamic>;
                return AiObservabilityDailyPoint(
                  date: m['date']?.toString() ?? '',
                  requests: (m['requests'] as num?)?.toInt() ?? 0,
                  errors: (m['errors'] as num?)?.toInt() ?? 0,
                  blocked: (m['blocked'] as num?)?.toInt() ?? 0,
                  avgLatencyMs: (m['avg_latency_ms'] as num?)?.toInt() ?? 0,
                );
              }).toList(),
              latencyByEndpoint: latencyRaw.map((e) {
                final m = e as Map<String, dynamic>;
                return AiEndpointLatencyPoint(
                  endpoint: m['endpoint']?.toString() ?? '',
                  p95LatencyMs: (m['p95_latency_ms'] as num?)?.toInt() ?? 0,
                  avgLatencyMs: (m['avg_latency_ms'] as num?)?.toInt() ?? 0,
                );
              }).toList(),
              queue: AiQueueStats(
                queued: (queueRaw['queued'] as num?)?.toInt() ?? 0,
                processing: (queueRaw['processing'] as num?)?.toInt() ?? 0,
                completed: (queueRaw['completed'] as num?)?.toInt() ?? 0,
                failed: (queueRaw['failed'] as num?)?.toInt() ?? 0,
                avgDurationMs:
                    (queueRaw['avg_duration_ms'] as num?)?.toInt() ?? 0,
              ),
              blocked: blockedRaw.map(
                (k, v) => MapEntry(k, (v as num?)?.toInt() ?? 0),
              ),
              alerts: alertsRaw.map((e) {
                final m = e as Map<String, dynamic>;
                return AiObservabilityAlert(
                  code: m['code']?.toString() ?? '',
                  level: m['level']?.toString() ?? 'info',
                  value: (m['value'] as num?)?.toDouble() ?? 0,
                  threshold: (m['threshold'] as num?)?.toDouble() ?? 0,
                  message: m['message']?.toString() ?? '',
                );
              }).toList(),
              policies: AiObservabilityPolicies(
                errorRateThreshold:
                    (policiesRaw['error_rate_threshold'] as num?)?.toDouble() ??
                    5,
                p95LatencyMsThreshold:
                    (policiesRaw['p95_latency_ms_threshold'] as num?)
                        ?.toInt() ??
                    2500,
                queueFailureThreshold:
                    (policiesRaw['queue_failure_threshold'] as num?)?.toInt() ??
                    3,
              ),
            ),
          );
        } catch (e) {
          return ApiFailure<AiObservabilitySummary>(
            'Could not parse observability response: $e',
          );
        }
      }(),
    };
  }

  Future<ApiResult<List<AiPromptVersionItem>>> getPromptVersions({
    String? featureKey,
  }) async {
    if (!ApiConfig.useApi) {
      return ApiSuccess([
        AiPromptVersionItem(
          id: 'demo-1',
          featureKey: featureKey ?? 'assistant_chat',
          versionLabel: 'v1-default',
          systemPrompt: 'Demo system prompt',
          isActive: true,
        ),
      ]);
    }

    final suffix = featureKey != null && featureKey.isNotEmpty
        ? '?feature_key=${Uri.encodeComponent(featureKey)}'
        : '';
    final result = await ApiClient.get('ai/prompts$suffix');
    return switch (result) {
      ApiFailure(:final message, :final statusCode) => ApiFailure(
        message,
        statusCode: statusCode,
      ),
      ApiSuccess(:final data) => () {
        try {
          final map = jsonDecode(data.body) as Map<String, dynamic>;
          final list = map['data'] as List<dynamic>? ?? const [];
          return ApiSuccess(
            list.map((e) {
              final m = e as Map<String, dynamic>;
              return AiPromptVersionItem(
                id: m['id']?.toString() ?? '',
                featureKey: m['feature_key']?.toString() ?? '',
                versionLabel: m['version_label']?.toString() ?? '',
                systemPrompt: m['system_prompt']?.toString() ?? '',
                isActive: m['is_active'] == true,
              );
            }).toList(),
          );
        } catch (e) {
          return ApiFailure<List<AiPromptVersionItem>>(
            'Could not parse prompt versions: $e',
          );
        }
      }(),
    };
  }

  Future<ApiResult<String>> createPromptVersion({
    required String featureKey,
    required String versionLabel,
    required String systemPrompt,
    bool activate = false,
  }) async {
    if (!ApiConfig.useApi) {
      return const ApiSuccess('demo-created');
    }

    final result = await ApiClient.post(
      'ai/prompts',
      body: {
        'feature_key': featureKey,
        'version_label': versionLabel,
        'system_prompt': systemPrompt,
        'activate': activate,
      },
    );
    return switch (result) {
      ApiFailure(:final message, :final statusCode) => ApiFailure(
        message,
        statusCode: statusCode,
      ),
      ApiSuccess(:final data) => () {
        try {
          final map = jsonDecode(data.body) as Map<String, dynamic>;
          final raw = map['data'] as Map<String, dynamic>? ?? map;
          return ApiSuccess(raw['id']?.toString() ?? '');
        } catch (e) {
          return ApiFailure<String>(
            'Could not parse create prompt response: $e',
          );
        }
      }(),
    };
  }

  Future<ApiResult<void>> activatePromptVersion(String id) async {
    if (!ApiConfig.useApi) {
      return const ApiSuccess(null);
    }

    final result = await ApiClient.post('ai/prompts/$id/activate', body: {});
    return switch (result) {
      ApiFailure(:final message, :final statusCode) => ApiFailure(
        message,
        statusCode: statusCode,
      ),
      ApiSuccess() => const ApiSuccess(null),
    };
  }

  Future<ApiResult<AiCanarySummary>> getCanary({int days = 14}) async {
    if (!ApiConfig.useApi) {
      return ApiSuccess(
        AiCanarySummary(
          rangeDays: days,
          variants: [
            AiCanaryVariant(
              provider: 'openai',
              model: 'gpt-4o-mini',
              requests: 20,
              successRatePercent: 99,
              avgLatencyMs: 700,
              avgCostUsd: 0.00021,
            ),
          ],
          recommended: AiCanaryVariant(
            provider: 'openai',
            model: 'gpt-4o-mini',
            requests: 20,
            successRatePercent: 99,
            avgLatencyMs: 700,
            avgCostUsd: 0.00021,
          ),
        ),
      );
    }

    final result = await ApiClient.get('ai/canary?days=$days');
    return switch (result) {
      ApiFailure(:final message, :final statusCode) => ApiFailure(
        message,
        statusCode: statusCode,
      ),
      ApiSuccess(:final data) => () {
        try {
          final map = jsonDecode(data.body) as Map<String, dynamic>;
          final raw = map['data'] as Map<String, dynamic>? ?? map;
          final variantsRaw = raw['variants'] as List<dynamic>? ?? const [];
          AiCanaryVariant parse(Map<String, dynamic> m) => AiCanaryVariant(
            provider: m['provider']?.toString() ?? '',
            model: m['model']?.toString() ?? '',
            requests: (m['requests'] as num?)?.toInt() ?? 0,
            successRatePercent:
                (m['success_rate_percent'] as num?)?.toDouble() ?? 0,
            avgLatencyMs: (m['avg_latency_ms'] as num?)?.toInt() ?? 0,
            avgCostUsd: (m['avg_cost_usd'] as num?)?.toDouble() ?? 0,
          );
          return ApiSuccess(
            AiCanarySummary(
              rangeDays: (raw['range_days'] as num?)?.toInt() ?? days,
              variants: variantsRaw
                  .map((e) => parse(e as Map<String, dynamic>))
                  .toList(),
              recommended: raw['recommended'] is Map<String, dynamic>
                  ? parse(raw['recommended'] as Map<String, dynamic>)
                  : null,
            ),
          );
        } catch (e) {
          return ApiFailure<AiCanarySummary>(
            'Could not parse canary response: $e',
          );
        }
      }(),
    };
  }

  Future<ApiResult<AiIncidentPlaybookBundle>> getIncidentPlaybooks({
    int days = 14,
  }) async {
    if (!ApiConfig.useApi) {
      return ApiSuccess(
        AiIncidentPlaybookBundle(
          alerts: const [],
          playbooks: [
            AiIncidentPlaybook(
              id: 'high_error_rate',
              title: 'High Error-Rate Response',
              actions: ['tighten_safety', 'reduce_rollout_50'],
            ),
          ],
        ),
      );
    }

    final result = await ApiClient.get('ai/incidents/playbooks?days=$days');
    return switch (result) {
      ApiFailure(:final message, :final statusCode) => ApiFailure(
        message,
        statusCode: statusCode,
      ),
      ApiSuccess(:final data) => () {
        try {
          final map = jsonDecode(data.body) as Map<String, dynamic>;
          final raw = map['data'] as Map<String, dynamic>? ?? map;
          final alertsRaw = raw['alerts'] as List<dynamic>? ?? const [];
          final playbooksRaw = raw['playbooks'] as List<dynamic>? ?? const [];
          return ApiSuccess(
            AiIncidentPlaybookBundle(
              alerts: alertsRaw.map((e) {
                final m = e as Map<String, dynamic>;
                return AiObservabilityAlert(
                  code: m['code']?.toString() ?? '',
                  level: m['level']?.toString() ?? 'info',
                  value: (m['value'] as num?)?.toDouble() ?? 0,
                  threshold: (m['threshold'] as num?)?.toDouble() ?? 0,
                  message: m['message']?.toString() ?? '',
                );
              }).toList(),
              playbooks: playbooksRaw.map((e) {
                final m = e as Map<String, dynamic>;
                return AiIncidentPlaybook(
                  id: m['id']?.toString() ?? '',
                  title: m['title']?.toString() ?? '',
                  actions: (m['actions'] as List<dynamic>? ?? const [])
                      .map((x) => x.toString())
                      .toList(),
                  runbookUrl: m['runbook_url']?.toString(),
                );
              }).toList(),
            ),
          );
        } catch (e) {
          return ApiFailure<AiIncidentPlaybookBundle>(
            'Could not parse playbooks response: $e',
          );
        }
      }(),
    };
  }

  Future<ApiResult<AiRemediationResult>> applyRemediation({
    required String actionId,
    bool dryRun = false,
  }) async {
    if (!ApiConfig.useApi) {
      return ApiSuccess(
        AiRemediationResult(
          actionId: actionId,
          dryRun: dryRun,
          before: const {},
          after: const {},
        ),
      );
    }

    final result = await ApiClient.post(
      'ai/remediation/apply',
      body: {'action_id': actionId, 'dry_run': dryRun},
    );
    return switch (result) {
      ApiFailure(:final message, :final statusCode) => ApiFailure(
        message,
        statusCode: statusCode,
      ),
      ApiSuccess(:final data) => () {
        try {
          final map = jsonDecode(data.body) as Map<String, dynamic>;
          final raw = map['data'] as Map<String, dynamic>? ?? map;
          return ApiSuccess(
            AiRemediationResult(
              actionId: raw['action_id']?.toString() ?? actionId,
              dryRun: raw['dry_run'] == true,
              before: raw['before'] as Map<String, dynamic>? ?? const {},
              after: raw['after'] as Map<String, dynamic>? ?? const {},
            ),
          );
        } catch (e) {
          return ApiFailure<AiRemediationResult>(
            'Could not parse remediation response: $e',
          );
        }
      }(),
    };
  }

  Future<ApiResult<Map<String, dynamic>>> autoRemediate({
    int days = 14,
    bool dryRun = true,
  }) async {
    if (!ApiConfig.useApi) {
      return const ApiSuccess({});
    }

    final result = await ApiClient.post(
      'ai/remediation/auto',
      body: {'days': days, 'dry_run': dryRun},
    );
    return switch (result) {
      ApiFailure(:final message, :final statusCode) => ApiFailure(
        message,
        statusCode: statusCode,
      ),
      ApiSuccess(:final data) => () {
        try {
          final map = jsonDecode(data.body) as Map<String, dynamic>;
          final raw = map['data'] as Map<String, dynamic>? ?? map;
          return ApiSuccess(raw);
        } catch (e) {
          return ApiFailure<Map<String, dynamic>>(
            'Could not parse auto-remediation response: $e',
          );
        }
      }(),
    };
  }

  Future<ApiResult<Map<String, dynamic>>> getSloReport() async {
    if (!ApiConfig.useApi) {
      return const ApiSuccess({
        'slo_target_success_rate': 99.5,
        'error_budget_percent': 0.5,
        'burn_rate_threshold': 2.0,
        'windows': {
          'last_1h': {'burn_rate': 1.2},
          'last_24h': {'burn_rate': 0.8},
        },
        'alerts': [],
      });
    }
    final result = await ApiClient.get('ai/slo');
    return switch (result) {
      ApiFailure(:final message, :final statusCode) => ApiFailure(
        message,
        statusCode: statusCode,
      ),
      ApiSuccess(:final data) => () {
        try {
          final map = jsonDecode(data.body) as Map<String, dynamic>;
          return ApiSuccess(map['data'] as Map<String, dynamic>? ?? map);
        } catch (e) {
          return ApiFailure<Map<String, dynamic>>(
            'Could not parse SLO response: $e',
          );
        }
      }(),
    };
  }

  Future<ApiResult<Map<String, dynamic>>> getCostAnomalies({
    int days = 35,
  }) async {
    if (!ApiConfig.useApi) {
      return const ApiSuccess({
        'daily': {'is_anomaly': false},
        'weekly': {'is_anomaly': false},
        'recommendations': [],
      });
    }
    final result = await ApiClient.get('ai/cost-anomalies?days=$days');
    return switch (result) {
      ApiFailure(:final message, :final statusCode) => ApiFailure(
        message,
        statusCode: statusCode,
      ),
      ApiSuccess(:final data) => () {
        try {
          final map = jsonDecode(data.body) as Map<String, dynamic>;
          return ApiSuccess(map['data'] as Map<String, dynamic>? ?? map);
        } catch (e) {
          return ApiFailure<Map<String, dynamic>>(
            'Could not parse cost anomaly response: $e',
          );
        }
      }(),
    };
  }

  Future<ApiResult<Map<String, dynamic>>> dispatchEscalation({
    required String alertCode,
    String severity = 'warning',
    List<String>? channels,
    bool dryRun = true,
  }) async {
    if (!ApiConfig.useApi) {
      return ApiSuccess({
        'alert_code': alertCode,
        'severity': severity,
        'channels': channels ?? const ['in_app'],
        'dry_run': dryRun,
      });
    }
    final body = <String, dynamic>{
      'alert_code': alertCode,
      'severity': severity,
      'dry_run': dryRun,
    };
    if (channels != null) {
      body['channels'] = channels;
    }
    final result = await ApiClient.post('ai/escalation/dispatch', body: body);
    return switch (result) {
      ApiFailure(:final message, :final statusCode) => ApiFailure(
        message,
        statusCode: statusCode,
      ),
      ApiSuccess(:final data) => () {
        try {
          final map = jsonDecode(data.body) as Map<String, dynamic>;
          return ApiSuccess(map['data'] as Map<String, dynamic>? ?? map);
        } catch (e) {
          return ApiFailure<Map<String, dynamic>>(
            'Could not parse escalation dispatch response: $e',
          );
        }
      }(),
    };
  }

  Future<ApiResult<Map<String, dynamic>>> getAuditTrail({int limit = 80}) async {
    if (!ApiConfig.useApi) {
      return const ApiSuccess({'total': 0, 'timeline': []});
    }
    final result = await ApiClient.get('ai/audit?limit=$limit');
    return switch (result) {
      ApiFailure(:final message, :final statusCode) => ApiFailure(
        message,
        statusCode: statusCode,
      ),
      ApiSuccess(:final data) => () {
        try {
          final map = jsonDecode(data.body) as Map<String, dynamic>;
          return ApiSuccess(map['data'] as Map<String, dynamic>? ?? map);
        } catch (e) {
          return ApiFailure<Map<String, dynamic>>(
            'Could not parse audit response: $e',
          );
        }
      }(),
    };
  }

  Future<ApiResult<Map<String, dynamic>>> getEscalationRunbooks() async {
    if (!ApiConfig.useApi) {
      return const ApiSuccess({
        'runbook_links': {'default': 'https://runbooks.example.com/ai/general'},
        'silence_windows': [],
        'digest': {'enabled': true, 'window_minutes': 60},
      });
    }
    final result = await ApiClient.get('ai/escalation/runbooks');
    return switch (result) {
      ApiFailure(:final message, :final statusCode) => ApiFailure(
        message,
        statusCode: statusCode,
      ),
      ApiSuccess(:final data) => () {
        try {
          final map = jsonDecode(data.body) as Map<String, dynamic>;
          return ApiSuccess(map['data'] as Map<String, dynamic>? ?? map);
        } catch (e) {
          return ApiFailure<Map<String, dynamic>>(
            'Could not parse runbooks response: $e',
          );
        }
      }(),
    };
  }

  Future<ApiResult<Map<String, dynamic>>> runEscalationDigest({
    int? windowMinutes,
    bool queue = true,
    bool dryRun = false,
  }) async {
    if (!ApiConfig.useApi) {
      return const ApiSuccess({'queued': false, 'window_minutes': 60});
    }
    final result = await ApiClient.post(
      'ai/escalation/digest',
      body: {
        'window_minutes':? windowMinutes,
        'queue': queue,
        'dry_run': dryRun,
      },
    );
    return switch (result) {
      ApiFailure(:final message, :final statusCode) => ApiFailure(
        message,
        statusCode: statusCode,
      ),
      ApiSuccess(:final data) => () {
        try {
          final map = jsonDecode(data.body) as Map<String, dynamic>;
          return ApiSuccess(map['data'] as Map<String, dynamic>? ?? map);
        } catch (e) {
          return ApiFailure<Map<String, dynamic>>(
            'Could not parse digest response: $e',
          );
        }
      }(),
    };
  }

  Future<ApiResult<Map<String, dynamic>>> getEscalationNotifications({
    int limit = 50,
  }) async {
    if (!ApiConfig.useApi) {
      return const ApiSuccess({
        'status_counts': {'queued': 0, 'sent': 0, 'failed': 0, 'suppressed': 0},
        'items': [],
      });
    }
    final result = await ApiClient.get('ai/escalation/notifications?limit=$limit');
    return switch (result) {
      ApiFailure(:final message, :final statusCode) => ApiFailure(
        message,
        statusCode: statusCode,
      ),
      ApiSuccess(:final data) => () {
        try {
          final map = jsonDecode(data.body) as Map<String, dynamic>;
          return ApiSuccess(map['data'] as Map<String, dynamic>? ?? map);
        } catch (e) {
          return ApiFailure<Map<String, dynamic>>(
            'Could not parse escalation notifications response: $e',
          );
        }
      }(),
    };
  }

  Future<ApiResult<Map<String, dynamic>>> getQueueHealthEvents({
    int limit = 30,
    int windowMinutes = 1440,
  }) async {
    if (!ApiConfig.useApi) {
      return const ApiSuccess({
        'window_minutes': 1440,
        'totals': {'alerts': 0, 'critical': 0, 'warning': 0},
        'latest': [],
      });
    }
    final result = await ApiClient.get(
      'ai/queue-health-events?limit=$limit&window_minutes=$windowMinutes',
    );
    return switch (result) {
      ApiFailure(:final message, :final statusCode) => ApiFailure(
        message,
        statusCode: statusCode,
      ),
      ApiSuccess(:final data) => () {
        try {
          final map = jsonDecode(data.body) as Map<String, dynamic>;
          return ApiSuccess(map['data'] as Map<String, dynamic>? ?? map);
        } catch (e) {
          return ApiFailure<Map<String, dynamic>>(
            'Could not parse queue health events response: $e',
          );
        }
      }(),
    };
  }
}
