import 'package:flutter/foundation.dart';

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

  factory TimeSession.fromJson(Map<String, dynamic> json) {
    return TimeSession(
      id: json['id'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      duration: Duration(milliseconds: json['durationMs']),
      sessionType: json['sessionType'],
      taskId: json['taskId'],
      wasCompleted: json['wasCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'durationMs': duration.inMilliseconds,
      'sessionType': sessionType,
      'taskId': taskId,
      'wasCompleted': wasCompleted,
    };
  }
}