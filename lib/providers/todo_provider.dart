import 'package:flutter/foundation.dart';
import '../models/todo_model.dart';
import '../models/todo_model.dart' show ChecklistItem;
import '../services/database_service.dart';
import '../services/notification_service.dart';
import 'package:csv/csv.dart';
import 'dart:io';

class TodoProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final NotificationService _notificationService = NotificationService();

  List<Todo> _todos = [];
  List<Todo> _filteredTodos = [];
  String _searchQuery = '';
  Priority? _filterPriority;
  bool? _filterCompleted;
  bool _isLoading = false;
  String? _errorMessage;

  List<Todo> get todos => _filteredTodos;
  String get searchQuery => _searchQuery;
  Priority? get filterPriority => _filterPriority;
  bool? get filterCompleted => _filterCompleted;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get totalTodos => _todos.length;
  int get completedTodos => _todos.where((todo) => todo.isCompleted).length;
  int get pendingTodos => _todos.where((todo) => !todo.isCompleted).length;
  int get lowPriorityTodos => _todos.where((todo) => todo.priority == Priority.low).length;
  int get mediumPriorityTodos => _todos.where((todo) => todo.priority == Priority.medium).length;
  int get highPriorityTodos => _todos.where((todo) => todo.priority == Priority.high).length;

  int get completedLowPriority => _todos.where((todo) => todo.priority == Priority.low && todo.isCompleted).length;
  int get completedMediumPriority => _todos.where((todo) => todo.priority == Priority.medium && todo.isCompleted).length;
  int get completedHighPriority => _todos.where((todo) => todo.priority == Priority.high && todo.isCompleted).length;

  Map<DateTime, int> get completedPerDay {
    final now = DateTime.now();
    final Map<DateTime, int> data = {};
    for (int i = 6; i >= 0; i--) {
      final day = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
      data[day] = _todos.where((todo) => todo.isCompleted && todo.dueDate != null &&
        todo.dueDate!.year == day.year && todo.dueDate!.month == day.month && todo.dueDate!.day == day.day).length;
    }
    return data;
  }

  Future<void> loadTodos() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _todos = await _databaseService.getAllTodos();
      _applyFilters();
    } catch (e) {
      _errorMessage = 'Error loading todos: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTodo(Todo todo) async {
    try {
      final id = await _databaseService.insertTodo(todo);
      final newTodo = todo.copyWith(id: id);
      _todos.add(newTodo);
      if (newTodo.dueDate != null) {
        await _notificationService.scheduleTaskReminder(newTodo);
      }
      _applyFilters();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error adding todo: $e';
      notifyListeners();
    }
  }

  Future<void> updateTodo(Todo todo) async {
    try {
      await _databaseService.updateTodo(todo);
      final index = _todos.indexWhere((t) => t.id == todo.id);
      if (index != -1) {
        _todos[index] = todo;
        if (todo.id != null) {
          await _notificationService.cancelNotification(todo.id!);
          if (todo.dueDate != null && !todo.isCompleted) {
            await _notificationService.scheduleTaskReminder(todo);
          }
        }
        _applyFilters();
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Error updating todo: $e';
      notifyListeners();
    }
  }

  Future<void> deleteTodo(int id) async {
    try {
      await _databaseService.deleteTodo(id);
      await _notificationService.cancelNotification(id);
      _todos.removeWhere((todo) => todo.id == id);
      _applyFilters();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error deleting todo: $e';
      notifyListeners();
    }
  }

  Future<void> toggleTodoComplete(Todo todo) async {
    final updatedTodo = todo.copyWith(isCompleted: !todo.isCompleted);
    await updateTodo(updatedTodo);
  }

  void searchTodos(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void filterByPriority(Priority? priority) {
    _filterPriority = priority;
    _applyFilters();
    notifyListeners();
  }

  void filterByCompleted(bool? completed) {
    _filterCompleted = completed;
    _applyFilters();
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _filterPriority = null;
    _filterCompleted = null;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    _filteredTodos = _todos.where((todo) {
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!todo.title.toLowerCase().contains(query) &&
            !todo.description.toLowerCase().contains(query)) {
          return false;
        }
      }
      if (_filterPriority != null && todo.priority != _filterPriority) {
        return false;
      }
      if (_filterCompleted != null && todo.isCompleted != _filterCompleted) {
        return false;
      }
      return true;
    }).toList();
    _filteredTodos.sort((a, b) {
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }
      if (a.dueDate != null && b.dueDate != null) {
        return a.dueDate!.compareTo(b.dueDate!);
      } else if (a.dueDate != null) {
        return -1;
      } else if (b.dueDate != null) {
        return 1;
      }
      return b.priority.index.compareTo(a.priority.index);
    });
  }

  Future<Todo?> getTodoById(int id) async {
    try {
      return await _databaseService.getTodoById(id);
    } catch (e) {
      _errorMessage = 'Error getting todo by id: $e';
      return null;
    }
  }

  Future<String> exportToCsv(String filePath) async {
    List<List<dynamic>> rows = [
      [
        'id', 'title', 'description', 'createdAt', 'dueDate', 'priority', 'isCompleted', 'attachments', 'checklist', 'theme'
      ],
      ..._todos.map((todo) => [
        todo.id ?? '',
        todo.title,
        todo.description,
        todo.createdAt.millisecondsSinceEpoch,
        todo.dueDate?.millisecondsSinceEpoch ?? '',
        todo.priority.index,
        todo.isCompleted ? 1 : 0,
        (todo.attachments ?? []).join('|'),
        (todo.checklist != null && todo.checklist is List<ChecklistItem>) ? ChecklistItem.encodeList(todo.checklist) : '',
        todo.theme ?? '',
      ])
    ];
    String csvData = const ListToCsvConverter().convert(rows);
    final file = File(filePath);
    await file.writeAsString(csvData);
    return file.path;
  }

  Future<int> importFromCsv(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) return 0;
    final csvData = await file.readAsString();
    final rows = const CsvToListConverter().convert(csvData, eol: '\n');
    int imported = 0;
    for (int i = 1; i < rows.length; i++) {
      final row = rows[i];
      try {
        final todo = Todo(
          title: row[1] ?? '',
          description: row[2] ?? '',
          createdAt: DateTime.fromMillisecondsSinceEpoch(int.tryParse(row[3].toString()) ?? DateTime.now().millisecondsSinceEpoch),
          dueDate: row[4] != '' ? DateTime.fromMillisecondsSinceEpoch(int.tryParse(row[4].toString()) ?? 0) : null,
          priority: Priority.values[int.tryParse(row[5].toString()) ?? 1],
          isCompleted: row[6] == 1,
          // attachments, checklist, theme tidak dikirim karena tidak ada di konstruktor model lama
        );
        await addTodo(todo);
        imported++;
      } catch (_) {}
    }
    return imported;
  }

  Future<void> triggerSmartReminder() async {
    await _notificationService.scheduleSmartReminder(_todos);
  }
}