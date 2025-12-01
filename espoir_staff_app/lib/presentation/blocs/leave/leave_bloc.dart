import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:espoir_staff_app/domain/entities/leave.dart';
import 'package:espoir_staff_app/domain/repositories/leave_repository.dart';
import 'leave_event.dart';
import 'leave_state.dart';

class LeaveBloc extends Bloc<LeaveEvent, LeaveState> {
  final LeaveRepository _leaveRepository;

  LeaveBloc({required LeaveRepository leaveRepository})
      : _leaveRepository = leaveRepository,
        super(LeaveInitial()) {
    on<LoadLeaves>(_onLoadLeaves);
    on<ApplyLeave>(_onApplyLeave);
    on<CancelLeave>(_onCancelLeave);
  }

  Future<void> _onLoadLeaves(LoadLeaves event, Emitter<LeaveState> emit) async {
    emit(LeaveLoading());
    try {
      await emit.forEach(
        _leaveRepository.getLeaves(event.userId),
        onData: (List<Leave> leaves) => LeaveLoaded(leaves),
        onError: (error, stackTrace) => LeaveFailure(error.toString()),
      );
    } catch (e) {
      emit(LeaveFailure(e.toString()));
    }
  }

  Future<void> _onApplyLeave(ApplyLeave event, Emitter<LeaveState> emit) async {
    emit(LeaveLoading());
    try {
      final totalDays = await _leaveRepository.calculateLeaveDays(
        event.fromDate,
        event.toDate,
      );

      final leave = Leave(
        id: '', // Firestore will generate ID
        userId: event.userId,
        fromDate: event.fromDate,
        toDate: event.toDate,
        reason: event.reason,
        status: 'Pending',
        appliedOn: DateTime.now(),
        totalDays: totalDays,
      );

      await _leaveRepository.applyLeave(leave);
      emit(const LeaveOperationSuccess('Leave applied successfully'));
      add(LoadLeaves(event.userId)); // Reload leaves
    } catch (e) {
      emit(LeaveFailure(e.toString()));
    }
  }

  Future<void> _onCancelLeave(
      CancelLeave event, Emitter<LeaveState> emit) async {
    try {
      await _leaveRepository.cancelLeave(event.leaveId);
      emit(const LeaveOperationSuccess('Leave cancelled successfully'));
    } catch (e) {
      emit(LeaveFailure(e.toString()));
    }
  }
}
