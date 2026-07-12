class PlatformOverview {
  const PlatformOverview({
    required this.companies,
    required this.users,
    required this.employees,
    required this.trialsActive,
    required this.trialsExpired,
  });

  final int companies;
  final int users;
  final int employees;
  final int trialsActive;
  final int trialsExpired;

  factory PlatformOverview.fromJson(Map<String, dynamic> json) {
    return PlatformOverview(
      companies: (json['companies'] as num?)?.toInt() ?? 0,
      users: (json['users'] as num?)?.toInt() ?? 0,
      employees: (json['employees'] as num?)?.toInt() ?? 0,
      trialsActive: (json['trials_active'] as num?)?.toInt() ?? 0,
      trialsExpired: (json['trials_expired'] as num?)?.toInt() ?? 0,
    );
  }
}

class PlatformCompany {
  const PlatformCompany({
    required this.id,
    required this.name,
    this.email,
    required this.status,
    required this.plan,
    this.trialEndsAt,
    this.employeeCount,
    this.employeeLimit,
    this.createdAt,
  });

  final String id;
  final String name;
  final String? email;
  final String status;
  final String plan;
  final String? trialEndsAt;
  final int? employeeCount;
  final int? employeeLimit;
  final String? createdAt;

  bool get isSuspended => status == 'suspended';

  factory PlatformCompany.fromJson(Map<String, dynamic> json) {
    return PlatformCompany(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString(),
      status: json['status']?.toString() ?? 'active',
      plan: json['plan']?.toString() ?? 'trial',
      trialEndsAt: json['trial_ends_at']?.toString(),
      employeeCount: (json['employee_count'] as num?)?.toInt(),
      employeeLimit: (json['employee_limit'] as num?)?.toInt(),
      createdAt: json['created_at']?.toString(),
    );
  }
}
