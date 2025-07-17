import 'package:flutter/material.dart';
import '../models/daily_stats.dart';

class DailySummaryCard extends StatelessWidget {
  final DailyStats stats;
  const DailySummaryCard({Key? key, required this.stats}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Date: ${stats.date.toLocal().toIso8601String().substring(0, 10)}', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Total Time Spent: ${_formatDuration(stats.totalTimeSpent)}'),
            Text('Tasks Completed: ${stats.tasksCompleted}'),
            Text('Pomodoro Sessions: ${stats.pomodoroSessions}'),
            Text('Productivity Score: ${stats.productivityScore.toStringAsFixed(2)}'),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    if (hours > 0) {
      return '${twoDigits(hours)}h ${twoDigits(minutes)}m';
    } else {
      return '${twoDigits(minutes)}m';
    }
  }
}