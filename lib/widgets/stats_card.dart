import 'package:flutter/material.dart';
import '../utils/constants.dart';

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

