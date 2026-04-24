import 'package:flutter/material.dart';
import '../../features/settings/settings_panel.dart';
import '../../core/theme/app_colors.dart';

void showSettingsBottomSheet({
  required BuildContext context,
  required bool isDarkMode,
  required double fontSize,
  required double lineSpacing,
  required Function(bool) onThemeChanged,
  required Function(double) onFontChanged,
  required Function(double) onSpacingChanged,
  required VoidCallback onReset,
  required bool showFontSize,
  required bool showLineSpacing,
}) {
  final cardColor = AppColors.card(isDarkMode);
  final borderColor = AppColors.border(isDarkMode);

  showModalBottomSheet(
    context: context,
    isScrollControlled: false,
    backgroundColor: Colors.transparent,
    builder: (_) {
      // 🔥 LOCAL STATE (for slider + toggle UI)
      double localFontSize = fontSize;
      double localLineSpacing = lineSpacing;
      bool localDarkMode = isDarkMode;

      return StatefulBuilder(
        builder: (context, setModalState) {
          final cardColor = AppColors.card(localDarkMode);
          return AnimatedContainer(
            duration: const Duration(milliseconds: 0),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: SettingsPanel(
                    isDarkMode: localDarkMode,
                    fontSize: localFontSize,
                    lineSpacing: localLineSpacing,
                    showFontSize: showFontSize,
                    showLineSpacing: showLineSpacing,

                    onClose: () => Navigator.pop(context),

                    // 🔥 DARK MODE
                    onThemeChanged: (value) {
                      localDarkMode = value;
                      setModalState(() {});      // update sheet UI
                      onThemeChanged(value);     // update parent
                    },

                    // 🔥 FONT SIZE
                    onFontChanged: (value) {
                      localFontSize = value;
                      setModalState(() {});
                      onFontChanged(value);
                    },

                    // 🔥 LINE SPACING
                    onSpacingChanged: (value) {
                      localLineSpacing = value;
                      setModalState(() {});
                      onSpacingChanged(value);
                    },

                    // 🔥 RESET
                    onReset: () {
                      localDarkMode = false;
                      localFontSize = 17.0;
                      localLineSpacing = 1.5;

                      setModalState(() {});
                      onReset(); // ❗ NO await
                    },
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
  );
}