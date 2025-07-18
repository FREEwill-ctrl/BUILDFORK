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
  final bool isCompleted;
  final List<String> attachments;
  final List<ChecklistItem> checklist;
  // --- Time Tracking & Productivity ---
  final DateTime? startTime;
  final DateTime? endTime;
  final Duration totalTimeSpent;
  final int estimatedMinutes;
  final List<dynamic> timeSessions;
  final bool isTimerActive;
  final DateTime? lastActiveTime;
  final int pomodoroSessionsCompleted;
  final double productivityScore;
  final String status;

  Todo({
    this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    this.dueDate,
    this.priority = EisenhowerPriority.urgentImportant,
    this.isCompleted = false,
    this.attachments = const [],
    this.checklist = const [],
    // --- Time Tracking & Productivity ---
    this.startTime,
    this.endTime,
    this.totalTimeSpent = Duration.zero,
    this.estimatedMinutes = 0,
    this.timeSessions = const [],
    this.isTimerActive = false,
    this.lastActiveTime,
    this.pomodoroSessionsCompleted = 0,
    this.productivityScore = 0.0,
    this.status = 'notStarted',
  });

  Todo copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? createdAt,
    DateTime? dueDate,
    EisenhowerPriority? priority,
    bool? isCompleted,
    List<String>? attachments,
    List<ChecklistItem>? checklist,
    DateTime? startTime,
    DateTime? endTime,
    Duration? totalTimeSpent,
    int? estimatedMinutes,
    List<dynamic>? timeSessions,
    bool? isTimerActive,
    DateTime? lastActiveTime,
    int? pomodoroSessionsCompleted,
    double? productivityScore,
    String? status,
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
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      totalTimeSpent: totalTimeSpent ?? this.totalTimeSpent,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      timeSessions: timeSessions ?? this.timeSessions,
      isTimerActive: isTimerActive ?? this.isTimerActive,
      lastActiveTime: lastActiveTime ?? this.lastActiveTime,
      pomodoroSessionsCompleted: pomodoroSessionsCompleted ?? this.pomodoroSessionsCompleted,
      productivityScore: productivityScore ?? this.productivityScore,
      status: status ?? this.status,
    );
  }

  static String getPriorityLabel(EisenhowerPriority p) {
    switch (p) {
      case EisenhowerPriority.urgentImportant:
        return 'Penting & Mendesak';
      case EisenhowerPriority.importantNotUrgent:
        return 'Penting & Tidak Mendesak';
      case EisenhowerPriority.notImportantUrgent:
        return 'Tidak Penting & Mendesak';
      case EisenhowerPriority.notImportantNotUrgent:
        return 'Tidak Penting & Tidak Mendesak';
    }
  }
}