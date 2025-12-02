import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:espoir_staff_app/domain/entities/daily_report.dart';
import 'package:espoir_staff_app/domain/repositories/daily_report_repository.dart';
import 'package:espoir_staff_app/presentation/blocs/daily_report/daily_report_event.dart';
import 'package:espoir_staff_app/presentation/blocs/daily_report/daily_report_state.dart';
import 'package:uuid/uuid.dart';

class DailyReportBloc extends Bloc<DailyReportEvent, DailyReportState> {
  final DailyReportRepository _repository;

  DailyReportBloc(this._repository) : super(DailyReportInitial()) {
    on<LoadDailyReportHistory>(_onLoadHistory);
    on<SubmitDailyReport>(_onSubmitReport);
    on<CheckTodaySubmission>(_onCheckTodaySubmission);
  }

  Future<void> _onLoadHistory(
    LoadDailyReportHistory event,
    Emitter<DailyReportState> emit,
  ) async {
    emit(DailyReportLoading());
    try {
      final reports = await _repository.getUserReports(event.userId);
      final isSubmitted =
          await _repository.isReportSubmittedToday(event.userId);
      emit(DailyReportLoaded(reports: reports, isSubmittedToday: isSubmitted));
    } catch (e) {
      emit(DailyReportError(e.toString()));
    }
  }

  Future<void> _onSubmitReport(
    SubmitDailyReport event,
    Emitter<DailyReportState> emit,
  ) async {
    emit(DailyReportLoading());
    try {
      final isSubmitted =
          await _repository.isReportSubmittedToday(event.userId);
      if (isSubmitted) {
        emit(const DailyReportError(
            "Daily report already submitted for today."));
        // Reload state to show correct UI
        add(LoadDailyReportHistory(event.userId));
        return;
      }

      final report = DailyReport(
        id: const Uuid().v4(),
        userId: event.userId,
        userName: event.userName,
        date: DateTime.now(),
        tasksCompleted: event.tasksCompleted,
        createdAt: DateTime.now(),
      );

      await _repository.submitReport(report);
      emit(DailyReportSuccess());
      // Reload history after success
      add(LoadDailyReportHistory(event.userId));
    } catch (e) {
      emit(DailyReportError(e.toString()));
    }
  }

  Future<void> _onCheckTodaySubmission(
    CheckTodaySubmission event,
    Emitter<DailyReportState> emit,
  ) async {
    // This might be redundant if we load history, but useful for initial check
    try {
      final isSubmitted =
          await _repository.isReportSubmittedToday(event.userId);
      if (state is DailyReportLoaded) {
        final currentState = state as DailyReportLoaded;
        emit(DailyReportLoaded(
          reports: currentState.reports,
          isSubmittedToday: isSubmitted,
        ));
      } else {
        // If not loaded yet, just load everything
        add(LoadDailyReportHistory(event.userId));
      }
    } catch (e) {
      // Ignore or handle
    }
  }
}
