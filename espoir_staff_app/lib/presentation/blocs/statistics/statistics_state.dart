part of 'statistics_bloc.dart';

abstract class StatisticsState {}

class StatisticsInitial extends StatisticsState {}

class StatisticsLoading extends StatisticsState {}

class StatisticsLoaded extends StatisticsState {
  final String attendancePercentage;
  final String remainingDays;
  final String totalLeavesTaken;

  StatisticsLoaded({
    required this.attendancePercentage,
    required this.remainingDays,
    required this.totalLeavesTaken,
  });
}

class StatisticsFailure extends StatisticsState {
  final String error;
  StatisticsFailure(this.error);
}
