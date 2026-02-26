import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../models/spoilage_model.dart';
import '../../widgets/countdown_timer.dart';

enum _LifeState { preHarvest, selectStorage, activeTimer }

class LifeScreen extends ConsumerStatefulWidget {
  const LifeScreen({super.key});

  @override
  ConsumerState<LifeScreen> createState() => _LifeScreenState();
}

class _LifeScreenState extends ConsumerState<LifeScreen> {
  _LifeState _state = _LifeState.preHarvest;
  String? _selectedStorage;
  SpoilageModel? _spoilageData;
  bool _isAlert = false;

  final _storageMethods = const [
    {'id': 'open_floor', 'icon': '🏠', 'label': 'Open Floor'},
    {'id': 'jute_bags', 'icon': '👜', 'label': 'Jute Bags'},
    {'id': 'plastic_crates', 'icon': '📦', 'label': 'Plastic Crates'},
    {'id': 'cold_storage', 'icon': '❄️', 'label': 'Cold Storage'},
  ];

  Future<void> _loadSpoilageData() async {
    final api = ref.read(apiServiceProvider);
    final result = await api.getSpoilageEstimate(
      'Tomato',
      _selectedStorage ?? 'open_floor',
    );

    if (result.success && result.data != null) {
      setState(() {
        _spoilageData = SpoilageModel.fromJson(result.data!);
        _state = _LifeState.activeTimer;
      });
    }
  }

  void _triggerAlert() {
    setState(() {
      _isAlert = true;
      if (_spoilageData != null) {
        _spoilageData = SpoilageModel(
          crop: _spoilageData!.crop,
          remainingHours: _spoilageData!.remainingHours * 0.5,
          initialHours: _spoilageData!.initialHours,
          riskLevel: 'high',
          hasWeatherAlert: true,
          alertMessage:
              'Temperature rising to 42°C in next 6 hours. Spoilage risk increased by 30%.',
          explanation: _spoilageData!.explanation,
          storageMethod: _spoilageData!.storageMethod,
          temperature: 42,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_state == _LifeState.preHarvest) _buildPreHarvest(),
          if (_state == _LifeState.selectStorage) _buildStorageSelection(),
          if (_state == _LifeState.activeTimer) _buildActiveTimer(),
        ],
      ),
    );
  }

  // ─── STATE 1: Pre-Harvest ──────────────────────────────────────────────
  Widget _buildPreHarvest() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AgriChainTheme.primaryGreen.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('🌾', style: TextStyle(fontSize: 56)),
              ),
            ).animate().scale(duration: 600.ms, curve: Curves.easeOut).fadeIn(),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 80,
              child: ElevatedButton(
                onPressed: () =>
                    setState(() => _state = _LifeState.selectStorage),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: const Text('🌾 I Have Harvested — Start Timer'),
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Tap when you\'ve harvested so we can track freshness and help you sell at the best time',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: AgriChainTheme.greyText,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── STATE 2: Storage Selection ────────────────────────────────────────
  Widget _buildStorageSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        const Text(
          'How are you storing your crop?',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        const Text(
          'आप अपनी फसल कैसे रख रहे हैं?',
          style: TextStyle(fontSize: 16, color: AgriChainTheme.greyText),
        ),
        const SizedBox(height: 20),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.3,
          ),
          itemCount: _storageMethods.length,
          itemBuilder: (context, i) {
            final method = _storageMethods[i];
            final isSelected = _selectedStorage == method['id'];
            return GestureDetector(
                  onTap: () => setState(() => _selectedStorage = method['id']),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AgriChainTheme.primaryGreen.withValues(alpha: 0.08)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? AgriChainTheme.primaryGreen
                            : Colors.grey.shade300,
                        width: isSelected ? 2.5 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          method['icon']!,
                          style: const TextStyle(fontSize: 40),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          method['label']!,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isSelected
                                ? AgriChainTheme.primaryGreen
                                : AgriChainTheme.darkText,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .animate()
                .fadeIn(
                  delay: Duration(milliseconds: 80 * i),
                  duration: 250.ms,
                )
                .slideY(begin: 0.1, end: 0);
          },
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: _selectedStorage == null ? null : _loadSpoilageData,
            icon: const Icon(Icons.timer, size: 22),
            label: const Text(
              'Start Freshness Timer',
              style: TextStyle(fontSize: 17),
            ),
          ),
        ),
      ],
    );
  }

  // ─── STATE 3: Active Timer ─────────────────────────────────────────────
  Widget _buildActiveTimer() {
    if (_spoilageData == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),

        // ── Alert card ──
        if (_isAlert)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AgriChainTheme.dangerRed,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '⚠️ Heatwave Alert!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Spoilage risk increased by 30%',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                SizedBox(height: 2),
                Text(
                  'Temperature rising to 42°C in next 6 hours',
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 300.ms).shake(duration: 400.ms, hz: 3),

        // ── Timer widget ──
        CountdownTimer(
          remainingHours: _spoilageData!.remainingHours,
          initialHours: _spoilageData!.initialHours,
          crop: _spoilageData!.crop,
          storageMethod: _spoilageData!.storageMethod,
          temperature: _spoilageData!.temperature,
          isAlert: _isAlert,
        ),
        const SizedBox(height: 8),

        // ── Explanation ──
        if (_spoilageData!.explanation.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('💡', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _spoilageData!.explanation,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AgriChainTheme.greyText,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 20),

        // ── Action buttons ──
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () => context.go('/market'),
                  style: _isAlert
                      ? ElevatedButton.styleFrom(
                          backgroundColor: AgriChainTheme.dangerRed,
                        )
                      : null,
                  icon: const Text('🛒', style: TextStyle(fontSize: 18)),
                  label: Text(
                    _isAlert ? 'Sell Now!' : 'Go to Market',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: () => context.go('/preservation'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AgriChainTheme.primaryGreen,
                    side: const BorderSide(
                      color: AgriChainTheme.primaryGreen,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Text('❄', style: TextStyle(fontSize: 18)),
                  label: const Text(
                    'Save My Crop',
                    style: TextStyle(fontSize: 15),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // ── Debug: Simulate Alert ──
        Center(
          child: TextButton(
            onPressed: _isAlert ? null : _triggerAlert,
            child: Text(
              _isAlert ? '(Alert active)' : '⚡ Simulate Heatwave Alert',
              style: TextStyle(
                fontSize: 13,
                color: _isAlert
                    ? AgriChainTheme.greyText
                    : Colors.grey.shade500,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
