import 'package:flutter/material.dart';
import 'dart:async';

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
  int _cycle = 0;
  int get cycle => _cycle;
  Timer? _timer;

  // Durasi default (detik)
  static const int pomodoroDuration = 25 * 60;
  static const int shortBreakDuration = 5 * 60;
  static const int longBreakDuration = 15 * 60;

  String get formattedTime {
    int minutes = _secondsRemaining ~/ 60;
    int seconds = _secondsRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void start() {
    if (_state == PomodoroState.running) return;
    _state = PomodoroState.running;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        _secondsRemaining--;
        notifyListeners();
      } else {
        _timer?.cancel();
        _onSessionComplete();
      }
    });
    notifyListeners();
  }

  void pause() {
    if (_state != PomodoroState.running) return;
    _state = PomodoroState.paused;
    _timer?.cancel();
    notifyListeners();
  }

  void reset() {
    _timer?.cancel();
    _state = PomodoroState.initial;
    switch (_sessionType) {
      case SessionType.pomodoro:
        _secondsRemaining = pomodoroDuration;
        break;
      case SessionType.shortBreak:
        _secondsRemaining = shortBreakDuration;
        break;
      case SessionType.longBreak:
        _secondsRemaining = longBreakDuration;
        break;
    }
    notifyListeners();
  }

  void skip() {
    _timer?.cancel();
    _onSessionComplete();
  }

  void _onSessionComplete() {
    // Placeholder: trigger notifikasi jika perlu
    // _showNotification();
    if (_sessionType == SessionType.pomodoro) {
      _pomodoroCount++;
      _cycle++;
      if (_cycle % 4 == 0) {
        _sessionType = SessionType.longBreak;
        _secondsRemaining = longBreakDuration;
      } else {
        _sessionType = SessionType.shortBreak;
        _secondsRemaining = shortBreakDuration;
      }
    } else {
      _sessionType = SessionType.pomodoro;
      _secondsRemaining = pomodoroDuration;
    }
    _state = PomodoroState.stopped;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}