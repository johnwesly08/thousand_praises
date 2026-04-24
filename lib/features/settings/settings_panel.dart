import 'package:flutter/material.dart';
import 'package:thousand_praises/core/theme/app_colors.dart';

class SettingsPanel extends StatelessWidget {
  final bool isDarkMode;
  final double fontSize;
  final double lineSpacing;
  final bool showFontSize;
  final bool showLineSpacing;

  final Function(bool) onThemeChanged;
  final Function(double) onFontChanged;
  final Function(double) onSpacingChanged;
  final VoidCallback onReset;
  final VoidCallback onClose;

  const SettingsPanel({
    super.key,
    required this.isDarkMode,
    required this.fontSize,
    required this.lineSpacing,
    required this.onThemeChanged,
    required this.onFontChanged,
    required this.onSpacingChanged,
    required this.onReset,
    required this.onClose,

    this.showFontSize = true,
    this.showLineSpacing = true,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = AppColors.text(isDarkMode);
    final cardColor = AppColors.card(isDarkMode);
    final borderColor = AppColors.border(isDarkMode);
    final accentColor = AppColors.accent(isDarkMode);

    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      color: cardColor,
      child: SafeArea(
        child: Column(
          children: [

            /// 🔹 HEADER
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: borderColor)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'வாசிப்பு அமைப்புகள்',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: textColor),
                    onPressed: onClose,
                  ),
                ],
              ),
            ),

            /// 🔹 CONTENT
        ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
                children: [ if (showFontSize) ...[
                  _section("எழுத்து அளவு", Icons.format_size, accentColor, textColor),
                  Slider(
                    value: fontSize,
                    min: 16,
                    max: 36,
                    divisions: 20,
                    activeColor: accentColor,
                    onChanged: onFontChanged,
                  ),

                  const SizedBox(height: 16),
                  ],

                  if (showLineSpacing) ...[
                  _section("வரி இடைவெளி", Icons.format_line_spacing, accentColor, textColor),
                  Slider(
                    value: lineSpacing,
                    min: 1.3,
                    max: 2.5,
                    divisions: 12,
                    activeColor: accentColor,
                    onChanged: onSpacingChanged,
                  ),

                  const SizedBox(height: 16),
                  ],

                  _section("காட்சி முறை", Icons.brightness_6, accentColor, textColor),
                  SwitchListTile(
                    value: isDarkMode,
                    activeThumbColor: accentColor,
                    onChanged: onThemeChanged,
                    title: Text(
                      isDarkMode ? 'இருண்ட பயன்முறை' : 'வெளிச்ச பயன்முறை',
                      style: TextStyle(color: textColor),
                    ),
                  ),

                  const SizedBox(height: 24),

                  /// RESET BUTTON
                  ElevatedButton.icon(
                    onPressed: onReset,
                    icon: const Icon(Icons.refresh),
                    label: const Text('இயல்புநிலைக்கு மீட்டமை'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _section(String title, IconData icon, Color accent, Color text) {
    return Row(
      children: [
        Icon(icon, color: accent, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: text,
          ),
        ),
      ],
    );
  }
}