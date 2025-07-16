import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/todo_model.dart';
import '../utils/constants.dart';
import 'priority_chip.dart';

class TaskCard extends StatelessWidget {
  final Todo todo;
  final VoidCallback onTap;
  final VoidCallback onToggleComplete;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const TaskCard({
    Key? key,
    required this.todo,
    required this.onTap,
    required this.onToggleComplete,
    required this.onDelete,
    required this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOverdue = !todo.isCompleted &&
        (todo.dueDate?.isBefore(DateTime.now()) ?? false);

    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingSmall),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  // Checkbox
                  GestureDetector(
                    onTap: onToggleComplete,
                    child: AnimatedContainer(
                      duration: AppConstants.shortAnimation,
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: todo.isCompleted
                              ? AppConstants.successColor
                              : theme.colorScheme.outline,
                          width: 2,
                        ),
                        color: todo.isCompleted
                            ? AppConstants.successColor
                            : Colors.transparent,
                      ),
                      child: todo.isCompleted
                          ? Image.asset('assets/icons/check.png', width: 16, height: 16, color: Colors.white)
                          : null,
                    ),
                  ),

                  const SizedBox(width: AppConstants.paddingMedium),

                  // Title and Priority
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          todo.title,
                          style: AppConstants.subheadingStyle.copyWith(
                            color: todo.isCompleted
                                ? theme.colorScheme.onSurface.withOpacity(0.6)
                                : theme.colorScheme.onSurface,
                            decoration: todo.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            PriorityChip(priority: todo.priority),
                            if (isOverdue) ...[
                              const SizedBox(width: AppConstants.paddingSmall),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      AppConstants.errorColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Overdue',
                                  style: TextStyle(
                                    color: AppConstants.errorColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Action Buttons
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          onEdit();
                          break;
                        case 'delete':
                          onDelete();
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Image.asset('assets/icons/edit.png', width: 18, height: 18),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Image.asset('assets/icons/delete.png', width: 18, height: 18),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Description
              if (todo.description.isNotEmpty) ...[
                const SizedBox(height: AppConstants.paddingSmall),
                Text(
                  todo.description,
                  style: AppConstants.bodyStyle.copyWith(
                    color: todo.isCompleted
                        ? theme.colorScheme.onSurface.withOpacity(0.6)
                        : theme.colorScheme.onSurface.withOpacity(0.8),
                    decoration:
                        todo.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              // Due Date and Created Date
              const SizedBox(height: AppConstants.paddingSmall),
              Row(
                children: [
                  if (todo.dueDate != null) ...[
                    Image.asset('assets/icons/calendar.png', width: 16, height: 16, color: isOverdue ? AppConstants.errorColor : theme.colorScheme.onSurface.withOpacity(0.6)),
                    const SizedBox(width: 4),
                    Text(
                      'Due: ${DateFormat('MMM dd, yyyy').format(todo.dueDate!)}',
                      style: AppConstants.captionStyle.copyWith(
                        color: isOverdue
                            ? AppConstants.errorColor
                            : theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(width: AppConstants.paddingMedium),
                  ],
                  Image.asset('assets/icons/timer.png', width: 16, height: 16, color: theme.colorScheme.onSurface.withOpacity(0.6)),
                  const SizedBox(width: 4),
                  Text(
                    'Created: ${DateFormat('MMM dd').format(todo.createdAt)}',
                    style: AppConstants.captionStyle,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CompactTaskCard extends StatelessWidget {
  final Todo todo;
  final VoidCallback onToggleComplete;

  const CompactTaskCard({
    Key? key,
    required this.todo,
    required this.onToggleComplete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: GestureDetector(
        onTap: onToggleComplete,
        child: AnimatedContainer(
          duration: AppConstants.shortAnimation,
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: todo.isCompleted
                  ? AppConstants.successColor
                  : theme.colorScheme.outline,
              width: 2,
            ),
            color: todo.isCompleted
                ? AppConstants.successColor
                : Colors.transparent,
          ),
          child: todo.isCompleted
              ? Image.asset('assets/icons/check.png', width: 16, height: 16, color: Colors.white)
              : null,
        ),
      ),
      title: Text(
        todo.title,
        style: TextStyle(
          decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
          color: todo.isCompleted
              ? theme.colorScheme.onSurface.withOpacity(0.6)
              : theme.colorScheme.onSurface,
        ),
      ),
      subtitle: todo.description.isNotEmpty
          ? Text(
              todo.description,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                decoration:
                    todo.isCompleted ? TextDecoration.lineThrough : null,
              ),
            )
          : null,
      trailing: PriorityChip(priority: todo.priority),
    );
  }
}