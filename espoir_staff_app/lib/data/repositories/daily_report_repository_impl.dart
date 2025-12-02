import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:espoir_staff_app/data/models/daily_report_model.dart';
import 'package:espoir_staff_app/domain/entities/daily_report.dart';
import 'package:espoir_staff_app/domain/repositories/daily_report_repository.dart';

class DailyReportRepositoryImpl implements DailyReportRepository {
  final FirebaseFirestore _firestore;

  DailyReportRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<void> submitReport(DailyReport report) async {
    final reportModel = DailyReportModel.fromEntity(report);
    await _firestore
        .collection('daily_reports')
        .doc(report.id)
        .set(reportModel.toJson());
  }

  @override
  Future<List<DailyReport>> getUserReports(String userId) async {
    final snapshot = await _firestore
        .collection('daily_reports')
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => DailyReportModel.fromJson(doc.data()))
        .toList();
  }

  @override
  Future<bool> isReportSubmittedToday(String userId) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    final snapshot = await _firestore
        .collection('daily_reports')
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty;
  }
}
