import 'package:flutter/material.dart';
import '../theme.dart';
import '../srs/scheduler.dart';
import '../models/review.dart';

class StreakCardWidget extends StatelessWidget {
  final int streak;
  final List<DayStat> recentStats;

  const StreakCardWidget({
    super.key,
    required this.streak,
    required this.recentStats,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    // Haftaning kunlari: Dushanba (1) dan Yakshanba (7) gacha
    final weekDayNames = ['D', 'S', 'CH', 'P', 'J', 'SH', 'Y'];
    final currentWeekday = now.weekday; // 1 = Mon, 7 = Sun

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.amber,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.amber.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
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
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.local_fire_department,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$streak kunlik ketma-ketlik',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        streak > 0
                            ? 'Ajoyib natija! Oʻqish maromini saqlang.'
                            : 'Bugun oʻqishni boshlang va seriyani yoqing!',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          // Hafta kunlari indikatori
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final dayIndex = index + 1; // 1 to 7
              final isToday = dayIndex == currentWeekday;
              final isPast = dayIndex < currentWeekday;

              // Hafta kuni uchun day_key topish
              final diff = dayIndex - currentWeekday;
              final targetDate = now.add(Duration(days: diff));
              final targetKey = SrsScheduler.getDayKey(targetDate);

              final dayStat = recentStats.where((s) => s.dayKey == targetKey).firstOrNull;
              final hasCompleted = dayStat != null && (dayStat.totalSeconds >= (dayStat.goalSeconds / 2));

              Color circleBg;
              Widget iconOrText;

              if (hasCompleted) {
                circleBg = Colors.white;
                iconOrText = const Icon(Icons.check, size: 16, color: AppTheme.amber);
              } else if (isToday) {
                circleBg = Colors.white.withOpacity(0.3);
                iconOrText = Text(
                  weekDayNames[index],
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                );
              } else if (isPast) {
                circleBg = Colors.black.withOpacity(0.12);
                iconOrText = Text(
                  weekDayNames[index],
                  style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13),
                );
              } else {
                circleBg = Colors.white.withOpacity(0.15);
                iconOrText = Text(
                  weekDayNames[index],
                  style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13),
                );
              }

              return Column(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: circleBg,
                      shape: BoxShape.circle,
                      border: isToday
                          ? Border.all(color: Colors.white, width: 2)
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: iconOrText,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    weekDayNames[index],
                    style: TextStyle(
                      color: Colors.white.withOpacity(isToday ? 1.0 : 0.75),
                      fontSize: 11,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}
