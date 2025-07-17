import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/time_distribution_chart.dart';
import '../widgets/productivity_heatmap.dart';
import '../widgets/daily_summary_card.dart';
import '../models/daily_stats.dart';
import '../providers/time_tracking_provider.dart';

class AnalyticsDashboard extends StatelessWidget {
  const AnalyticsDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Analytics Dashboard')),
      body: Consumer<TimeTrackingProvider>(
        builder: (context, timerProvider, _) {
          // TODO: Replace with real quadrant calculation
          final quadrantTimes = {
            'Penting & Mendesak': 120.0,
            'Penting & Tidak Mendesak': 90.0,
            'Tidak Penting & Mendesak': 60.0,
            'Tidak Penting & Tidak Mendesak': 30.0,
          };
          // TODO: Replace with real productivity score calculation
          final productivityScores = <DateTime, double>{};
          // TODO: Replace with real daily stats
          final dailyStats = DailyStats(
            date: DateTime.now(),
            totalTimeSpent: Duration(hours: 3, minutes: 45),
            tasksCompleted: 5,
            pomodoroSessions: 6,
            productivityScore: 0.82,
          );
          return SingleChildScrollView(
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
          );
        },
      ),
    );
  }
}