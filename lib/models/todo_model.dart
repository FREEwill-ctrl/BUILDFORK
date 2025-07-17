class Todo {
  final int? id;
  final String title;
  final String description;
  final DateTime createdAt;
  final DateTime? dueDate;
  final Priority priority;
  final bool isCompleted;
  final List<String> attachments;
  final List<ChecklistItem> checklist;
  final String? theme;

  Todo({
    this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    this.dueDate,
    required this.priority,
    this.isCompleted = false,
    this.attachments = const [],
    this.checklist = const [],
    this.theme,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'dueDate': dueDate?.millisecondsSinceEpoch,
      'priority': priority.index,
      'isCompleted': isCompleted ? 1 : 0,
      'attachments': attachments.join(','),
      'checklist': ChecklistItem.encodeList(checklist),
      'theme': theme,
    };
  }

  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      dueDate: map['dueDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['dueDate'])
          : null,
      priority: Priority.values[map['priority']],
      isCompleted: map['isCompleted'] == 1,
      attachments: map['attachments'] != null && map['attachments'] != ''
          ? (map['attachments'] as String).split(',')
          : [],
      checklist: map['checklist'] != null && map['checklist'] != ''
          ? ChecklistItem.decodeList(map['checklist'])
          : [],
      theme: map['theme'],
    );
  }

  Todo copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? createdAt,
    DateTime? dueDate,
    Priority? priority,
    bool? isCompleted,
    List<String>? attachments,
    List<ChecklistItem>? checklist,
    String? theme,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      attachments: attachments ?? this.attachments,
      checklist: checklist ?? this.checklist,
      theme: theme ?? this.theme,
    );
  }
}

class ChecklistItem {
  final String text;
  final bool isDone;
  ChecklistItem({required this.text, this.isDone = false});

  Map<String, dynamic> toMap() => {'text': text, 'isDone': isDone ? 1 : 0};
  factory ChecklistItem.fromMap(Map<String, dynamic> map) => ChecklistItem(
        text: map['text'],
        isDone: map['isDone'] == 1,
      );
  static String encodeList(List<ChecklistItem> items) =>
      items.map((e) => '${e.text}|${e.isDone ? 1 : 0}').join(';');
  static List<ChecklistItem> decodeList(String s) =>
      s.isEmpty ? [] : s.split(';').map((e) {
        final parts = e.split('|');
        return ChecklistItem(text: parts[0], isDone: parts.length > 1 && parts[1] == '1');
      }).toList();
}

enum Priority {
  low,
  medium,
  high,
}

extension PriorityExtension on Priority {
  String get name {
    switch (this) {
      case Priority.low:
        return 'Low';
      case Priority.medium:
        return 'Medium';
      case Priority.high:
        return 'High';
    }
  }

  String get color {
    switch (this) {
      case Priority.low:
        return 'green';
      case Priority.medium:
        return 'orange';
      case Priority.high:
        return 'red';
    }
  }
}
