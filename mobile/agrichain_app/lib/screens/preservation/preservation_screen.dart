import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../models/preservation_model.dart';
import '../../widgets/preservation_card.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/error_card.dart';

class PreservationScreen extends ConsumerStatefulWidget {
  const PreservationScreen({super.key});

  @override
  ConsumerState<PreservationScreen> createState() => _PreservationScreenState();
}

class _PreservationScreenState extends ConsumerState<PreservationScreen> {
  List<PreservationModel> _methods = [];
  bool _loading = true;
  String? _error;
  String? _explanationText;

  @override
  void initState() {
    super.initState();
    _loadMethods();
  }

  Future<void> _loadMethods() async {
    setState(() {
      _loading = true;
      _error = null;
      _explanationText = null;
    });
    final api = ref.read(apiServiceProvider);
    final result = await api.getPreservationMethods('Tomato');

    if (result.success && result.data != null) {
      final raw = result.data!;
      final payload = raw.containsKey('data') && raw['data'] is Map
          ? raw['data'] as Map<String, dynamic>
          : raw;

      final explText = payload['explanation_text'] as String?;
      final list = List<Map<String, dynamic>>.from(payload['methods'] ?? []);
      if (list.isNotEmpty) {
        setState(() {
          _methods = list.map((m) => PreservationModel.fromJson(m)).toList();
          _methods.sort((a, b) => b.level.compareTo(a.level));
          _explanationText = explText;
          _loading = false;
        });
      } else if (explText != null && explText.isNotEmpty) {
        setState(() {
          _methods = [];
          _explanationText = explText;
          _loading = false;
        });
      } else {
        setState(() {
          _error = 'No preservation data available';
          _loading = false;
        });
      }
    } else {
      setState(() {
        _error = result.error ?? 'Unknown error';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const LoadingIndicator(
        message: 'Finding best preservation methods...',
        emoji: '❄️',
      );
    }

    if (_error != null) {
      return ErrorCard(
        message: ErrorCard.friendlyMessage(_error!),
        onRetry: _loadMethods,
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

          // ── AI Explanation (from real API) ──
          if (_explanationText != null && _explanationText!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AgriChainTheme.primaryGreen.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AgriChainTheme.primaryGreen.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Text('🤖', style: TextStyle(fontSize: 20)),
                        SizedBox(width: 8),
                        Text(
                          'AI Preservation Analysis',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _explanationText!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AgriChainTheme.darkText,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

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
