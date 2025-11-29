part of 'attendance_bloc.dart';

abstract class AttendanceEvent {}

class AttendanceStarted extends AttendanceEvent {}

class PunchIn extends AttendanceEvent {}

class PunchOut extends AttendanceEvent {}

class SetCurrentLocationAsOffice extends AttendanceEvent {}
