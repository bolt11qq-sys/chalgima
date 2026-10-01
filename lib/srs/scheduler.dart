import 'dart:math';
import '../models/card.dart';

class SrsScheduler {
  // Standart QA intervallari (kunlarda): stage 0..5
  static const List<int> qaIntervals = [0, 1, 3, 7, 21, 60];

  // Vaziyat (scenario) intervallari: vaziyat faktdan ko'ra sekinroq unutiladi
  static const List<int> scenarioIntervals = [0, 3, 7, 21, 60, 120];

  /// 5.1 Kun chegarasi: Kun 04:00 da almashadi.
  /// Soat 01:30 da tugagan sessiya kechagi day_key ga yoziladi.
  static String getDayKey([DateTime? date]) {
    final now = date ?? DateTime.now();
    DateTime adjusted = now;
    if (now.hour < 4) {
      adjusted = now.subtract(const Duration(days: 1));
    }
    final y = adjusted.year.toString().padLeft(4, '0');
    final m = adjusted.month.toString().padLeft(2, '0');
    final d = adjusted.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  /// Sanaga kun qo'shish
  static String addDaysToKey(String dayKey, int days) {
    final parts = dayKey.split('-').map(int.parse).toList();
    final dt = DateTime(parts[0], parts[1], parts[2]).add(Duration(days: days));
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  /// 5.4 Esladim: stage + 1 (5 dan oshmaydi), next_due = bugun + interval
  static Map<String, dynamic> processRemembered(FlashCard card, String todayKey) {
    final nextStage = min(5, card.stage + 1);
    final intervals = card.type == 'scenario' ? scenarioIntervals : qaIntervals;
    final intervalDays = intervals[nextStage];
    final nextDue = addDaysToKey(todayKey, intervalDays);

    final newCorrect = card.correctCount + 1;
    final newStreak = card.streakCorrect + 1;
    // Agar ko'p marta xato qilgan bo'lsa, qiyin maqomi ketma-ket 3 ta to'g'ri bo'lmaguncha qoladi
    final isDifficult = card.wrongCount >= 3 && newStreak < 3;

    return {
      'stage': nextStage,
      'interval_days': intervalDays,
      'next_due': nextDue,
      'correct_count': newCorrect,
      'streak_correct': newStreak,
      'last_seen': DateTime.now().millisecondsSinceEpoch,
      'difficult': isDifficult ? 1 : 0,
    };
  }

  /// 5.4 Unutdim: stage = 1 (0 ga emas), ertaga qaytadi, wrong_count++
  static Map<String, dynamic> processForgot(FlashCard card, String todayKey) {
    final wrongCount = card.wrongCount + 1;
    return {
      'stage': 1,
      'interval_days': 1,
      'next_due': addDaysToKey(todayKey, 1),
      'wrong_count': wrongCount,
      'streak_correct': 0,
      'difficult': wrongCount >= 3 ? 1 : 0,
      'last_seen': DateTime.now().millisecondsSinceEpoch,
    };
  }

  /// 5.7 Diqqat ko'rsatkichi (focus score: 0-100)
  static ({int score, bool isEstimated}) calculateFocusScore({
    required int? rating,
    required int distractionCount,
    required int pauseSeconds,
    required int netSeconds,
  }) {
    final isEstimated = rating == null;
    final effectiveRating = rating ?? 3;
    final base = effectiveRating * 20; // 20-100
    final distractionPen = min(distractionCount * 6, 30);
    final total = netSeconds + pauseSeconds;
    final pauseRatio = total > 0 ? pauseSeconds / total : 0.0;
    final pausePen = (pauseRatio * 20).round();

    final score = (base - distractionPen - pausePen).clamp(0, 100);
    return (score: score, isEstimated: isEstimated);
  }

  /// 5.4 Kunlik navbat: muddati o'tganlar -> bugungilar -> yangilar.
  /// Vaziyatlar soni cheklanadi (default 3), umumiy chegara (default 20).
  /// Fanlar ketma-ket kelmasligi uchun aralashtiriladi.
  static List<FlashCard> buildTodayQueue({
    required List<FlashCard> cards,
    required String todayKey,
    int dailyLimit = 20,
    int newLimit = 10,
    int scenarioLimit = 3,
  }) {
    final active = cards.where((c) => c.status == 'active').toList();
    final overdue = active.where((c) => c.stage > 0 && c.nextDue.compareTo(todayKey) < 0).toList();
    final todayDue = active.where((c) => c.stage > 0 && c.nextDue == todayKey).toList();
    final newCards = active.where((c) => c.stage == 0).take(newLimit).toList();

    final candidates = [...overdue, ...todayDue, ...newCards];
    int scenarios = 0;
    final filtered = <FlashCard>[];

    for (final c in candidates) {
      if (c.type == 'scenario') {
        if (scenarios < scenarioLimit) {
          scenarios++;
          filtered.add(c);
        }
      } else {
        filtered.add(c);
      }
      if (filtered.length >= dailyLimit) break;
    }

    return interleaveBySubject(filtered);
  }

  /// Fanlar ketma-ket kelmasligi uchun aralashtirish
  static List<FlashCard> interleaveBySubject(List<FlashCard> list) {
    if (list.length <= 1) return list;
    final Map<int, List<FlashCard>> groups = {};
    for (final c in list) {
      groups.putIfAbsent(c.subjectId, () => []).add(c);
    }
    final result = <FlashCard>[];
    final keys = groups.keys.toList();
    bool hasMore = true;
    while (hasMore) {
      hasMore = false;
      for (final k in keys) {
        if (groups[k]!.isNotEmpty) {
          result.add(groups[k]!.removeAt(0));
          hasMore = true;
        }
      }
    }
    return result;
  }
}
