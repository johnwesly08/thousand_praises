import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thousand_praises/core/ui/settings_bottom_sheet.dart';
import 'package:thousand_praises/core/services/praise_storage.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:thousand_praises/core/theme/app_colors.dart';

class ScrollReaderScreen extends StatefulWidget {
  final List praises;
  final int startIndex;
  final bool isDarkMode;
  final double? fontSize;
  final double? lineSpacing;
  final VoidCallback onPraiseAdded;

  const ScrollReaderScreen({
    super.key,
    required this.praises,
    required this.startIndex,
    required this.isDarkMode,
    required this.fontSize,
    required this.lineSpacing,
    required this.onPraiseAdded,
  });

  @override
  State<ScrollReaderScreen> createState() => _ScrollReaderScreenState();
}

class _ScrollReaderScreenState extends State<ScrollReaderScreen> {
  DateTime _lastSavedTime = DateTime.now();
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionListener = ItemPositionsListener.create();
  static const String lastReadKey = "lastReadIndex";
  static const bool devMode = true;
  bool _isDarkMode = false;
  double _fontSize = 17.0;
  double _lineSpacing = 1.5;

  Color get bgColor => AppColors.bg(_isDarkMode);
  Color get textColor => AppColors.text(_isDarkMode);
  Color get cardColor => AppColors.card(_isDarkMode);
  Color get borderColor => AppColors.border(_isDarkMode);
  Color get accentColor => AppColors.accent(_isDarkMode);

  @override
  void initState() {
    super.initState();

    _isDarkMode = widget.isDarkMode;
    _fontSize = widget.fontSize ?? 17.0;
    _lineSpacing = widget.lineSpacing ?? 1.5;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _itemScrollController.jumpTo(index: widget.startIndex);
    });

    _itemPositionListener.itemPositions.addListener(_saveReadingPosition);
  }

  @override
  void dispose() {
    _saveReadingPosition();
    super.dispose();
  }

  void _scrollToBottom() {
    _itemScrollController.scrollTo(
      index: widget.praises.length - 1,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOut,
    );
  }

  void _openAddPraiseSheet() {
    final referenceController = TextEditingController();
    final praiseController = TextEditingController();

    showModalBottomSheet(
      context: context,
      elevation: 8,
      backgroundColor: Colors.black.withValues(alpha: 0.2),
      isScrollControlled: false,
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
                            fillColor: widget.isDarkMode
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
                            fillColor: widget.isDarkMode
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

                        widget.onPraiseAdded();

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

  Future<void> _saveReadingPosition() async {
    final now = DateTime.now();

    if (now.difference(_lastSavedTime).inMilliseconds < 500) return;
    _lastSavedTime = now;

    final positions = _itemPositionListener.itemPositions.value;

    if (positions.isEmpty) return;

    final visibleItems = positions.toList()
      ..sort((a, b) => a.itemLeadingEdge.compareTo(b.itemLeadingEdge));

    final firstVisible = visibleItems.first;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(lastReadKey, firstVisible.index);

    print("Saved index: ${firstVisible.index}"); // 🔥 DEBUG
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,

      appBar: AppBar(
        title: const Text("1000 ஸ்தோத்திரங்கள்"),
        backgroundColor: bgColor,
        foregroundColor: textColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.tune, color: textColor),
            onPressed: () {
              showSettingsBottomSheet(
                context: context,
                isDarkMode: _isDarkMode,
                fontSize: _fontSize,
                lineSpacing: _lineSpacing,

                showFontSize: true,        // 🔥 FULL SETTINGS HERE
                showLineSpacing: true,

                onThemeChanged: (value) async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool("isDarkMode", value);
                  setState(() => _isDarkMode = value);
                },

                onFontChanged: (value) async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setDouble("fontSize", value);
                  setState(() => _fontSize = value);
                },

                onSpacingChanged: (value) async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setDouble("lineSpacing", value);
                  setState(() => _lineSpacing = value);
                },

                onReset: () async {
                  final prefs = await SharedPreferences.getInstance();

                  await prefs.setBool("isDarkMode", false);
                  await prefs.setDouble("fontSize", 17.0);
                  await prefs.setDouble("lineSpacing", 1.5);

                  setState(() {
                    _isDarkMode = false;
                    _fontSize = 17.0;
                    _lineSpacing = 1.5;
                  });
                },
              );
            },
          ),
        ],
      ),

      floatingActionButton: devMode
          ? Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: "scrollBottom",
            backgroundColor: accentColor,
            foregroundColor: textColor,
            onPressed: _scrollToBottom,
            child: const Icon(Icons.arrow_downward),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: "addPraise",
            backgroundColor: accentColor,
            foregroundColor: textColor,
            onPressed: _openAddPraiseSheet,
            child: const Icon(Icons.add),
          ),
        ],
      ) : null,

      body: Stack(
        children: [

          /// MAIN LIST
          ScrollablePositionedList.builder(
            itemScrollController: _itemScrollController,
            itemPositionsListener: _itemPositionListener,
            padding: const EdgeInsets.all(20),
            physics: const BouncingScrollPhysics(),
            itemCount: widget.praises.length,
            itemBuilder: (context, index) {
              final praise = widget.praises[index];
              return RepaintBoundary(
                child: _buildPraiseCard(praise, index),
              );
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
          Row(
            children: [
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Text(
              praise['praise'] ?? 'Praise Missing',
              style: TextStyle(
                fontSize: _fontSize,
                height: _lineSpacing,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}