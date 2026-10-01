class Subject {
  final int id;
  final String name;
  final String icon;
  final String color;
  final int weeklyGoalMin;
  final int dailyGoalMin;
  final String? note;
  final int sortOrder;
  final String status;
  final int totalSeconds;
  final int createdAt;

  Subject({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.weeklyGoalMin,
    required this.dailyGoalMin,
    this.note,
    required this.sortOrder,
    required this.status,
    required this.totalSeconds,
    required this.createdAt,
  });

  factory Subject.fromMap(Map<String, dynamic> map) {
    return Subject(
      id: map['id'],
      name: map['name'],
      icon: map['icon'],
      color: map['color'],
      weeklyGoalMin: map['weekly_goal_min'],
      dailyGoalMin: map['daily_goal_min'],
      note: map['note'],
      sortOrder: map['sort_order'],
      status: map['status'],
      totalSeconds: map['total_seconds'] ?? 0,
      createdAt: map['created_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id > 0) 'id': id,
      'name': name,
      'icon': icon,
      'color': color,
      'weekly_goal_min': weeklyGoalMin,
      'daily_goal_min': dailyGoalMin,
      'note': note,
      'sort_order': sortOrder,
      'status': status,
      'total_seconds': totalSeconds,
      'created_at': createdAt,
    };
  }
}
