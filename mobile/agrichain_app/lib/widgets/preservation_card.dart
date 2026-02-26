import 'package:flutter/material.dart';
import '../app/theme.dart';

/// Card showing a preservation option.
class PreservationCard extends StatelessWidget {
  final String method;
  final String icon;
  final int extendsLifeHours;
  final double costPerKg;
  final String availability;
  final VoidCallback? onTap;

  const PreservationCard({
    super.key,
    required this.method,
    required this.icon,
    required this.extendsLifeHours,
    required this.costPerKg,
    required this.availability,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 36)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(method,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(
                      '+${extendsLifeHours}h shelf life • ₹$costPerKg/kg',
                      style: const TextStyle(
                          fontSize: 14, color: AgriChainTheme.greyText),
                    ),
                    const SizedBox(height: 2),
                    Text(availability,
                        style: const TextStyle(
                            fontSize: 14,
                            color: AgriChainTheme.primaryGreen,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios,
                  size: 16, color: AgriChainTheme.greyText),
            ],
          ),
        ),
      ),
    );
  }
}
