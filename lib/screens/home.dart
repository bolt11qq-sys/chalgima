import 'package:flutter/material.dart';
import '../theme.dart';
import '../store/app_store.dart';
import '../store/timer_service.dart';
import '../widgets/streak_card.dart';
import '../widgets/ring_progress.dart';
import 'review.dart';
import 'timer.dart';
import 'subjects.dart';
import 'cards.dart';
import 'paths.dart';
import 'settings.dart';

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

  @override
  Widget build(BuildContext context) {
    final todaySec = (store.todayStats['total_seconds'] as num?)?.toInt() ?? 0;
    final goalSec = (store.todayStats['goal_seconds'] as num?)?.toInt() ?? (store.dailyGoalMinutes * 60);
    final todayMinutes = todaySec ~/ 60;
    final goalMinutes = goalSec ~/ 60;
    final progress = goalSec > 0 ? (todaySec / goalSec) : 0.0;

    final todayQueue = store.getTodayQueue();
    final reviewsDone = (store.todayStats['reviews_done'] as num?)?.toInt() ?? 0;
    final totalDue = todayQueue.length + reviewsDone;
    final reviewProgress = totalDue > 0 ? (reviewsDone / totalDue) : 1.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Chalg'ima"),
        actions: [
          IconButton(
            icon: const Icon(Icons.alt_route_outlined),
            tooltip: 'Oʻquv yoʻllari (Roadmap)',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => PathsScreen(store: store)),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.style_outlined),
            tooltip: 'Kartochkalar',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CardsScreen(store: store)),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Sozlamalar',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SettingsScreen(store: store, timerService: timerService)),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => store.reloadAll(),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          children: [
            // 1. Streak bloki (Variant D)
            StreakCardWidget(
              streak: store.currentStreak,
              recentStats: store.recentDayStats,
            ),
            const SizedBox(height: 24),

            // 2. Kunlik maqsad doirasi & O'qishni boshlash tugmasi
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color ?? Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.line),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Bugungi oʻqish maqsadi',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.accent.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$todayMinutes / $goalMinutes daq',
                          style: const TextStyle(
                            color: AppTheme.accent,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  RingProgressWidget(
                    progress: progress,
                    size: 170,
                    strokeWidth: 16,
                    centerChild: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: const TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.ink,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          progress >= 1.0 ? 'Maqsadga yetildi! 🎉' : '$todayMinutes daq oʻqildi',
                          style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Katta boshlash tugmasi
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (onNavigateTab != null) {
                          onNavigateTab!(2); // Taymer tabiga o'tish
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TimerScreen(store: store, timerService: timerService),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.ink,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      icon: const Icon(Icons.play_arrow_rounded, size: 28),
                      label: const Text(
                        "O'qishni boshlash",
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 3. Kunlik takrorlash (SRS) vazifasi kartochkasi
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color ?? Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.line),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.accent.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.auto_stories, color: AppTheme.accent, size: 22),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Kunlik takrorlash',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                      Text(
                        '$reviewsDone / $totalDue ta',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.accent),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: reviewProgress.clamp(0.0, 1.0),
                      backgroundColor: AppTheme.line,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accent),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        todayQueue.isNotEmpty
                            ? 'Kutayotgan kartochkalar: ${todayQueue.length} ta'
                            : 'Bugungi hamma kartochkalar takrorlandi! 🌟',
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                      if (todayQueue.isNotEmpty)
                        TextButton(
                          onPressed: () {
                            if (onNavigateTab != null) {
                              onNavigateTab!(1); // Review tabiga o'tish
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ReviewScreen(store: store),
                                ),
                              );
                            }
                          },
                          child: const Text('Boshlash →', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 4. Fanlar bo'yicha o'zlashtirish va haftalik maqsadlar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Fanlar progressi',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => SubjectsScreen(store: store)),
                    );
                  },
                  child: const Text('Barchasi'),
                ),
              ],
            ),
            const SizedBox(height: 8),

            ...store.subjects.where((s) => s.status == 'active').take(4).map((subj) {
              final hours = (subj.totalSeconds / 3600).toStringAsFixed(1);
              final color = _parseColor(subj.color);
              final cardCount = store.cards.where((c) => c.subjectId == subj.id).length;

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color ?? Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.line),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 38,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            subj.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$cardCount kartochka • Maqsad: ${subj.weeklyGoalMin} daq/hafta',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).textTheme.bodySmall?.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '$hours s',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 16),

            // 5. Life Detective tezkor kiritish bloki (5.10)
            _buildLifeDetectiveCard(context),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildLifeDetectiveCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.ink.withOpacity(0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.line),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.line),
            ),
            child: const Icon(Icons.insights, color: AppTheme.ink, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Life Detective',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  'Bugungi uyqu, kayfiyat va sportni belgilang (15 soniya)',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, size: 16),
            onPressed: () => _showLifeDetectiveDialog(context),
          ),
        ],
      ),
    );
  }

  void _showLifeDetectiveDialog(BuildContext context) {
    double sleep = 7.5;
    int mood = 4;
    bool exercise = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Bugungi kun koʻrsatkichlari',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Oʻqish samaradorligingiz bilan bogʻliqlikni topish uchun xizmat qiladi.',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                  const SizedBox(height: 20),
                  // Uyqu
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Tungi uyqu:', style: TextStyle(fontWeight: FontWeight.w600)),
                      Text('${sleep.toStringAsFixed(1)} soat', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.accent)),
                    ],
                  ),
                  Slider(
                    value: sleep,
                    min: 3.0,
                    max: 12.0,
                    divisions: 18,
                    activeColor: AppTheme.accent,
                    onChanged: (val) => setState(() => sleep = val),
                  ),
                  const SizedBox(height: 12),
                  // Kayfiyat
                  const Text('Bugungi kayfiyat:', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      for (int i = 1; i <= 5; i++)
                        GestureDetector(
                          onTap: () => setState(() => mood = i),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: mood == i ? AppTheme.accent.withOpacity(0.15) : Colors.transparent,
                              shape: BoxShape.circle,
                              border: Border.all(color: mood == i ? AppTheme.accent : Colors.transparent, width: 2),
                            ),
                            child: Text(
                              ['😫', '😕', '😐', '🙂', '😄'][i - 1],
                              style: const TextStyle(fontSize: 26),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Sport
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Jismoniy mashq / Sport:', style: TextStyle(fontWeight: FontWeight.w600)),
                      Switch(
                        value: exercise,
                        activeColor: AppTheme.accent,
                        onChanged: (val) => setState(() => exercise = val),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () async {
                        await store.saveLifeDetective(
                          sleepHours: sleep,
                          mood: mood,
                          exercise: exercise ? 1 : 0,
                        );
                        if (ctx.mounted) Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Koʻrsatkichlar saqlandi!')),
                        );
                      },
                      child: const Text('Saqlash', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Color _parseColor(String? hexString) {
    if (hexString == null || hexString.isEmpty) return AppTheme.accent;
    try {
      final buffer = StringBuffer();
      if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
      buffer.write(hexString.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return AppTheme.accent;
    }
  }
}
