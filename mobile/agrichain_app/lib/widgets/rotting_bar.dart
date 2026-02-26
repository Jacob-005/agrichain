import 'package:flutter/material.dart';
import '../app/theme.dart';

/// A progress bar showing spoilage/rotting progress.
class RottingBar extends StatelessWidget {
  final double percentage;
  final String label;

  const RottingBar({
    super.key,
    required this.percentage,
    this.label = 'Spoilage',
  });

  Color get _color {
    if (percentage < 30) return AgriChainTheme.primaryGreen;
    if (percentage < 60) return AgriChainTheme.cautionYellow;
    return AgriChainTheme.dangerRed;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 14, color: AgriChainTheme.greyText)),
            Text('${percentage.toStringAsFixed(1)}%',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _color)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: percentage / 100,
            minHeight: 12,
            backgroundColor: Colors.grey.shade200,
            color: _color,
          ),
        ),
      ],
    );
  }
}
