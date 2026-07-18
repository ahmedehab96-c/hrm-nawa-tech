/// أدوار المستخدم في الـ API (Laravel): `company_admin`، `employee`، إلخ.
abstract final class UserRole {
  static const String employee = 'employee';
  static const String companyAdmin = 'company_admin';
  static const String superAdmin = 'super_admin';

  static bool isEmployeeRole(String? role) => role == employee;
  static bool isSuperAdmin(String? role) => role == superAdmin;
  static bool isCompanyAdmin(String? role) => role == companyAdmin;
}
