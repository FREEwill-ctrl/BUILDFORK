import 'dart:async';
import 'package:flutter/material.dart';
import '../models/time_session.dart';
import '../services/time_tracking_storage.dart';
import 'package:uuid/uuid.dart';

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
    if (_activeTaskId != null && _activeTaskId != taskId) {
      stopTaskTimer(_activeTaskId!);
    }
    _activeTaskId = taskId;
    _sessionStartTime = DateTime.now();
    _activeTimer?.cancel();
    _activeTimer = Timer.periodic(Duration(seconds: 1), (_) => _tick());
    await _storage.persistActiveTimer(taskId, _sessionStartTime!);
    notifyListeners();
  }

  void _tick() {
    if (_activeTaskId == null || _sessionStartTime == null) return;
    final now = DateTime.now();
    final elapsed = now.difference(_sessionStartTime!);
    _taskTimers[_activeTaskId!] = (_taskTimers[_activeTaskId!] ?? Duration.zero) + Duration(seconds: 1);
    notifyListeners();
  }

  void stopTaskTimer(String taskId, {bool completed = false}) async {
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
  }

  void pauseTaskTimer(String taskId) async {
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
  }

  void resumeTaskTimer(String taskId) async {
    if (_activeTaskId != null && _activeTaskId != taskId) {
      stopTaskTimer(_activeTaskId!);
    }
    _activeTaskId = taskId;
    _sessionStartTime = DateTime.now();
    _activeTimer?.cancel();
    _activeTimer = Timer.periodic(Duration(seconds: 1), (_) => _tick());
    await _storage.persistActiveTimer(taskId, _sessionStartTime!);
    notifyListeners();
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
    // TODO: Restore active timer state from storage if app was closed
  }
}