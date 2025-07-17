import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DeadlinePerformanceScatterChart extends StatelessWidget {
  final List<double> daysToDeadline;
  final List<double> timeDiffMinutes;
  const DeadlinePerformanceScatterChart({Key? key, required this.daysToDeadline, required this.timeDiffMinutes}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScatterChart(
      ScatterChartData(
        scatterSpots: List.generate(daysToDeadline.length, (i) => ScatterSpot(
          daysToDeadline[i],
          timeDiffMinutes[i],
          color: timeDiffMinutes[i] < 0 ? Colors.green : Colors.red,
          radius: 8,
        )),
        minX: daysToDeadline.isEmpty ? 0 : daysToDeadline.reduce((a, b) => a < b ? a : b) - 1,
        maxX: daysToDeadline.isEmpty ? 1 : daysToDeadline.reduce((a, b) => a > b ? a : b) + 1,
        minY: timeDiffMinutes.isEmpty ? 0 : timeDiffMinutes.reduce((a, b) => a < b ? a : b) - 10,
        maxY: timeDiffMinutes.isEmpty ? 1 : timeDiffMinutes.reduce((a, b) => a > b ? a : b) + 10,
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
        ),
      ),
    );
  }
}