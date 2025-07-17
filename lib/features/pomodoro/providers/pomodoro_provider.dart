import 'package:flutter/material.dart';

enum PomodoroState { initial, running, paused, stopped }

enum SessionType { pomodoro, shortBreak, longBreak }

class PomodoroProvider with ChangeNotifier {
  PomodoroState _state = PomodoroState.initial;
  PomodoroState get state => _state;
  int _pomodoroCount = 0;
  int get pomodoroCount => _pomodoroCount;
  int _secondsRemaining = 25 * 60;
  int get secondsRemaining => _secondsRemaining;
  SessionType _sessionType = SessionType.pomodoro;
  SessionType get sessionType => _sessionType;
  String get formattedTime {
    int minutes = _secondsRemaining ~/ 60;
    int seconds = _secondsRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}