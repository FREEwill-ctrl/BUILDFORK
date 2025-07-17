import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pomodoro_provider.dart';

class PomodoroScreen extends StatelessWidget {
  const PomodoroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pomodoro Timer')),
      body: Center(
        child: Consumer<PomodoroProvider>(
          builder: (context, provider, _) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(provider.formattedTime, style: const TextStyle(fontSize: 48)),
                const SizedBox(height: 24),
                Text('Pomodoros Completed: ${provider.pomodoroCount}'),
              ],
            );
          },
        ),
      ),
    );
  }
}