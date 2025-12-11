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

      // Check for monthly limit
      final approvedLeaves = await _leaveRepository.getApprovedLeavesForMonth(
          event.userId, event.fromDate);

      // TODO: Logic needs to handle leaves spanning multiple months effectively.
      // For now, we assume the leave being applied for falls largely in 'fromDate' month
      // or we check the total APPROVED days in that month.
      //
      // However, calculating "days in month" for existing leaves is complex if they span.
      // Simplification: We already have 'totalDays' on the Leave entity.
      // BUT 'totalDays' is the total duration of the leave.
      // If a leave is Jan 30 - Feb 2 (4 days), how many count for Jan?
      //
      // Given the complexity and "2 days total" requirement:
      // We will sum up the total days of all approved leaves that START in this month
      // OR overlap.
      //
      // Let's refine the calculation:
      // For each approved leave, calculate overlapping days with the requested month.

      int approvedDaysInMonth = 0;
      final startOfMonth =
          DateTime(event.fromDate.year, event.fromDate.month, 1);
      final endOfMonth =
          DateTime(event.fromDate.year, event.fromDate.month + 1, 0);

      for (var l in approvedLeaves) {
        // Intersection of [l.fromDate, l.toDate] and [startOfMonth, endOfMonth]
        DateTime overlapStart =
            l.fromDate.isBefore(startOfMonth) ? startOfMonth : l.fromDate;
        DateTime overlapEnd =
            l.toDate.isAfter(endOfMonth) ? endOfMonth : l.toDate;

        if (overlapStart.isBefore(overlapEnd) ||
            overlapStart.isAtSameMomentAs(overlapEnd)) {
          // We need to use the Repo's calculator to exclude holidays/weekends for the overlap period
          // forcing the repo to be public or reusing helper?
          // calculateLeaveDays is already public in Repo.
          approvedDaysInMonth += await _leaveRepository.calculateLeaveDays(
              overlapStart, overlapEnd);
        }
      }

      if (approvedDaysInMonth + totalDays > 2) {
        emit(const LeaveFailure(
            "You have exceeded the monthly leave limit of 2 days. Please contact your manager."));
        add(LoadLeaves(event.userId)); // Reload to be safe
        return;
      }

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
