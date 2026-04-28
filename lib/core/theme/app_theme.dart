import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: false,

    textTheme: const TextTheme(
      bodyMedium: TextStyle(
        fontFamily: 'NotoSerifTamil',
        height: 1.5,
      ),
    ),

    scaffoldBackgroundColor: AppColors.bg(false),
    canvasColor: AppColors.bg(false),

    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,

    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.bg(false),
      foregroundColor: AppColors.text(false),
      elevation: 0,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: false,

    fontFamily: 'NotoSerifTamil', // ✅ HERE ALSO

    scaffoldBackgroundColor: AppColors.bg(true),
    canvasColor: AppColors.bg(true),

    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,

    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.bg(true),
      foregroundColor: AppColors.text(true),
      elevation: 0,
    ),
  );
}