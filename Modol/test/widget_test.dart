import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_todo_app/main.dart';
import 'package:flutter_todo_app/providers/todo_provider.dart';
import 'package:flutter_todo_app/services/database_service.dart';
import 'package:flutter_todo_app/services/notification_service.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class MockNotificationService extends Mock implements NotificationService {}

void main() {
  late MockNotificationService mockNotificationService;

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    WidgetsFlutterBinding.ensureInitialized();
    await DatabaseService().database;
    mockNotificationService = MockNotificationService();
    NotificationService.setInstance(mockNotificationService);
  });

  testWidgets('MyApp builds without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => TodoProvider()),
        ],
        child: const MyApp(),
      ),
    );
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
