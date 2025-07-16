import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/todo_provider.dart';
import 'providers/pomodoro_provider.dart';
import 'services/notification_service.dart';
import 'screens/home_screen.dart';
import 'utils/constants.dart';
import 'package:quick_actions/quick_actions.dart';
import 'screens/add_task_screen.dart';
import 'screens/pomodoro_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize notification service
  await NotificationService().initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    final quickActions = QuickActions();
    quickActions.setShortcutItems(<ShortcutItem>[
      const ShortcutItem(type: 'add_task', localizedTitle: 'Add Task', icon: 'add'),
      const ShortcutItem(type: 'pomodoro', localizedTitle: 'Pomodoro Timer', icon: 'timer'),
    ]);
    quickActions.initialize((String shortcutType) {
      if (shortcutType == 'add_task') {
        navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (context) => const AddTaskScreen()),
        );
      } else if (shortcutType == 'pomodoro') {
        navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (context) => const PomodoroScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TodoProvider()),
        ChangeNotifierProvider(create: (_) => PomodoroProvider()),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const HomeScreen(),
      ),
    );
  }
}
