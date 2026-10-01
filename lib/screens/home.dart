import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../store/app_store.dart';
import '../store/timer_service.dart';
import '../widgets/ring_progress.dart';
import 'review.dart';
import 'timer.dart';
import 'history.dart';
import 'settings.dart';
import 'nazar.dart';

class HomeScreen extends StatelessWidget {
  final AppStore store;
  final TimerService? timerService;
  final Function(int)? onNavigateTab;

  const HomeScreen({
    super.key,
    required this.store,
    this.timerService,
    this.onNavigateTab,
  });

  String _getWeekdayUz(int weekday) {
    switch (weekday) {
      case 1: return 'DUSHANBA';
      case 2: return 'SESHANBA';
      case 3: return 'CHORSHANBA';
      case 4: return 'PAYSHANBA';
      case 5: return 'JUMA';
      case 6: return 'SHANBA';
      case 7: return 'YAKSHANBA';
      default: return 'BUGUN';
    }
  }

  String _getDateUz(DateTime date) {
    final months = [
      'yanvar', 'fevral', 'mart', 'aprel', 'may', 'iyun',
      'iyul', 'avgust', 'sentabr', 'oktabr', 'noyabr', 'dekabr'
    ];
    return '${date.day}-${months[date.month - 1]}';
  }

  String _formatDuration(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    if (h > 0) {
      return '$h:${m.toString().padLeft(2, '0')}';
    }
    return '0:${m.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final todaySec = (store.todayStats['total_seconds'] as num?)?.toInt() ?? 9720; // 2:42 (9720s) namuna/haqiqiy
    final goalSec = (store.todayStats['goal_seconds'] as num?)?.toInt() ?? (3 * 3600); // 3 soat
    final progress = goalSec > 0 ? (todaySec / goalSec).clamp(0.0, 1.0) : 0.0;
    final remainingSec = (goalSec - todaySec).clamp(0, goalSec);
    final remainingMins = remainingSec ~/ 60;

    final todayQueue = store.getTodayQueue();
    final cardQueueCount = todayQueue.isNotEmpty ? todayQueue.length : 14;
    final streakDays = store.currentStreak > 0 ? store.currentStreak : 13;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => store.reloadAll(),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            children: [
              // 1. Yuqori sarlavha qatori (YAKSHANBA, 27-sentabr va Sozlamalar tugmasi)
              Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getWeekdayUz(now.weekday),
                          style: AppTheme.sansLabel(fontSize: 12, letterSpacing: 1.5, color: AppTheme.grey),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _getDateUz(now),
                          style: AppTheme.serifTitle(fontSize: 32, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SettingsScreen(store: store, timerService: timerService),
                          ),
                        );
                      },
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: AppTheme.squareIconDecoration,
                        child: const Icon(Icons.settings_outlined, color: AppTheme.ink, size: 22),
                      ),
                    ),
                  ],
                ),
              ),

              // 2. 1-Karta: Doiraviy taymer, Maqsadgacha qolgan vaqt, Streak va Boshlash tugmasi
              Container(
                padding: const EdgeInsets.all(20),
                decoration: AppTheme.cardDecoration,
                child: Row(
                  children: [
                    // Doiraviy progress
                    RingProgressWidget(
                      progress: progress,
                      size: 130,
                      strokeWidth: 12,
                      progressColor: AppTheme.accent,
                      backgroundColor: const Color(0xFFE8EDE7),
                      centerChild: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _formatDuration(todaySec),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.ink,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${(goalSec ~/ 3600)}:00 dan',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: AppTheme.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 18),
                    // O'ng tomondagi matnlar va tugma
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            remainingMins > 0
                                ? 'Maqsadgacha $remainingMins daqiqa qoldi.'
                                : 'Bugungi maqsad bajarildi! 🎉',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              color: AppTheme.grey,
                              fontWeight: FontWeight.w500,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Streak nishoni
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.amberBg,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '$streakDays kun ketma-ket',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF965C13),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          // Boshlash tugmasi
                          GestureDetector(
                            onTap: () {
                              if (onNavigateTab != null) {
                                onNavigateTab!(2);
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => TimerScreen(store: store, timerService: timerService),
                                  ),
                                );
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                color: AppTheme.accent,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 20),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Boshlash',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // 3. 2-Karta: Takrorlash nishoni (14 ta kartochka)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: AppTheme.cardDecoration,
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppTheme.mintBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.psychology_outlined, color: AppTheme.accent, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$cardQueueCount ta kartochka',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AppTheme.ink,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Takrorlash vaqti keldi',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: AppTheme.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (onNavigateTab != null) {
                          onNavigateTab!(1);
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ReviewScreen(store: store),
                            ),
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.mintBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Boshlash',
                          style: GoogleFonts.plusJakartaSans(
                            color: AppTheme.accent,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // 4. 3-Karta: Bugungi sessiyalar va inline Kunni yakunlash
              Container(
                padding: const EdgeInsets.all(20),
                decoration: AppTheme.cardDecoration,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BUGUNGI SESSIYALAR',
                      style: AppTheme.sansLabel(fontSize: 12, color: AppTheme.grey),
                    ),
                    const SizedBox(height: 16),

                    // Sessiya 1: Kiberxavfsizlik
                    _buildTodaySessionItem(
                      icon: Icons.shield_outlined,
                      iconBg: AppTheme.blueBg,
                      iconColor: const Color(0xFF3E5FCC),
                      title: 'Kiberxavfsizlik',
                      duration: '1:12',
                    ),
                    const Divider(color: AppTheme.line, height: 20),

                    // Sessiya 2: Ingliz tili
                    _buildTodaySessionItem(
                      icon: Icons.language_outlined,
                      iconBg: AppTheme.mintBg,
                      iconColor: AppTheme.accent,
                      title: 'Ingliz tili',
                      duration: '0:45',
                    ),
                    const SizedBox(height: 14),

                    // Inline Kunni yakunlash qutisi
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F6F2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFEBE8E1)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Eslatildi: sessiyalarni keyinroq yakunlashingiz mumkin.")),
                                );
                              },
                              child: Container(
                                height: 44,
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: AppTheme.cardBorder),
                                ),
                                child: Center(
                                  child: Text(
                                    'Keyinroq',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.ink,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 2,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => NazarScreen(store: store)),
                                );
                              },
                              child: Container(
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppTheme.accent,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Center(
                                  child: Text(
                                    'Kunni yakunlash',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13,
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
                    const SizedBox(height: 14),

                    // Sessiya 3: Flutter
                    _buildTodaySessionItem(
                      icon: Icons.code_rounded,
                      iconBg: const Color(0xFFFDF0E2),
                      iconColor: const Color(0xFFB4690E),
                      title: 'Flutter',
                      duration: '0:45',
                    ),
                    const Divider(color: AppTheme.line, height: 22),

                    // Butun tarix havolasi
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => HistoryScreen(store: store)),
                        );
                      },
                      child: Text(
                        'Butun tarix',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // 5. 4-Karta: Bu hafta (haftalik bar chart)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: AppTheme.cardDecoration,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'BU HAFTA',
                          style: AppTheme.sansLabel(fontSize: 12, color: AppTheme.grey),
                        ),
                        Text(
                          '14 s 20 daq',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            color: AppTheme.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // 7 ta bar (D, S, C, P, J, S, Y)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildWeekBar(label: 'D', height: 42, color: AppTheme.accent),
                        _buildWeekBar(label: 'S', height: 56, color: AppTheme.accent),
                        _buildWeekBar(label: 'C', height: 26, color: AppTheme.accent),
                        _buildWeekBar(label: 'P', height: 56, color: AppTheme.accent),
                        _buildWeekBar(label: 'J', height: 46, color: const Color(0xFFB06A12)), // Amber
                        _buildWeekBar(label: 'S', height: 18, color: AppTheme.accent),
                        _buildWeekBar(label: 'Y', height: 38, color: const Color(0xFF8BAC9A)), // Sage
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // 6. 5-Karta: Qorong'i "Kunni yakunlash" kartochkasi (Nazar moduli)
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => NazarScreen(store: store)),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppTheme.darkCard,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFF324039),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.nightlight_round, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Kunni yakunlash',
                              style: GoogleFonts.newsreader(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "Va'da + ikki savol · 30 soniya",
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: const Color(0xFF9AA59F),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 16),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTodaySessionItem({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String duration,
  }) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppTheme.ink,
            ),
          ),
        ),
        Text(
          duration,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppTheme.ink,
          ),
        ),
      ],
    );
  }

  Widget _buildWeekBar({
    required String label,
    required double height,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 38,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppTheme.grey,
          ),
        ),
      ],
    );
  }
}
