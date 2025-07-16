class Todo {
  final int? id;
  final String title;
  final String description;
  final DateTime createdAt;
  final DateTime? dueDate;
  final Priority priority;
  final bool isCompleted;

  Todo({
    this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    this.dueDate,
    required this.priority,
    this.isCompleted = false,
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
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
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
