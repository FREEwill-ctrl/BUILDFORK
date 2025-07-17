import 'package:flutter/foundation.dart';

class DailyStats {
  final DateTime date;
  final Duration totalTimeSpent;
  final int tasksCompleted;
  final int pomodoroSessions;
  final double productivityScore;

  DailyStats({
    required this.date,
    required this.totalTimeSpent,
    required this.tasksCompleted,
    required this.pomodoroSessions,
    required this.productivityScore,
  });

  factory DailyStats.fromJson(Map<String, dynamic> json) {
    return DailyStats(
      date: DateTime.parse(json['date']),
      totalTimeSpent: Duration(milliseconds: json['totalTimeSpentMs']),
      tasksCompleted: json['tasksCompleted'],
      pomodoroSessions: json['pomodoroSessions'],
      productivityScore: json['productivityScore'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'totalTimeSpentMs': totalTimeSpent.inMilliseconds,
      'tasksCompleted': tasksCompleted,
      'pomodoroSessions': pomodoroSessions,
      'productivityScore': productivityScore,
    };
  }
}