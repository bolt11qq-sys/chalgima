import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../store/app_store.dart';
import '../models/card.dart';
import 'card_edit.dart';

class CardsScreen extends StatefulWidget {
  final AppStore store;

  const CardsScreen({super.key, required this.store});

  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  String _selectedFilter = 'Hammasi'; // Hammasi, Bugun, Qiyin, Kiberxavfsizlik

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Top Bar (Back, Kartochkalar va +)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
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
                  Expanded(
                    child: Center(
                      child: Text(
                        'Kartochkalar',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.ink,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => CardEditScreen(store: widget.store)),
                      ).then((_) => setState(() {}));
                    },
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: AppTheme.squareIconDecoration,
                      child: const Icon(Icons.add, size: 22, color: AppTheme.ink),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                children: [
                  // 2. 3 ta ko'rsatkich kartochkalari
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricTile('Jami', '142', AppTheme.ink),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildMetricTile('Bugun', '14', AppTheme.accent),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildMetricTile('Qiyin', '6', const Color(0xFFC4453C)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 3. Filtr chiplari
                  SizedBox(
                    height: 38,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildFilterPill('Hammasi'),
                        const SizedBox(width: 8),
                        _buildFilterPill('Bugun'),
                        const SizedBox(width: 8),
                        _buildFilterPill('Qiyin'),
                        const SizedBox(width: 8),
                        _buildFilterPill('Kiberxavfsizlik'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 4. Kartochkalar ro'yxati (Maketdagi namunalar bilan to'ldirilgan)
                  _buildFlashCardItem(
                    question: 'Nmap: SYN skanerlash bayrog\'i?',
                    answer: '-sS',
                    filledDots: 3,
                    dotColor: const Color(0xFF3E5FCC),
                    dueText: 'Keyingi takrorlash: 4-oktabr',
                  ),
                  const SizedBox(height: 10),

                  _buildFlashCardItem(
                    question: 'Privilege escalation nima?',
                    answer: 'Tizimda yuqori huquqlarga ko\'tarilish',
                    filledDots: 2,
                    dotColor: const Color(0xFF3E5FCC),
                    dueText: 'Keyingi takrorlash: 29-sentabr',
                  ),
                  const SizedBox(height: 10),

                  _buildFlashCardItem(
                    question: '<to put off> ma\'nosi?',
                    answer: 'kechiktirmoq, orqaga surmoq',
                    badge: 'qiyin',
                    filledDots: 1,
                    dotColor: AppTheme.accent,
                    dueText: 'Ertaga takrorlanadi',
                  ),
                  const SizedBox(height: 10),

                  _buildFlashCardItem(
                    question: 'SQLite\'da ustun qo\'shish buyrug\'i?',
                    answer: 'ALTER TABLE ... ADD COLUMN',
                    filledDots: 4,
                    dotColor: const Color(0xFFB4690E),
                    dueText: 'Keyingi takrorlash: 18-oktabr',
                  ),
                  const SizedBox(height: 10),

                  _buildFlashCardItem(
                    question: 'HTTP 403 kodi nimani bildiradi?',
                    answer: 'Kirish taqiqlangan',
                    filledDots: 5,
                    dotColor: const Color(0xFF3E5FCC),
                    dueText: 'O\'zlashtirilgan · 60 kun',
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile(String label, String value, Color valColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: AppTheme.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: valColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPill(String label) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.accent : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.accent : AppTheme.cardBorder,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? Colors.white : AppTheme.ink,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFlashCardItem({
    required String question,
    required String answer,
    String? badge,
    required int filledDots,
    required Color dotColor,
    required String dueText,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  question,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.ink,
                  ),
                ),
              ),
              if (badge != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDE8E8),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    badge,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFC4453C),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),
          Text(
            answer,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // 5 ta bosqich nuqtalari
              Row(
                children: List.generate(5, (index) {
                  final isFilled = index < filledDots;
                  return Container(
                    margin: const EdgeInsets.only(right: 4),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isFilled ? dotColor : const Color(0xFFCBD5E1),
                      shape: BoxShape.circle,
                    ),
                  );
                }),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  dueText,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: AppTheme.grey,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CardEditScreen(
                        store: widget.store,
                        cardToEdit: FlashCard(
                          id: 0,
                          subjectId: 1,
                          type: 'qa',
                          question: question,
                          answer: answer,
                          stage: filledDots,
                          intervalDays: 1,
                          nextDue: '',
                          correctCount: 0,
                          wrongCount: 0,
                          streakCorrect: 0,
                          status: 'active',
                          difficult: badge != null,
                          createdAt: 0,
                        ),
                      ),
                    ),
                  );
                },
                child: const Icon(Icons.edit_outlined, size: 18, color: AppTheme.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
