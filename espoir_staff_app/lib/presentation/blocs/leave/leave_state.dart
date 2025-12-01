import 'package:equatable/equatable.dart';
import 'package:espoir_staff_app/domain/entities/leave.dart';

abstract class LeaveState extends Equatable {
  const LeaveState();

  @override
  List<Object> get props => [];
}

class LeaveInitial extends LeaveState {}

class LeaveLoading extends LeaveState {}

class LeaveLoaded extends LeaveState {
  final List<Leave> leaves;

  const LeaveLoaded(this.leaves);

  @override
  List<Object> get props => [leaves];
}

class LeaveOperationSuccess extends LeaveState {
  final String message;

  const LeaveOperationSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class LeaveFailure extends LeaveState {
  final String error;

  const LeaveFailure(this.error);

  @override
  List<Object> get props => [error];
}
