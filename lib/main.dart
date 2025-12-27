import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const ThousandPraiseApp());
}

class ThousandPraiseApp extends StatelessWidget {
  const ThousandPraiseApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Thousand Praises',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.amber,
        textTheme: GoogleFonts.notoSerifTamilTextTheme(),
      ),
      home: const PraiseReaderScreen(),
    );
  }
}

class PraiseReaderScreen extends StatefulWidget {
  const PraiseReaderScreen({Key? key}) : super(key: key);

  @override
  State<PraiseReaderScreen> createState() => _PraiseReaderScreenState();
}

class _PraiseReaderScreenState extends State<PraiseReaderScreen> with TickerProviderStateMixin {
  List<dynamic> _praises = [];
  bool _isLoading = true;

  // Settings
  double _fontSize = 15.0;
  bool _isDarkMode = false;
  double _lineSpacing = 1.8;
  bool _showSettings = false;

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
    loadPraises();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _settingsAnimController.dispose();
    super.dispose();
  }

  Future<void> loadPraises() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/praises.json');
      final List<dynamic> jsonData = json.decode(jsonString);
      setState(() {
        _praises = jsonData;
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

  Color get bgColor => _isDarkMode ? const Color(0xFF0D1117) : const Color(0xFFFDF6E3);
  Color get textColor => _isDarkMode ? const Color(0xFFE6EDF3) : const Color(0xFF2C2416);
  Color get accentColor => _isDarkMode ? const Color(0xFFFFB74D) : const Color(0xFFD97706);
  Color get cardColor => _isDarkMode ? const Color(0xFF161B22) : const Color(0xFFFFFBF0);
  Color get borderColor => _isDarkMode ? const Color(0xFF30363D) : const Color(0xFFE5D5B7);

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

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // Decorative background pattern
          Positioned.fill(
            child: CustomPaint(
              painter: BackgroundPatternPainter(
                color: _isDarkMode ? Colors.white.withOpacity(0.02) : Colors.black.withOpacity(0.02),
              ),
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
                      return _buildPraiseCard(_praises[index], index);
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
                color: Colors.black.withOpacity(0.5),
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
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: borderColor, width: 1),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.auto_stories, color: accentColor, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ஆயிரம் துதிகள்',
                  style: GoogleFonts.notoSerifTamil(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                Text(
                  '${_praises.length} துதிகள்',
                  style: TextStyle(
                    fontSize: 12,
                    color: textColor.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.tune, color: textColor, size: 24),
            onPressed: _toggleSettings,
          ),
        ],
      ),
    );
  }

  Widget _buildPraiseCard(dynamic praise, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: _isDarkMode
                ? Colors.black.withOpacity(0.3)
                : Colors.brown.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Number badge and reference
          Row(
            children: [
              // Number circle
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: accentColor.withOpacity(0.3), width: 2),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: GoogleFonts.notoSerifTamil(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Reference badge
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: accentColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    praise['reference'],
                    style: GoogleFonts.notoSerifTamil(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: accentColor,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Decorative divider
          Row(
            children: [
              Expanded(child: Divider(color: borderColor, thickness: 1)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Icon(Icons.auto_awesome, color: accentColor, size: 14),
              ),
              Expanded(child: Divider(color: borderColor, thickness: 1)),
            ],
          ),

          const SizedBox(height: 20),

          // Opening quote
          Transform.rotate(
            angle: 3.14159,
            child: Icon(
              Icons.format_quote,
              color: accentColor.withOpacity(0.3),
              size: 32,
            ),
          ),

          const SizedBox(height: 12),

          // Praise text
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: RichText(
              textAlign: TextAlign.justify,
              text: TextSpan(
                text: _praises[index]['praise'] ?? 'Praise Missing',
                style: GoogleFonts.notoSerifTamil(
                  fontSize: _fontSize,
                  height: _lineSpacing,
                  color: textColor,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Closing quote
          Align(
            alignment: Alignment.bottomRight,
            child: Icon(
              Icons.format_quote,
              color: accentColor.withOpacity(0.3),
              size: 32,
            ),
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: borderColor)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'வாசிப்பு அமைப்புகள்',
                    style: GoogleFonts.notoSerifTamil(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textColor,
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
                padding: const EdgeInsets.all(20),
                children: [
                  // Font size
                  _buildSettingSection(
                    'எழுத்து அளவு',
                    Icons.format_size,
                  ),
                  Row(
                    children: [
                      Text('அ', style: TextStyle(fontSize: 14, color: textColor)),
                      Expanded(
                        child: Slider(
                          value: _fontSize,
                          min: 16,
                          max: 36,
                          divisions: 20,
                          activeColor: accentColor,
                          inactiveColor: borderColor,
                          onChanged: (value) => setState(() => _fontSize = value),
                        ),
                      ),
                      Text('அ', style: TextStyle(fontSize: 28, color: textColor)),
                    ],
                  ),
                  Center(
                    child: Text(
                      '${_fontSize.round()} pt',
                      style: TextStyle(color: textColor.withOpacity(0.6), fontSize: 14),
                    ),
                  ),

                  const SizedBox(height: 24),

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
                    onChanged: (value) => setState(() => _lineSpacing = value),
                  ),

                  const SizedBox(height: 24),

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
                        style: GoogleFonts.notoSerifTamil(
                          fontSize: 16,
                          color: textColor,
                        ),
                      ),
                      value: _isDarkMode,
                      activeColor: accentColor,
                      onChanged: (value) => setState(() => _isDarkMode = value),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Reset button
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _fontSize = 22.0;
                        _lineSpacing = 1.8;
                        _isDarkMode = false;
                      });
                    },
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text(
                      'இயல்புநிலைக்கு மீட்டமை',
                      style: GoogleFonts.notoSerifTamil(fontSize: 16),
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
            style: GoogleFonts.notoSerifTamil(
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