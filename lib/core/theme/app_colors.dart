import 'package:flutter/material.dart';

class AppColors {
  // ===============================
  // 🌞 LIGHT THEME (Paper Feel)
  // ===============================
  static const lightBg = Color(0xFFF1E7D0);
  static const lightText = Color(0xFF3B2F2F);
  static const lightCard = Color(0xFFF8F1DC);
  static const lightBorder = Color(0xFFD8C8A8);
  static const lightAccent = Color(0xFF7A5C3E);

  // ===============================
  // 🌙 DARK THEME (Reading Mode)
  // ===============================
  static const darkBg = Color(0xFF191714);
  static const darkText = Color(0xFFE3D6C5);
  static const darkCard = Color(0xFF23201C);
  static const darkBorder = Color(0xFF2E2A25);
  static const darkAccent = Color(0xFFA8926E);

  // ===============================
  // 🔁 HELPERS
  // ===============================
  static Color bg(bool isDark) => isDark ? darkBg : lightBg;
  static Color text(bool isDark) => isDark ? darkText : lightText;
  static Color card(bool isDark) => isDark ? darkCard : lightCard;
  static Color border(bool isDark) => isDark ? darkBorder : lightBorder;
  static Color accent(bool isDark) => isDark ? darkAccent : lightAccent;
}