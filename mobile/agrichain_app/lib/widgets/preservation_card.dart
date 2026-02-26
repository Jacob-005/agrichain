import 'package:flutter/material.dart';
import '../app/theme.dart';
import '../models/preservation_model.dart';

/// Card displaying a preservation method with ROI and expandable instructions.
class PreservationCard extends StatefulWidget {
  final PreservationModel method;

  const PreservationCard({super.key, required this.method});

  @override
  State<PreservationCard> createState() => _PreservationCardState();
}

class _PreservationCardState extends State<PreservationCard> {
  bool _expanded = false;

  PreservationModel get m => widget.method;

  @override
  Widget build(BuildContext context) {
    final isBest = m.level == 3;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isBest ? AgriChainTheme.primaryGreen : Colors.grey.shade300,
          width: isBest ? 2 : 1,
        ),
        color: Colors.white,
        boxShadow: isBest
            ? [
                BoxShadow(
                  color: AgriChainTheme.primaryGreen.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Level badge + title ──
                Row(
                  children: [
                    Text(m.stars, style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Text(m.icon, style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        m.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // ── Cost ──
                Row(
                  children: [
                    const Icon(
                      Icons.attach_money,
                      size: 18,
                      color: AgriChainTheme.greyText,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      m.costRupees == 0
                          ? 'Cost: FREE 🎉'
                          : 'Cost: ₹${m.costRupees.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: m.costRupees == 0
                            ? AgriChainTheme.primaryGreen
                            : AgriChainTheme.darkText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // ── Extra days ──
                Row(
                  children: [
                    const Icon(
                      Icons.schedule,
                      size: 18,
                      color: AgriChainTheme.greyText,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Saves: ${m.extraDays} extra days',
                      style: const TextStyle(fontSize: 15),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // ── Prevents loss ──
                Row(
                  children: [
                    const Icon(
                      Icons.savings,
                      size: 18,
                      color: AgriChainTheme.primaryGreen,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Prevents: ₹${m.savesRupees.toStringAsFixed(0)} rot loss',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AgriChainTheme.primaryGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // ── ROI chip ──
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: m.costRupees == 0
                        ? AgriChainTheme.primaryGreen.withValues(alpha: 0.12)
                        : AgriChainTheme.cautionYellow.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '💰 ${m.roiText}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: m.costRupees == 0
                          ? AgriChainTheme.primaryGreen
                          : const Color(0xFF8D6E0F),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // ── How to do this ──
                GestureDetector(
                  onTap: () => setState(() => _expanded = !_expanded),
                  child: Row(
                    children: [
                      Icon(
                        _expanded ? Icons.expand_less : Icons.expand_more,
                        size: 20,
                        color: AgriChainTheme.primaryGreen,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _expanded ? 'Hide steps' : 'How to do this ▼',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AgriChainTheme.primaryGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.volume_up_outlined,
                        size: 18,
                        color: AgriChainTheme.greyText,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Expanded instructions ──
          if (_expanded)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  m.instructions,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AgriChainTheme.darkText,
                    height: 1.5,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
