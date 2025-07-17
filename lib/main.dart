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
import 'package:shared_preferences/shared_preferences.dart';
import 'package:home_widget/home_widget.dart';

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
  ThemeMode _themeMode = ThemeMode.system;
  String _customTheme = 'default';

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
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

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final mode = prefs.getString('theme_mode') ?? 'system';
    final custom = prefs.getString('custom_theme') ?? 'default';
    setState(() {
      if (mode == 'light') {
        _themeMode = ThemeMode.light;
      } else if (mode == 'dark') {
        _themeMode = ThemeMode.dark;
      } else {
        _themeMode = ThemeMode.system;
      }
      _customTheme = custom;
    });
  }

  Future<void> setThemeMode(ThemeMode mode, {String custom = 'default'}) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _themeMode = mode;
      _customTheme = custom;
    });
    await prefs.setString('theme_mode',
        mode == ThemeMode.light ? 'light' : mode == ThemeMode.dark ? 'dark' : 'system');
    await prefs.setString('custom_theme', custom);
  }

  ThemeData _getTheme() {
    if (_customTheme == 'blue') return AppTheme.blueTheme;
    if (_customTheme == 'green') return AppTheme.greenTheme;
    if (_customTheme == 'red') return AppTheme.redTheme;
    return AppTheme.lightTheme;
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
        theme: _getTheme(),
        darkTheme: AppTheme.darkTheme,
        themeMode: _themeMode,
        home: HomeScreen(onThemeModeChanged: setThemeMode, currentThemeMode: _themeMode, customTheme: _customTheme),
      ),
    );
  }
}

// Tambahkan fungsi update widget
Future<void> updateHomeWidget(int taskCount) async {
  await HomeWidget.saveWidgetData('task_count', taskCount);
  await HomeWidget.updateWidget(name: 'HomeWidgetProvider', iOSName: 'HomeWidgetProvider');
}
