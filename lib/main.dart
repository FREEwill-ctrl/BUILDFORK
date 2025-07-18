import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/todo/providers/todo_provider.dart';
import 'features/pomodoro/providers/pomodoro_provider.dart';
import 'shared/app_theme.dart';
import 'features/todo/screens/home_screen.dart';
import 'features/pomodoro/screens/pomodoro_screen.dart';
import 'features/analytics/providers/time_tracking_provider.dart';
import 'features/analytics/screens/analytics_dashboard.dart';
import 'features/todo/screens/onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
// ThemeProvider sudah ada di app_theme.dart

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

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
          navigatorKey: navigatorKey,
          home: _RootScreen(),
        ),
      ),
    );
  }
}

class _RootScreen extends StatefulWidget {
  @override
  State<_RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<_RootScreen> {
  bool _loading = true;
  bool _showOnboarding = false;

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    final done = prefs.getBool('onboarding_done') ?? false;
    setState(() {
      _showOnboarding = !done;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_showOnboarding) {
      return OnboardingScreen(onFinish: () => setState(() => _showOnboarding = false));
    }
    return MainTabScreen();
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

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
      Provider.of<TodoProvider>(context, listen: false).loadTodos()
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: SafeArea(
        child: BottomNavigationBar(
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
      ),
    );
  }
}