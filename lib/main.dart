import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/todo/providers/todo_provider.dart';
import 'features/pomodoro/providers/pomodoro_provider.dart';
import 'shared/app_theme.dart';
import 'features/todo/screens/home_screen.dart';
import 'features/pomodoro/screens/pomodoro_screen.dart';
import 'features/analytics/providers/time_tracking_provider.dart';
import 'features/analytics/screens/analytics_dashboard.dart';
import 'package:flutter/services.dart';
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
    // Neko-ray launcher tab
    NekoRayLauncherTab(),
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
          BottomNavigationBarItem(
            icon: Icon(Icons.extension),
            label: 'Neko-ray',
          ),
        ],
      ),
    );
  }
}

class NekoRayLauncherTab extends StatelessWidget {
  static const platform = MethodChannel('com.neko.ray/launcher');

  Future<void> _launchNekoRay(BuildContext context) async {
    try {
      final bool launched = await platform.invokeMethod('launchNekoRay');
      if (!launched) {
        _showInstallDialog(context);
      }
    } catch (e) {
      _showInstallDialog(context);
    }
  }

  void _showInstallDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Neko-ray tidak ditemukan'),
        content: const Text('Aplikasi Neko-ray belum terinstall. Silakan install Neko-ray terlebih dahulu.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
        icon: const Icon(Icons.open_in_new),
        label: const Text('Buka Neko-ray'),
        onPressed: () => _launchNekoRay(context),
      ),
    );
  }
}