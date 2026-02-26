import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme.dart';

class PersonalInfoScreen extends ConsumerWidget {
  const PersonalInfoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              const Icon(Icons.person_outline,
                  size: 48, color: AgriChainTheme.primaryGreen),
              const SizedBox(height: 24),
              const Text('Personal Information',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              const Text('Tell us about yourself',
                  style: TextStyle(fontSize: 16, color: AgriChainTheme.greyText)),
              const SizedBox(height: 32),
              const TextField(
                style: TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              const TextField(
                style: TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  labelText: 'Village',
                  prefixIcon: Icon(Icons.location_on),
                ),
              ),
              const SizedBox(height: 16),
              const TextField(
                style: TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  labelText: 'District',
                  prefixIcon: Icon(Icons.map),
                ),
              ),
              const SizedBox(height: 16),
              const TextField(
                style: TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  labelText: 'State',
                  prefixIcon: Icon(Icons.flag),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.go('/crop-selection'),
                  child: const Text('Continue', style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
