import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final counterFeedbackProvider = Provider<CounterFeedback>((ref) {
  final service = CounterFeedback();
  ref.onDispose(service.dispose);
  return service;
});

class CounterFeedback {
  AudioPlayer? _player;
  Future<void> play({required bool sound, required bool vibration}) async {
    // Feedback failure must never affect persistence of the actual count.
    if (vibration) {
      try {
        await HapticFeedback.lightImpact();
      } catch (_) {}
    }
    if (sound) {
      try {
        final player = _player ??= AudioPlayer();
        await player.play(AssetSource('sounds/bead.wav'), volume: 0.4);
      } catch (_) {}
    }
  }

  void dispose() {
    final player = _player;
    if (player != null) unawaited(player.dispose());
  }
}

/// Counts only intervals between consecutive taps, capped by an inactivity gap.
class TapActivityClock {
  TapActivityClock({Duration Function()? elapsed, DateTime Function()? now})
    : _elapsed = elapsed ?? _timer(),
      _now = now ?? DateTime.now;
  final Duration Function() _elapsed;
  final DateTime Function() _now;
  Duration? _previous;
  DateTime? _previousDay;
  static Duration Function() _timer() {
    final timer = Stopwatch()..start();
    return () => timer.elapsed;
  }

  int tap() {
    final elapsed = _elapsed();
    final now = _now();
    final today = DateTime(now.year, now.month, now.day);
    final gap = _previous == null ? Duration.zero : elapsed - _previous!;
    final milliseconds =
        _previousDay == today &&
            gap > Duration.zero &&
            gap <= const Duration(seconds: 30)
        ? gap.inMilliseconds
        : 0;
    _previous = elapsed;
    _previousDay = today;
    return milliseconds;
  }

  void pause() {
    _previous = null;
    _previousDay = null;
  }
}
