import 'package:espoir_staff_app/data/repositories/auth_repository_impl.dart';
import 'package:espoir_staff_app/data/repositories/attendance_repository_impl.dart';
import 'package:espoir_staff_app/data/services/geofencing_service.dart';
import 'package:espoir_staff_app/data/services/notification_service.dart';
import 'package:espoir_staff_app/domain/repositories/auth_repository.dart';
import 'package:espoir_staff_app/domain/repositories/attendance_repository.dart';
import 'package:espoir_staff_app/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:espoir_staff_app/presentation/blocs/auth/auth_bloc.dart';
import 'package:espoir_staff_app/presentation/blocs/attendance/attendance_bloc.dart';
import 'package:espoir_staff_app/presentation/blocs/weekly_status/weekly_status_bloc.dart';
import 'package:espoir_staff_app/presentation/blocs/theme/theme_bloc.dart';
import 'package:espoir_staff_app/data/repositories/leave_repository_impl.dart';
import 'package:espoir_staff_app/domain/repositories/leave_repository.dart';
import 'package:espoir_staff_app/presentation/blocs/leave/leave_bloc.dart';
import 'package:espoir_staff_app/presentation/blocs/statistics/statistics_bloc.dart';
import 'package:espoir_staff_app/presentation/screens/auth_wrapper.dart';
import 'package:espoir_staff_app/data/repositories/daily_report_repository_impl.dart';
import 'package:espoir_staff_app/domain/repositories/daily_report_repository.dart';
import 'package:espoir_staff_app/presentation/blocs/daily_report/daily_report_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  try {
    await NotificationService().init();
    await NotificationService().scheduleDailyReminders();
  } catch (e) {
    debugPrint('Failed to initialize notifications: $e');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(
          create: (context) => AuthRepositoryImpl(),
        ),
        RepositoryProvider<AttendanceRepository>(
          create: (context) => AttendanceRepositoryImpl(),
        ),
        RepositoryProvider<GeofencingService>(
          create: (context) => GeofencingService(),
        ),
        RepositoryProvider<LeaveRepository>(
          create: (context) => LeaveRepositoryImpl(),
        ),
        RepositoryProvider<DailyReportRepository>(
          create: (context) => DailyReportRepositoryImpl(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => ThemeBloc()..add(ThemeLoaded()),
          ),
          BlocProvider(
            create: (context) => AuthBloc(
              authRepository: context.read<AuthRepository>(),
            ),
          ),
          BlocProvider<AttendanceBloc>(
            create: (context) => AttendanceBloc(
              attendanceRepository: context.read<AttendanceRepository>(),
              geofencingService: context.read<GeofencingService>(),
            )..add(AttendanceStarted()),
          ),
          BlocProvider<WeeklyStatusBloc>(
            create: (context) => WeeklyStatusBloc(
              attendanceRepository: context.read<AttendanceRepository>(),
            )..add(LoadWeeklyStatus()),
          ),
          BlocProvider<LeaveBloc>(
            create: (context) => LeaveBloc(
              leaveRepository: context.read<LeaveRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => StatisticsBloc(
              attendanceRepository: context.read<AttendanceRepository>(),
              leaveRepository: context.read<LeaveRepository>(),
            ),
          ),
          BlocProvider<DailyReportBloc>(
            create: (context) => DailyReportBloc(
              context.read<DailyReportRepository>(),
            ),
          ),
        ],
        child: BlocBuilder<ThemeBloc, ThemeState>(
          builder: (context, state) {
            return MaterialApp(
              title: 'Espoir Staff App',
              theme: ThemeData(
                useMaterial3: true,
                brightness: Brightness.light,
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
              ),
              darkTheme: ThemeData(
                useMaterial3: true,
                brightness: Brightness.dark,
                cardColor: const Color(0xFF1E1E1E),
                scaffoldBackgroundColor: const Color(0xFF121212),
                colorScheme: ColorScheme.fromSeed(
                  seedColor: Colors.blue,
                  brightness: Brightness.dark,
                  surface: const Color(0xFF1E1E1E),
                ),
                textTheme: const TextTheme(
                  titleLarge: TextStyle(color: Colors.white),
                  bodyLarge: TextStyle(color: Colors.white),
                  bodyMedium: TextStyle(color: Colors.white70),
                ),
              ),
              themeMode: state.themeMode,
              home: const AuthWrapper(),
            );
          },
        ),
      ),
    );
  }
}
