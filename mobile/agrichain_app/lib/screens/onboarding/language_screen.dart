import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme.dart';

class LanguageScreen extends ConsumerWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              const Icon(Icons.translate, size: 64, color: AgriChainTheme.primaryGreen),
              const SizedBox(height: 24),
              const Text(
                'Choose Your Language',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
              ),
              const Text(
                'अपनी भाषा चुनें',
                style: TextStyle(fontSize: 20, color: AgriChainTheme.greyText),
              ),
              const SizedBox(height: 40),
              _LanguageTile(
                label: 'English',
                nativeLabel: 'English',
                onTap: () => context.go('/otp'),
              ),
              const SizedBox(height: 12),
              _LanguageTile(
                label: 'Hindi',
                nativeLabel: 'हिन्दी',
                onTap: () => context.go('/otp'),
              ),
              const SizedBox(height: 12),
              _LanguageTile(
                label: 'Marathi',
                nativeLabel: 'मराठी',
                onTap: () => context.go('/otp'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final String label;
  final String nativeLabel;
  final VoidCallback onTap;

  const _LanguageTile({required this.label, required this.nativeLabel, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 20),
        ),
        child: Text('$label  •  $nativeLabel', style: const TextStyle(fontSize: 18)),
      ),
    );
  }
}
