import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hrm_saas/features/employee/attendance/data/attendance_repository.dart';
import 'package:hrm_saas/core/api/api_result.dart';

void main() {
  group('AttendanceRecord', () {
    test('default status is present', () {
      final r = AttendanceRecord(employeeId: '1', employeeName: 'Ahmed');
      expect(r.status, 'present');
    });

    test('all fields assigned correctly', () {
      final r = AttendanceRecord(
        id: '42',
        employeeId: '5',
        employeeName: 'Sara',
        checkIn: '08:00',
        checkOut: '17:00',
        status: 'late',
        workDate: '2025-03-01',
      );
      expect(r.id, '42');
      expect(r.checkIn, '08:00');
      expect(r.checkOut, '17:00');
      expect(r.workDate, '2025-03-01');
    });

    test('id can be null (absent employee with no record)', () {
      final r = AttendanceRecord(employeeId: '3', employeeName: 'Khaled', status: 'absent');
      expect(r.id, isNull);
    });
  });

  group('AttendanceRepository demo data', () {
    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
    });

    test('getDailyAttendance returns demo records when API disabled', () async {
      final result = await AttendanceRepository.getDailyAttendance();
      expect(result, isA<ApiSuccess<List<AttendanceRecord>>>());
      final records = (result as ApiSuccess<List<AttendanceRecord>>).data;
      expect(records, hasLength(4));
    });

    test('demo data has expected statuses', () async {
      final result = await AttendanceRepository.getDailyAttendance();
      final records = (result as ApiSuccess<List<AttendanceRecord>>).data;
      final statuses = records.map((r) => r.status).toSet();
      expect(statuses, contains('present'));
      expect(statuses, contains('absent'));
      expect(statuses, contains('late'));
    });

    test('demo data includes employee names', () async {
      final result = await AttendanceRepository.getDailyAttendance();
      final records = (result as ApiSuccess<List<AttendanceRecord>>).data;
      expect(records.every((r) => r.employeeName.isNotEmpty), isTrue);
    });
  });
}
