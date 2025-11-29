import 'package:bloc/bloc.dart';
import 'package:espoir_staff_app/data/services/geofencing_service.dart';
import 'package:espoir_staff_app/domain/repositories/attendance_repository.dart';
import 'package:espoir_staff_app/models/attendance.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

part 'attendance_event.dart';
part 'attendance_state.dart';

class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  final AttendanceRepository attendanceRepository;
  final GeofencingService geofencingService;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Map<String, dynamic>? _officeConfig;
  static const double maxAllowedDistance = 200.0;

  AttendanceBloc(
      {required this.attendanceRepository, required this.geofencingService})
      : super(AttendanceInitial()) {
    on<AttendanceStarted>((event, emit) async {
      // Don't fetch location on startup
      await _loadData(emit, fetchLocation: false);
    });

    on<PunchIn>((event, emit) async {
      emit(AttendanceLoading());
      try {
        _officeConfig ??= await attendanceRepository.getOfficeConfig();

        // 1. Fetch Location Explicitly
        final position = await geofencingService.getCurrentLocation();
        final double officeLat = _officeConfig!['lat'];
        final double officeLng = _officeConfig!['lng'];

        // 2. Calculate Distance
        final distance = await geofencingService.calculateDistance(
          position.latitude,
          position.longitude,
          officeLat,
          officeLng,
        );

        // 3. Strict Validation (200m)
        if (distance > maxAllowedDistance) {
          emit(AttendanceFailure(
              'You are too far from office. Distance: ${distance.toStringAsFixed(0)}m (Max: ${maxAllowedDistance.toInt()}m)'));
          // Reload data to restore state, passing the fetched location so user can see where they are
          await _loadData(emit,
              fetchLocation: false,
              preFetchedPosition: position,
              preFetchedDistance: distance);
          return;
        }

        final userId = _auth.currentUser!.uid;
        final now = DateTime.now();
        final isLate = now.hour > 10 || (now.hour == 10 && now.minute > 0);

        await attendanceRepository.punchIn(userId, isLate: isLate);
        emit(AttendanceSuccess());

        // Reload data to reflect new punch
        await _loadData(emit,
            fetchLocation: false,
            preFetchedPosition: position,
            preFetchedDistance: distance);
      } catch (e) {
        emit(AttendanceFailure(e.toString()));
        await _loadData(emit, fetchLocation: false);
      }
    });

    on<PunchOut>((event, emit) async {
      emit(AttendanceLoading());
      try {
        final userId = _auth.currentUser!.uid;

        // Fetch location for Punch Out as well (as requested "during punch-in and punch-out")
        final position = await geofencingService.getCurrentLocation();

        await attendanceRepository.punchOut(userId);
        emit(AttendanceSuccess());

        // Reload data
        await _loadData(emit,
            fetchLocation: false, preFetchedPosition: position);
      } catch (e) {
        emit(AttendanceFailure(e.toString()));
        await _loadData(emit, fetchLocation: false);
      }
    });

    on<SetCurrentLocationAsOffice>((event, emit) async {
      emit(AttendanceLoading());
      try {
        final position = await geofencingService.getCurrentLocation();
        await attendanceRepository.setOfficeLocation(
          position.latitude,
          position.longitude,
          maxAllowedDistance, // Set to 200m default
        );
        // Force refresh config
        _officeConfig = null;
        await _loadData(emit,
            fetchLocation: false, preFetchedPosition: position);
      } catch (e) {
        emit(AttendanceFailure('Failed to set office location: $e'));
        await _loadData(emit, fetchLocation: false);
      }
    });
  }

  Future<void> _loadData(Emitter<AttendanceState> emit,
      {bool fetchLocation = false,
      Position? preFetchedPosition,
      double? preFetchedDistance}) async {
    emit(AttendanceLoading());
    try {
      final userId = _auth.currentUser!.uid;

      // Removed weeklyAttendance from parallel fetch
      final results = await Future.wait([
        _officeConfig == null
            ? attendanceRepository.getOfficeConfig()
            : Future.value(_officeConfig),
        (fetchLocation && preFetchedPosition == null)
            ? geofencingService.getCurrentLocation()
            : Future.value(preFetchedPosition),
        attendanceRepository.getLatestAttendance(userId),
        attendanceRepository.getLateCount(userId),
      ]);

      _officeConfig = results[0] as Map<String, dynamic>;
      final position = results[1] as Position?;
      final currentAttendance = results[2] as Attendance?;
      final lateCount = results[3] as int;

      final double officeLat = _officeConfig!['lat'];
      final double officeLng = _officeConfig!['lng'];

      // Use preFetchedDistance if available, otherwise calculate if position is available
      double? distance = preFetchedDistance;
      bool isWithinRange = false;

      if (distance == null && position != null) {
        distance = await geofencingService.calculateDistance(
          position.latitude,
          position.longitude,
          officeLat,
          officeLng,
        );
      }

      if (distance != null) {
        isWithinRange = distance <= maxAllowedDistance;
      }

      final now = DateTime.now();
      final isLate = now.hour > 10 || (now.hour == 10 && now.minute > 0);

      bool isPunchOutEnabled = false;
      bool isAttendanceCompleted = false;
      DateTime? punchInTime;

      if (currentAttendance != null) {
        if (currentAttendance.punchIn.day == now.day &&
            currentAttendance.punchIn.month == now.month &&
            currentAttendance.punchIn.year == now.year) {
          punchInTime = currentAttendance.punchIn;

          if (currentAttendance.punchOut != null) {
            isAttendanceCompleted = true;
          } else {
            final duration = now.difference(currentAttendance.punchIn);
            if (duration.inMinutes >= 210) {
              isPunchOutEnabled = true;
            }
          }
        }
      }

      emit(AttendanceLoaded(
        distance: distance,
        isWithinRange: isWithinRange,
        isLate: isLate,
        userLocation: position != null
            ? {'lat': position.latitude, 'lng': position.longitude}
            : null,
        officeLocation: {'lat': officeLat, 'lng': officeLng},
        punchInTime: punchInTime,
        isPunchOutEnabled: isPunchOutEnabled,
        isAttendanceCompleted: isAttendanceCompleted,
        lateCount: lateCount,
      ));
    } catch (e) {
      emit(AttendanceFailure('Error loading data: $e'));
    }
  }
}
