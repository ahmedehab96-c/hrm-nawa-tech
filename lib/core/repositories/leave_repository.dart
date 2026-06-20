import 'dart:convert';

import '../api/api_client.dart';
import '../api/api_config.dart';
import '../api/api_localized.dart';
import '../api/api_result.dart';
import 'employees_repository.dart' show PagedResult;

class LeaveRequestItem {
  LeaveRequestItem({
    required this.id,
    required this.employeeName,
    required this.type,
    required this.from,
    required this.to,
    required this.days,
    this.balance,
    required this.status,
  });

  final String id;
  final String employeeName;
  final String type;
  final String from;
  final String to;
  final String days;
  final String? balance;
  final String status;
}

class LeaveBalanceItem {
  LeaveBalanceItem({
    required this.employeeName,
    required this.annual,
    required this.annualTotal,
    required this.sick,
    required this.sickTotal,
    required this.emergency,
    required this.emergencyTotal,
  });

  final String employeeName;
  final String annual;
  final String annualTotal;
  final String sick;
  final String sickTotal;
  final String emergency;
  final String emergencyTotal;
}

class LeaveRecommendation {
  LeaveRecommendation({
    required this.recommendedAction,
    required this.confidenceScore,
    required this.reason,
    this.remainingBalance,
  });

  final String recommendedAction;
  final int confidenceScore;
  final String reason;
  final double? remainingBalance;
}

class LeaveRepository {
  static LeaveRequestItem _fromMap(Map<String, dynamic> m) => LeaveRequestItem(
        id: m['id']?.toString() ?? '',
        employeeName: m['employee_name']?.toString() ?? m['name']?.toString() ?? '',
        type: m['type']?.toString() ?? 'annual',
        from: m['from']?.toString() ?? m['start_date']?.toString() ?? '',
        to: m['to']?.toString() ?? m['end_date']?.toString() ?? '',
        days: m['days']?.toString() ?? '0',
        balance: m['balance']?.toString(),
        status: m['status']?.toString() ?? 'pending',
      );

  static Future<ApiResult<PagedResult<LeaveRequestItem>>> getLeaveRequestsPaged({
    int page = 1,
    int perPage = 15,
    String? status,
  }) async {
    await ApiConfig.load();
    if (ApiConfig.useApi && ApiConfig.baseUrl != null && ApiConfig.baseUrl!.isNotEmpty) {
      final params = StringBuffer('leave-requests?page=$page&per_page=$perPage');
      if (status != null && status.isNotEmpty) params.write('&status=$status');

      final res = await ApiClient.get(params.toString());
      if (res is ApiFailure<dynamic>) {
        return ApiFailure((res as ApiFailure<dynamic>).message, statusCode: (res as ApiFailure<dynamic>).statusCode);
      }
      try {
        final decoded = jsonDecode((res as ApiSuccess).data.body) as Map<String, dynamic>;
        final list = decoded['data'] as List<dynamic>? ?? [];
        final meta = decoded['meta'] as Map<String, dynamic>? ?? {};
        final items = list.map((e) => _fromMap(e as Map<String, dynamic>)).toList();
        return ApiSuccess(PagedResult(
          items: items,
          currentPage: (meta['current_page'] as num?)?.toInt() ?? 1,
          lastPage: (meta['last_page'] as num?)?.toInt() ?? 1,
          total: (meta['total'] as num?)?.toInt() ?? items.length,
        ));
      } catch (e) {
        return ApiFailure(ApiLocalized.strings.apiErrorLeaveRequests(e.toString()));
      }
    }
    // Demo data
    return ApiSuccess(PagedResult(
      items: [
        LeaveRequestItem(id: '1', employeeName: 'محمد أحمد', type: 'annual',    from: '2025-02-07', to: '2025-02-10', days: '4', balance: '16', status: 'pending'),
        LeaveRequestItem(id: '2', employeeName: 'سارة علي',  type: 'emergency', from: '2025-02-15', to: '2025-02-15', days: '1', balance: '2',  status: 'pending'),
        LeaveRequestItem(id: '3', employeeName: 'خالد حسن',  type: 'sick',      from: '2025-02-20', to: '2025-02-22', days: '3', balance: '12', status: 'approved'),
      ],
      currentPage: 1, lastPage: 1, total: 3,
    ));
  }

  /// للتوافق مع باقي الكود
  static Future<ApiResult<List<LeaveRequestItem>>> getLeaveRequests() async {
    final res = await getLeaveRequestsPaged(page: 1, perPage: 100);
    return switch (res) {
      ApiFailure(:final message, :final statusCode) => ApiFailure(message, statusCode: statusCode),
      ApiSuccess(:final data) => ApiSuccess(data.items),
    };
  }

