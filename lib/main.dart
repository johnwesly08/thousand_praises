import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thousand_praises/praise_storage.dart';
import 'scroll_reading_screen.dart';

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
  int _lastReadIndex = 0;
  int? _expandedGroup = 0;

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

  void _openReader(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ScrollReaderScreen(
          praises: _praises,
          startIndex: index,
          isDarkMode: _isDarkMode,
          fontSize: _fontSize,
          lineSpacing: _lineSpacing,
          onPraiseAdded: loadPraises,
        ),
      ),
    );
  }

  void _openGroupBrowser() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: borderColor),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(Icons.view_list, color: accentColor),
                      Text(
                        "Browse Groups",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  //List
                  SizedBox(
                    height: 300,
                    child: ListView.builder(
                      itemCount: (_praises.length / 100).ceil(),
                      itemBuilder: (context,index) {
                        int start = index * 100 + 1;
                        int end = (start + 99).clamp(1, _praises.length);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: borderColor),
                          ),
                          child: ListTile(
                            title: Text(
                              "$start - $end",
                              style: TextStyle(color: textColor),
                            ),
                            trailing: Icon(Icons.arrow_forward_ios, size: 16, color: accentColor),
                            onTap: () {
                              Navigator.pop(context);
                              _openReader(start - 1);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _jumpToPraise() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              Row(
                children: [
                  Icon(Icons.pin, color: accentColor),
                  const SizedBox(width: 10),
                  Text(
                    "Go to Praise",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  hintText: "Enter number",
                  hintStyle: TextStyle(color: textColor.withValues(alpha: 0.5)),
                  filled: true,
                  fillColor: _isDarkMode
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.black.withValues(alpha: 0.02),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: borderColor),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    int? value = int.tryParse(controller.text);

                    if (value != null &&
                        value > 0 &&
                        value <= _praises.length) {
                      Navigator.pop(context);
                      _openReader(value - 1);
                    }
                  },
                  child: const Text("Go"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _continueReadingCard() {
    if (_lastReadIndex <= 0) return const SizedBox();

    return _menuCard(
      title: "Continue Reading (${_lastReadIndex + 1})",
      icon: Icons.history,
      onTap: () {
        _openReader(_lastReadIndex);
      },
    );
  }

  Widget _menuCard({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Icon(icon, color: accentColor),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, size: 16, color: accentColor),
          ],
        ),
      ),
    );
  }


  static const String _themePrefKey = 'isDarkMode';
  static const String _fontSizePrefKey = 'fontSize';
  static const String _lineSpacingPrefKey = 'lineSpacing';
  static const String _lastReadKey = 'lastReadIndex';

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool(_themePrefKey) ?? false;
      _fontSize = prefs.getDouble(_fontSizePrefKey) ?? 17.0;
      _lineSpacing = prefs.getDouble(_lineSpacingPrefKey) ?? 1.5;
      _lastReadIndex = prefs.getInt(_lastReadKey) ?? 0;
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
        _expandedGroup = (_lastReadIndex ~/ 100);
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_lastReadIndex > 0 && _lastReadIndex < _praises.length) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ScrollReaderScreen(
                praises: _praises,
                startIndex: _lastReadIndex,
                isDarkMode: _isDarkMode,
                fontSize: _fontSize,
                lineSpacing: _lineSpacing,
                onPraiseAdded: loadPraises,
              ),
            ),
          );
        }
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
                // _buildContinueReadingBanner(),
                // Scrollable content
                Expanded(
                  child:  ListView(
                    padding: const EdgeInsets.fromLTRB(20,10,20,20),
                    children: [
                    _continueReadingCard(),
                    const SizedBox(height: 10),
                    _menuCard(
                      title: "Start Reading",
                      icon: Icons.menu_book,
                      onTap: () {
                        _openReader(0);
                      },
                    ),
                    _menuCard(
                      title: "Browse by Groups",
                      icon: Icons.view_list,
                      onTap: _openGroupBrowser,
                    ),
                    _menuCard(
                      title: "Jump to Number",
                      icon: Icons.pin,
                      onTap: _jumpToPraise,
                      ),
                    ],
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