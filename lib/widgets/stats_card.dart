import 'package:flutter/material.dart';
import '../utils/constants.dart';
import 'package:provider/provider.dart';
import '../providers/todo_provider.dart';

class StatsCard extends StatelessWidget {
  final int totalTodos;
  final int completedTodos;
  final int pendingTodos;

  const StatsCard({
    Key? key,
    required this.totalTodos,
    required this.completedTodos,
    required this.pendingTodos,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final completionRate = totalTodos > 0 ? (completedTodos / totalTodos) : 0.0;
    final todoProvider = Provider.of<TodoProvider>(context, listen: false);
    final completedPerDay = todoProvider.completedPerDay;
    final maxCompleted = completedPerDay.values.isNotEmpty ? completedPerDay.values.reduce((a, b) => a > b ? a : b) : 1;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.analytics_outlined,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: AppConstants.paddingSmall),
                Text(
                  'Statistics',
                  style: AppConstants.subheadingStyle.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingMedium),

            // Progress Bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Completion Rate',
                      style: AppConstants.bodyStyle.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      '${(completionRate * 100).toInt()}%',
                      style: AppConstants.bodyStyle.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.paddingSmall),
                LinearProgressIndicator(
                  value: completionRate,
                  backgroundColor: theme.colorScheme.surfaceVariant,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.primary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppConstants.paddingMedium),

            // Stats Row
            Row(
              children: [
                Expanded(
                  child: _StatItem(
                    icon: Icons.list_alt,
                    label: 'Total',
                    value: totalTodos.toString(),
                    color: theme.colorScheme.primary,
                  ),
                ),
                Expanded(
                  child: _StatItem(
                    icon: Icons.check_circle,
                    label: 'Completed',
                    value: completedTodos.toString(),
                    color: AppConstants.successColor,
                  ),
                ),
                Expanded(
                  child: _StatItem(
                    icon: Icons.pending,
                    label: 'Pending',
                    value: pendingTodos.toString(),
                    color: AppConstants.warningColor,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppConstants.paddingMedium),

            // Priority Distribution
            Text('Priority Distribution', style: AppConstants.bodyStyle),
            const SizedBox(height: 8),
            Row(
              children: [
                _PriorityStat(
                  label: 'Low',
                  value: todoProvider.lowPriorityTodos,
                  completed: todoProvider.completedLowPriority,
                  color: AppConstants.lowPriorityColor,
                ),
                _PriorityStat(
                  label: 'Medium',
                  value: todoProvider.mediumPriorityTodos,
                  completed: todoProvider.completedMediumPriority,
                  color: AppConstants.mediumPriorityColor,
                ),
                _PriorityStat(
                  label: 'High',
                  value: todoProvider.highPriorityTodos,
                  completed: todoProvider.completedHighPriority,
                  color: AppConstants.highPriorityColor,
                ),
              ],
            ),

            const SizedBox(height: AppConstants.paddingMedium),

            // Completion per Day (simple bar chart)
            Text('Completed per Day (7 days)', style: AppConstants.bodyStyle),
            const SizedBox(height: 8),
            SizedBox(
              height: 48,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: completedPerDay.entries.map((entry) {
                  final percent = maxCompleted > 0 ? entry.value / maxCompleted : 0.0;
                  return Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          height: 36 * percent,
                          width: 12,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${entry.key.month}/${entry.key.day}',
                          style: AppConstants.captionStyle.copyWith(fontSize: 10),
                        ),
                        Text(
                          '${entry.value}',
                          style: AppConstants.captionStyle.copyWith(fontSize: 10),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    Key? key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppConstants.paddingSmall),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: AppConstants.paddingSmall),
        Text(
          value,
          style: AppConstants.subheadingStyle.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppConstants.captionStyle,
        ),
      ],
    );
  }
}

class _PriorityStat extends StatelessWidget {
  final String label;
  final int value;
  final int completed;
  final Color color;
  const _PriorityStat({required this.label, required this.value, required this.completed, required this.color});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: AppConstants.captionStyle.copyWith(color: color)),
          Text('$completed/$value', style: AppConstants.bodyStyle.copyWith(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class CompactStatsCard extends StatelessWidget {
  final int totalTodos;
  final int completedTodos;
  final int pendingTodos;

  const CompactStatsCard({
    Key? key,
    required this.totalTodos,
    required this.completedTodos,
    required this.pendingTodos,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final completionRate = totalTodos > 0 ? (completedTodos / totalTodos) : 0.0;

    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Progress',
                  style: AppConstants.captionStyle.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${(completionRate * 100).toInt()}% Complete',
                  style: AppConstants.subheadingStyle.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Text(
                '$completedTodos/$totalTodos',
                style: AppConstants.headingStyle.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              Text(
                'Tasks',
                style: AppConstants.captionStyle.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
