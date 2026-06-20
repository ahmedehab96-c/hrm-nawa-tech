import 'dart:convert';

import '../api/api_client.dart';
import '../api/api_config.dart';
import '../api/api_result.dart';

class PerformanceReviewItem {
  PerformanceReviewItem({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.periodLabel,
    this.department,
    this.position,
    this.rating,
    this.goalsSummary,
    this.strengths,
    this.improvementAreas,
    this.managerComment,
    this.aiSummary,
  });

  final String id;
  final String employeeId;
  final String employeeName;
  final String periodLabel;
  final String? department;
  final String? position;
  final int? rating;
  final String? goalsSummary;
  final String? strengths;
  final String? improvementAreas;
  final String? managerComment;
  final String? aiSummary;

  factory PerformanceReviewItem.fromJson(Map<String, dynamic> json) {
    return PerformanceReviewItem(
      id: json['id']?.toString() ?? '',
      employeeId: json['employee_id']?.toString() ?? '',
      employeeName: json['employee_name']?.toString() ?? '',
      periodLabel: json['period_label']?.toString() ?? '',
      department: json['department']?.toString(),
      position: json['position']?.toString(),
      rating: (json['rating'] as num?)?.toInt(),
      goalsSummary: json['goals_summary']?.toString(),
      strengths: json['strengths']?.toString(),
      improvementAreas: json['improvement_areas']?.toString(),
      managerComment: json['manager_comment']?.toString(),
      aiSummary: json['ai_summary']?.toString(),
    );
  }
}

class PerformanceAnalysisResult {
  PerformanceAnalysisResult({
    required this.reviewId,
    required this.aiSummary,
    this.provider,
    this.model,
    this.status,
  });

  final String reviewId;
  final String aiSummary;
  final String? provider;
  final String? model;
  final String? status;
}

class PerformanceRepository {
  PerformanceRepository._();
  static final instance = PerformanceRepository._();

  Future<ApiResult<List<PerformanceReviewItem>>> getReviews({
    String? period,
  }) async {
    if (!ApiConfig.useApi) {
      return const ApiSuccess([]);
    }
    final path = period != null && period.isNotEmpty
        ? 'performance/reviews?period=${Uri.encodeComponent(period)}'
        : 'performance/reviews';
    final result = await ApiClient.get(path);
    return switch (result) {
      ApiFailure(:final message, :final statusCode) => ApiFailure(
        message,
        statusCode: statusCode,
      ),
      ApiSuccess(:final data) => () {
        try {
          final map = jsonDecode(data.body) as Map<String, dynamic>;
          final list = (map['data'] as List<dynamic>? ?? const []);
          return ApiSuccess(
            list
                .map(
                  (e) =>
                      PerformanceReviewItem.fromJson(e as Map<String, dynamic>),
                )
                .toList(),
          );
        } catch (e) {
          return ApiFailure<List<PerformanceReviewItem>>(
            'Could not parse performance reviews: $e',
          );
        }
      }(),
    };
  }

  Future<ApiResult<String>> saveReview({
    required String employeeId,
    required String periodLabel,
    int? rating,
    String? goalsSummary,
    String? strengths,
    String? improvementAreas,
    String? managerComment,
  }) async {
    if (!ApiConfig.useApi) {
      return const ApiSuccess('demo-review-id');
    }
    final result = await ApiClient.post(
      'performance/reviews',
      body: {
        'employee_id': int.tryParse(employeeId) ?? employeeId,
        'period_label': periodLabel,
        'rating': rating,
        'goals_summary': goalsSummary,
        'strengths': strengths,
        'improvement_areas': improvementAreas,
        'manager_comment': managerComment,
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
          return ApiSuccess(map['id']?.toString() ?? '');
        } catch (_) {
          return const ApiSuccess('');
        }
      }(),
    };
  }

  Future<ApiResult<PerformanceAnalysisResult>> analyzeReview(
    String reviewId, {
    required String languageCode,
  }) async {
    if (!ApiConfig.useApi) {
      return ApiSuccess(
        PerformanceAnalysisResult(
          reviewId: 'demo',
          aiSummary: 'Demo AI summary',
          status: 'success',
        ),
      );
    }

    final result = await ApiClient.post(
      'performance/reviews/$reviewId/analyze',
      body: {'language_code': languageCode},
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
            PerformanceAnalysisResult(
              reviewId: raw['review_id']?.toString() ?? reviewId,
              aiSummary: raw['ai_summary']?.toString() ?? '',
              provider: raw['provider']?.toString(),
              model: raw['model']?.toString(),
              status: raw['status']?.toString(),
            ),
          );
        } catch (e) {
          return ApiFailure<PerformanceAnalysisResult>(
            'Could not parse performance analysis: $e',
          );
        }
      }(),
    };
  }

  Future<ApiResult<String>> queueAnalyzeReview(
    String reviewId, {
    required String languageCode,
  }) async {
    if (!ApiConfig.useApi) {
      return const ApiSuccess('demo-task-performance');
    }

    final result = await ApiClient.post(
      'performance/reviews/$reviewId/analyze/queue',
      body: {'language_code': languageCode},
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
          return ApiFailure<String>('Could not parse queued task response: $e');
        }
      }(),
    };
  }
}
