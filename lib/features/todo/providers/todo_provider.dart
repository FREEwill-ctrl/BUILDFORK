import 'package:flutter/material.dart';
import '../models/todo_model.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TodoProvider with ChangeNotifier {
  final List<Todo> _todos = [];
  List<Todo> get todos => List.unmodifiable(_todos);
  Todo? _lastDeleted;
  int? _lastDeletedIndex;
  final Map<int, List<Todo>> _editHistory = {};
  int? _lastEditedIndex;

  void addTodo(Todo todo) {
    _todos.add(todo);
    saveTodos();
    notifyListeners();
  }

  void updateTodo(int index, Todo todo) {
    if (index >= 0 && index < _todos.length) {
      final oldTodo = _todos[index];
      // Simpan history edit
      if (oldTodo.id != null) {
        _editHistory.putIfAbsent(oldTodo.id!, () => []).add(oldTodo);
      }
      _todos[index] = todo;
      _lastEditedIndex = index;
      saveTodos();
      notifyListeners();
    }
  }

  void undoEdit() {
    if (_lastEditedIndex != null) {
      final todo = _todos[_lastEditedIndex!];
      if (todo.id != null && _editHistory.containsKey(todo.id!) && _editHistory[todo.id!]!.isNotEmpty) {
        _todos[_lastEditedIndex!] = _editHistory[todo.id!]!.removeLast();
        saveTodos();
        notifyListeners();
      }
    }
  }

  List<Todo> getEditHistory(int todoId) => _editHistory[todoId] ?? [];

  void deleteTodo(int index) {
    if (index >= 0 && index < _todos.length) {
      _lastDeleted = _todos[index];
      _lastDeletedIndex = index;
      _todos.removeAt(index);
      saveTodos();
      notifyListeners();
    }
  }

  void undoDelete() {
    if (_lastDeleted != null && _lastDeletedIndex != null) {
      _todos.insert(_lastDeletedIndex!, _lastDeleted!);
      saveTodos();
      notifyListeners();
      _lastDeleted = null;
      _lastDeletedIndex = null;
    }
  }

  void toggleTodoStatus(int index) {
    if (index >= 0 && index < _todos.length) {
      final todo = _todos[index];
      _todos[index] = todo.copyWith(isCompleted: !todo.isCompleted);
      saveTodos();
      notifyListeners();
    }
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

  // Persistence stub
  Future<void> loadTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('todos');
    if (data != null) {
      final List<dynamic> jsonList = jsonDecode(data);
      _todos.clear();
      _todos.addAll(jsonList.map((e) => Todo(
        id: e['id'],
        title: e['title'],
        description: e['description'],
        createdAt: DateTime.parse(e['createdAt']),
        dueDate: e['dueDate'] != null ? DateTime.tryParse(e['dueDate']) : null,
        priority: EisenhowerPriority.values[e['priority']],
        isCompleted: e['isCompleted'] ?? false,
        attachments: (e['attachments'] as List?)?.cast<String>() ?? [],
        checklist: [], // TODO: Implement checklist deserialization
        startTime: e['startTime'] != null ? DateTime.tryParse(e['startTime']) : null,
        endTime: e['endTime'] != null ? DateTime.tryParse(e['endTime']) : null,
        totalTimeSpent: e['totalTimeSpent'] != null ? Duration(microseconds: e['totalTimeSpent']) : Duration.zero,
        estimatedMinutes: e['estimatedMinutes'] ?? 0,
        timeSessions: e['timeSessions'] ?? [],
        isTimerActive: e['isTimerActive'] ?? false,
        lastActiveTime: e['lastActiveTime'] != null ? DateTime.tryParse(e['lastActiveTime']) : null,
        pomodoroSessionsCompleted: e['pomodoroSessionsCompleted'] ?? 0,
        productivityScore: (e['productivityScore'] ?? 0.0).toDouble(),
        status: e['status'] ?? 'notStarted',
        reminder: e['reminder'] != null ? DateTime.tryParse(e['reminder']) : null,
      )));
      notifyListeners();
    }
  }
  Future<void> saveTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(_todos.map((e) => {
      'id': e.id,
      'title': e.title,
      'description': e.description,
      'createdAt': e.createdAt.toIso8601String(),
      'dueDate': e.dueDate?.toIso8601String(),
      'priority': e.priority.index,
      'isCompleted': e.isCompleted,
      'attachments': e.attachments,
      // TODO: Implement checklist serialization
      'startTime': e.startTime?.toIso8601String(),
      'endTime': e.endTime?.toIso8601String(),
      'totalTimeSpent': e.totalTimeSpent.inMicroseconds,
      'estimatedMinutes': e.estimatedMinutes,
      'timeSessions': e.timeSessions,
      'isTimerActive': e.isTimerActive,
      'lastActiveTime': e.lastActiveTime?.toIso8601String(),
      'pomodoroSessionsCompleted': e.pomodoroSessionsCompleted,
      'productivityScore': e.productivityScore,
      'status': e.status,
      'reminder': e.reminder?.toIso8601String(),
    }).toList());
    await prefs.setString('todos', data);
  }
}