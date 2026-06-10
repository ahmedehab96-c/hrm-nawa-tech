/// توافق حالات الإجازة بين العربية والإنجليزية (استجابة Laravel).
bool isPendingLeaveStatus(String status) {
  final s = status.trim().toLowerCase();
  return s == 'pending' || s == 'معلقة' || s.contains('pending');
}

bool isApprovedLeaveStatus(String status) {
  final s = status.trim().toLowerCase();
  return s == 'approved' || s == 'موافق' || s.contains('approved') || s.contains('موافق');
}
