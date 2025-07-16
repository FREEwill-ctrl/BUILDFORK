import 'package:flutter/foundation.dart';
import '../models/todo_model.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';

class TodoProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final NotificationService _notificationService = NotificationService();

  List<Todo> _todos = [];
  List<Todo> _filteredTodos = [];
  String _searchQuery = '';
  Priority? _filterPriority;
  bool? _filterCompleted;
  bool _isLoading = false;

  List<Todo> get todos => _filteredTodos;
  String get searchQuery => _searchQuery;
  Priority? get filterPriority => _filterPriority;
  bool? get filterCompleted => _filterCompleted;
  bool get isLoading => _isLoading;

  int get totalTodos => _todos.length;
  int get completedTodos => _todos.where((todo) => todo.isCompleted).length;
  int get pendingTodos => _todos.where((todo) => !todo.isCompleted).length;

  Future<void> loadTodos() async {
    _isLoading = true;
    notifyListeners();

    try {
      _todos = await _databaseService.getAllTodos();
      _applyFilters();
    } catch (e) {
      print('Error loading todos: $e');
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

      // Schedule notification if due date is set
      if (newTodo.dueDate != null) {
        await _notificationService.scheduleTaskReminder(newTodo);
      }

      _applyFilters();
      notifyListeners();
    } catch (e) {
      print('Error adding todo: $e');
    }
  }

  Future<void> updateTodo(Todo todo) async {
    try {
      await _databaseService.updateTodo(todo);
      final index = _todos.indexWhere((t) => t.id == todo.id);
      if (index != -1) {
        _todos[index] = todo;

        // Update notification
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
      print('Error updating todo: $e');
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
      print('Error deleting todo: $e');
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
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!todo.title.toLowerCase().contains(query) &&
            !todo.description.toLowerCase().contains(query)) {
          return false;
        }
      }

      // Priority filter
      if (_filterPriority != null && todo.priority != _filterPriority) {
        return false;
      }

      // Completed filter
      if (_filterCompleted != null && todo.isCompleted != _filterCompleted) {
        return false;
      }

      return true;
    }).toList();

    // Sort by due date and priority
    _filteredTodos.sort((a, b) {
      // Completed tasks go to bottom
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }

      // Sort by due date (closest first)
      if (a.dueDate != null && b.dueDate != null) {
        return a.dueDate!.compareTo(b.dueDate!);
      } else if (a.dueDate != null) {
        return -1;
      } else if (b.dueDate != null) {
        return 1;
      }

      // Sort by priority (high first)
      return b.priority.index.compareTo(a.priority.index);
    });
  }

  Future<Todo?> getTodoById(int id) async {
    try {
      return await _databaseService.getTodoById(id);
    } catch (e) {
      print('Error getting todo by id: $e');
      return null;
    }
  }
}
