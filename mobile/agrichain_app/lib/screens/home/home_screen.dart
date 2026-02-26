import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../models/harvest_score_model.dart';
import '../../widgets/score_circle.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/error_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _selectedCrop = 'tomato';
  HarvestScoreModel? _scoreData;
  bool _loading = true;
  String? _error;
  bool _whyExpanded = false;

  final List<Map<String, String>> _crops = const [
    {'id': 'tomato', 'name': 'Tomato', 'icon': '🍅'},
    {'id': 'onion', 'name': 'Onion', 'icon': '🧅'},
    {'id': 'potato', 'name': 'Potato', 'icon': '🥔'},
    {'id': 'wheat', 'name': 'Wheat', 'icon': '🌾'},
    {'id': 'rice', 'name': 'Rice', 'icon': '🍚'},
  ];

  @override
  void initState() {
    super.initState();
    _loadScore();
  }

  Future<void> _loadScore() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final api = ref.read(apiServiceProvider);
    final result = await api.getHarvestScore(_selectedCrop);

    if (result.success && result.data != null) {
      // Real API returns {success, data:{...}}, mock returns flat
      final raw = result.data!;
      final payload = raw.containsKey('data') && raw['data'] is Map
          ? raw['data'] as Map<String, dynamic>
          : raw;
      setState(() {
        _scoreData = HarvestScoreModel.fromJson(payload);
        _loading = false;
      });
    } else {
      setState(() {
        _error = result.error ?? 'Unknown error';
        _loading = false;
      });
    }
  }

  void _selectCrop(String cropId) {
    setState(() {
      _selectedCrop = cropId;
      _whyExpanded = false;
    });
    _loadScore();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Crop selector ───────────────────────────────────
          const SizedBox(height: 4),
          const Text(
            'Your Crops',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _crops.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final crop = _crops[i];
                final isSelected = _selectedCrop == crop['id'];
                return GestureDetector(
                  onTap: () => _selectCrop(crop['id']!),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AgriChainTheme.primaryGreen
                          : Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: isSelected
                            ? AgriChainTheme.primaryGreen
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          crop['icon']!,
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          crop['name']!,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : AgriChainTheme.darkText,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          // ─── Harvest score circle ────────────────────────────
          if (_loading)
            const LoadingIndicator(
              message: 'AI is analyzing your crop...',
              emoji: '🌾',
            )
          else if (_error != null)
            ErrorCard(
              message: ErrorCard.friendlyMessage(_error!),
              onRetry: _loadScore,
            )
          else if (_scoreData != null) ...[
            Center(
              child: ScoreCircle(
                score: _scoreData!.overallScore,
                color: _scoreData!.statusColor,
              ),
            ),
            const SizedBox(height: 12),
            // Status label
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: _scoreData!.statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  _scoreData!.statusLabel,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: _scoreData!.statusColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Recommendation text
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  _scoreData!.recommendation,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AgriChainTheme.greyText,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ─── Score breakdown ────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _scoreData!.breakdown.entries.map((e) {
                return _BreakdownChip(label: e.key, score: e.value);
              }).toList(),
            ),

            const SizedBox(height: 20),

            // ─── "Why this score?" card ────────────────────────
            GestureDetector(
              onTap: () => setState(() => _whyExpanded = !_whyExpanded),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _scoreData!.statusColor.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _scoreData!.statusColor.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('💡', style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Why this score? Tap to learn',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        // Speaker icon (TTS placeholder)
                        const Icon(
                          Icons.volume_up_outlined,
                          size: 20,
                          color: AgriChainTheme.greyText,
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          _whyExpanded ? Icons.expand_less : Icons.expand_more,
                          color: AgriChainTheme.greyText,
                        ),
                      ],
                    ),
                    if (_whyExpanded) ...[
                      const SizedBox(height: 12),
                      Text(
                        _scoreData!.explanation.isNotEmpty
                            ? _scoreData!.explanation
                            : _scoreData!.recommendation,
                        style: const TextStyle(
                          fontSize: 15,
                          color: AgriChainTheme.darkText,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 24),

          // ─── Quick Actions ───────────────────────────────────
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: OutlinedButton.icon(
                    onPressed: () => context.go('/life'),
                    icon: const Text('✅', style: TextStyle(fontSize: 18)),
                    label: const Text(
                      'I Harvested',
                      style: TextStyle(fontSize: 15),
                    ),
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
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: OutlinedButton.icon(
                    onPressed: () => context.go('/crop-selection'),
                    icon: const Text('➕', style: TextStyle(fontSize: 18)),
                    label: const Text(
                      'Add Crop',
                      style: TextStyle(fontSize: 15),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AgriChainTheme.greyText,
                      side: BorderSide(color: Colors.grey.shade400, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          // ─── Services Grid ───────────────────────────────────
          const Text(
            'Services',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          _buildServicesGrid(context),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildServicesGrid(BuildContext context) {
    final services = [
      {'icon': '🌦', 'label': 'Weather', 'route': ''},
      {'icon': '🌱', 'label': 'Soil', 'route': ''},
      {'icon': '📍', 'label': 'Nearest DC', 'route': ''},
      {'icon': '💰', 'label': 'Mandi Prices', 'route': '/market'},
      {'icon': '🩺', 'label': 'Crop Doctor', 'route': ''},
      {'icon': '📹', 'label': 'Video Call', 'route': ''},
      {'icon': '💬', 'label': 'Ask Expert', 'route': ''},
      {'icon': '🚁', 'label': 'Book Drone', 'route': ''},
      {'icon': '📖', 'label': 'Crop Guide', 'route': ''},
      {'icon': '🧪', 'label': 'Soil Test', 'route': ''},
      {'icon': '🦠', 'label': 'Diseases', 'route': ''},
      {'icon': '📊', 'label': 'History', 'route': '/advice-history'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.0,
      ),
      itemCount: services.length,
      itemBuilder: (context, i) {
        final s = services[i];
        return GestureDetector(
          onTap: () {
            final route = s['route']!;
            if (route.isNotEmpty) {
              context.go(route);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Coming soon: ${s['label']}'),
                  duration: const Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(s['icon']!, style: const TextStyle(fontSize: 30)),
                const SizedBox(height: 6),
                Text(
                  s['label']!,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _BreakdownChip extends StatelessWidget {
  final String label;
  final int score;

  const _BreakdownChip({required this.label, required this.score});

  Color get _color {
    if (score >= 70) return AgriChainTheme.primaryGreen;
    if (score >= 40) return AgriChainTheme.cautionYellow;
    return AgriChainTheme.dangerRed;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            '$score',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: _color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AgriChainTheme.greyText,
            ),
          ),
        ],
      ),
    );
  }
}
