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
          final quadrantTimes = timerProvider.getQuadrantTimeDistribution(context);
          return FutureBuilder(
            future: Future.wait([
              timerProvider.getProductivityHeatmap(context),
              timerProvider.getTodayStats(context),
            ]),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }
              final productivityScores = snapshot.data![0] as Map<DateTime, double>;
              final dailyStats = snapshot.data![1] as DailyStats;
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
          );
        },
      ),
    );
  }
}