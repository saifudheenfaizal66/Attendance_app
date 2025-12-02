import 'package:equatable/equatable.dart';

class DailyReport extends Equatable {
  final String id;
  final String userId;
  final String userName;
  final DateTime date;
  final String tasksCompleted;
  final DateTime createdAt;

  const DailyReport({
    required this.id,
    required this.userId,
    required this.userName,
    required this.date,
    required this.tasksCompleted,
    required this.createdAt,
  });

  @override
  List<Object?> get props =>
      [id, userId, userName, date, tasksCompleted, createdAt];
}
