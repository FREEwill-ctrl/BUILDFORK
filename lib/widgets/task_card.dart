import 'package:flutter/material.dart';
import '../models/todo_model.dart';
import '../utils/constants.dart';
import 'priority_chip.dart';

class TaskCard extends StatelessWidget {
  final Todo todo;
  final VoidCallback? onTap;
  final VoidCallback? onToggleComplete;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const TaskCard({
    Key? key,
    required this.todo,
    this.onTap,
    this.onToggleComplete,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOverdue = todo.dueDate != null && 
        todo.dueDate!.isBefore(DateTime.now()) && 
        !todo.isCompleted;

    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingSmall),
      elevation: todo.isCompleted ? 1 : 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Checkbox
                  GestureDetector(
                    onTap: onToggleComplete,
                    child: Container(
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
                          ? const Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ),
                  
                  const SizedBox(width: AppConstants.paddingMedium),
                  
                  // Title and content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          todo.title,
                          style: AppConstants.subheadingStyle.copyWith(
                            decoration: todo.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            color: todo.isCompleted
                                ? theme.colorScheme.onSurface.withOpacity(0.6)
                                : isOverdue
                                    ? AppConstants.errorColor
                                    : null,
                          ),
                        ),
                        if (todo.description.isNotEmpty) ...[
                          const SizedBox(height: AppConstants.paddingSmall),
                          Text(
                            todo.description,
                            style: AppConstants.bodyStyle.copyWith(
                              decoration: todo.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  // Priority chip
                  PriorityChip(priority: todo.priority),
                ],
              ),
              
              // Due date and actions
              if (todo.dueDate != null || onEdit != null || onDelete != null) ...[
                const SizedBox(height: AppConstants.paddingMedium),
                Row(
                  children: [
                    // Due date
                    if (todo.dueDate != null) ...[
                      Icon(
                        isOverdue ? Icons.warning : Icons.schedule,
                        size: 16,
                        color: isOverdue
                            ? AppConstants.errorColor
                            : theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                      const SizedBox(width: AppConstants.paddingSmall),
                      Text(
                        _formatDueDate(todo.dueDate!),
                        style: AppConstants.captionStyle.copyWith(
                          color: isOverdue
                              ? AppConstants.errorColor
                              : theme.colorScheme.onSurface.withOpacity(0.6),
                          fontWeight: isOverdue ? FontWeight.w600 : null,
                        ),
                      ),
                    ],
                    
                    const Spacer(),
                    
                    // Action buttons
                    if (onEdit != null) ...[
                      IconButton(
                        onPressed: onEdit,
                        icon: Icon(
                          Icons.edit,
                          size: 20,
                          color: theme.colorScheme.primary,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                    
                    if (onDelete != null) ...[
                      IconButton(
                        onPressed: onDelete,
                        icon: Icon(
                          Icons.delete,
                          size: 20,
                          color: AppConstants.errorColor,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDueDate(DateTime dueDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dueDateOnly = DateTime(dueDate.year, dueDate.month, dueDate.day);

    if (dueDateOnly == today) {
      return 'Due today at ${_formatTime(dueDate)}';
    } else if (dueDateOnly == tomorrow) {
      return 'Due tomorrow at ${_formatTime(dueDate)}';
    } else if (dueDateOnly.isBefore(today)) {
      final difference = today.difference(dueDateOnly).inDays;
      return 'Overdue by $difference day${difference > 1 ? 's' : ''}';
    } else {
      final difference = dueDateOnly.difference(today).inDays;
      if (difference <= 7) {
        return 'Due in $difference day${difference > 1 ? 's' : ''} at ${_formatTime(dueDate)}';
      } else {
        return 'Due ${dueDate.day}/${dueDate.month}/${dueDate.year} at ${_formatTime(dueDate)}';
      }
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }
}

