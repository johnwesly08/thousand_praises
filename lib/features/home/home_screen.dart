import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thousand_praises/core/ui/settings_bottom_sheet.dart';
import '../reader/scroll_reading_screen.dart';
import '../../core/services/praise_storage.dart';
import '../../core/theme/app_colors.dart';
import 'package:thousand_praises/core/services/settings_service.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  List<dynamic> _praises = [];

  // Settings
  bool _isDarkMode = false;
  double _fontSize = 17.0;
  double _lineSpacing = 1.5;
  bool _isLoading = true;
  int _lastReadIndex = 0;
  static const bool devMode = true;

  Color get bgColor => AppColors.bg(_isDarkMode);
  Color get textColor => AppColors.text(_isDarkMode);
  Color get accentColor => AppColors.accent(_isDarkMode);
  Color get borderColor => AppColors.border(_isDarkMode);
  Color get cardColor => AppColors.card(_isDarkMode);

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    loadPraises();
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
    ).then((_) {
      _loadPreferences();
    });
  }

  void _openGroupBrowser() {
    showModalBottomSheet(
      context: context,
      elevation: 8,
      backgroundColor: Colors.black.withValues(alpha: 0.2),
      isScrollControlled: false,
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

  Future<void> _loadPreferences() async {
    _isDarkMode = await SettingsService.getDarkMode();
    _fontSize = await SettingsService.getFontSize();
    _lineSpacing = await SettingsService.getLineSpacing();

    final prefs = await SharedPreferences.getInstance();
    _lastReadIndex = prefs.getInt("lastReadIndex") ?? 0;

    print("Loaded last index: $_lastReadIndex"); // debug

    setState(() {});
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
            icon: Icon(Icons.tune, color: textColor),
            onPressed: () {
              showSettingsBottomSheet(
                context: context,
                isDarkMode: _isDarkMode,
                fontSize: _fontSize,
                lineSpacing: _lineSpacing,

                showFontSize: false,        // 🔥 Home = minimal
                showLineSpacing: false,

                onThemeChanged: (value) async {
                  await SettingsService.setDarkMode(value);
                  setState(() => _isDarkMode = value);
                },

                onFontChanged: (_) {},      // not needed
                onSpacingChanged: (_) {},   // not needed

                onReset: () async {
                  await SettingsService.reset();
                  await _loadPreferences();
                },
              );
            },
          ),

          if(devMode)
            IconButton(
              icon: Icon(Icons.upload_file, color: textColor),
              tooltip: 'Export Praises',
              onPressed: () async {
                try {
                  await exportUserPraises();
                  if (!mounted) return;
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: bgColor,
        body: Center(
          child: CircularProgressIndicator(color: accentColor),
        ),
      );
    }
    return PopScope(
      onPopInvokedWithResult: (didPop,result) {
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
                  // Scrollable content
                  Expanded(
                    child:  ListView(
                      padding: const EdgeInsets.fromLTRB(20,10,20,20),
                      children: [
                        if (_lastReadIndex > 0) ...[
                        _continueReadingCard(),
                        const SizedBox(height: 10),
                      ],
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
          ],
        ),
      ),
    );
  }
}
