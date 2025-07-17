import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../lib/features/analytics/services/time_tracking_storage.dart';
import '../../../lib/features/analytics/models/time_session.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  final storage = TimeTrackingStorage();
  final taskId = '1';
  final session = TimeSession(
    id: 'abc',
    startTime: DateTime(2023, 1, 1, 10, 0),
    endTime: DateTime(2023, 1, 1, 10, 30),
    duration: Duration(minutes: 30),
    sessionType: 'manual',
    taskId: taskId,
    wasCompleted: true,
  );

  test('save and load time session', () async {
    await storage.saveTimeSession(taskId, session);
    final sessions = await storage.getTaskTimeSessions(taskId);
    expect(sessions.length, 1);
    expect(sessions.first.duration.inMinutes, 30);
  });

  test('update and get total time', () async {
    await storage.updateTaskTimeSpent(taskId, Duration(minutes: 45));
    final prefs = await SharedPreferences.getInstance();
    final timers = prefs.getString(TimeTrackingStorage.taskTimersKey);
    expect(timers, isNotNull);
    expect(timers!.contains('45'), true);
  });
}