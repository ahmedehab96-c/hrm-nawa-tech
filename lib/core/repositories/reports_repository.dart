import 'dart:convert';

import '../api/api_client.dart';
import '../api/api_config.dart';
import '../api/api_result.dart';

class ReportSummaryResult {
  ReportSummaryResult({
    required this.id,
    required this.metrics,
    required this.narrative,
    this.provider,
    this.model,
    this.status,
  });

  final String id;
  final Map<String, dynamic> metrics;
  final String narrative;
  final String? provider;
  final String? model;
  final String? status;
}

class ReportsRepository {
  ReportsRepository._();
  static final instance = ReportsRepository._();

  Future<ApiResult<ReportSummaryResult>> generateSummary({
    required String periodStart,
    required String periodEnd,
    required String languageCode,
    String reportType = 'hr_overview',
  }) async {
    if (!ApiConfig.useApi) {
      return ApiSuccess(
        ReportSummaryResult(
          id: 'demo',
          metrics: {},
          narrative: 'Demo narrative summary.',
          status: 'success',
        ),
      );
    }

    final result = await ApiClient.post(
      'reports/summaries',
      body: {
        'period_start': periodStart,
        'period_end': periodEnd,
        'report_type': reportType,
        'language_code': languageCode,
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
          return ApiSuccess(
            ReportSummaryResult(
              id: raw['id']?.toString() ?? '',
              metrics: (raw['metrics'] as Map<String, dynamic>? ?? const {}),
              narrative: raw['narrative']?.toString() ?? '',
              provider: raw['provider']?.toString(),
              model: raw['model']?.toString(),
              status: raw['status']?.toString(),
            ),
          );
        } catch (e) {
          return ApiFailure<ReportSummaryResult>(
            'Could not parse report summary: $e',
          );
        }
      }(),
    };
  }

  Future<ApiResult<String>> queueSummary({
    required String periodStart,
    required String periodEnd,
    required String languageCode,
    String reportType = 'hr_overview',
  }) async {
    if (!ApiConfig.useApi) {
      return const ApiSuccess('demo-task-report');
    }

    final result = await ApiClient.post(
      'reports/summaries/queue',
      body: {
        'period_start': periodStart,
        'period_end': periodEnd,
        'report_type': reportType,
        'language_code': languageCode,
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
          return ApiSuccess(raw['task_id']?.toString() ?? '');
        } catch (e) {
          return ApiFailure<String>('Could not parse queued report task: $e');
        }
      }(),
    };
  }
}
