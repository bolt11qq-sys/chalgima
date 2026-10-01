import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../store/app_store.dart';

class FinishStep3Screen extends StatefulWidget {
  final AppStore store;
  final Map<String, dynamic> sessionData;
  final int rating;
  final String kind;
  final String note;
  final int? intentionDone;

  const FinishStep3Screen({
    super.key,
    required this.store,
    required this.sessionData,
    required this.rating,
    required this.kind,
    required this.note,
    this.intentionDone,
  });

  @override
  State<FinishStep3Screen> createState() => _FinishStep3ScreenState();
}

class _FinishStep3ScreenState extends State<FinishStep3Screen> {
  int _tabIndex = 0; // 0: Savol · javob, 1: Bo'sh joy
  final TextEditingController _cardsController = TextEditingController(
    text: "SYN skanerlash bayrog'i :: -sS\nVersiyani aniqlash bayrog'i :: -sV",
  );

  List<Map<String, String>> _parsedCards = [
    {"q": "SYN skanerlash bayrog'i", "a": "-sS"},
    {"q": "Versiyani aniqlash bayrog'i", "a": "-sV"},
  ];

  @override
  void initState() {
    super.initState();
    _cardsController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _cardsController.removeListener(_onTextChanged);
    _cardsController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final text = _cardsController.text;
    final lines = text.split('\n').where((l) => l.contains('::')).toList();
    setState(() {
      _parsedCards = lines.map((l) {
        final parts = l.split('::');
        return {
          "q": parts[0].trim(),
          "a": parts.length > 1 ? parts[1].trim() : '',
        };
      }).toList();
    });
  }

  void _removeCard(int index) {
    if (index >= 0 && index < _parsedCards.length) {
      final list = List<Map<String, String>>.from(_parsedCards)..removeAt(index);
      final newText = list.map((c) => "${c['q']} :: ${c['a']}").join('\n');
      _cardsController.text = newText;
    }
  }

  void _save(bool includeCards) async {
    final lines = includeCards
        ? _parsedCards.map((c) => "${c['q']} :: ${c['a']}").toList()
        : <String>[];

    await widget.store.saveCompletedSession(
      baseData: widget.sessionData,
      rating: widget.rating,
      note: widget.note.isNotEmpty ? widget.note : null,
      kind: widget.kind,
      intentionDone: widget.intentionDone,
      quickCardsText: lines,
    );

    if (mounted) {
      Navigator.popUntil(context, (route) => route.isFirst);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            lines.isNotEmpty
                ? 'Sessiya va ${lines.length} ta kartochka saqlandi! 🎉'
                : 'Sessiya saqlandi! Baraka toping.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar (Back va 3 / 3)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: AppTheme.squareIconDecoration,
                      child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppTheme.ink),
                    ),
                  ),
                  Text(
                    '3 / 3',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.grey,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                children: [
                  Text(
                    'Takrorlash uchun kartochka',
                    style: GoogleFonts.newsreader(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Hozir yozsangiz, mavzu yodda turibdi. Keyin bu savollar o'zi qaytib keladi.",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: AppTheme.grey,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Segmented control (Savol · javob / Bo'sh joy)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8EBE6),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        _buildTabItem(0, 'Savol · javob'),
                        _buildTabItem(1, "Bo'sh joy"),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Tez yozuv kartasi
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: AppTheme.cardDecoration,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TEZ YOZUV',
                          style: AppTheme.sansLabel(fontSize: 11, color: AppTheme.grey),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _cardsController,
                          maxLines: 3,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.ink,
                            height: 1.4,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Har qatorda: savol :: javob',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: AppTheme.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Qo'shildi ro'yxati
                  if (_parsedCards.isNotEmpty) ...[
                    Text(
                      "QO'SHILDI · ${_parsedCards.length} ta",
                      style: AppTheme.sansLabel(fontSize: 11, color: AppTheme.grey),
                    ),
                    const SizedBox(height: 12),
                    ...List.generate(_parsedCards.length, (index) {
                      final item = _parsedCards[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.cardBorder),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['q'] ?? '',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.ink,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    item['a'] ?? '',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.accent,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _removeCard(index),
                              child: const Icon(Icons.delete_outline_rounded, size: 20, color: AppTheme.grey),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                  const SizedBox(height: 20),
                ],
              ),
            ),

            // Pastki tugmalar (Keyinroq va Saqlash)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _save(false),
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.cardBorder),
                        ),
                        child: Center(
                          child: Text(
                            'Keyinroq',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.ink,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _save(true),
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppTheme.accent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            'Saqlash',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
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

  Widget _buildTabItem(int index, String label) {
    final isSelected = _tabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tabIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppTheme.ink : AppTheme.grey,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
