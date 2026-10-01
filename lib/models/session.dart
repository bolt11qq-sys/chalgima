class StudySession {
  final int id;
  final int subjectId;
  final int startAt;
  final int endAt;
  final int netSeconds;
  final int pauseSeconds;
  final int distractionCount;
  final String mode; // 'free' | 'pomodoro' | 'manual'
  final int? rating; // 1-5
  final String? note;
  final String dayKey; // YYYY-MM-DD
  final int confirmed; // 0 or 1
  final String? intention;
  final int? intentionDone; // 0 = yo'q, 1 = ha, 2 = qisman, null = berilmagan
  final String kind; // 'read' | 'practice' | 'project' | 'review'
  final int focusScore; // 0-100
  final int cardsCreated;

  StudySession({
    required this.id,
    required this.subjectId,
    required this.startAt,
    required this.endAt,
    required this.netSeconds,
    required this.pauseSeconds,
    required this.distractionCount,
    required this.mode,
    this.rating,
    this.note,
    required this.dayKey,
    required this.confirmed,
    this.intention,
    this.intentionDone,
    required this.kind,
    required this.focusScore,
    required this.cardsCreated,
  });

  factory StudySession.fromMap(Map<String, dynamic> map) {
    return StudySession(
      id: map['id'],
      subjectId: map['subject_id'],
      startAt: map['start_at'],
      endAt: map['end_at'],
      netSeconds: map['net_seconds'],
      pauseSeconds: map['pause_seconds'] ?? 0,
      distractionCount: map['distraction_count'] ?? 0,
      mode: map['mode'] ?? 'free',
      rating: map['rating'],
      note: map['note'],
      dayKey: map['day_key'],
      confirmed: map['confirmed'] ?? 1,
      intention: map['intention'],
      intentionDone: map['intention_done'],
      kind: map['kind'] ?? 'read',
      focusScore: map['focus_score'] ?? 50,
      cardsCreated: map['cards_created'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id > 0) 'id': id,
      'subject_id': subjectId,
      'start_at': startAt,
      'end_at': endAt,
      'net_seconds': netSeconds,
      'pause_seconds': pauseSeconds,
      'distraction_count': distractionCount,
      'mode': mode,
      'rating': rating,
      'note': note,
      'day_key': dayKey,
      'confirmed': confirmed,
      'intention': intention,
      'intention_done': intentionDone,
      'kind': kind,
      'focus_score': focusScore,
      'cards_created': cardsCreated,
    };
  }
}
