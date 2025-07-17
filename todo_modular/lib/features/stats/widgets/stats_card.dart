import 'package:flutter/material.dart';

class StatsCard extends StatelessWidget {
  final int totalTodos;
  final int completedTodos;
  const StatsCard({super.key, required this.totalTodos, required this.completedTodos});
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Statistics', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Total: $totalTodos'),
            Text('Completed: $completedTodos'),
          ],
        ),
      ),
    );
  }
}