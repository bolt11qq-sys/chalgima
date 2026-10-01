class LearningPath {
  final int id;
  final String name;
  final int subjectId;
  final String? note;
  final int createdAt;
  final List<PathItem> items;

  LearningPath({
    required this.id,
    required this.name,
    required this.subjectId,
    this.note,
    required this.createdAt,
    this.items = const [],
  });

  factory LearningPath.fromMap(Map<String, dynamic> map, [List<PathItem> items = const []]) {
    return LearningPath(
      id: map['id'],
      name: map['name'],
      subjectId: map['subject_id'],
      note: map['note'],
      createdAt: map['created_at'],
      items: items,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id > 0) 'id': id,
      'name': name,
      'subject_id': subjectId,
      'note': note,
      'created_at': createdAt,
    };
  }
}

class PathItem {
  final int id;
  final int pathId;
  final String title;
  final String? note;
  final String status; // 'todo' | 'doing' | 'done'
  final int sortOrder;
  final int? doneAt;

  PathItem({
    required this.id,
    required this.pathId,
    required this.title,
    this.note,
    required this.status,
    required this.sortOrder,
    this.doneAt,
  });

  factory PathItem.fromMap(Map<String, dynamic> map) {
    return PathItem(
      id: map['id'],
      pathId: map['path_id'],
      title: map['title'],
      note: map['note'],
      status: map['status'] ?? 'todo',
      sortOrder: map['sort_order'] ?? 0,
      doneAt: map['done_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id > 0) 'id': id,
      'path_id': pathId,
      'title': title,
      'note': note,
      'status': status,
      'sort_order': sortOrder,
      'done_at': doneAt,
    };
  }
}
