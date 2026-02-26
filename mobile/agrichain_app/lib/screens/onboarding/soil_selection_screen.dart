import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../app/providers.dart';
import '../../app/theme.dart';

class SoilSelectionScreen extends ConsumerStatefulWidget {
  const SoilSelectionScreen({super.key});

  @override
  ConsumerState<SoilSelectionScreen> createState() =>
      _SoilSelectionScreenState();
}

class _SoilSelectionScreenState extends ConsumerState<SoilSelectionScreen> {
  String? _selectedId;
  List<Map<String, dynamic>> _soilTypes = [];
  bool _loading = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadSoilTypes();
  }

  Future<void> _loadSoilTypes() async {
    final api = ref.read(apiServiceProvider);
    final result = await api.getSoilTypes();

    if (result.success && result.data != null) {
      setState(() {
        _soilTypes =
            List<Map<String, dynamic>>.from(result.data!['soil_types']);
        _loading = false;
      });
    }
  }

  Color _hexToColor(String hex) {
    hex = hex.replaceFirst('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }

  Future<void> _finishOnboarding() async {
    setState(() => _submitting = true);

    final storage = ref.read(storageServiceProvider);
    await storage.saveOnboardingComplete(true);

    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
            child: CircularProgressIndicator(
                color: AgriChainTheme.primaryGreen)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new,
                        color: AgriChainTheme.darkText),
                    onPressed: () => context.go('/crop-selection'),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'What\'s Your Soil Type?',
                    style:
                        TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'आपकी मिट्टी कैसी है?',
                    style: TextStyle(
                        fontSize: 18, color: AgriChainTheme.greyText),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Soil cards grid ──
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.72,
                ),
                itemCount: _soilTypes.length,
                itemBuilder: (context, i) {
                  final soil = _soilTypes[i];
                  final id = soil['id'] as String;
                  final isSelected = _selectedId == id;
                  final soilColor =
                      _hexToColor(soil['color_hex'] ?? '#795548');
                  final suitableCrops =
                      List<String>.from(soil['suitable_crops'] ?? []);

                  return GestureDetector(
                    onTap: () => setState(() => _selectedId = id),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AgriChainTheme.primaryGreen
                                .withValues(alpha: 0.06)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isSelected
                              ? AgriChainTheme.primaryGreen
                              : Colors.grey.shade300,
                          width: isSelected ? 2.5 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AgriChainTheme.primaryGreen
                                      .withValues(alpha: 0.15),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                )
                              ]
                            : null,
                      ),
                      child: Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                // Soil color circle
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: soilColor,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color:
                                          soilColor.withValues(alpha: 0.3),
                                      width: 3,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                // Name (Hindi + English)
                                Text(
                                  soil['name_hi'] ?? '',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    color: isSelected
                                        ? AgriChainTheme.primaryGreen
                                        : AgriChainTheme.darkText,
                                  ),
                                ),
                                Text(
                                  soil['name'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AgriChainTheme.greyText,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                // Description
                                Text(
                                  soil['description'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AgriChainTheme.greyText,
                                    height: 1.3,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const Spacer(),
                                // Suitable crops
                                Wrap(
                                  spacing: 4,
                                  children: suitableCrops
                                      .take(3)
                                      .map((c) => Container(
                                            padding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                    vertical: 2),
                                            decoration: BoxDecoration(
                                              color: AgriChainTheme
                                                  .primaryGreen
                                                  .withValues(
                                                      alpha: 0.08),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              c,
                                              style: const TextStyle(
                                                fontSize: 10,
                                                color: AgriChainTheme
                                                    .primaryGreen,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ))
                                      .toList(),
                                ),
                              ],
                            ),
                          ),
                          // Checkmark
                          if (isSelected)
                            const Positioned(
                              top: 10,
                              right: 10,
                              child: Icon(
                                Icons.check_circle,
                                color: AgriChainTheme.primaryGreen,
                                size: 24,
                              ),
                            ),
                        ],
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(
                        delay: Duration(milliseconds: 80 * i),
                        duration: 300.ms,
                      )
                      .slideY(
                        begin: 0.1,
                        end: 0,
                        delay: Duration(milliseconds: 80 * i),
                        duration: 300.ms,
                        curve: Curves.easeOut,
                      );
                },
              ),
            ),

            // ── Sticky bottom button ──
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, -2)),
                ],
              ),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed:
                        (_selectedId == null || _submitting) ? null : _finishOnboarding,
                    icon: _submitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.rocket_launch, size: 22),
                    label: const Text('Start AgriChain →',
                        style: TextStyle(fontSize: 18)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
