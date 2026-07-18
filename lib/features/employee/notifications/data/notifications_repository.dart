import 'dart:convert';

import 'package:hrm_saas/core/api/api_client.dart';
import 'package:hrm_saas/core/api/api_config.dart';
import 'package:hrm_saas/core/api/api_enabled.dart';
import 'package:hrm_saas/core/api/api_localized.dart';
import 'package:hrm_saas/core/api/api_result.dart';

class EmployeeNotificationItem {
  EmployeeNotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.timeLabel,
    required this.isRead,
    this.category,
  });

  final String id;
  final String title;
  final String body;
  final String timeLabel;
  final bool isRead;
  /// leave | payroll | attendance | policy
  final String? category;

  EmployeeNotificationItem copyWith({bool? isRead}) => EmployeeNotificationItem(
        id: id,
        title: title,
        body: body,
        timeLabel: timeLabel,
        isRead: isRead ?? this.isRead,
        category: category,
      );
}

class NotificationsRepository {
  static Future<ApiResult<List<EmployeeNotificationItem>>> getNotifications() async {
    await ApiConfig.load();
    if (isApiEnabled) {
      final res = await ApiClient.get('notifications');
      if (res is ApiFailure<dynamic>) {
        return ApiFailure(
          (res as ApiFailure<dynamic>).message,
          statusCode: (res as ApiFailure<dynamic>).statusCode,
        );
      }
      try {
        final decoded = jsonDecode((res as ApiSuccess).data.body);
        List<dynamic> list = const [];
        if (decoded is List) {
          list = decoded;
        } else if (decoded is Map && decoded['data'] is List) {
          list = decoded['data'] as List;
        }
        final items = list.map((e) {
          final m = e as Map<String, dynamic>;
          final readAt = m['read_at'];
          return EmployeeNotificationItem(
            id: m['id']?.toString() ?? '',
            title: m['title']?.toString() ?? '',
            body: m['body']?.toString() ?? m['message']?.toString() ?? '',
            timeLabel: m['created_at']?.toString() ?? '',
            isRead: readAt != null && readAt.toString().isNotEmpty,
            category: m['type']?.toString().toLowerCase(),
          );
        }).toList();
        return ApiSuccess(items);
      } catch (e) {
        return ApiFailure(ApiLocalized.strings.apiErrorNotifications(e.toString()));
      }
    }
    return ApiSuccess(_mockItems());
  }

  static Future<ApiResult<void>> markAsRead(String id) async {
    if (!ApiConfig.useApi) return const ApiSuccess(null);
    final res = await ApiClient.patch('notifications/$id/read');
    return switch (res) {
      ApiFailure(:final message, :final statusCode) => ApiFailure(message, statusCode: statusCode),
      ApiSuccess() => const ApiSuccess(null),
    };
  }

  static Future<ApiResult<void>> markAllRead() async {
    if (!ApiConfig.useApi) return const ApiSuccess(null);
    final res = await ApiClient.post('notifications/read-all');
    return switch (res) {
      ApiFailure(:final message, :final statusCode) => ApiFailure(message, statusCode: statusCode),
      ApiSuccess() => const ApiSuccess(null),
    };
  }

  static Future<ApiResult<void>> deleteNotification(String id) async {
    if (!ApiConfig.useApi) return const ApiSuccess(null);
    final res = await ApiClient.delete('notifications/$id');
    return switch (res) {
      ApiFailure(:final message, :final statusCode) => ApiFailure(message, statusCode: statusCode),
      ApiSuccess() => const ApiSuccess(null),
    };
  }

  static List<EmployeeNotificationItem> _mockItems() => [
        EmployeeNotificationItem(
          id: '1',
          title: 'تمت الموافقة على إجازتك',
          body: 'طلب إجازة سنوية من 5 إلى 7 مارس — تمت الموافقة',
          timeLabel: 'منذ ساعتين',
          isRead: false,
          category: 'leave',
        ),
        EmployeeNotificationItem(
          id: '2',
          title: 'قسيمة الراتب جاهزة',
          body: 'يمكنك عرض قسيمة فبراير 2025 من تبويب الرواتب',
          timeLabel: 'أمس',
          isRead: false,
          category: 'payroll',
        ),
        EmployeeNotificationItem(
          id: '3',
          title: 'تذكير حضور',
          body: 'لا تنسَ تسجيل الدخول عند الاتصال بشبكة المكتب',
          timeLabel: 'منذ يوم',
          isRead: true,
          category: 'attendance',
        ),
        EmployeeNotificationItem(
          id: '4',
          title: 'تحديث سياسة الشركة',
          body: 'تم نشر دليل الموظف المحدّث على البوابة الداخلية',
          timeLabel: 'منذ 3 أيام',
          isRead: true,
          category: 'policy',
        ),
      ];
}
