import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme.dart';

class AdviceHistoryScreen extends ConsumerWidget {
  const AdviceHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Advice History')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.history,
                size: 80, color: AgriChainTheme.primaryGreen),
            const SizedBox(height: 16),
            const Text('Advice History Screen',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            const Text('Past recommendations and their outcomes.',
                style: TextStyle(fontSize: 16, color: AgriChainTheme.greyText)),
          ],
        ),
      ),
    );
  }
}
