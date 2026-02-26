import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme.dart';

class CropSelectionScreen extends ConsumerStatefulWidget {
  const CropSelectionScreen({super.key});

  @override
  ConsumerState<CropSelectionScreen> createState() => _CropSelectionScreenState();
}

class _CropSelectionScreenState extends ConsumerState<CropSelectionScreen> {
  final Set<String> _selected = {};

  final List<Map<String, String>> _crops = const [
    {'id': 'wheat', 'name': 'Wheat', 'icon': '🌾'},
    {'id': 'rice', 'name': 'Rice', 'icon': '🍚'},
    {'id': 'tomato', 'name': 'Tomato', 'icon': '🍅'},
    {'id': 'onion', 'name': 'Onion', 'icon': '🧅'},
    {'id': 'potato', 'name': 'Potato', 'icon': '🥔'},
    {'id': 'cotton', 'name': 'Cotton', 'icon': '🏵️'},
    {'id': 'sugarcane', 'name': 'Sugarcane', 'icon': '🎋'},
    {'id': 'soybean', 'name': 'Soybean', 'icon': '🫘'},
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
              const Text('Select Your Crops',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              const Text('Choose the crops you grow',
                  style: TextStyle(fontSize: 16, color: AgriChainTheme.greyText)),
              const SizedBox(height: 24),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.4,
                  ),
                  itemCount: _crops.length,
                  itemBuilder: (context, i) {
                    final crop = _crops[i];
                    final isSelected = _selected.contains(crop['id']);
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selected.remove(crop['id']);
                          } else {
                            _selected.add(crop['id']!);
                          }
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AgriChainTheme.primaryGreen.withValues(alpha: 0.1)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? AgriChainTheme.primaryGreen
                                : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(crop['icon']!,
                                style: const TextStyle(fontSize: 32)),
                            const SizedBox(height: 8),
                            Text(crop['name']!,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight:
                                      isSelected ? FontWeight.w600 : FontWeight.w400,
                                  color: isSelected
                                      ? AgriChainTheme.primaryGreen
                                      : AgriChainTheme.darkText,
                                )),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selected.isEmpty
                      ? null
                      : () => context.go('/soil-selection'),
                  child: Text(
                    'Continue (${_selected.length} selected)',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
