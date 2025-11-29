import 'package:bloc/bloc.dart';
import 'package:espoir_staff_app/domain/repositories/attendance_repository.dart';
import 'package:espoir_staff_app/models/attendance.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'weekly_status_event.dart';
part 'weekly_status_state.dart';

class WeeklyStatusBloc extends Bloc<WeeklyStatusEvent, WeeklyStatusState> {
  final AttendanceRepository attendanceRepository;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  WeeklyStatusBloc({required this.attendanceRepository})
      : super(WeeklyStatusInitial()) {
    on<LoadWeeklyStatus>((event, emit) async {
      emit(WeeklyStatusLoading());
      try {
        final userId = _auth.currentUser!.uid;
        final weeklyAttendance =
            await attendanceRepository.getWeeklyAttendance(userId);
        emit(WeeklyStatusLoaded(weeklyAttendance));
      } catch (e) {
        emit(WeeklyStatusFailure(e.toString()));
      }
    });
  }
}
