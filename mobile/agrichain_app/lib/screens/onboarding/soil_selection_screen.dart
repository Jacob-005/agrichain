import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme.dart';

class SoilSelectionScreen extends ConsumerStatefulWidget {
  const SoilSelectionScreen({super.key});

  @override
  ConsumerState<SoilSelectionScreen> createState() => _SoilSelectionScreenState();
}

class _SoilSelectionScreenState extends ConsumerState<SoilSelectionScreen> {
  String? _selected;

  final List<Map<String, String>> _soilTypes = const [
    {'id': 'alluvial', 'name': 'Alluvial', 'icon': '🏞️'},
    {'id': 'black', 'name': 'Black Soil', 'icon': '⬛'},
    {'id': 'red', 'name': 'Red Soil', 'icon': '🟫'},
    {'id': 'laterite', 'name': 'Laterite', 'icon': '🧱'},
    {'id': 'sandy', 'name': 'Sandy', 'icon': '🏖️'},
    {'id': 'clayey', 'name': 'Clayey', 'icon': '🪨'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              const Text('Select Soil Type',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              const Text('What soil does your farm have?',
                  style: TextStyle(fontSize: 16, color: AgriChainTheme.greyText)),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.separated(
                  itemCount: _soilTypes.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final soil = _soilTypes[i];
                    final isSelected = _selected == soil['id'];
                    return ListTile(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      tileColor: isSelected
                          ? AgriChainTheme.primaryGreen.withValues(alpha: 0.1)
                          : Colors.white,
                      leading: Text(soil['icon']!,
                          style: const TextStyle(fontSize: 28)),
                      title: Text(soil['name']!,
                          style: const TextStyle(fontSize: 18)),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle,
                              color: AgriChainTheme.primaryGreen)
                          : const Icon(Icons.circle_outlined,
                              color: AgriChainTheme.greyText),
                      onTap: () => setState(() => _selected = soil['id']),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selected == null
                      ? null
                      : () => context.go('/home'),
                  child: const Text('Finish Setup',
                      style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
