import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../store/app_store.dart';
import 'finish_3.dart';

class FinishStep2Screen extends StatefulWidget {
  final AppStore store;
  final Map<String, dynamic> sessionData;
  final int? intentionDone;

  const FinishStep2Screen({
    super.key,
    required this.store,
    required this.sessionData,
    this.intentionDone,
  });

  @override
  State<FinishStep2Screen> createState() => _FinishStep2ScreenState();
}

class _FinishStep2ScreenState extends State<FinishStep2Screen> {
  int _rating = 4; // 1-5
  final String _kind = 'read';
  final TextEditingController _noteController = TextEditingController(
    text: "Tugatdim: TryHackMe Nmap xonasi. Skanerlash turlari va -sV bayrog'i.",
  );

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _addPrefix(String prefix) {
    setState(() {
      if (_noteController.text.isEmpty) {
        _noteController.text = prefix;
      } else {
        _noteController.text = '$prefix ${_noteController.text}';
      }
      _noteController.selection = TextSelection.fromPosition(
        TextPosition(offset: _noteController.text.length),
      );
    });
  }

  void _goToStep3() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FinishStep3Screen(
          store: widget.store,
          sessionData: widget.sessionData,
          rating: _rating,
          kind: _kind,
          note: _noteController.text.trim(),
          intentionDone: widget.intentionDone,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar (Back va 2 / 3)
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
                    '2 / 3',
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
                    'Diqqatingiz qanday edi?',
                    style: GoogleFonts.newsreader(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Vaqt emas, diqqat sifati muhim',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: AppTheme.grey,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 5 ta baho kartochkalari
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildRatingItem(1, '😫'),
                      _buildRatingItem(2, '😕'),
                      _buildRatingItem(3, '🙂'),
                      _buildRatingItem(4, '😀'),
                      _buildRatingItem(5, '🤩'),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Nima o'rgandingiz?
                  Text(
                    "Nima o'rgandingiz?",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.ink,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 3 ta tezkor chip
                  Row(
                    children: [
                      _buildQuickChip('Tugatdim:'),
                      const SizedBox(width: 8),
                      _buildQuickChip('Tushunmadim:'),
                      const SizedBox(width: 8),
                      _buildQuickChip('Keyingi safar:'),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Yozuv kiritish maydoni
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppTheme.cardBorder),
                    ),
                    child: TextField(
                      controller: _noteController,
                      maxLines: 4,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        color: AppTheme.ink,
                        height: 1.4,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                        hintText: "Sessiyada nimalarni o'zlashtirdingiz?",
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Oxirgi yozuvlaringiz
                  Text(
                    'OXIRGI YOZUVLARINGIZ',
                    style: AppTheme.sansLabel(fontSize: 11, color: AppTheme.grey),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '19-sen · Nmap asoslari, host discovery',
                    style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppTheme.grey),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '18-sen · TCP/IP qatlamlari, portlar',
                    style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppTheme.grey),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),

            // Pastki tugmalar (O'tkazib yuborish va Davom)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _goToStep3,
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.cardBorder),
                        ),
                        child: Center(
                          child: Text(
                            "O'tkazib yuborish",
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
                      onTap: _goToStep3,
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppTheme.accent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            'Davom',
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

  Widget _buildRatingItem(int value, String emoji) {
    final isSelected = _rating == value;
    return GestureDetector(
      onTap: () => setState(() => _rating = value),
      child: Container(
        width: 60,
        height: 74,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFDDEEE4) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.accent : AppTheme.cardBorder,
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 26)),
            const SizedBox(height: 4),
            Text(
              '$value',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppTheme.accent : AppTheme.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickChip(String label) {
    return GestureDetector(
      onTap: () => _addPrefix(label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.cardBorder),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppTheme.ink,
          ),
        ),
      ),
    );
  }
}
