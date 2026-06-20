import 'dart:convert';

import '../api/api_client.dart';
import '../api/api_config.dart';
import '../api/api_result.dart';

class AiChatReply {
  AiChatReply({
    required this.reply,
    required this.conversationId,
    this.provider,
    this.model,
    this.latencyMs,
    this.status,
  });

  final String reply;
  final String conversationId;
  final String? provider;
  final String? model;
  final int? latencyMs;
  final String? status;

  factory AiChatReply.fromJson(Map<String, dynamic> json) => AiChatReply(
        reply: json['reply']?.toString() ?? '',
        conversationId: json['conversation_id']?.toString() ?? '',
        provider: json['provider']?.toString(),
        model: json['model']?.toString(),
        latencyMs: (json['latency_ms'] as num?)?.toInt(),
        status: json['status']?.toString(),
      );
}

class AiRepository {
  AiRepository._();
  static final instance = AiRepository._();

  Future<ApiResult<AiChatReply>> chat({
    required String message,
    required String languageCode,
    String? conversationId,
  }) async {
    if (!ApiConfig.useApi) {
      return const ApiFailure('API is disabled');
    }

    final body = <String, dynamic>{
      'message': message,
      'language_code': languageCode,
      if (conversationId != null && conversationId.isNotEmpty)
        'conversation_id': int.tryParse(conversationId),
    };

    final result = await ApiClient.post('ai/chat', body: body);
    return switch (result) {
      ApiFailure(:final message, :final statusCode) =>
        ApiFailure(message, statusCode: statusCode),
      ApiSuccess(:final data) => () {
          try {
            final map = jsonDecode(data.body) as Map<String, dynamic>;
            final raw = map['data'] as Map<String, dynamic>? ?? map;
            return ApiSuccess(AiChatReply.fromJson(raw));
          } catch (e) {
            return ApiFailure<AiChatReply>('Could not parse AI chat response: $e');
          }
        }(),
    };
  }
}
