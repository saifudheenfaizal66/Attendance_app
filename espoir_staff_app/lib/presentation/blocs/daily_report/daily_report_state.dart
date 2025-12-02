import 'package:equatable/equatable.dart';
import 'package:espoir_staff_app/domain/entities/daily_report.dart';

abstract class DailyReportState extends Equatable {
  const DailyReportState();

  @override
  List<Object> get props => [];
}

class DailyReportInitial extends DailyReportState {}

class DailyReportLoading extends DailyReportState {}

class DailyReportLoaded extends DailyReportState {
  final List<DailyReport> reports;
  final bool isSubmittedToday;

  const DailyReportLoaded({
    required this.reports,
    this.isSubmittedToday = false,
  });

  @override
  List<Object> get props => [reports, isSubmittedToday];
}

class DailyReportSuccess extends DailyReportState {}

class DailyReportError extends DailyReportState {
  final String message;

  const DailyReportError(this.message);

  @override
  List<Object> get props => [message];
}
