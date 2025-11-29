import 'package:espoir_staff_app/presentation/blocs/auth/auth_bloc.dart';
import 'package:espoir_staff_app/presentation/screens/dashboard_screen.dart';
import 'package:espoir_staff_app/presentation/screens/login_screen.dart';
import 'package:espoir_staff_app/presentation/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthInitial) {
          return const SplashScreen();
        } else if (state is AuthAuthenticated) {
          return const DashboardScreen();
        } else if (state is AuthFailure) {
          return const LoginScreen();
        } else if (state is AuthUnauthenticated) {
          return const LoginScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
