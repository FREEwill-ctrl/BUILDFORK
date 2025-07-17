import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class EstimatedActualBarChart extends StatelessWidget {
  final List<String> taskTitles;
  final List<double> estimatedMinutes;
  final List<double> actualMinutes;
  const EstimatedActualBarChart({Key? key, required this.taskTitles, required this.estimatedMinutes, required this.actualMinutes}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        barGroups: List.generate(taskTitles.length, (i) => BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(toY: estimatedMinutes[i], color: Colors.blue, width: 8),
            BarChartRodData(toY: actualMinutes[i], color: Colors.green, width: 8),
          ],
        )),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= taskTitles.length) return SizedBox();
                return RotatedBox(
                  quarterTurns: 1,
                  child: Text(taskTitles[idx], style: TextStyle(fontSize: 10)),
                );
              },
            ),
          ),
        ),
        barTouchData: BarTouchData(enabled: true),
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: false),
      ),
    );
  }
}