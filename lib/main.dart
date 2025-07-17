import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/todo/providers/todo_provider.dart';
import 'features/pomodoro/providers/pomodoro_provider.dart';
import 'shared/app_theme.dart';
import 'features/todo/screens/home_screen.dart';

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
      ],
      child: MaterialApp(
        title: 'Todo Modular',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const HomeScreen(),
      ),
    );
  }
}