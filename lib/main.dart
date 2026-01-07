import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thousand_praises/praise_storage.dart';

const bool devMode = true;

void main() {
  runApp(const ThousandPraiseApp());
}

class ThousandPraiseApp extends StatelessWidget {
  const ThousandPraiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Thousand Praises',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: false,
        fontFamily: 'NotoSerifTamil',
      ),
      home: const PraiseReaderScreen(),
    );
  }
}

class PraiseReaderScreen extends StatefulWidget {
  const PraiseReaderScreen({super.key});

  @override
  State<PraiseReaderScreen> createState() => _PraiseReaderScreenState();
}

class _PraiseReaderScreenState extends State<PraiseReaderScreen> with TickerProviderStateMixin {
  List<dynamic> _praises = [];

  // Settings
  double _fontSize = 16.0;
  bool _isDarkMode = false;
  double _lineSpacing = 1.8;
  bool _showSettings = false;
  bool _isLoading = true;

  final ScrollController _scrollController = ScrollController();
  late AnimationController _settingsAnimController;
  late Animation<Offset> _settingsSlideAnimation;

  @override
  void initState() {
    super.initState();
    _settingsAnimController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _settingsSlideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _settingsAnimController,
      curve: Curves.easeInOut,
    ));
    _loadThemePreference();
    loadPraises();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _settingsAnimController.dispose();
    super.dispose();
  }

  static const String _themePrefKey = 'isDarkMode';
  static const String _fontSizePrefKey = 'fontSize';
  static const String _lineSpacingPrefKey = 'lineSpacing';

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool(_themePrefKey) ?? false;
      _fontSize = prefs.getDouble(_fontSizePrefKey) ?? 17.0;
      _lineSpacing = prefs.getDouble(_lineSpacingPrefKey) ?? 1.5;
    });
  }

  Future<void> _saveThemePreference(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themePrefKey, value);
  }

  Future<void> loadPraises() async {
    try {
      setState(() => _isLoading = true);

      // Load Base Praises
      final baseJson = await rootBundle.loadString('assets/praises.json');
      final base = List<Map<String, dynamic>>.from(json.decode(baseJson));

      // Load user-added praises
      final user = await loadUserPraises();

      setState(() {
        _praises = [...base, ...user];
        _isLoading = false;
      });
    } catch (e) {
      // Fallback to sample data if file not found
      setState(() {
        _praises = _getSampleData();
        _isLoading = false;
      });
    }
  }

  List<dynamic> _getSampleData() {
    return List.generate(10, (index) => {
      'reference': 'துதி ${index + 1}',
      'praise': 'இது ${index + 1}-வது துதி உள்ளடக்கம். இறைவனின் மகிமையை பாடும் இந்த வரிகள் நமது உள்ளத்தில் ஆழமான பக்தியை ஏற்படுத்துகின்றன. தெய்வீக அருளால் நாம் நல்வழியில் செல்கிறோம். இறைவனின் அருள் நம்மை எப்போதும் காக்கும். நாம் அவரை நினைத்து வணங்குவோம்.',
    });
  }

  void _toggleSettings() {
    setState(() {
      _showSettings = !_showSettings;
    });
    if (_showSettings) {
      _settingsAnimController.forward();
    } else {
      _settingsAnimController.reverse();
    }
  }

  void _openAddPraiseSheet() {
    final referenceController = TextEditingController();
    final praiseController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: SingleChildScrollView(
            child: SafeArea(
              top: false,
              left: false,
              right: false,
            child: Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,

              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header with icon
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: accentColor.withValues(alpha: 0.3)),
                        ),
                        child: Icon(
                          Icons.add_circle_outline,
                          color: accentColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'புதிய துதி சேர்க்க',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            Text(
                              'Add New Praise',
                              style: TextStyle(
                                fontSize: 12,
                                color: textColor.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: textColor),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  // Reference field
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.bookmark_border, color: accentColor, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'குறிப்பு / Reference',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: referenceController,
                        style: TextStyle(
                          fontSize: 16,
                          color: textColor,
                        ),
                        decoration: InputDecoration(
                          hintText: 'e.g., துதி 101',
                          hintStyle: TextStyle(
                            color: textColor.withValues(alpha: 0.4),
                          ),
                          filled: true,
                          fillColor: _isDarkMode
                              ? Colors.white.withValues(alpha: 0.05)
                              : Colors.black.withValues(alpha: 0.02),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: borderColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: borderColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: accentColor, width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Praise text field
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.edit_note, color: accentColor, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'துதி உரை / Praise Text',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: praiseController,
                        maxLines: 6,
                        style: TextStyle(
                          fontSize: 16,
                          color: textColor,
                          height: 1.8,
                        ),
                        decoration: InputDecoration(
                          hintText: 'உங்கள் துதியை இங்கே எழுதுங்கள்...',
                          hintStyle: TextStyle(
                            color: textColor.withValues(alpha: 0.4),
                          ),
                          filled: true,
                          fillColor: _isDarkMode
                              ? Colors.white.withValues(alpha: 0.05)
                              : Colors.black.withValues(alpha: 0.02),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: borderColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: borderColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: accentColor, width: 2),
                          ),
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Save button
                  ElevatedButton(
                    onPressed: () async {
                      final ref = referenceController.text.trim();
                      final praise = praiseController.text.trim();

                      if (ref.isEmpty || praise.isEmpty) {
                        _showModernToast(context, 'Please fill all fields', isError: true);
                        return;
                      }

                      await addUserPraise(
                        reference: ref,
                        praise: praise,
                      );

                      await loadPraises();

                      Navigator.pop(context);
                      _showModernToast(context, 'Praise saved successfully!');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle_outline, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'சேமிக்க / Save Praise',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            ),
          ),
        );
      },
    );
  }

  void _showModernToast(BuildContext context, String message, {bool isError = false}) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: MediaQuery.of(context).padding.bottom + 80, // Changed from top to bottom
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: TweenAnimationBuilder(
            duration: const Duration(milliseconds: 300),
            tween: Tween<double>(begin: 0, end: 1),
            builder: (context, double value, child) {
              return Transform.translate(
                offset: Offset(0, 20 * (1 - value)), // Changed animation direction
                child: Opacity(opacity: value, child: child),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: isError ? Colors.red.shade50 : Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isError ? Colors.red.shade200 : Colors.green.shade200,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isError ? Colors.red.shade100 : Colors.green.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isError ? Icons.error_outline : Icons.check_circle_outline,
                      color: isError ? Colors.red.shade700 : Colors.green.shade700,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      message,
                      style: TextStyle(
                        color: isError ? Colors.red.shade900 : Colors.green.shade900,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }

  Color get bgColor => _isDarkMode ? const Color(0xFF0D1117) : const Color(0xFFFDF6E3);
  Color get textColor => _isDarkMode ? const Color(0xFFE6EDF3) : const Color(0xFF2C2416);
  Color get accentColor => _isDarkMode ? const Color(0xFFFFB74D) : const Color(0xFFD97706);
  Color get cardColor => _isDarkMode ? const Color(0xFF161B22) : const Color(0xFFFFFBF0);
  Color get borderColor => _isDarkMode ? const Color(0xFF30363D) : const Color(0xFFE5D5B7);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_showSettings,
      onPopInvokedWithResult: (didPop,result) {
        if (didPop) return;
        if (_showSettings) {
          _toggleSettings();
        }
      },
      child: Scaffold(
      backgroundColor: bgColor,

      floatingActionButton: devMode
          ? FloatingActionButton(
              backgroundColor: accentColor,
              foregroundColor: textColor,
              onPressed: _openAddPraiseSheet,
              child: const Icon(Icons.add),
            )
          : null,

      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
            color: _isDarkMode ? Colors.white.withValues(alpha: 0.02) : Colors.black.withValues(alpha: 0.02),
            ),
          ),
          // Main content
          SafeArea(
            child: Column(
              children: [
                // Custom app bar
                _buildAppBar(),

                // Scrollable content
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                    itemCount: _praises.length,
                    itemBuilder: (context, index) {
                      return RepaintBoundary(
                        child: _buildPraiseCard(_praises[index], index),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Settings panel overlay
          if (_showSettings)
            GestureDetector(
              onTap: _toggleSettings,
              child: Container(
                color: Colors.black.withValues(alpha: 0.5),
              ),
            ),

          SlideTransition(
            position: _settingsSlideAnimation,
            child: Align(
              alignment: Alignment.centerRight,
              child: _buildSettingsPanel(),
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: borderColor, width: 1),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.auto_stories, color: accentColor, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ஆயிரம் துதிகள்',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                Text(
                  '${_praises.length} துதிகள்',
                  style: TextStyle(
                    fontSize: 12,
                    color: textColor.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.tune, color: textColor, size: 24),
            onPressed: _toggleSettings,
          ),

          if(devMode)
            IconButton(
              icon: Icon(Icons.upload_file, color: textColor),
              tooltip: 'Export Praises',
              onPressed: () async {
                try {
                  await exportUserPraises();
                } on FileSystemException {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No praises to export')),
                  );
                } catch(e) {
                  debugPrint('Export warning: $e');
                }
              },
            ),
        ],
      ),
    );
  }

  Widget _buildPraiseCard(dynamic praise, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom:16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Number badge and reference
          Row(
            children: [
              // Number circle
              Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: accentColor.withValues(alpha: 0.3), width: 2),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontSize: 12,
                      color: accentColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Reference badge
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5.2),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: accentColor.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    praise['reference'],
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: accentColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Praise text
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Text(
              _praises[index]['praise'] ?? 'Praise Missing',
              textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: _fontSize,
                  height: _lineSpacing,
                  color: textColor,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          const SizedBox(height: 1),
        ],
      ),
    );
  }

  Widget _buildSettingsPanel() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      height: double.infinity,
      decoration: BoxDecoration(
        color: cardColor,
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: textColor),
                    onPressed: _toggleSettings,
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Font size
                  _buildSettingSection(
                    'எழுத்து அளவு',
                    Icons.format_size,
                  ),
                  Row(
                    children: [
                      const SizedBox(
                        width: 20,
                        child: Text('அ', textAlign: TextAlign.center),
                      ),
                      Expanded(
                        child: Slider(
                          value: _fontSize,
                          min: 16,
                          max: 36,
                          divisions: 20,
                          activeColor: accentColor,
                          inactiveColor: borderColor,
                          onChanged: (value) async {
                            setState(() => _fontSize = value);
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setDouble(_fontSizePrefKey, value);
                          },
                        ),
                      ),
                      const SizedBox(
                        width: 28,
                        child: Text(
                          'அ',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 28),
                        ),
                      ),
                    ],
                  ),
                  Center(
                    child: Text(
                      '${_fontSize.round()} pt',
                      style: TextStyle(color: textColor.withValues(alpha: 0.6), fontSize: 14),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Line spacing
                  _buildSettingSection(
                    'வரி இடைவெளி',
                    Icons.format_line_spacing,
                  ),
                  Slider(
                    value: _lineSpacing,
                    min: 1.3,
                    max: 2.5,
                    divisions: 12,
                    activeColor: accentColor,
                    inactiveColor: borderColor,
                    label: _lineSpacing.toStringAsFixed(1),
                    onChanged: (value) async {
                      setState(() => _lineSpacing = value);
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setDouble(_lineSpacingPrefKey, value);
                    },
                  ),

                  const SizedBox(height: 16),

                  // Dark mode toggle
                  _buildSettingSection(
                    'காட்சி முறை',
                    Icons.brightness_6,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: borderColor),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SwitchListTile(
                      title: Text(
                        _isDarkMode ? 'இருண்ட பயன்முறை' : 'வெளிச்ச பயன்முறை',
                        style: TextStyle(
                          fontSize: 13,
                          color: textColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      value: _isDarkMode,
                      activeColor: accentColor,
                      onChanged: (value) async {
                        setState(() => _isDarkMode = value);
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setBool(_themePrefKey, value);
                        await _saveThemePreference(value);
                      },
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Reset button
                  ElevatedButton.icon(
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();

                      await prefs.setBool(_themePrefKey, false);
                      await prefs.setDouble(_fontSizePrefKey, 17.0);
                      await prefs.setDouble(_lineSpacingPrefKey, 1.5);

                      setState(() {
                        _fontSize = 22.0;
                        _lineSpacing = 1.8;
                        _isDarkMode = false;
                      });
                    },
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text(
                        'இயல்புநிலைக்கு மீட்டமை',
                        style: TextStyle(fontSize: 16),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingSection(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: accentColor, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

class BackgroundPatternPainter extends CustomPainter {
  final Color color;

  BackgroundPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    const spacing = 30.0;

    for (double i = 0; i < size.width; i += spacing) {
      for (double j = 0; j < size.height; j += spacing) {
        canvas.drawCircle(Offset(i, j), 1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}