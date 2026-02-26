import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme.dart';

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.notifications,
                size: 80, color: AgriChainTheme.cautionYellow),
            const SizedBox(height: 16),
            const Text('Notification Screen',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            const Text('Price alerts, weather, and spoilage notifications.',
                style: TextStyle(fontSize: 16, color: AgriChainTheme.greyText)),
          ],
        ),
      ),
    );
  }
}
