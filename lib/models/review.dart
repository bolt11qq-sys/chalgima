class ReviewLog {
  final int id;
  final int cardId;
  final int at;
  final int result; // 0 = unutdim, 1 = esladim
  final int stageBefore;
  final int stageAfter;

  ReviewLog({
    required this.id,
    required this.cardId,
    required this.at,
    required this.result,
    required this.stageBefore,
    required this.stageAfter,
  });

  factory ReviewLog.fromMap(Map<String, dynamic> map) {
    return ReviewLog(
      id: map['id'],
      cardId: map['card_id'],
      at: map['at'],
      result: map['result'],
      stageBefore: map['stage_before'],
      stageAfter: map['stage_after'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id > 0) 'id': id,
      'card_id': cardId,
      'at': at,
      'result': result,
      'stage_before': stageBefore,
      'stage_after': stageAfter,
    };
  }
}

class DayStat {
  final String dayKey;
  final int totalSeconds;
  final int goalSeconds;
  final int sessionsCount;
  final int reviewsDone;
  final int reviewsCorrect;
  final int goalMet; // 0 or 1
  final int avgFocus;
  final double? sleepHours;
  final int? mood; // 1-5
  final int? exercise; // 0 or 1
  final int? screenMinutes;

  DayStat({
    required this.dayKey,
    required this.totalSeconds,
    required this.goalSeconds,
    required this.sessionsCount,
    required this.reviewsDone,
    required this.reviewsCorrect,
    required this.goalMet,
    required this.avgFocus,
    this.sleepHours,
    this.mood,
    this.exercise,
    this.screenMinutes,
  });

  factory DayStat.fromMap(Map<String, dynamic> map) {
    return DayStat(
      dayKey: map['day_key'],
      totalSeconds: map['total_seconds'] ?? 0,
      goalSeconds: map['goal_seconds'] ?? 5400,
      sessionsCount: map['sessions_count'] ?? 0,
      reviewsDone: map['reviews_done'] ?? 0,
      reviewsCorrect: map['reviews_correct'] ?? 0,
      goalMet: map['goal_met'] ?? 0,
      avgFocus: map['avg_focus'] ?? 0,
      sleepHours: map['sleep_hours'] != null ? (map['sleep_hours'] as num).toDouble() : null,
      mood: map['mood'],
      exercise: map['exercise'],
      screenMinutes: map['screen_minutes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'day_key': dayKey,
      'total_seconds': totalSeconds,
      'goal_seconds': goalSeconds,
      'sessions_count': sessionsCount,
      'reviews_done': reviewsDone,
      'reviews_correct': reviewsCorrect,
      'goal_met': goalMet,
      'avg_focus': avgFocus,
      'sleep_hours': sleepHours,
      'mood': mood,
      'exercise': exercise,
      'screen_minutes': screenMinutes,
    };
  }
}
