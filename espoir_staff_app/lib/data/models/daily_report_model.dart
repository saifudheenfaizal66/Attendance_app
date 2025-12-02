import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:espoir_staff_app/domain/entities/daily_report.dart';

class DailyReportModel extends DailyReport {
  const DailyReportModel({
    required super.id,
    required super.userId,
    required super.userName,
    required super.date,
    required super.tasksCompleted,
    required super.createdAt,
  });

  factory DailyReportModel.fromJson(Map<String, dynamic> json) {
    return DailyReportModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      date: (json['date'] as Timestamp).toDate(),
      tasksCompleted: json['tasksCompleted'] as String,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'date': Timestamp.fromDate(date),
      'tasksCompleted': tasksCompleted,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory DailyReportModel.fromEntity(DailyReport report) {
    return DailyReportModel(
      id: report.id,
      userId: report.userId,
      userName: report.userName,
      date: report.date,
      tasksCompleted: report.tasksCompleted,
      createdAt: report.createdAt,
    );
  }
}
