import 'package:espoir_staff_app/domain/entities/daily_report.dart';

abstract class DailyReportRepository {
  Future<void> submitReport(DailyReport report);
  Future<List<DailyReport>> getUserReports(String userId);
  Future<bool> isReportSubmittedToday(String userId);
}
