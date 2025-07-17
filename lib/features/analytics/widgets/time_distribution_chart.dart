import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class TimeDistributionChart extends StatelessWidget {
  final Map<String, double> quadrantTimes;
  const TimeDistributionChart({Key? key, required this.quadrantTimes}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = [Colors.red, Colors.blue, Colors.green, Colors.orange];
    final sections = quadrantTimes.entries.map((entry) {
      final idx = quadrantTimes.keys.toList().indexOf(entry.key);
      return PieChartSectionData(
        color: colors[idx % colors.length],
        value: entry.value,
        title: entry.key,
        radius: 40,
        titleStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();
    return PieChart(
      PieChartData(
        sections: sections,
        centerSpaceRadius: 32,
        sectionsSpace: 2,
      ),
    );
  }
}