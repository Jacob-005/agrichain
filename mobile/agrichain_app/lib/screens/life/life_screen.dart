import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme.dart';

class LifeScreen extends ConsumerWidget {
  const LifeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Text(
            '⏱ Shelf Life Tracker',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Icon(Icons.timer,
                      size: 48, color: AgriChainTheme.cautionYellow),
                  const SizedBox(height: 12),
                  const Text('Life Screen',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  const Text(
                    'Track spoilage, check remaining shelf life, and get alerts.',
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
