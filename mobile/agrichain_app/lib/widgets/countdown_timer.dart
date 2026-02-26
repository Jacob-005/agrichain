import 'dart:async';
import 'package:flutter/material.dart';
import '../app/theme.dart';

/// Countdown timer widget for spoilage tracking.
class CountdownTimer extends StatefulWidget {
  final Duration duration;
  final VoidCallback? onComplete;

  const CountdownTimer({
    super.key,
    required this.duration,
    this.onComplete,
  });

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  late Duration _remaining;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remaining = widget.duration;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remaining.inSeconds <= 0) {
        timer.cancel();
        widget.onComplete?.call();
        return;
      }
      setState(() {
        _remaining = _remaining - const Duration(seconds: 1);
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Color get _color {
    final totalSeconds = widget.duration.inSeconds;
    final remainingSeconds = _remaining.inSeconds;
    final ratio = remainingSeconds / totalSeconds;
    if (ratio > 0.5) return AgriChainTheme.primaryGreen;
    if (ratio > 0.2) return AgriChainTheme.cautionYellow;
    return AgriChainTheme.dangerRed;
  }

  String get _formatted {
    final h = _remaining.inHours;
    final m = _remaining.inMinutes.remainder(60);
    final s = _remaining.inSeconds.remainder(60);
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _color, width: 2),
      ),
      child: Text(
        _formatted,
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: _color,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}
