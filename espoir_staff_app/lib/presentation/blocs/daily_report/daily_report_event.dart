import 'package:equatable/equatable.dart';

abstract class DailyReportEvent extends Equatable {
  const DailyReportEvent();

  @override
  List<Object> get props => [];
}

class LoadDailyReportHistory extends DailyReportEvent {
  final String userId;

  const LoadDailyReportHistory(this.userId);

  @override
  List<Object> get props => [userId];
}

class SubmitDailyReport extends DailyReportEvent {
  final String userId;
  final String userName;
  final String tasksCompleted;

  const SubmitDailyReport({
    required this.userId,
    required this.userName,
    required this.tasksCompleted,
  });

  @override
  List<Object> get props => [userId, userName, tasksCompleted];
}

class CheckTodaySubmission extends DailyReportEvent {
  final String userId;

  const CheckTodaySubmission(this.userId);

  @override
  List<Object> get props => [userId];
}
