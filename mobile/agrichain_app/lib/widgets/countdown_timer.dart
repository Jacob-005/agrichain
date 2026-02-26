import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../app/theme.dart';

/// Prominent countdown timer widget with progress bar and alert state.
class CountdownTimer extends StatefulWidget {
  final double remainingHours;
  final double initialHours;
  final String crop;
  final String storageMethod;
  final double temperature;
  final bool isAlert;

  const CountdownTimer({
    super.key,
    required this.remainingHours,
    required this.initialHours,
    required this.crop,
    this.storageMethod = 'Open Floor',
    this.temperature = 32,
    this.isAlert = false,
  });

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  late double _currentHours;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _currentHours = widget.remainingHours;
    _startTimer();
  }

  @override
  void didUpdateWidget(covariant CountdownTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.remainingHours != widget.remainingHours) {
      _currentHours = widget.remainingHours;
    }
  }

  void _startTimer() {
    // Update every 30 seconds for demo effect (subtracts ~1 min each tick)
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted && _currentHours > 0) {
        setState(() {
          _currentHours = (_currentHours - 0.017).clamp(
            0.0,
            widget.initialHours,
          );
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Color get _timerColor {
    if (widget.isAlert || _currentHours < 12) return AgriChainTheme.dangerRed;
    if (_currentHours < 48) return AgriChainTheme.cautionYellow;
    return AgriChainTheme.primaryGreen;
  }

  String get _timeDisplay {
    final h = _currentHours.floor();
    final m = ((_currentHours - h) * 60).round();
    return '${h}h ${m.toString().padLeft(2, '0')}m';
  }

  double get _fraction => (_currentHours / widget.initialHours).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    Widget timerWidget = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _timerColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: widget.isAlert ? AgriChainTheme.dangerRed : _timerColor,
          width: widget.isAlert ? 3 : 1.5,
        ),
      ),
      child: Column(
        children: [
          // Time display
          Text(
            _timeDisplay,
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w800,
              color: _timerColor,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'remaining before spoilage',
            style: TextStyle(
              fontSize: 14,
              color: _timerColor.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 16),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: _fraction,
              minHeight: 12,
              backgroundColor: Colors.grey.shade200,
              color: _timerColor,
            ),
          ),
          const SizedBox(height: 12),

          // Info row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _InfoChip(icon: '🌾', label: widget.crop),
              _InfoChip(icon: '📦', label: widget.storageMethod),
              _InfoChip(
                icon: '🌡',
                label: '${widget.temperature.toStringAsFixed(0)}°C',
              ),
            ],
          ),
        ],
      ),
    );

    // Add pulsing animation if alert
    if (widget.isAlert) {
      timerWidget = timerWidget
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .shimmer(
            duration: 1200.ms,
            color: AgriChainTheme.dangerRed.withValues(alpha: 0.15),
          );
    }

    return timerWidget;
  }
}

class _InfoChip extends StatelessWidget {
  final String icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(icon, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: AgriChainTheme.greyText),
        ),
      ],
    );
  }
}
