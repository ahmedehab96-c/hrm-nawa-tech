import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hrm_saas/core/api/api_result.dart';
import 'package:hrm_saas/features/employee/profile/data/employees_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('EmployeesRepository demo fallback', () {
    test('getMyEmployee returns demo employee when API is disabled', () async {
      final result = await EmployeesRepository.getMyEmployee();
      expect(result, isA<ApiSuccess<EmployeeItem>>());
      final employee = (result as ApiSuccess<EmployeeItem>).data;
      expect(employee.name, 'Mohamed Ahmed');
      expect(employee.email, 'emp01@demo.com');
    });
  });
}
