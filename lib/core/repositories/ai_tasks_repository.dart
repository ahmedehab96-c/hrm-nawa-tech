import 'dart:convert';

import '../api/api_client.dart';
import '../api/api_config.dart';
import '../api/api_result.dart';

class AiTaskStatus {
  AiTaskStatus({
    required this.id,
    required this.taskType,
    required this.status,
    required this.progressPercent,
    this.result,
    this.errorMessage,
  });

  final String id;
  final String taskType;
  final String status;
  final int progressPercent;
  final Map<String, dynamic>? result;
  final String? errorMessage;

  bool get isCompleted => status == 'completed';
  bool get isFailed => status == 'failed';
}

class AiTasksRepository {
  AiTasksRepository._();
  static final instance = AiTasksRepository._();

  Future<ApiResult<AiTaskStatus>> getTaskStatus(String taskId) async {
    if (!ApiConfig.useApi) {
      return ApiSuccess(
        AiTaskStatus(
          id: 'demo',
          taskType: 'demo',
          status: 'completed',
          progressPercent: 100,
          result: const {},
        ),
      );
    }

    final result = await ApiClient.get('ai/tasks/$taskId');
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
            AiTaskStatus(
              id: raw['id']?.toString() ?? taskId,
              taskType: raw['task_type']?.toString() ?? '',
              status: raw['status']?.toString() ?? 'queued',
              progressPercent: (raw['progress_percent'] as num?)?.toInt() ?? 0,
              result: raw['result'] as Map<String, dynamic>?,
              errorMessage: raw['error_message']?.toString(),
            ),
          );
        } catch (e) {
          return ApiFailure<AiTaskStatus>('Could not parse task status: $e');
        }
      }(),
    };
  }
}
