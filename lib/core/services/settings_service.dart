import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const _darkKey = "isDarkMode";
  static const _fontKey = "fontSize";
  static const _spacingKey = "lineSpacing";

  static Future<bool> getDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_darkKey) ?? false;
  }

  static Future<void> setDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkKey, value);
  }

  static Future<double> getFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_fontKey) ?? 17.0;
  }

  static Future<void> setFontSize(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_fontKey, value);
  }

  static Future<double> getLineSpacing() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_spacingKey) ?? 1.5;
  }

  static Future<void> setLineSpacing(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_spacingKey, value);
  }

  static Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}