import 'package:flutter/material.dart';
import '../models/todo_model.dart';
import '../../analytics/widgets/task_timer_widget.dart';
import 'package:provider/provider.dart';
import '../../analytics/providers/time_tracking_provider.dart';

class TodoTile extends StatelessWidget {
  final Todo todo;
  final VoidCallback? onDelete;
  final VoidCallback? onToggle;
  final VoidCallback? onEdit;
  const TodoTile({super.key, required this.todo, this.onDelete, this.onToggle, this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        leading: Checkbox(
          value: todo.isCompleted,
          onChanged: (_) => onToggle?.call(),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                (todo.title.isNotEmpty ? todo.title : 'No Title'),
                style: TextStyle(
                  decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                  color: todo.isCompleted ? Colors.grey : null,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _priorityColor(todo.priority),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                (Todo.getPriorityLabel(todo.priority).isNotEmpty ? Todo.getPriorityLabel(todo.priority) : '-'),
                style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (todo.description.isNotEmpty)
              Text(
                todo.description,
                style: TextStyle(
                  decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                  color: todo.isCompleted ? Colors.grey : null,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            if (todo.dueDate != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: todo.isCompleted ? Colors.grey : (todo.dueDate!.isBefore(DateTime.now()) && !todo.isCompleted ? Colors.red : Colors.blue)),
                    const SizedBox(width: 4),
                    Text(
                      'Tenggat: ${todo.dueDate!.day}/${todo.dueDate!.month}/${todo.dueDate!.year}',
                      style: TextStyle(
                        color: todo.isCompleted ? Colors.grey : (todo.dueDate!.isBefore(DateTime.now()) && !todo.isCompleted ? Colors.red : Colors.blue),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (todo.dueDate!.isBefore(DateTime.now()) && !todo.isCompleted)
                      const Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: Text('Terlambat', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
              ),
            if (todo.checklist.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Wrap(
                  spacing: 8,
                  children: todo.checklist.map((item) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(item.isDone ? Icons.check_box : Icons.check_box_outline_blank, size: 16),
                      Text(item.text, style: TextStyle(decoration: item.isDone ? TextDecoration.lineThrough : null)),
                    ],
                  )).toList(),
                ),
              ),
            if (todo.attachments.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Wrap(
                  spacing: 8,
                  children: todo.attachments.map((file) => Chip(label: Text(file.split('/').last))).toList(),
                ),
              ),
            // --- Task Timer Widget Integration ---
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Consumer<TimeTrackingProvider>(
                builder: (context, timerProvider, _) {
                  final isActive = timerProvider.activeTaskId == todo.id.toString();
                  final totalTime = timerProvider.getTaskTotalTime(todo.id.toString());
                  return TaskTimerWidget(
                    isActive: isActive,
                    totalTime: totalTime,
                    onStart: () => timerProvider.startTaskTimer(todo.id.toString()),
                    onPause: () => timerProvider.pauseTaskTimer(todo.id.toString()),
                    onStop: () => timerProvider.stopTaskTimer(todo.id.toString()),
                  );
                },
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onEdit != null)
              IconButton(icon: const Icon(Icons.edit), onPressed: onEdit),
            if (onDelete != null)
              IconButton(icon: const Icon(Icons.delete), onPressed: onDelete),
          ],
        ),
      ),
    );
  }
}

Color _priorityColor(EisenhowerPriority p) {
  switch (p) {
    case EisenhowerPriority.urgentImportant:
      return Colors.redAccent;
    case EisenhowerPriority.importantNotUrgent:
      return Colors.blueAccent;
    case EisenhowerPriority.notImportantUrgent:
      return Colors.orangeAccent;
    case EisenhowerPriority.notImportantNotUrgent:
      return Colors.grey;
  }
}