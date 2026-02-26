import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../models/mandi_result_model.dart';
import '../../widgets/mandi_card.dart';

class MarketScreen extends ConsumerStatefulWidget {
  const MarketScreen({super.key});

  @override
  ConsumerState<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends ConsumerState<MarketScreen> {
  String? _selectedCrop;
  final _qtyController = TextEditingController();
  bool _loading = false;
  bool _searched = false;
  List<MandiResultModel> _results = [];
  String _bestOption = '';

  final List<Map<String, String>> _crops = const [
    {'id': 'tomato', 'name': 'Tomato', 'icon': '🍅'},
    {'id': 'onion', 'name': 'Onion', 'icon': '🧅'},
    {'id': 'potato', 'name': 'Potato', 'icon': '🥔'},
    {'id': 'wheat', 'name': 'Wheat', 'icon': '🌾'},
    {'id': 'rice', 'name': 'Rice', 'icon': '🍚'},
    {'id': 'cotton', 'name': 'Cotton', 'icon': '🏵️'},
  ];

  @override
  void dispose() {
    _qtyController.dispose();
    super.dispose();
  }

  Future<void> _findBestMandi() async {
    if (_selectedCrop == null) {
      _showSnackBar('Please select a crop');
      return;
    }
    final qty = double.tryParse(_qtyController.text.trim());
    if (qty == null || qty <= 0) {
      _showSnackBar('Please enter a valid quantity');
      return;
    }

    setState(() {
      _loading = true;
      _searched = false;
    });

    final api = ref.read(apiServiceProvider);
    final result = await api.getMarketComparison(_selectedCrop!, qty);

    if (result.success && result.data != null) {
      final mandisJson =
          List<Map<String, dynamic>>.from(result.data!['mandis'] ?? []);
      final mandis = mandisJson.map((m) => MandiResultModel.fromJson(m)).toList();
      mandis.sort((a, b) => b.pocketCash.compareTo(a.pocketCash));
      // Assign ranks after sorting
      for (int i = 0; i < mandis.length; i++) {
        mandis[i] = MandiResultModel(
          rank: i + 1,
          name: mandis[i].name,
          pricePerKg: mandis[i].pricePerKg,
          distanceKm: mandis[i].distanceKm,
          fuelCost: mandis[i].fuelCost,
          spoilageLoss: mandis[i].spoilageLoss,
          spoilagePct: mandis[i].spoilagePct,
          pocketCash: mandis[i].pocketCash,
          riskLevel: mandis[i].riskLevel,
          explanation: mandis[i].explanation,
          demand: mandis[i].demand,
        );
      }
      setState(() {
        _results = mandis;
        _bestOption = result.data!['best_option'] ?? '';
        _loading = false;
        _searched = true;
      });
    } else {
      setState(() => _loading = false);
      _showSnackBar('Failed to fetch data. Try again.');
    }
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontSize: 16)),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Title ───────────────────────────────────────────
          const SizedBox(height: 4),
          const Text(
            '💰 Pocket Cash Calculator',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          const Text(
            'Find the mandi that puts the most ₹ in YOUR pocket',
            style: TextStyle(fontSize: 14, color: AgriChainTheme.greyText),
          ),
          const SizedBox(height: 20),

          // ─── Crop dropdown ───────────────────────────────────
          DropdownButtonFormField<String>(
            value: _selectedCrop,
            decoration: const InputDecoration(
              labelText: 'Select Crop',
              prefixIcon:
                  Icon(Icons.eco, color: AgriChainTheme.primaryGreen),
            ),
            items: _crops
                .map((c) => DropdownMenuItem(
                      value: c['id'],
                      child: Row(
                        children: [
                          Text(c['icon']!,
                              style: const TextStyle(fontSize: 20)),
                          const SizedBox(width: 8),
                          Text(c['name']!),
                        ],
                      ),
                    ))
                .toList(),
            onChanged: (val) => setState(() => _selectedCrop = val),
          ),
          const SizedBox(height: 16),

          // ─── Quantity input ──────────────────────────────────
          TextField(
            controller: _qtyController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(fontSize: 18),
            decoration: const InputDecoration(
              labelText: 'Enter quantity (kg)',
              hintText: 'e.g. 800',
              prefixIcon: Icon(Icons.scale,
                  color: AgriChainTheme.primaryGreen),
              suffixText: 'kg',
            ),
          ),
          const SizedBox(height: 20),

          // ─── Search button ───────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _loading ? null : _findBestMandi,
              icon: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.search, size: 22),
              label: Text(
                _loading
                    ? 'Analyzing mandis near you... 🚛'
                    : '🔍 Find Best Mandi',
                style: const TextStyle(fontSize: 17),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ─── Results or empty state ──────────────────────────
          if (!_searched && !_loading) _buildEmptyState(),
          if (_searched && _results.isNotEmpty) _buildResults(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AgriChainTheme.primaryGreen.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.store,
                  size: 40, color: AgriChainTheme.primaryGreen),
            ),
            const SizedBox(height: 16),
            const Text(
              'Enter crop and quantity to find\nthe best mandi for you',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 16, color: AgriChainTheme.greyText, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        const Text(
          'Best Option for Your Pocket 💰',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        const Text(
          'Ranked by cash reaching YOU, not just price',
          style: TextStyle(fontSize: 14, color: AgriChainTheme.greyText),
        ),
        const SizedBox(height: 16),

        // ── Road map visual ──
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Text('🧑‍🌾', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        gradient: const LinearGradient(
                          colors: [
                            AgriChainTheme.primaryGreen,
                            AgriChainTheme.cautionYellow,
                            AgriChainTheme.dangerRed,
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('🏪', style: TextStyle(fontSize: 24)),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Spoilage increases with distance →',
                style: TextStyle(
                    fontSize: 12,
                    color: AgriChainTheme.greyText,
                    fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ── Mandi cards ──
        ...List.generate(_results.length, (i) {
          return MandiCard(mandi: _results[i])
              .animate()
              .fadeIn(
                delay: Duration(milliseconds: 150 * i),
                duration: 300.ms,
              )
              .slideY(
                begin: 0.08,
                end: 0,
                delay: Duration(milliseconds: 150 * i),
                duration: 300.ms,
              );
        }),

        const SizedBox(height: 16),

        // ── AI Recommendation card ──
        if (_bestOption.isNotEmpty)
          Container(
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
                const Text('🤖', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('AI Recommendation',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(
                        'Sell at $_bestOption for the best net return. Lower per-kg price but you save on fuel and spoilage.',
                        style: const TextStyle(
                            fontSize: 14,
                            color: AgriChainTheme.darkText,
                            height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 24),
      ],
    );
  }
}
