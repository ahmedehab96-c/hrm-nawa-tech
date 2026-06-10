/// أدوار المستخدم في الـ API (Laravel): `company_admin`، `employee`، إلخ.
abstract final class UserRole {
  static const String employee = 'employee';
  static const String companyAdmin = 'company_admin';

  static bool isEmployeeRole(String? role) => role == employee;
}

/// سطح تسجيل الدخول: يفرض مطابقة الدور مع الويب أو التطبيق.
enum LoginSurface {
  webAdmin,
  mobileEmployee,
}
