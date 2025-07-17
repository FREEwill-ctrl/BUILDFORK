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
  });
}

class ChecklistItem {
  final String text;
  final bool isDone;
  ChecklistItem({required this.text, this.isDone = false});
}

enum Priority { low, medium, high }