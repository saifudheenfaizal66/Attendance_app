part of 'weekly_status_bloc.dart';

abstract class WeeklyStatusState {}

class WeeklyStatusInitial extends WeeklyStatusState {}

class WeeklyStatusLoading extends WeeklyStatusState {}

class WeeklyStatusLoaded extends WeeklyStatusState {
  final List<Attendance> weeklyAttendance;

  WeeklyStatusLoaded(this.weeklyAttendance);
}

class WeeklyStatusFailure extends WeeklyStatusState {
  final String error;

  WeeklyStatusFailure(this.error);
}
