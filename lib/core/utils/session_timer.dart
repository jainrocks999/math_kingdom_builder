import 'dart:async';
import 'package:flutter/foundation.dart';

class SessionTimer {
  final int maxMinutes; // Set by parent (5/10/15/20)
  final VoidCallback onBreakSuggested;
  Timer? _timer;
  int _elapsedSeconds = 0;

  SessionTimer({
    this.maxMinutes = 10,
    required this.onBreakSuggested,
  });

  void start() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      _elapsedSeconds++;
      if (_elapsedSeconds >= maxMinutes * 60) {
        onBreakSuggested();
        _timer?.cancel();
      }
    });
  }

  void reset() {
    _timer?.cancel();
    _elapsedSeconds = 0;
  }

  void pause() => _timer?.cancel();
  void resume() => start();
}