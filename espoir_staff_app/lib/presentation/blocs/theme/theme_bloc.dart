import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

part 'theme_event.dart';
part 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  static const String _themeKey = 'theme_mode';

  ThemeBloc() : super(const ThemeState(themeMode: ThemeMode.system)) {
    on<ThemeLoaded>(_onThemeLoaded);
    on<ThemeChanged>(_onThemeChanged);
  }

  Future<void> _onThemeLoaded(
      ThemeLoaded event, Emitter<ThemeState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_themeKey);
    if (isDark != null) {
      emit(ThemeState(themeMode: isDark ? ThemeMode.dark : ThemeMode.light));
    }
  }

  Future<void> _onThemeChanged(
      ThemeChanged event, Emitter<ThemeState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, event.isDarkMode);
    emit(ThemeState(
        themeMode: event.isDarkMode ? ThemeMode.dark : ThemeMode.light));
  }
}
