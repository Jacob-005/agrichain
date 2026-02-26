import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Text(
            '🌾 Welcome, Farmer!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Icon(Icons.eco,
                      size: 48, color: AgriChainTheme.primaryGreen),
                  const SizedBox(height: 12),
                  const Text('Home Screen',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  const Text(
                    'Your harvest scores, weather, and quick actions will appear here.',
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
