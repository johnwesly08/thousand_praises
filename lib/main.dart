import 'package:flutter/material.dart';
import 'features/home/home_screen.dart';
import 'core/theme/app_theme.dart';
import 'core/services/settings_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final isDarkMode = await SettingsService.getDarkMode();

  runApp(ThousandPraiseApp(isDarkMode: isDarkMode));
}

class ThousandPraiseApp extends StatelessWidget {
  final bool isDarkMode;

  const ThousandPraiseApp({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Thousand Praises',
      debugShowCheckedModeBanner: false,

      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,

      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,

      home: const HomeScreen(),
    );
  }
}