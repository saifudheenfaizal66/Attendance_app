import 'package:bloc/bloc.dart';
import 'package:espoir_staff_app/domain/repositories/attendance_repository.dart';
import 'package:espoir_staff_app/domain/repositories/leave_repository.dart';

part 'statistics_event.dart';
part 'statistics_state.dart';

class StatisticsBloc extends Bloc<StatisticsEvent, StatisticsState> {
  final AttendanceRepository _attendanceRepository;
  final LeaveRepository _leaveRepository;

  StatisticsBloc({
    required AttendanceRepository attendanceRepository,
    required LeaveRepository leaveRepository,
  })  : _attendanceRepository = attendanceRepository,
        _leaveRepository = leaveRepository,
        super(StatisticsInitial()) {
    on<LoadStatistics>(_onLoadStatistics);
  }

  Future<void> _onLoadStatistics(
      LoadStatistics event, Emitter<StatisticsState> emit) async {
    emit(StatisticsLoading());
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0);

      // 1. Fetch Attendance History
      // Note: This gets a Stream. We'll take the first emission for the snapshot.
      // Ideally, we should listen to the stream for real-time updates, but for now a snapshot is fine.
      final attendanceList =
          await _attendanceRepository.getAttendanceHistory(event.userId).first;

      // Filter for current month
      final monthlyAttendance = attendanceList.where((a) {
        return a.punchIn.year == now.year && a.punchIn.month == now.month;
      }).toList();

      // 2. Calculate Total Leaves (Absent Days)
      // Option B: Calculate up to Yesterday.
      // Formula: (Working Days from Start of Month to Yesterday) - (Attended Days before Today)

      int totalLeavesTaken = 0;
      final yesterday = now.subtract(const Duration(days: 1));

      // Only calculate if we are past the first day of the month
      if (now.day > 1) {
        // Calculate working days up to yesterday
        // Ensure we don't go before startOfMonth
        final calculationEndDate =
            yesterday.isBefore(startOfMonth) ? startOfMonth : yesterday;

        // If yesterday is before startOfMonth (e.g. on 1st of month), working days is 0.
        // But the 'if (now.day > 1)' check handles the 1st of the month case mostly.
        // However, if startOfMonth is today, yesterday is last month.

        if (!yesterday.isBefore(startOfMonth)) {
          final workingDaysUntilYesterday = await _leaveRepository
              .calculateLeaveDays(startOfMonth, calculationEndDate);

          // Count unique attended days before today
          final attendedDaysBeforeToday = monthlyAttendance
              .where((a) {
                final punchDate =
                    DateTime(a.punchIn.year, a.punchIn.month, a.punchIn.day);
                // Check if punchDate is strictly before today (i.e., <= yesterday)
                return punchDate
                    .isBefore(DateTime(now.year, now.month, now.day));
              })
              .map((a) {
                return DateTime(a.punchIn.year, a.punchIn.month, a.punchIn.day);
              })
              .toSet()
              .length;

          totalLeavesTaken =
              workingDaysUntilYesterday - attendedDaysBeforeToday;
          if (totalLeavesTaken < 0) totalLeavesTaken = 0;
        }
      }

      // 3. Calculate Attendance Percentage
      // Formula: (Present Days / Total Working Days In Month) * 100

      // Count unique days to handle multiple punches on the same day
      final uniquePresentDays = monthlyAttendance
          .map((a) {
            return DateTime(a.punchIn.year, a.punchIn.month, a.punchIn.day);
          })
          .toSet()
          .length;

      final totalWorkingDaysInMonth =
          await _leaveRepository.calculateLeaveDays(startOfMonth, endOfMonth);

      // Avoid division by zero
      final double percentage = totalWorkingDaysInMonth > 0
          ? (uniquePresentDays / totalWorkingDaysInMonth) * 100
          : 0.0;

      // 4. Calculate Remaining Days
      // Remaining Days = Days in month - Today's day
      final remainingDays = endOfMonth.day - now.day;

      emit(StatisticsLoaded(
        attendancePercentage: '${percentage.toStringAsFixed(0)}%',
        remainingDays: remainingDays.toString(),
        totalLeavesTaken: totalLeavesTaken.toString(),
      ));
    } catch (e) {
      emit(StatisticsFailure(e.toString()));
    }
  }
}