  static Future<ApiResult<List<LeaveBalanceItem>>> getLeaveBalances() async {
    await ApiConfig.load();
    if (ApiConfig.useApi && ApiConfig.baseUrl != null && ApiConfig.baseUrl!.isNotEmpty) {
      final res = await ApiClient.get('leave-balances');
      if (res is ApiFailure<dynamic>) return ApiFailure((res as ApiFailure<dynamic>).message, statusCode: (res as ApiFailure<dynamic>).statusCode);
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
          return LeaveBalanceItem(
            employeeName: m['employee_name']?.toString() ?? m['name']?.toString() ?? '',
            annual: m['annual']?.toString() ?? '0',
            annualTotal: m['annual_total']?.toString() ?? m['annualTotal']?.toString() ?? '0',
            sick: m['sick']?.toString() ?? '0',
            sickTotal: m['sick_total']?.toString() ?? m['sickTotal']?.toString() ?? '0',
            emergency: m['emergency']?.toString() ?? '0',
            emergencyTotal: m['emergency_total']?.toString() ?? m['emergencyTotal']?.toString() ?? '0',
          );
        }).toList();
        return ApiSuccess(items);
      } catch (e) {
        return ApiFailure(ApiLocalized.strings.apiErrorLeaveBalances(e.toString()));
      }
    }
    return ApiSuccess([
      LeaveBalanceItem(
        employeeName: 'محمد أحمد',
        annual: '20',
        annualTotal: '21',
        sick: '10',
        sickTotal: '10',
        emergency: '5',
        emergencyTotal: '5',
      ),
      LeaveBalanceItem(
        employeeName: 'سارة علي',
        annual: '21',
        annualTotal: '21',
        sick: '10',
        sickTotal: '10',
        emergency: '2',
        emergencyTotal: '5',
      ),
    ]);
  }

  static Future<ApiResult<void>> approveLeave(String id) async {
    await ApiConfig.load();
    if (ApiConfig.useApi && ApiConfig.baseUrl != null && ApiConfig.baseUrl!.isNotEmpty) {
      final res = await ApiClient.post('leave-requests/$id/approve');
      if (res is ApiFailure<dynamic>) return ApiFailure((res as ApiFailure<dynamic>).message, statusCode: (res as ApiFailure<dynamic>).statusCode);
      return const ApiSuccess(null);
    }
    return const ApiSuccess(null);
  }

  static Future<ApiResult<void>> rejectLeave(String id) async {
    await ApiConfig.load();
    if (ApiConfig.useApi && ApiConfig.baseUrl != null && ApiConfig.baseUrl!.isNotEmpty) {
      final res = await ApiClient.post('leave-requests/$id/reject');
      if (res is ApiFailure<dynamic>) return ApiFailure((res as ApiFailure<dynamic>).message, statusCode: (res as ApiFailure<dynamic>).statusCode);
      return const ApiSuccess(null);
    }
    return const ApiSuccess(null);
  }

  /// طلب إجازة من الموظف — POST `leave-requests`
  static Future<ApiResult<void>> createLeaveRequest(Map<String, dynamic> body) async {
    await ApiConfig.load();
    if (ApiConfig.useApi && ApiConfig.baseUrl != null && ApiConfig.baseUrl!.isNotEmpty) {
      final res = await ApiClient.post('leave-requests', body: body);
      if (res is ApiFailure<dynamic>) {
        return ApiFailure((res as ApiFailure<dynamic>).message, statusCode: (res as ApiFailure<dynamic>).statusCode);
      }
      return const ApiSuccess(null);
    }
    return const ApiSuccess(null);
  }

  static Future<ApiResult<LeaveRecommendation>> getRecommendation(String leaveRequestId) async {
    await ApiConfig.load();
    if (ApiConfig.useApi && ApiConfig.baseUrl != null && ApiConfig.baseUrl!.isNotEmpty) {
      final res = await ApiClient.post('leave-requests/$leaveRequestId/recommendation');
      if (res is ApiFailure<dynamic>) {
        return ApiFailure((res as ApiFailure<dynamic>).message, statusCode: (res as ApiFailure<dynamic>).statusCode);
      }
      try {
        final decoded = jsonDecode((res as ApiSuccess).data.body) as Map<String, dynamic>;
        final data = decoded['data'] as Map<String, dynamic>? ?? decoded;
        return ApiSuccess(LeaveRecommendation(
          recommendedAction: data['recommended_action']?.toString() ?? 'review',
          confidenceScore: (data['confidence_score'] as num?)?.toInt() ?? 50,
          reason: data['reason']?.toString() ?? '',
          remainingBalance: (data['remaining_balance'] as num?)?.toDouble(),
        ));
      } catch (e) {
        return ApiFailure('Could not parse leave recommendation: $e');
      }
    }

    return ApiSuccess(LeaveRecommendation(
      recommendedAction: 'approve',
      confidenceScore: 72,
      reason: 'Requested days are within remaining balance.',
      remainingBalance: 8,
    ));
  }
}
