import 'package:flutter_test/flutter_test.dart';
import '../../../lib/features/analytics/providers/time_tracking_provider.dart';
import '../../../lib/features/todo/models/todo_model.dart';

class MockTodoProvider {
  List<Todo> get todos => _todos;
  final List<Todo> _todos;
  MockTodoProvider(this._todos);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TimeTrackingProvider', () {
    late TimeTrackingProvider provider;
    final todo = Todo(id: 1, title: 'Test', description: '', createdAt: DateTime.now(), priority: EisenhowerPriority.urgentImportant, priorityLabel: 'Penting & Mendesak', isCompleted: false, attachments: [], checklist: []);

    setUp(() {
      provider = TimeTrackingProvider();
    });

    test('start and stop timer', () async {
      provider.startTaskTimer('1');
      await Future.delayed(Duration(seconds: 2));
      provider.stopTaskTimer('1');
      final total = provider.getTaskTotalTime('1');
      expect(total.inSeconds >= 2, true);
    });

    test('pause and resume timer', () async {
      provider.startTaskTimer('1');
      await Future.delayed(Duration(seconds: 1));
      provider.pauseTaskTimer('1');
      final paused = provider.getTaskTotalTime('1');
      await Future.delayed(Duration(seconds: 1));
      provider.resumeTaskTimer('1');
      await Future.delayed(Duration(seconds: 1));
      provider.stopTaskTimer('1');
      final total = provider.getTaskTotalTime('1');
      expect(total.inSeconds > paused.inSeconds, true);
    });
  });
}