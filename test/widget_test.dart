import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_todo_app/main.dart';
import 'package:flutter_todo_app/services/database_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'mock_notification_service.dart';

void main() {
  late MockNotificationService mockNotificationService;

  setUpAll(() async {
    // Initialize FFI
    sqfliteFfiInit();
    // Change the default factory for unit testing
    databaseFactory = databaseFactoryFfi;

    // Initialize services
    WidgetsFlutterBinding.ensureInitialized();
    await DatabaseService().database;
    mockNotificationService = MockNotificationService();
  });

  testWidgets('MyApp builds without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
