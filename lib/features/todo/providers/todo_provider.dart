import 'package:flutter/material.dart';
import '../models/todo_model.dart';

class TodoProvider with ChangeNotifier {
  final List<Todo> _todos = [];
  List<Todo> get todos => List.unmodifiable(_todos);

  void addTodo(Todo todo) {
    _todos.add(todo.copyWith(priorityLabel: _priorityLabelFromEnum(todo.priority)));
    notifyListeners();
  }

  void updateTodo(int index, Todo todo) {
    _todos[index] = todo;
    notifyListeners();
  }

  void deleteTodo(int index) {
    _todos.removeAt(index);
    notifyListeners();
  }

  void toggleTodoStatus(int index) {
    final todo = _todos[index];
    _todos[index] = Todo(
      id: todo.id,
      title: todo.title,
      description: todo.description,
      createdAt: todo.createdAt,
      dueDate: todo.dueDate,
      priority: todo.priority,
      isCompleted: !todo.isCompleted,
      attachments: todo.attachments,
      checklist: todo.checklist,
    );
    notifyListeners();
  }

  void editTodo(int index, Todo newTodo) {
    _todos[index] = newTodo.copyWith(priorityLabel: _priorityLabelFromEnum(newTodo.priority));
    notifyListeners();
  }

  List<Todo> filterByPriority(EisenhowerPriority? priority) {
    if (priority == null) return _todos;
    return _todos.where((todo) => todo.priority == priority).toList();
  }

  List<Todo> getTodosByDate(DateTime date) {
    return _todos.where((todo) => todo.dueDate != null &&
      todo.dueDate!.year == date.year &&
      todo.dueDate!.month == date.month &&
      todo.dueDate!.day == date.day).toList();
  }

  String _priorityLabelFromEnum(EisenhowerPriority p) {
    switch (p) {
      case EisenhowerPriority.urgentImportant:
        return 'Penting & Mendesak';
      case EisenhowerPriority.importantNotUrgent:
        return 'Penting & Tidak Mendesak';
      case EisenhowerPriority.notImportantUrgent:
        return 'Tidak Penting & Mendesak';
      case EisenhowerPriority.notImportantNotUrgent:
        return 'Tidak Penting & Tidak Mendesak';
    }
  }
}