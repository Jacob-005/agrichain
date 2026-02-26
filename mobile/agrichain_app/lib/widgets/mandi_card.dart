import 'package:flutter/material.dart';
import '../app/theme.dart';
import '../models/mandi_result_model.dart';
import 'rotting_bar.dart';

/// Card widget to display a ranked mandi in market comparison.
class MandiCard extends StatefulWidget {
  final MandiResultModel mandi;

  const MandiCard({super.key, required this.mandi});

  @override
  State<MandiCard> createState() => _MandiCardState();
}

class _MandiCardState extends State<MandiCard> {
  bool _expanded = false;

  MandiResultModel get m => widget.mandi;

  @override
  Widget build(BuildContext context) {
    final isTop = m.rank == 1;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isTop ? AgriChainTheme.primaryGreen : Colors.grey.shade300,
          width: isTop ? 2 : 1,
        ),
        color: Colors.white,
        boxShadow: isTop
            ? [
                BoxShadow(
                  color: AgriChainTheme.primaryGreen.withValues(alpha: 0.12),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
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
                // ── Top row: rank + name + distance ──
                Row(
                  children: [
                    Text(m.rankEmoji, style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        m.name,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${m.distanceKm.toStringAsFixed(0)} km',
                        style: const TextStyle(
                            fontSize: 13, color: AgriChainTheme.greyText),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // ── Price row ──
                Text(
                  '₹${m.pricePerKg.toStringAsFixed(0)}/kg',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),

                // ── Cost details ──
                Text(
                  'Fuel: ₹${m.fuelCost.toStringAsFixed(0)}  •  Spoilage: ₹${m.spoilageLoss.toStringAsFixed(0)}',
                  style: const TextStyle(
                      fontSize: 13, color: AgriChainTheme.greyText),
                ),
                const SizedBox(height: 12),

                // ── POCKET CASH (hero number) ──
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isTop
                        ? AgriChainTheme.primaryGreen.withValues(alpha: 0.08)
                        : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Text('💰', style: TextStyle(fontSize: 22)),
                      const SizedBox(width: 8),
                      const Text('Pocket Cash: ',
                          style: TextStyle(fontSize: 15)),
                      Text(
                        '₹${m.pocketCash.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: isTop
                              ? AgriChainTheme.primaryGreen
                              : AgriChainTheme.darkText,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // ── Rotting bar ──
                RottingBar(fraction: m.rottingBarFraction),

                const SizedBox(height: 8),

                // ── Why? button ──
                if (m.explanation.isNotEmpty)
                  GestureDetector(
                    onTap: () => setState(() => _expanded = !_expanded),
                    child: Row(
                      children: [
                        Icon(
                          _expanded
                              ? Icons.expand_less
                              : Icons.expand_more,
                          size: 20,
                          color: AgriChainTheme.primaryGreen,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _expanded ? 'Hide details' : 'Why this rank?',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AgriChainTheme.primaryGreen,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // ── Expanded explanation ──
          if (_expanded && m.explanation.isNotEmpty)
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
                  m.explanation,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AgriChainTheme.darkText,
                    height: 1.4,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
