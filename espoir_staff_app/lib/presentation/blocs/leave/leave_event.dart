import 'package:equatable/equatable.dart';

abstract class LeaveEvent extends Equatable {
  const LeaveEvent();

  @override
  List<Object> get props => [];
}

class LoadLeaves extends LeaveEvent {
  final String userId;

  const LoadLeaves(this.userId);

  @override
  List<Object> get props => [userId];
}

class ApplyLeave extends LeaveEvent {
  final String userId;
  final DateTime fromDate;
  final DateTime toDate;
  final String reason;

  const ApplyLeave({
    required this.userId,
    required this.fromDate,
    required this.toDate,
    required this.reason,
  });

  @override
  List<Object> get props => [userId, fromDate, toDate, reason];
}

class CancelLeave extends LeaveEvent {
  final String leaveId;

  const CancelLeave(this.leaveId);

  @override
  List<Object> get props => [leaveId];
}
