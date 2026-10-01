import 'dart:async';
import 'package:flutter/material.dart';
import '../srs/scheduler.dart';

enum TimerMode { free, pomodoro, manual }
enum PomodoroPhase { work, shortBreak, longBreak }

class TimerService extends ChangeNotifier with WidgetsBindingObserver {
  Timer? _ticker;
  TimerMode _mode = TimerMode.free;
  
  bool _isRunning = false;
  bool _isPaused = false;

  int _netSeconds = 0;
  int _pauseSeconds = 0;
  int _distractionCount = 0;
  DateTime? _startedAt;
  DateTime? _pausedAt;
  DateTime? _appPausedTime;

  int _selectedSubjectId = 1;
  String _intention = '';

  // Pomodoro sozlamalari (daqiqa)
  int workDurationMin = 25;
  int shortBreakMin = 5;
  int longBreakMin = 15;
  int cyclesBeforeLongBreak = 4;
  int _completedCycles = 0;
  PomodoroPhase _pomodoroPhase = PomodoroPhase.work;
  int _phaseSecondsRemaining = 25 * 60;

  // Getters
  bool get isRunning => _isRunning;
  bool get isPaused => _isPaused;
  TimerMode get mode => _mode;
  int get netSeconds => _netSeconds;
  int get pauseSeconds => _pauseSeconds;
  int get distractionCount => _distractionCount;
  int get selectedSubjectId => _selectedSubjectId;
  String get intention => _intention;
  PomodoroPhase get pomodoroPhase => _pomodoroPhase;
  int get completedCycles => _completedCycles;
  int get phaseSecondsRemaining => _phaseSecondsRemaining;
  bool get isForgottenTimer => _netSeconds >= 14400; // 4 soatdan oshsa

  TimerService() {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker?.cancel();
    super.dispose();
  }

  void setSubjectId(int id) {
    _selectedSubjectId = id;
    notifyListeners();
  }

  void setMode(TimerMode m) {
    if (_isRunning) return;
    _mode = m;
    if (m == TimerMode.pomodoro) {
      _phaseSecondsRemaining = workDurationMin * 60;
      _pomodoroPhase = PomodoroPhase.work;
    }
    notifyListeners();
  }

  void start({String intention = ''}) {
    if (_isRunning) return;
    _isRunning = true;
    _isPaused = false;
    _netSeconds = 0;
    _pauseSeconds = 0;
    _distractionCount = 0;
    _startedAt = DateTime.now();
    _intention = intention;

    if (_mode == TimerMode.pomodoro) {
      _pomodoroPhase = PomodoroPhase.work;
      _phaseSecondsRemaining = workDurationMin * 60;
    }

    _startTicker();
    notifyListeners();
  }

  void pause() {
    if (!_isRunning || _isPaused) return;
    _isPaused = true;
    _pausedAt = DateTime.now();
    _ticker?.cancel();
    notifyListeners();
  }

  void resume() {
    if (!_isRunning || !_isPaused) return;
    if (_pausedAt != null) {
      final pausedDiff = DateTime.now().difference(_pausedAt!).inSeconds;
      _pauseSeconds += pausedDiff;
      _pausedAt = null;
    }
    _isPaused = false;
    _startTicker();
    notifyListeners();
  }

  void recordManualDistraction() {
    if (!_isRunning) return;
    _distractionCount++;
    notifyListeners();
  }

  void adjustNetSeconds(int deltaSeconds) {
    _netSeconds = (_netSeconds + deltaSeconds).clamp(0, 86400);
    notifyListeners();
  }

  void setNetSecondsDirectly(int seconds) {
    _netSeconds = seconds.clamp(0, 86400);
    notifyListeners();
  }

  Map<String, dynamic> stopAndGetSessionData() {
    _ticker?.cancel();
    _isRunning = false;
    _isPaused = false;

    final endAt = DateTime.now().millisecondsSinceEpoch;
    final startAt = _startedAt?.millisecondsSinceEpoch ?? (endAt - (_netSeconds * 1000));
    final dayKey = SrsScheduler.getDayKey(DateTime.fromMillisecondsSinceEpoch(endAt));

    final data = {
      'subject_id': _selectedSubjectId,
      'start_at': startAt,
      'end_at': endAt,
      'net_seconds': _netSeconds,
      'pause_seconds': _pauseSeconds,
      'distraction_count': _distractionCount,
      'mode': _mode.name,
      'day_key': dayKey,
      'intention': _intention.isNotEmpty ? _intention : null,
      'confirmed': isForgottenTimer ? 0 : 1,
    };

    _netSeconds = 0;
    _pauseSeconds = 0;
    _distractionCount = 0;
    _intention = '';
    notifyListeners();
    return data;
  }

  void cancel() {
    _ticker?.cancel();
    _isRunning = false;
    _isPaused = false;
    _netSeconds = 0;
    _pauseSeconds = 0;
    _distractionCount = 0;
    _intention = '';
    notifyListeners();
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused && _isRunning) {
        _netSeconds++;

        if (_mode == TimerMode.pomodoro) {
          if (_phaseSecondsRemaining > 0) {
            _phaseSecondsRemaining--;
          } else {
            _handlePomodoroPhaseTransition();
          }
        }
        notifyListeners();
      }
    });
  }

  void _handlePomodoroPhaseTransition() {
    if (_pomodoroPhase == PomodoroPhase.work) {
      _completedCycles++;
      if (_completedCycles % cyclesBeforeLongBreak == 0) {
        _pomodoroPhase = PomodoroPhase.longBreak;
        _phaseSecondsRemaining = longBreakMin * 60;
      } else {
        _pomodoroPhase = PomodoroPhase.shortBreak;
        _phaseSecondsRemaining = shortBreakMin * 60;
      }
    } else {
      _pomodoroPhase = PomodoroPhase.work;
      _phaseSecondsRemaining = workDurationMin * 60;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_isRunning) return;

    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _appPausedTime = DateTime.now();
    } else if (state == AppLifecycleState.resumed && _appPausedTime != null) {
      final elapsed = DateTime.now().difference(_appPausedTime!).inSeconds;
      if (elapsed > 2) {
        // 5.2 Chalg'ish sanagichi: boshqa ilovaga o'tib qaytilsa
        _distractionCount++;
        _pauseSeconds += elapsed;
      }
      _appPausedTime = null;
      notifyListeners();
    }
  }
}
