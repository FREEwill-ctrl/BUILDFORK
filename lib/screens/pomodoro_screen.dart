import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pomodoro_provider.dart';
import '../utils/constants.dart';

class PomodoroScreen extends StatelessWidget {
  const PomodoroScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pomodoro Timer'),
      ),
      body: Consumer<PomodoroProvider>(
        builder: (context, pomodoroProvider, child) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  pomodoroProvider.formattedTime,
                  style: const TextStyle(fontSize: 80, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 100,
                  width: 100,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: 1 - pomodoroProvider.secondsRemaining /
                          (pomodoroProvider.sessionType == SessionType.pomodoro
                            ? 25 * 60
                            : pomodoroProvider.sessionType == SessionType.shortBreak
                              ? 5 * 60
                              : 15 * 60),
                        strokeWidth: 8,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          pomodoroProvider.sessionType == SessionType.pomodoro
                            ? AppConstants.primaryColor
                            : pomodoroProvider.sessionType == SessionType.shortBreak
                              ? AppConstants.successColor
                              : AppConstants.warningColor,
                        ),
                      ),
                      Text(
                        pomodoroProvider.sessionType == SessionType.pomodoro
                          ? 'Focus'
                          : pomodoroProvider.sessionType == SessionType.shortBreak
                            ? 'Break'
                            : 'Long Break',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppConstants.paddingLarge),
                Text(
                  'Session: ${pomodoroProvider.sessionType.toString().split('.').last}',
                  style: const TextStyle(fontSize: 24),
                ),
                Text(
                  'Pomodoros Completed: ${pomodoroProvider.pomodoroCount}',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: AppConstants.paddingLarge),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (pomodoroProvider.state != PomodoroState.running) 
                      ElevatedButton(
                        onPressed: pomodoroProvider.startTimer,
                        child: const Text('Start'),
                      ),
                    if (pomodoroProvider.state == PomodoroState.running) 
                      ElevatedButton(
                        onPressed: pomodoroProvider.pauseTimer,
                        child: const Text('Pause'),
                      ),
                    const SizedBox(width: AppConstants.paddingMedium),
                    if (pomodoroProvider.state == PomodoroState.paused) 
                      ElevatedButton(
                        onPressed: pomodoroProvider.resumeTimer,
                        child: const Text('Resume'),
                      ),
                    const SizedBox(width: AppConstants.paddingMedium),
                    ElevatedButton(
                      onPressed: pomodoroProvider.stopTimer,
                      child: const Text('Stop'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}


