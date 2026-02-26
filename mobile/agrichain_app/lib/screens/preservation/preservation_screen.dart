import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../models/preservation_model.dart';
import '../../widgets/preservation_card.dart';

class PreservationScreen extends ConsumerStatefulWidget {
  const PreservationScreen({super.key});

  @override
  ConsumerState<PreservationScreen> createState() => _PreservationScreenState();
}

class _PreservationScreenState extends ConsumerState<PreservationScreen> {
  List<PreservationModel> _methods = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadMethods();
  }

  Future<void> _loadMethods() async {
    final api = ref.read(apiServiceProvider);
    final result = await api.getPreservationMethods('Tomato');

    if (result.success && result.data != null) {
      final list = List<Map<String, dynamic>>.from(
        result.data!['methods'] ?? [],
      );
      setState(() {
        _methods = list.map((m) => PreservationModel.fromJson(m)).toList();
        _methods.sort((a, b) => b.level.compareTo(a.level));
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AgriChainTheme.primaryGreen),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AgriChainTheme.primaryGreen.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AgriChainTheme.primaryGreen.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('💡', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Want to wait for a better price?\nHere\'s how to keep it fresh',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.volume_up_outlined,
                    size: 20,
                    color: AgriChainTheme.greyText,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Preservation cards ──
          ...List.generate(_methods.length, (i) {
            return PreservationCard(method: _methods[i])
                .animate()
                .fadeIn(
                  delay: Duration(milliseconds: 100 * i),
                  duration: 300.ms,
                )
                .slideY(begin: 0.05, end: 0);
          }),

          const SizedBox(height: 16),

          // ── Bottom note ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Text('🌱', style: TextStyle(fontSize: 18)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Even small steps save money. Start with what\'s free!',
                      style: TextStyle(
                        fontSize: 14,
                        color: AgriChainTheme.greyText,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
