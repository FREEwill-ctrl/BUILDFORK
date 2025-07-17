import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class EfficiencyLineChart extends StatelessWidget {
  final List<DateTime> dates;
  final List<double> efficiencyScores;
  const EfficiencyLineChart({Key? key, required this.dates, required this.efficiencyScores}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(dates.length, (i) => FlSpot(i.toDouble(), efficiencyScores[i])),
            isCurved: true,
            color: Colors.purple,
            barWidth: 3,
            dotData: FlDotData(show: true),
          ),
        ],
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= dates.length) return SizedBox();
                final date = dates[idx];
                return Text('${date.month}/${date.day}', style: TextStyle(fontSize: 10));
              },
            ),
          ),
        ),
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: false),
      ),
    );
  }
}