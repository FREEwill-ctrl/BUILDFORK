import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/time_session.dart';
import '../models/daily_stats.dart';
import '../services/time_tracking_storage.dart';
import '../../todo/providers/todo_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class TimeTrackingProvider extends ChangeNotifier {
  Timer? _activeTimer;
  String? _activeTaskId;
  DateTime? _sessionStartTime;
  Map<String, Duration> _taskTimers = {};
  final TimeTrackingStorage _storage = TimeTrackingStorage();

  String? get activeTaskId => _activeTaskId;
  Map<String, Duration> get taskTimers => _taskTimers;

  // --- Caching for performance ---
  Map<String, double>? _quadrantCache;
  DateTime? _quadrantCacheTime;
  Map<DateTime, double>? _heatmapCache;
  DateTime? _heatmapCacheTime;

  @override
  void notifyListeners() {
    // Invalidate cache on any update
    _quadrantCache = null;
    _heatmapCache = null;
    super.notifyListeners();
  }

  TimeTrackingProvider() {
    _restoreActiveTimer();
  }

  void startTaskTimer(String taskId) async {
    try {
      if (_activeTaskId != null && _activeTaskId != taskId) {
        stopTaskTimer(_activeTaskId!);
      }
      _activeTaskId = taskId;
      _sessionStartTime = DateTime.now();
      _activeTimer?.cancel();
      _activeTimer = Timer.periodic(Duration(seconds: 1), (_) => _tick());
      await _storage.persistActiveTimer(taskId, _sessionStartTime!);
      notifyListeners();
    } catch (e) {
      debugPrint('Error starting timer: $e');
    }
  }

  void _tick() {
    if (_activeTaskId == null || _sessionStartTime == null) return;
    _taskTimers[_activeTaskId!] = (_taskTimers[_activeTaskId!] ?? Duration.zero) + Duration(seconds: 1);
    notifyListeners();
  }

  void stopTaskTimer(String taskId, {bool completed = false}) async {
    try {
      if (_activeTaskId != taskId) return;
      _activeTimer?.cancel();
      final now = DateTime.now();
      final start = _sessionStartTime ?? now;
      final duration = now.difference(start);
      _taskTimers[taskId] = (_taskTimers[taskId] ?? Duration.zero) + duration;
      await _storage.updateTaskTimeSpent(taskId, _taskTimers[taskId]!);
      await _storage.saveTimeSession(
        taskId,
        TimeSession(
          id: Uuid().v4(),
          startTime: start,
          endTime: now,
          duration: duration,
          sessionType: 'manual',
          taskId: taskId,
          wasCompleted: completed,
        ),
      );
      await _storage.clearActiveTimer(taskId);
      _activeTaskId = null;
      _sessionStartTime = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Error stopping timer: $e');
    }
  }

  void pauseTaskTimer(String taskId) async {
    try {
      if (_activeTaskId != taskId) return;
      _activeTimer?.cancel();
      final now = DateTime.now();
      final start = _sessionStartTime ?? now;
      final duration = now.difference(start);
      _taskTimers[taskId] = (_taskTimers[taskId] ?? Duration.zero) + duration;
      await _storage.updateTaskTimeSpent(taskId, _taskTimers[taskId]!);
      await _storage.saveTimeSession(
        taskId,
        TimeSession(
          id: Uuid().v4(),
          startTime: start,
          endTime: now,
          duration: duration,
          sessionType: 'manual',
          taskId: taskId,
          wasCompleted: false,
        ),
      );
      await _storage.persistActiveTimer(taskId, now);
      _sessionStartTime = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Error pausing timer: $e');
    }
  }

  void resumeTaskTimer(String taskId) async {
    try {
      if (_activeTaskId != null && _activeTaskId != taskId) {
        stopTaskTimer(_activeTaskId!);
      }
      _activeTaskId = taskId;
      _sessionStartTime = DateTime.now();
      _activeTimer?.cancel();
      _activeTimer = Timer.periodic(Duration(seconds: 1), (_) => _tick());
      await _storage.persistActiveTimer(taskId, _sessionStartTime!);
      notifyListeners();
    } catch (e) {
      debugPrint('Error resuming timer: $e');
    }
  }

  Duration getTaskTotalTime(String taskId) {
    return _taskTimers[taskId] ?? Duration.zero;
  }

  /// Returns a map of quadrant label to total time spent (in minutes)
  Map<String, double> getQuadrantTimeDistribution(BuildContext context) {
    if (_quadrantCache != null && _quadrantCacheTime != null && DateTime.now().difference(_quadrantCacheTime!) < Duration(seconds: 10)) {
      return _quadrantCache!;
    }
    final todoProvider = Provider.of<TodoProvider>(context, listen: false);
    final todos = todoProvider.todos;
    final Map<String, double> result = {
      'Penting & Mendesak': 0,
      'Penting & Tidak Mendesak': 0,
      'Tidak Penting & Mendesak': 0,
      'Tidak Penting & Tidak Mendesak': 0,
    };
    for (final todo in todos) {
      final key = todo.priorityLabel;
      final time = getTaskTotalTime(todo.id.toString()).inMinutes.toDouble();
      if (result.containsKey(key)) {
        result[key] = result[key]! + time;
      }
    }
    _quadrantCache = result;
    _quadrantCacheTime = DateTime.now();
    return result;
  }

  /// Returns a map of DateTime (day) to productivity score (0..1)
  Future<Map<DateTime, double>> getProductivityHeatmap(BuildContext context) async {
    if (_heatmapCache != null && _heatmapCacheTime != null && DateTime.now().difference(_heatmapCacheTime!) < Duration(seconds: 10)) {
      return _heatmapCache!;
    }
    final todoProvider = Provider.of<TodoProvider>(context, listen: false);
    final todos = todoProvider.todos;
    final Map<DateTime, double> result = {};
    for (final todo in todos) {
      final sessions = await _storage.getTaskTimeSessions(todo.id.toString());
      for (final session in sessions) {
        final day = DateTime(session.startTime.year, session.startTime.month, session.startTime.day);
        result[day] = (result[day] ?? 0.0) + (session.duration.inMinutes.toDouble() / 120.0); // Normalize to 2h max
      }
    }
    // Clamp to 1.0
    result.updateAll((k, v) => v is double ? (v > 1.0 ? 1.0 : v) : (v is num ? (v > 1.0 ? 1.0 : v.toDouble()) : 0.0));
    _heatmapCache = result;
    _heatmapCacheTime = DateTime.now();
    return result;
  }

  /// Returns daily stats for today (can be extended for range)
  Future<DailyStats> getTodayStats(BuildContext context) async {
    final todoProvider = Provider.of<TodoProvider>(context, listen: false);
    final todos = todoProvider.todos;
    final today = DateTime.now();
    int tasksCompleted = 0;
    int pomodoroSessions = 0; // Placeholder, integrate with PomodoroProvider
    double totalMinutes = 0;
    for (final todo in todos) {
      if (todo.isCompleted && todo.dueDate != null &&
          todo.dueDate!.year == today.year && todo.dueDate!.month == today.month && todo.dueDate!.day == today.day) {
        tasksCompleted++;
      }
      totalMinutes += getTaskTotalTime(todo.id.toString()).inMinutes;
    }
    // Productivity score: ratio of completed tasks to total
    final productivityScore = todos.isEmpty ? 0 : tasksCompleted / todos.length;
    return DailyStats(
      date: today,
      totalTimeSpent: Duration(minutes: totalMinutes.toInt()),
      tasksCompleted: tasksCompleted,
      pomodoroSessions: pomodoroSessions,
      productivityScore: productivityScore,
    );
  }

  // Integration dengan existing PomodoroProvider
  String? _linkedTaskId;
  void linkTaskWithPomodoro(String taskId) {
    _linkedTaskId = taskId;
  }

  void syncPomodoroTaskTime(Duration pomodoroTime) {
    if (_linkedTaskId != null) {
      _taskTimers[_linkedTaskId!] = (_taskTimers[_linkedTaskId!] ?? Duration.zero) + pomodoroTime;
      notifyListeners();
    }
  }

  // Notifikasi stub: panggil ini saat Pomodoro selesai
  void notifyPomodoroCompleted(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Pomodoro selesai! Waktumu sudah tercatat di task.')),
    );
  }

  Future<void> _restoreActiveTimer() async {
    // Restore active timer state from storage if app was closed
    final prefs = await TimeTrackingStorage()._getPrefs();
    final timers = prefs.getString(TimeTrackingStorage.activeTimersKey);
    if (timers != null) {
      final timersMap = Map<String, dynamic>.from(jsonDecode(timers));
      if (timersMap.isNotEmpty) {
        final entry = timersMap.entries.first;
        _activeTaskId = entry.key;
        _sessionStartTime = DateTime.tryParse(entry.value);
        if (_activeTaskId != null && _sessionStartTime != null) {
          _activeTimer?.cancel();
          _activeTimer = Timer.periodic(Duration(seconds: 1), (_) => _tick());
        }
      }
    }
    // Restore total times
    final timersStr = prefs.getString(TimeTrackingStorage.taskTimersKey);
    if (timersStr != null) {
      final timersMap = Map<String, dynamic>.from(jsonDecode(timersStr));
      _taskTimers = timersMap.map((k, v) => MapEntry(k, Duration(milliseconds: v)));
    }
    notifyListeners();
  }
}

extension on TimeTrackingStorage {
  Future<SharedPreferences> _getPrefs() => SharedPreferences.getInstance();
}