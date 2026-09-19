import 'package:flutter/material.dart';
import '../models/task.dart';

class AppColors {
  static const brandFrom = Color(0xFF6366F1);
  static const brandTo = Color(0xFF8B5CF6);

  static const todo = Color(0xFF94A3B8);
  static const todoBg = Color(0xFFF1F5F9);
  static const inProgress = Color(0xFF3B82F6);
  static const inProgressBg = Color(0xFFEFF6FF);
  static const done = Color(0xFF10B981);
  static const doneBg = Color(0xFFECFDF5);

  static Color of(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return todo;
      case TaskStatus.inProgress:
        return inProgress;
      case TaskStatus.done:
        return done;
    }
  }

  static Color bgOf(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return todoBg;
      case TaskStatus.inProgress:
        return inProgressBg;
      case TaskStatus.done:
        return doneBg;
    }
  }
}

final appTheme = ThemeData(
  useMaterial3: true,
  colorSchemeSeed: AppColors.brandFrom,
  scaffoldBackgroundColor: const Color(0xFFF8FAFC),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    foregroundColor: Color(0xFF0F172A),
    elevation: 0,
    scrolledUnderElevation: 1,
    centerTitle: false,
  ),
  cardTheme: CardThemeData(
    elevation: 0,
    color: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(color: Colors.black.withOpacity(0.06)),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.black.withOpacity(0.08)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.black.withOpacity(0.08)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.brandFrom, width: 1.5),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.brandFrom,
      foregroundColor: Colors.white,
      elevation: 0,
      padding: const EdgeInsets.symmetric(vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
    ),
  ),
);
