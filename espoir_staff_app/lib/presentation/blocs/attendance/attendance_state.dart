part of 'attendance_bloc.dart';

abstract class AttendanceState {}

class AttendanceInitial extends AttendanceState {}

class AttendanceLoading extends AttendanceState {}

class AttendanceLoaded extends AttendanceState {
  final double? distance;
  final bool isWithinRange;
  final bool isLate;
  final Map<String, double>? userLocation;
  final Map<String, double>? officeLocation;
  final DateTime? punchInTime;
  final bool isPunchOutEnabled;
  final bool isAttendanceCompleted;
  final int lateCount;

  AttendanceLoaded({
    this.distance,
    this.isWithinRange = false,
    this.isLate = false,
    this.userLocation,
    this.officeLocation,
    this.punchInTime,
    this.isPunchOutEnabled = false,
    this.isAttendanceCompleted = false,
    this.lateCount = 0,
  });
}

class AttendanceSuccess extends AttendanceState {
  final DateTime punchInTime;

  AttendanceSuccess() : punchInTime = DateTime.now();
}

class AttendanceFailure extends AttendanceState {
  final String error;

  AttendanceFailure(this.error);
}
