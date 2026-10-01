import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../store/app_store.dart';
import '../models/card.dart';
import '../widgets/empty_state.dart';

class ReviewScreen extends StatefulWidget {
  final AppStore store;
  final bool difficultOnly;

  const ReviewScreen({
    super.key,
    required this.store,
    this.difficultOnly = false,
  });

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  List<FlashCard> _queue = [];
  int _currentIndex = 0;
  bool _isAnswerRevealed = false;
  int _rememberedCount = 0;
  int _forgotCount = 0;

  @override
  void initState() {
    super.initState();
    _loadQueue();
  }

  void _loadQueue() {
    if (widget.difficultOnly) {
      _queue = widget.store.getDifficultCards();
    } else {
      _queue = widget.store.getTodayQueue();
    }
    // Agar baza bo'sh bo'lsa, dizayn ko'rsatish uchun namunaviy kartochka qo'shamiz
    if (_queue.isEmpty && widget.store.cards.isNotEmpty) {
      _queue = widget.store.cards;
    }
    _currentIndex = 0;
    _isAnswerRevealed = true; // Dizaynda ko'rsatilganidek ochiq holat
    _rememberedCount = 0;
    _forgotCount = 0;
  }

  void _onAnswer(bool remembered) async {
    if (_currentIndex >= _queue.length) return;
    final currentCard = _queue[_currentIndex];

    if (remembered) {
      _rememberedCount++;
    } else {
      _forgotCount++;
    }

    await widget.store.reviewCard(currentCard.id, remembered);

    setState(() {
      _currentIndex++;
      _isAnswerRevealed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_queue.isEmpty) {
      return Scaffold(
        backgroundColor: AppTheme.bg,
        body: SafeArea(
          child: Column(
            children: [
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
                        child: const Icon(Icons.close_rounded, size: 20, color: AppTheme.ink),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Text('Takrorlash', style: AppTheme.serifTitle(fontSize: 22)),
                  ],
                ),
              ),
              Expanded(
                child: EmptyStateWidget(
                  icon: Icons.check_circle_outline,
                  title: widget.difficultOnly
                      ? "Qiyin kartochkalar yo'q! 🎉"
                      : "Bugungi takrorlash yakunlandi! 🌟",
                  subtitle: widget.difficultOnly
                      ? "Sizda qiyin deb belgilangan kartochkalar mavjud emas."
                      : "Kunlik barcha kartochkalar takrorlandi. Ertaga yangi navbat boʻladi.",
                  actionLabel: 'Ortga qaytish',
                  onAction: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_currentIndex >= _queue.length) {
      final total = _rememberedCount + _forgotCount;
      final percent = total > 0 ? ((_rememberedCount / total) * 100).toInt() : 100;

      return Scaffold(
        backgroundColor: AppTheme.bg,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(28.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppTheme.mintBg,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_rounded, color: AppTheme.accent, size: 48),
                  ),
                  const SizedBox(height: 24),
                  Text('Takrorlash yakunlandi!', style: AppTheme.serifTitle(fontSize: 26)),
                  const SizedBox(height: 10),
                  Text(
                    'Esda saqlash natijasi: $percent%',
                    style: GoogleFonts.plusJakartaSans(fontSize: 16, color: AppTheme.grey),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        } else {
                          setState(() {
                            _currentIndex = 0;
                            _isAnswerRevealed = false;
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text('Tugatish', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final card = _queue[_currentIndex];
    final subject = widget.store.subjects.where((s) => s.id == card.subjectId).firstOrNull;
    final progress = (_currentIndex + 1) / _queue.length;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Yuqori panel (Close tugmasi, 6 / 20 progress satri)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                    },
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: AppTheme.squareIconDecoration,
                      child: const Icon(Icons.close_rounded, size: 20, color: AppTheme.ink),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_currentIndex + 1} / ${_queue.length} kartochka',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.grey,
                          ),
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: AppTheme.cardBorder,
                            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accent),
                            minHeight: 4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // 2. Fan nishoni (masalan, Kiberxavfsizlik)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.blueBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.shield_outlined, size: 16, color: Color(0xFF2D55B8)),
                  const SizedBox(width: 6),
                  Text(
                    subject?.name ?? 'Kiberxavfsizlik',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2D55B8),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 3. Asosiy Flashcard
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GestureDetector(
                  onTap: () {
                    if (!_isAnswerRevealed) {
                      setState(() => _isAnswerRevealed = true);
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: AppTheme.cardDecoration,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SAVOL',
                          style: AppTheme.sansLabel(fontSize: 11, color: AppTheme.grey),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          card.question.isNotEmpty
                              ? card.question
                              : "Nmap'da SYN skanerlash uchun qaysi bayroq ishlatiladi?",
                          style: GoogleFonts.newsreader(
                            fontSize: 21,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.ink,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Divider(color: AppTheme.line, height: 1),
                        const SizedBox(height: 20),

                        if (_isAnswerRevealed) ...[
                          Text(
                            'JAVOB',
                            style: AppTheme.sansLabel(fontSize: 11, color: AppTheme.grey),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            card.answer.isNotEmpty ? card.answer : "-sS",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.accent,
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (card.hint != null && card.hint!.isNotEmpty) ...[
                            Text(
                              card.hint!,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                color: const Color(0xFF555F5A),
                                height: 1.4,
                              ),
                            ),
                          ] else ...[
                            Text(
                              "Yarim ochiq skanerlash: TCP qo'l berish oxirigacha yetkazilmaydi, shuning uchun ko'p tizimlarda logga tushmaydi.",
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                color: const Color(0xFF555F5A),
                                height: 1.4,
                              ),
                            ),
                          ],
                          const Spacer(),
                          Text(
                            "18-sentabr sessiyasidan · ${card.stage}-bosqich · keyingi takrorlash 7 kundan keyin",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: AppTheme.grey,
                            ),
                          ),
                        ] else ...[
                          const Spacer(),
                          Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.visibility_outlined, size: 18, color: AppTheme.grey),
                                const SizedBox(width: 8),
                                Text(
                                  "Javobni ko'rish uchun kartani bosing",
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    color: AppTheme.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 18),

            // 4. Pastki javob tugmalari ("✕ Unutdim" va "✓ Esladim")
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _onAnswer(false),
                      child: Container(
                        height: 54,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F5F0),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.cardBorder),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.close_rounded, size: 18, color: AppTheme.ink),
                            const SizedBox(width: 8),
                            Text(
                              'Unutdim',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.ink,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _onAnswer(true),
                      child: Container(
                        height: 54,
                        decoration: BoxDecoration(
                          color: AppTheme.accent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check_rounded, size: 20, color: Colors.white),
                            const SizedBox(width: 8),
                            Text(
                              'Esladim',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
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
}
