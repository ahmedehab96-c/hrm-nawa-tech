import 'package:flutter_test/flutter_test.dart';
import 'package:hrm_saas/core/api/paged_result.dart';
import 'package:hrm_saas/features/employee/payslip/data/payroll_repository.dart';

void main() {
  group('PayslipItem', () {
    test('all fields assigned correctly', () {
      final item = PayslipItem(
        employeeId: '1',
        employeeName: 'Ahmed',
        baseSalary: '5000',
        allowances: '500',
        deductions: '100',
        netSalary: '5400',
        status: 'processed',
      );
      expect(item.employeeId, '1');
      expect(item.netSalary, '5400');
      expect(item.status, 'processed');
    });
  });

  group('PagedResult', () {
    test('hasMore is true when currentPage < lastPage', () {
      final paged = PagedResult<String>(
        items: ['a', 'b'],
        currentPage: 1,
        lastPage: 3,
        total: 6,
      );
      expect(paged.hasMore, isTrue);
    });

    test('hasMore is false when on last page', () {
      final paged = PagedResult<String>(
        items: ['a'],
        currentPage: 3,
        lastPage: 3,
        total: 3,
      );
      expect(paged.hasMore, isFalse);
    });

    test('single page result', () {
      final paged = PagedResult<int>(items: [1, 2, 3], currentPage: 1, lastPage: 1, total: 3);
      expect(paged.hasMore, isFalse);
      expect(paged.items.length, 3);
    });
  });
}
