import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme.dart';

class PreservationScreen extends ConsumerWidget {
  const PreservationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Text(
            '❄ Preservation Options',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Icon(Icons.ac_unit,
                      size: 48, color: Color(0xFF1565C0)),
                  const SizedBox(height: 12),
                  const Text('Preservation Screen',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  const Text(
                    'Find cold storage, drying, and preservation methods near you.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 16, color: AgriChainTheme.greyText),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
