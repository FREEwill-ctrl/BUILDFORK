import 'package:flutter/material.dart';
import '../models/todo_model.dart';

class TodoTile extends StatelessWidget {
  final Todo todo;
  final VoidCallback? onDelete;
  const TodoTile({super.key, required this.todo, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        title: Text(todo.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (todo.description.isNotEmpty) Text(todo.description),
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
          ],
        ),
        trailing: onDelete != null ? IconButton(icon: const Icon(Icons.delete), onPressed: onDelete) : null,
      ),
    );
  }
}