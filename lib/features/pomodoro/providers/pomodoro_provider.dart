import 'package:flutter/material.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final AudioPlayer _audioPlayer = AudioPlayer();

  int _pomodoroMinutes = 25;
  int _shortBreakMinutes = 5;
  int _longBreakMinutes = 15;
  int get pomodoroMinutes => _pomodoroMinutes;
  int get shortBreakMinutes => _shortBreakMinutes;
  int get longBreakMinutes => _longBreakMinutes;

  int _todayPomodoro = 0;
  int _weekPomodoro = 0;
  int _totalPomodoro = 0;
  DateTime? _lastPomodoroDate;
  int get todayPomodoro => _todayPomodoro;
  int get weekPomodoro => _weekPomodoro;
  int get totalPomodoro => _totalPomodoro;

  PomodoroProvider() {
    _loadStats();
  }

  void setDurations(int pomodoro, int shortBreak, int longBreak) {
    _pomodoroMinutes = pomodoro;
    _shortBreakMinutes = shortBreak;
    _longBreakMinutes = longBreak;
    reset();
    notifyListeners();
  }

  int get _pomodoroDuration => _pomodoroMinutes * 60;
  int get _shortBreakDuration => _shortBreakMinutes * 60;
  int get _longBreakDuration => _longBreakMinutes * 60;

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
        _secondsRemaining = _pomodoroDuration;
        break;
      case SessionType.shortBreak:
        _secondsRemaining = _shortBreakDuration;
        break;
      case SessionType.longBreak:
        _secondsRemaining = _longBreakDuration;
        break;
    }
    notifyListeners();
  }

  void skip() {
    _timer?.cancel();
    _onSessionComplete();
  }

  void _onSessionComplete() {
    _playAlarm();
    // Placeholder: trigger notifikasi jika perlu
    // _showNotification();
    if (_sessionType == SessionType.pomodoro) {
      _pomodoroCount++;
      _cycle++;
      _updateStats();
      if (_cycle % 4 == 0) {
        _sessionType = SessionType.longBreak;
        _secondsRemaining = _longBreakDuration;
      } else {
        _sessionType = SessionType.shortBreak;
        _secondsRemaining = _shortBreakDuration;
      }
    } else {
      _sessionType = SessionType.pomodoro;
      _secondsRemaining = _pomodoroDuration;
    }
    _state = PomodoroState.stopped;
    notifyListeners();
  }

  Future<void> _playAlarm() async {
    try {
      await _audioPlayer.play(AssetSource('alarm.mp3'));
    } catch (e) {
      // ignore error
    }
  }

  Future<void> _loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    _todayPomodoro = prefs.getInt('todayPomodoro') ?? 0;
    _weekPomodoro = prefs.getInt('weekPomodoro') ?? 0;
    _totalPomodoro = prefs.getInt('totalPomodoro') ?? 0;
    final lastDateStr = prefs.getString('lastPomodoroDate');
    if (lastDateStr != null) {
      _lastPomodoroDate = DateTime.tryParse(lastDateStr);
    }
    _checkStatsReset();
    notifyListeners();
  }

  Future<void> _saveStats() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('todayPomodoro', _todayPomodoro);
    await prefs.setInt('weekPomodoro', _weekPomodoro);
    await prefs.setInt('totalPomodoro', _totalPomodoro);
    await prefs.setString('lastPomodoroDate', DateTime.now().toIso8601String());
  }

  void _checkStatsReset() {
    final now = DateTime.now();
    if (_lastPomodoroDate == null) return;
    // Reset harian
    if (_lastPomodoroDate!.day != now.day || _lastPomodoroDate!.month != now.month || _lastPomodoroDate!.year != now.year) {
      _todayPomodoro = 0;
    }
    // Reset mingguan (Senin)
    if (now.weekday == DateTime.monday && _lastPomodoroDate!.weekday != DateTime.monday) {
      _weekPomodoro = 0;
    }
  }

  void _updateStats() {
    final now = DateTime.now();
    if (_lastPomodoroDate == null || _lastPomodoroDate!.day != now.day || _lastPomodoroDate!.month != now.month || _lastPomodoroDate!.year != now.year) {
      _todayPomodoro = 0;
    }
    if (_lastPomodoroDate == null || (now.weekday == DateTime.monday && _lastPomodoroDate!.weekday != DateTime.monday)) {
      _weekPomodoro = 0;
    }
    _todayPomodoro++;
    _weekPomodoro++;
    _totalPomodoro++;
    _lastPomodoroDate = now;
    _saveStats();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}