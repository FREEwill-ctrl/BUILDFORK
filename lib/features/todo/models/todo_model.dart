class ChecklistItem {
  final String text;
  final bool isDone;
  ChecklistItem({required this.text, this.isDone = false});
}

enum EisenhowerPriority {
  urgentImportant, // Penting & Mendesak
  importantNotUrgent, // Penting & Tidak Mendesak
  notImportantUrgent, // Tidak Penting & Mendesak
  notImportantNotUrgent, // Tidak Penting & Tidak Mendesak
}

class Todo {
  final int? id;
  final String title;
  final String description;
  final DateTime createdAt;
  final DateTime? dueDate;
  final EisenhowerPriority priority;
  final String priorityLabel;
  final bool isCompleted;
  final List<String> attachments;
  final List<ChecklistItem> checklist;

  // --- Time Tracking & Productivity ---
  DateTime? startTime;
  DateTime? endTime;
  Duration totalTimeSpent;
  int estimatedMinutes;
  List<TimeSession> timeSessions;
  bool isTimerActive;
  DateTime? lastActiveTime;
  int pomodoroSessionsCompleted;
  double productivityScore;
  TaskStatus status;

  Todo({
    this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    this.dueDate,
    this.priority = EisenhowerPriority.urgentImportant,
    this.priorityLabel = 'Penting & Mendesak',
    this.isCompleted = false,
    this.attachments = const [],
    this.checklist = const [],
  });

  Todo copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? createdAt,
    DateTime? dueDate,
    EisenhowerPriority? priority,
    String? priorityLabel,
    bool? isCompleted,
    List<String>? attachments,
    List<ChecklistItem>? checklist,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      priorityLabel: priorityLabel ?? this.priorityLabel,
      isCompleted: isCompleted ?? this.isCompleted,
      attachments: attachments ?? this.attachments,
      checklist: checklist ?? this.checklist,
    );
  }
}

// --- TimeSession Model ---
class TimeSession {
  final String id;
  final DateTime startTime;
  final DateTime endTime;
  final Duration duration;
  final String sessionType; // 'pomodoro', 'manual', 'focus'
  final String taskId;
  final bool wasCompleted;

  TimeSession({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.sessionType,
    required this.taskId,
    this.wasCompleted = false,
  });
}

enum TaskStatus { notStarted, inProgress, paused, completed }