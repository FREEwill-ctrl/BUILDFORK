import 'package:flutter/foundation.dart';
import '../../analytics/models/time_session.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class TimeTrackingStorage {
  static const String timeSessionsKey = 'time_sessions';
  static const String taskTimersKey = 'task_timers';
  static const String productivityStatsKey = 'productivity_stats';
  static const String activeTimersKey = 'active_timers';

  Future<void> saveTimeSession(String taskId, TimeSession session) async {
    final prefs = await SharedPreferences.getInstance();
    final sessionsJson = prefs.getStringList('$timeSessionsKey".$taskId"') ?? [];
    sessionsJson.add(jsonEncode(session.toJson()));
    await prefs.setStringList('$timeSessionsKey".$taskId"', sessionsJson);
  }

  Future<List<TimeSession>> getTaskTimeSessions(String taskId) async {
    final prefs = await SharedPreferences.getInstance();
    final sessionsJson = prefs.getStringList('$timeSessionsKey".$taskId"') ?? [];
    return sessionsJson.map((s) => TimeSession.fromJson(jsonDecode(s))).toList();
  }

  Future<void> updateTaskTimeSpent(String taskId, Duration totalTime) async {
    final prefs = await SharedPreferences.getInstance();
    final timers = prefs.getString(taskTimersKey);
    Map<String, dynamic> timersMap = timers != null ? jsonDecode(timers) : {};
    timersMap[taskId] = totalTime.inMilliseconds;
    await prefs.setString(taskTimersKey, jsonEncode(timersMap));
  }

  Future<Map<String, dynamic>> getProductivityStats(DateTimeRange range) async {
    // Placeholder: implement aggregation logic as needed
    return {};
  }

  Future<void> persistActiveTimer(String taskId, DateTime startTime) async {
    final prefs = await SharedPreferences.getInstance();
    final timers = prefs.getString(activeTimersKey);
    Map<String, dynamic> timersMap = timers != null ? jsonDecode(timers) : {};
    timersMap[taskId] = startTime.toIso8601String();
    await prefs.setString(activeTimersKey, jsonEncode(timersMap));
  }

  Future<void> clearActiveTimer(String taskId) async {
    final prefs = await SharedPreferences.getInstance();
    final timers = prefs.getString(activeTimersKey);
    if (timers == null) return;
    Map<String, dynamic> timersMap = jsonDecode(timers);
    timersMap.remove(taskId);
    await prefs.setString(activeTimersKey, jsonEncode(timersMap));
  }
}