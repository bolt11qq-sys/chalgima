class FlashCard {
  final int id;
  final int subjectId;
  final int? sessionId;
  final String type; // 'qa', 'cloze', 'scenario'
  final String question;
  final String answer;
  final String? hint;
  final int stage; // 0-5
  final int intervalDays;
  final String nextDue; // YYYY-MM-DD
  final int? lastSeen;
  final int correctCount;
  final int wrongCount;
  final int streakCorrect;
  final String status; // 'active', 'archived'
  final bool difficult;
  final int createdAt;
  final List<ScenarioOption>? options;

  FlashCard({
    required this.id,
    required this.subjectId,
    this.sessionId,
    required this.type,
    required this.question,
    required this.answer,
    this.hint,
    required this.stage,
    required this.intervalDays,
    required this.nextDue,
    this.lastSeen,
    required this.correctCount,
    required this.wrongCount,
    required this.streakCorrect,
    required this.status,
    required this.difficult,
    required this.createdAt,
    this.options,
  });

  factory FlashCard.fromMap(Map<String, dynamic> map, [List<ScenarioOption>? options]) {
    return FlashCard(
      id: map['id'],
      subjectId: map['subject_id'],
      sessionId: map['session_id'],
      type: map['type'],
      question: map['question'],
      answer: map['answer'],
      hint: map['hint'],
      stage: map['stage'] ?? 0,
      intervalDays: map['interval_days'] ?? 0,
      nextDue: map['next_due'],
      lastSeen: map['last_seen'],
      correctCount: map['correct_count'] ?? 0,
      wrongCount: map['wrong_count'] ?? 0,
      streakCorrect: map['streak_correct'] ?? 0,
      status: map['status'] ?? 'active',
      difficult: (map['difficult'] ?? 0) == 1,
      createdAt: map['created_at'],
      options: options,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id > 0) 'id': id,
      'subject_id': subjectId,
      'session_id': sessionId,
      'type': type,
      'question': question,
      'answer': answer,
      'hint': hint,
      'stage': stage,
      'interval_days': intervalDays,
      'next_due': nextDue,
      'last_seen': lastSeen,
      'correct_count': correctCount,
      'wrong_count': wrongCount,
      'streak_correct': streakCorrect,
      'status': status,
      'difficult': difficult ? 1 : 0,
      'created_at': createdAt,
    };
  }

  FlashCard copyWith({
    int? id,
    int? subjectId,
    int? sessionId,
    String? type,
    String? question,
    String? answer,
    String? hint,
    int? stage,
    int? intervalDays,
    String? nextDue,
    int? lastSeen,
    int? correctCount,
    int? wrongCount,
    int? streakCorrect,
    String? status,
    bool? difficult,
    int? createdAt,
    List<ScenarioOption>? options,
  }) {
    return FlashCard(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      sessionId: sessionId ?? this.sessionId,
      type: type ?? this.type,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      hint: hint ?? this.hint,
      stage: stage ?? this.stage,
      intervalDays: intervalDays ?? this.intervalDays,
      nextDue: nextDue ?? this.nextDue,
      lastSeen: lastSeen ?? this.lastSeen,
      correctCount: correctCount ?? this.correctCount,
      wrongCount: wrongCount ?? this.wrongCount,
      streakCorrect: streakCorrect ?? this.streakCorrect,
      status: status ?? this.status,
      difficult: difficult ?? this.difficult,
      createdAt: createdAt ?? this.createdAt,
      options: options ?? this.options,
    );
  }
}

class ScenarioOption {
  final int id;
  final int cardId;
  final String text;
  final bool isCorrect;
  final String feedback;
  final int sortOrder;

  ScenarioOption({
    required this.id,
    required this.cardId,
    required this.text,
    required this.isCorrect,
    required this.feedback,
    required this.sortOrder,
  });

  factory ScenarioOption.fromMap(Map<String, dynamic> map) {
    return ScenarioOption(
      id: map['id'],
      cardId: map['card_id'],
      text: map['text'],
      isCorrect: (map['is_correct'] ?? 0) == 1,
      feedback: map['feedback'],
      sortOrder: map['sort_order'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id > 0) 'id': id,
      'card_id': cardId,
      'text': text,
      'is_correct': isCorrect ? 1 : 0,
      'feedback': feedback,
      'sort_order': sortOrder,
    };
  }
}
