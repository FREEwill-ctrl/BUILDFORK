import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/todo/providers/todo_provider.dart';
import 'features/pomodoro/providers/pomodoro_provider.dart';
import 'shared/app_theme.dart';
import 'features/todo/screens/home_screen.dart';
import 'features/pomodoro/screens/pomodoro_screen.dart';
import 'features/time_tracking/providers/time_tracking_provider.dart';
import 'features/analytics/screens/analytics_dashboard.dart';
// ThemeProvider sudah ada di app_theme.dart

void main() {
  runApp(const TodoModularApp());
}

class TodoModularApp extends StatelessWidget {
  const TodoModularApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TodoProvider()),
        ChangeNotifierProvider(create: (_) => PomodoroProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => TimeTrackingProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) => MaterialApp(
          title: 'Todo Modular',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          home: const MainTabScreen(),
        ),
      ),
    );
  }
}

class MainTabScreen extends StatefulWidget {
  const MainTabScreen({super.key});

  @override
  State<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> {
  int _selectedIndex = 0;
  static final List<Widget> _pages = [
    HomeScreen(),
    PomodoroScreen(),
    AnalyticsDashboard(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle_outline),
            label: 'Todo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timer),
            label: 'Pomodoro',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
        ],
      ),
    );
  }
}