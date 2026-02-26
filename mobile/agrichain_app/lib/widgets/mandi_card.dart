import 'package:flutter/material.dart';
import '../app/theme.dart';

/// Card widget to display a mandi option in market comparison.
class MandiCard extends StatelessWidget {
  final String name;
  final int distanceKm;
  final double pricePerKg;
  final double netProfit;
  final String demand;
  final bool isBest;
  final VoidCallback? onTap;

  const MandiCard({
    super.key,
    required this.name,
    required this.distanceKm,
    required this.pricePerKg,
    required this.netProfit,
    this.demand = 'low',
    this.isBest = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isBest ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isBest
            ? const BorderSide(color: AgriChainTheme.primaryGreen, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(name,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600)),
                  if (isBest)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AgriChainTheme.primaryGreen,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('BEST',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text('📍 $distanceKm km away',
                  style: const TextStyle(
                      fontSize: 14, color: AgriChainTheme.greyText)),
              const SizedBox(height: 4),
              Text('₹${pricePerKg.toStringAsFixed(1)}/kg',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Text('Net Profit: ₹${netProfit.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: netProfit > 0
                        ? AgriChainTheme.primaryGreen
                        : AgriChainTheme.dangerRed,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
