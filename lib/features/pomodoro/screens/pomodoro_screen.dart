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
            String sessionLabel;
            Color sessionColor;
            switch (provider.sessionType) {
              case SessionType.pomodoro:
                sessionLabel = 'Focus';
                sessionColor = Colors.redAccent;
                break;
              case SessionType.shortBreak:
                sessionLabel = 'Short Break';
                sessionColor = Colors.green;
                break;
              case SessionType.longBreak:
                sessionLabel = 'Long Break';
                sessionColor = Colors.blue;
                break;
            }
            int totalSeconds;
            switch (provider.sessionType) {
              case SessionType.pomodoro:
                totalSeconds = PomodoroProvider.pomodoroDuration;
                break;
              case SessionType.shortBreak:
                totalSeconds = PomodoroProvider.shortBreakDuration;
                break;
              case SessionType.longBreak:
                totalSeconds = PomodoroProvider.longBreakDuration;
                break;
            }
            double progress = 1 - (provider.secondsRemaining / totalSeconds);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Pomodoro adalah teknik manajemen waktu: 25 menit fokus, 5 menit istirahat, 4 siklus lalu istirahat panjang.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    sessionLabel,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: sessionColor),
                  ),
                  const SizedBox(height: 8),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 180,
                        height: 180,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 10,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(sessionColor),
                        ),
                      ),
                      Text(
                        provider.formattedTime,
                        style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, color: Colors.redAccent, size: 20),
                      const SizedBox(width: 4),
                      Text('Pomodoro: ${provider.pomodoroCount}'),
                      const SizedBox(width: 16),
                      Icon(Icons.repeat, color: Colors.blue, size: 20),
                      const SizedBox(width: 4),
                      Text('Cycle: ${provider.cycle % 4}/4'),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        icon: Icon(provider.state == PomodoroState.running ? Icons.pause : Icons.play_arrow),
                        label: Text(provider.state == PomodoroState.running ? 'Pause' : 'Start'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: sessionColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        onPressed: () {
                          if (provider.state == PomodoroState.running) {
                            provider.pause();
                          } else {
                            provider.start();
                          }
                        },
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reset'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[400],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                        onPressed: provider.reset,
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.skip_next),
                        label: const Text('Skip'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                        onPressed: provider.skip,
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}