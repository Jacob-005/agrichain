import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.account_circle,
                size: 80, color: AgriChainTheme.primaryGreen),
            const SizedBox(height: 16),
            const Text('Profile Screen',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            const Text('Your profile details will appear here.',
                style: TextStyle(fontSize: 16, color: AgriChainTheme.greyText)),
          ],
        ),
      ),
    );
  }
}
