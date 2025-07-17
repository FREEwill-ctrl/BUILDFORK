import 'package:flutter/material.dart';
import '../widgets/time_distribution_chart.dart';
import '../widgets/productivity_heatmap.dart';
import '../widgets/daily_summary_card.dart';
import '../models/daily_stats.dart';

class AnalyticsDashboard extends StatelessWidget {
  const AnalyticsDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Mock data for demonstration
    final quadrantTimes = {
      'Penting & Mendesak': 120.0,
      'Penting & Tidak Mendesak': 90.0,
      'Tidak Penting & Mendesak': 60.0,
      'Tidak Penting & Tidak Mendesak': 30.0,
    };
    final productivityScores = Map.fromIterable(
      List.generate(35, (i) => DateTime.now().subtract(Duration(days: 34 - i))),
      key: (d) => DateTime(d.year, d.month, d.day),
      value: (d) => (d.day % 5) / 5.0,
    );
    final dailyStats = DailyStats(
      date: DateTime.now(),
      totalTimeSpent: Duration(hours: 3, minutes: 45),
      tasksCompleted: 5,
      pomodoroSessions: 6,
      productivityScore: 0.82,
    );
    return Scaffold(
      appBar: AppBar(title: Text('Analytics Dashboard')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 16),
            Text('Time Distribution by Eisenhower Quadrant', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            SizedBox(height: 200, child: TimeDistributionChart(quadrantTimes: quadrantTimes)),
            Divider(),
            Text('Productivity Heatmap', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            SizedBox(height: 120, child: ProductivityHeatmap(productivityScores: productivityScores)),
            Divider(),
            Text('Daily Summary', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
            DailySummaryCard(stats: dailyStats),
          ],
        ),
      ),
    );
  }
}