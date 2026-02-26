import 'package:flutter/material.dart';
import '../../app/theme.dart';

class AdviceHistoryScreen extends StatelessWidget {
  const AdviceHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final totalSaved = 3800;
    final entries = [
      {
        'date': '25 Feb 2026',
        'type': 'harvest',
        'icon': '🌾',
        'advice':
            'Harvest tomato when score reached 82. Market was 15% above average.',
        'savings': 1200,
        'followed': true,
      },
      {
        'date': '22 Feb 2026',
        'type': 'market',
        'icon': '🏪',
        'advice':
            'Sell at Wardha Mandi instead of Nagpur. Closer, less spoilage.',
        'savings': 1100,
        'followed': true,
      },
      {
        'date': '18 Feb 2026',
        'type': 'preservation',
        'icon': '❄',
        'advice': 'Store in plastic crates to extend shelf life by 3 days.',
        'savings': 900,
        'followed': true,
      },
      {
        'date': '14 Feb 2026',
        'type': 'timer',
        'icon': '⏱',
        'advice': 'Sell before 48h mark. Spoilage risk was increasing.',
        'savings': 600,
        'followed': true,
      },
      {
        'date': '10 Feb 2026',
        'type': 'market',
        'icon': '🏪',
        'advice': 'Wait 2 days to sell onion — prices expected to rise.',
        'savings': 0,
        'followed': false,
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Your Savings History 📊'),
        backgroundColor: Colors.white,
        foregroundColor: AgriChainTheme.darkText,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ── Summary card ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AgriChainTheme.primaryGreen,
                    AgriChainTheme.primaryGreen.withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  const Text(
                    'Total Extra Earnings',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹$totalSaved',
                    style: const TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "By following AgriChain's advice",
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Entries list ──
            ...entries.map((e) {
              final savings = e['savings'] as int;
              final followed = e['followed'] as bool;

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      e['icon'] as String,
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                e['date'] as String,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AgriChainTheme.greyText,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: followed
                                      ? AgriChainTheme.primaryGreen.withValues(
                                          alpha: 0.1,
                                        )
                                      : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  followed ? '✅ Followed' : '❌ Skipped',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: followed
                                        ? AgriChainTheme.primaryGreen
                                        : AgriChainTheme.greyText,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            e['advice'] as String,
                            style: const TextStyle(fontSize: 14, height: 1.3),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            savings > 0 ? '₹$savings saved' : '—',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: savings > 0
                                  ? AgriChainTheme.primaryGreen
                                  : AgriChainTheme.greyText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
