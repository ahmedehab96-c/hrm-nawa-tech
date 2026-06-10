import 'package:flutter_test/flutter_test.dart';
import 'package:hrm_saas/core/utils/leave_status_util.dart';

void main() {
  group('isPendingLeaveStatus', () {
    test('returns true for English pending variants', () {
      expect(isPendingLeaveStatus('pending'), isTrue);
      expect(isPendingLeaveStatus('Pending'), isTrue);
      expect(isPendingLeaveStatus('PENDING'), isTrue);
    });

    test('returns true for Arabic pending', () {
      expect(isPendingLeaveStatus('معلقة'), isTrue);
    });

    test('returns false for approved/rejected', () {
      expect(isPendingLeaveStatus('approved'), isFalse);
      expect(isPendingLeaveStatus('rejected'), isFalse);
      expect(isPendingLeaveStatus('موافق عليها'), isFalse);
    });
  });

  group('isApprovedLeaveStatus', () {
    test('returns true for English approved variants', () {
      expect(isApprovedLeaveStatus('approved'), isTrue);
      expect(isApprovedLeaveStatus('Approved'), isTrue);
    });

    test('returns true for Arabic approved', () {
      expect(isApprovedLeaveStatus('موافق عليها'), isTrue);
      expect(isApprovedLeaveStatus('موافقة'), isTrue);
    });

    test('returns false for pending/rejected', () {
      expect(isApprovedLeaveStatus('pending'), isFalse);
      expect(isApprovedLeaveStatus('rejected'), isFalse);
    });
  });
}
