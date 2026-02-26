import 'package:flutter/material.dart';
import '../app/theme.dart';

/// Circular score indicator widget.
class ScoreCircle extends StatelessWidget {
  final int score;
  final String label;
  final double size;

  const ScoreCircle({
    super.key,
    required this.score,
    required this.label,
    this.size = 100,
  });

  Color get _color {
    if (score >= 70) return AgriChainTheme.primaryGreen;
    if (score >= 40) return AgriChainTheme.cautionYellow;
    return AgriChainTheme.dangerRed;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: score / 100,
                strokeWidth: 8,
                backgroundColor: Colors.grey.shade200,
                color: _color,
              ),
              Text(
                '$score',
                style: TextStyle(
                  fontSize: size * 0.3,
                  fontWeight: FontWeight.w700,
                  color: _color,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AgriChainTheme.greyText,
          ),
        ),
      ],
    );
  }
}
