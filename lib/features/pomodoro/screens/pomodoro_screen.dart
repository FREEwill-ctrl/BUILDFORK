import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pomodoro_provider.dart';
import '../../../shared/app_theme.dart';
import '../../todo/providers/todo_provider.dart';

class PomodoroScreen extends StatelessWidget {
  const PomodoroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pomodoroProvider = Provider.of<PomodoroProvider>(context);
    final todoProvider = Provider.of<TodoProvider>(context);
    final todos = todoProvider.todos;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pomodoro Timer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => showDialog(
              context: context,
              builder: (context) => const _PomodoroSettingsDialog(),
            ),
          ),
          IconButton(
            icon: Icon(Theme.of(context).brightness == Brightness.dark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // --- Link Pomodoro to Task ---
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButtonFormField<String>(
              value: pomodoroProvider.linkedTaskId,
              items: todos.map((t) => DropdownMenuItem(value: t.id.toString(), child: Text(t.title))).toList(),
              onChanged: (val) {
                if (val != null) pomodoroProvider.linkToTask(val);
              },
              decoration: InputDecoration(labelText: 'Link ke Task'),
            ),
          ),
          Center(
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
                    totalSeconds = provider.pomodoroMinutes * 60;
                    break;
                  case SessionType.shortBreak:
                    totalSeconds = provider.shortBreakMinutes * 60;
                    break;
                  case SessionType.longBreak:
                    totalSeconds = provider.longBreakMinutes * 60;
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
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        sessionLabel,
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: sessionColor),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle, color: Colors.redAccent, size: 20),
                          const SizedBox(width: 4),
                          Text('Pomodoro: ${provider.pomodoroCount}',
                            style: const TextStyle(fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(width: 16),
                          Icon(Icons.repeat, color: Colors.blue, size: 20),
                          const SizedBox(width: 4),
                          Text('Cycle: ${provider.cycle % 4}/4',
                            style: const TextStyle(fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
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
                        ],
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.skip_next),
                          label: const Text('Skip'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                          ),
                          onPressed: provider.skip,
                        ),
                      ),
                      const SizedBox(height: 32),
                      _PomodoroStats(),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PomodoroSettingsDialog extends StatefulWidget {
  const _PomodoroSettingsDialog();

  @override
  State<_PomodoroSettingsDialog> createState() => _PomodoroSettingsDialogState();
}

class _PomodoroSettingsDialogState extends State<_PomodoroSettingsDialog> {
  late TextEditingController pomodoroController;
  late TextEditingController shortBreakController;
  late TextEditingController longBreakController;

  @override
  void initState() {
    final provider = Provider.of<PomodoroProvider>(context, listen: false);
    pomodoroController = TextEditingController(text: (provider.pomodoroMinutes).toString());
    shortBreakController = TextEditingController(text: (provider.shortBreakMinutes).toString());
    longBreakController = TextEditingController(text: (provider.longBreakMinutes).toString());
    super.initState();
  }

  @override
  void dispose() {
    pomodoroController.dispose();
    shortBreakController.dispose();
    longBreakController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Pengaturan Durasi'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: pomodoroController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Pomodoro (menit)'),
          ),
          TextField(
            controller: shortBreakController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Short Break (menit)'),
          ),
          TextField(
            controller: longBreakController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Long Break (menit)'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () {
            final provider = Provider.of<PomodoroProvider>(context, listen: false);
            final int pomodoro = int.tryParse(pomodoroController.text) ?? 25;
            final int shortBreak = int.tryParse(shortBreakController.text) ?? 5;
            final int longBreak = int.tryParse(longBreakController.text) ?? 15;
            provider.setDurations(pomodoro, shortBreak, longBreak);
            Navigator.pop(context);
          },
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}

class _PomodoroStats extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PomodoroProvider>(context);
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                const Text('Hari ini', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('${provider.todayPomodoro}'),
              ],
            ),
            Column(
              children: [
                const Text('Minggu ini', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('${provider.weekPomodoro}'),
              ],
            ),
            Column(
              children: [
                const Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('${provider.totalPomodoro}'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}