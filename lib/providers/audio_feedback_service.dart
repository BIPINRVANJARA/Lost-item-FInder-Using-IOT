import 'dart:async';
import 'package:flutter/services.dart';

class AudioFeedbackService {
  static Timer? _beeperTimer;
  static bool _isPlaying = false;

  static bool get isPlaying => _isPlaying;

  /// Starts repeating finding acoustic beeps and haptic pulses
  /// As distance decreases, interval gets faster and frequency pitch increases
  static void startFindingAlarm({
    required double distanceMeters,
    required VoidCallback onBeep,
  }) {
    stopFindingAlarm();
    _isPlaying = true;

    // Calculate dynamic interval based on proximity
    // 15m => 1200ms, 5m => 600ms, 1m => 200ms, 0.3m => 100ms
    int intervalMs = (distanceMeters * 100).clamp(120, 1400).toInt();

    _beeperTimer = Timer.periodic(Duration(milliseconds: intervalMs), (timer) {
      if (!_isPlaying) {
        timer.cancel();
        return;
      }

      // Trigger haptic vibration on devices
      try {
        HapticFeedback.mediumImpact();
      } catch (_) {}

      // Play beep sound callback for visual / audio representation
      onBeep();
    });
  }

  static void updateProximityInterval(double distanceMeters, VoidCallback onBeep) {
    if (_isPlaying) {
      startFindingAlarm(distanceMeters: distanceMeters, onBeep: onBeep);
    }
  }

  static void stopFindingAlarm() {
    _isPlaying = false;
    _beeperTimer?.cancel();
    _beeperTimer = null;
  }

  static void triggerHapticSuccess() {
    try {
      HapticFeedback.heavyImpact();
    } catch (_) {}
  }

  static void triggerHapticClick() {
    try {
      HapticFeedback.lightImpact();
    } catch (_) {}
  }
}
