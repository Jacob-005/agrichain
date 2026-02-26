import 'package:flutter/material.dart';
import '../app/theme.dart';

/// A color-coded progress bar showing spoilage/rotting progress.
class RottingBar extends StatelessWidget {
  final double fraction; // 0.0 – 1.0
  final String label;

  const RottingBar({
    super.key,
    required this.fraction,
    this.label = 'Spoilage Risk',
  });

  Color get _color {
    if (fraction < 0.3) return AgriChainTheme.primaryGreen;
    if (fraction < 0.6) return AgriChainTheme.cautionYellow;
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
                    fontSize: 12, color: AgriChainTheme.greyText)),
            Text('${(fraction * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _color)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: fraction.clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: Colors.grey.shade200,
            color: _color,
          ),
        ),
      ],
    );
  }
}
