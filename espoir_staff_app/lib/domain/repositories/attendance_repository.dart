import 'package:espoir_staff_app/models/attendance.dart';

abstract class AttendanceRepository {
  Future<void> punchIn(String userId, {bool isLate = false});
  Future<void> punchOut(String userId);
  Future<Map<String, dynamic>> getOfficeConfig();
  Future<void> setOfficeLocation(double lat, double lng, double radius);
  Future<Attendance?> getLatestAttendance(String userId);
  Future<int> getLateCount(String userId);
  Future<List<Attendance>> getWeeklyAttendance(String userId);
  Stream<List<Attendance>> getAttendanceHistory(String userId);
}
