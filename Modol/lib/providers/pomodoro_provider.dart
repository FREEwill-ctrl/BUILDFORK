import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../services/notification_service.dart';

enum PomodoroState {
  initial,
  running,
  paused,
  stopped,
}

enum SessionType {
  pomodoro,
  shortBreak,
  longBreak,
}

class PomodoroProvider with ChangeNotifier {
  static const int _pomodoroDuration = 25 * 60; // 25 minutes
  static const int _shortBreakDuration = 5 * 60; // 5 minutes
  static const int _longBreakDuration = 15 * 60; // 15 minutes

  Timer? _timer;
  int _secondsRemaining = _pomodoroDuration;
  PomodoroState _state = PomodoroState.initial;
  SessionType _sessionType = SessionType.pomodoro;
  int _pomodoroCount = 0;

  int get secondsRemaining => _secondsRemaining;
  PomodoroState get state => _state;
  SessionType get sessionType => _sessionType;
  int get pomodoroCount => _pomodoroCount;

  String get formattedTime {
    int minutes = _secondsRemaining ~/ 60;
    int seconds = _secondsRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void startTimer() {
    if (_state == PomodoroState.running) return;

    _state = PomodoroState.running;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        _secondsRemaining--;
      } else {
        _timer?.cancel();
        _state = PomodoroState.stopped;
        _moveToNextSession();
      }
      notifyListeners();
    });
    notifyListeners();
  }

  void pauseTimer() {
    if (_state == PomodoroState.running) {
      _timer?.cancel();
      _state = PomodoroState.paused;
      notifyListeners();
    }
  }

  void resumeTimer() {
    if (_state == PomodoroState.paused) {
      startTimer();
    }
  }

  void stopTimer() {
    _timer?.cancel();
    _state = PomodoroState.stopped;
    _secondsRemaining = _pomodoroDuration; // Reset to initial pomodoro duration
    _sessionType = SessionType.pomodoro;
    notifyListeners();
  }

  void _moveToNextSession() {
    String notificationTitle;
    String notificationBody;

    if (_sessionType == SessionType.pomodoro) {
      _pomodoroCount++;
      if (_pomodoroCount % 4 == 0) {
        _sessionType = SessionType.longBreak;
        _secondsRemaining = _longBreakDuration;
        notificationTitle = 'Long Break Time!';
        notificationBody = 'You completed 4 Pomodoros. Take a 15-minute break.';
      } else {
        _sessionType = SessionType.shortBreak;
        _secondsRemaining = _shortBreakDuration;
        notificationTitle = 'Short Break Time!';
        notificationBody = 'Pomodoro completed. Take a 5-minute break.';
      }
    } else {
      _sessionType = SessionType.pomodoro;
      _secondsRemaining = _pomodoroDuration;
      notificationTitle = 'Time to Focus!';
      notificationBody = 'Break is over. Start your next Pomodoro.';
    }
    NotificationService().showPomodoroNotification(id: 0, title: notificationTitle, body: notificationBody);
    startTimer(); // Automatically start next session
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}


