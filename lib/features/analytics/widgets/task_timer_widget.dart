import 'package:flutter/material.dart';

class TaskTimerWidget extends StatelessWidget {
  final bool isActive;
  final Duration totalTime;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onStop;

  const TaskTimerWidget({
    Key? key,
    required this.isActive,
    required this.totalTime,
    required this.onStart,
    required this.onPause,
    required this.onStop,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Chip(
          label: Text(_formatDuration(totalTime)),
          avatar: Icon(isActive ? Icons.timer : Icons.timer_off),
        ),
        const SizedBox(width: 8),
        isActive
            ? IconButton(
                icon: Icon(Icons.pause),
                onPressed: onPause,
              )
            : IconButton(
                icon: Icon(Icons.play_arrow),
                onPressed: onStart,
              ),
        IconButton(
          icon: Icon(Icons.stop),
          onPressed: onStop,
        ),
      ],
    );
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    if (d == Duration.zero) {
      return '00:00';
    }
    if (hours > 0) {
      return '${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}';
    } else {
      return '${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
  }
}