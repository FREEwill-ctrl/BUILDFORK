import 'dart:async';
import 'package:flutter/material.dart';
import '../models/time_session.dart';
import '../services/time_tracking_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class TimeTrackingProvider extends ChangeNotifier {
  Timer? _activeTimer;
  String? _activeTaskId;
  DateTime? _sessionStartTime;
  Map<String, Duration> _taskTimers = {};
  final TimeTrackingStorage _storage = TimeTrackingStorage();

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
    final now = DateTime.now();
    final elapsed = now.difference(_sessionStartTime!);
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

  Map<String, Duration> getDailyTimeDistribution() {
    // TODO: Implement distribution logic
    return {};
  }

  double calculateProductivityScore(String taskId) {
    // TODO: Implement productivity score calculation
    return 0.0;
  }

  void linkTaskWithPomodoro(String taskId, String pomodoroSessionId) {
    // TODO: Implement linking logic
  }

  void syncPomodoroTaskTime(String taskId, Duration pomodoroTime) {
    _taskTimers[taskId] = (_taskTimers[taskId] ?? Duration.zero) + pomodoroTime;
    notifyListeners();
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