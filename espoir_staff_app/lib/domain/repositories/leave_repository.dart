import 'package:espoir_staff_app/domain/entities/leave.dart';

abstract class LeaveRepository {
  Future<void> applyLeave(Leave leave);
  Stream<List<Leave>> getLeaves(String userId);
  Future<void> cancelLeave(String leaveId);
  Future<int> calculateLeaveDays(DateTime from, DateTime to);
}
