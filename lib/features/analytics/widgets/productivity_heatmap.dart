import 'package:flutter/material.dart';

class ProductivityHeatmap extends StatelessWidget {
  final Map<DateTime, double> productivityScores;
  const ProductivityHeatmap({Key? key, required this.productivityScores}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // For simplicity, show a 7x5 grid (weeks x days)
    final days = List.generate(35, (i) => DateTime.now().subtract(Duration(days: 34 - i)));
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7),
      itemCount: days.length,
      itemBuilder: (context, idx) {
        final day = days[idx];
        final score = productivityScores[DateTime(day.year, day.month, day.day)] ?? 0.0;
        final color = Color.lerp(Colors.white, Colors.green, score.clamp(0, 1));
        return Container(
          margin: EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.grey.shade300, width: 0.5),
          ),
          child: Center(
            child: Text(
              '${day.day}',
              style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: Colors.black87),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        );
      },
    );
  }
}