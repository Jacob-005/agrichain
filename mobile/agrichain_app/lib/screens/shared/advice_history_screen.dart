import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/error_card.dart';

class AdviceHistoryScreen extends ConsumerStatefulWidget {
  const AdviceHistoryScreen({super.key});

  @override
  ConsumerState<AdviceHistoryScreen> createState() =>
      _AdviceHistoryScreenState();
}

class _AdviceHistoryScreenState extends ConsumerState<AdviceHistoryScreen> {
  int _totalSaved = 0;
  List<Map<String, dynamic>> _entries = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final api = ref.read(apiServiceProvider);
    final result = await api.getAdviceHistory();

    if (result.success && result.data != null) {
      final raw = result.data!;
      // Real API: {success, data: {total_estimated_savings, entries: [...]}}
      // Mock: {history: [...]}
      final payload = raw.containsKey('data') && raw['data'] is Map
          ? raw['data'] as Map<String, dynamic>
          : raw;

      List<dynamic> entries;
      if (payload['entries'] is List) {
        entries = payload['entries'];
      } else if (payload['history'] is List) {
        entries = payload['history'];
      } else {
        entries = [];
      }

      setState(() {
        _totalSaved = payload['total_estimated_savings'] ?? 0;
        _entries = List<Map<String, dynamic>>.from(entries);
        _loading = false;
      });
    } else {
      setState(() {
        _error = result.error ?? 'Failed to load history';
        _loading = false;
      });
    }
  }

  String _typeIcon(String type) {
    switch (type) {
      case 'harvest':
        return '🌾';
      case 'market':
        return '🏪';
      case 'preservation':
        return '❄';
      case 'spoilage':
        return '⏱';
      default:
        return '📋';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Your Savings History 📊'),
        backgroundColor: Colors.white,
        foregroundColor: AgriChainTheme.darkText,
        elevation: 0,
      ),
      body: _loading
          ? const LoadingIndicator(message: 'Loading your savings...')
          : _error != null
          ? ErrorCard(
              message: ErrorCard.friendlyMessage(_error!),
              onRetry: _loadHistory,
            )
          : SingleChildScrollView(
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
                          '₹$_totalSaved',
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

                  if (_entries.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(32),
                      child: Text(
                        'No advice history yet. Start using AgriChain!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: AgriChainTheme.greyText,
                        ),
                      ),
                    ),

                  // ── Entries list ──
                  ..._entries.map((e) {
                    final savings = e['savings_rupees'] ?? e['savings'] ?? 0;
                    final followed = e['followed'] ?? e['status'] == 'followed';
                    final type = e['type'] ?? '';
                    final advice = e['recommendation'] ?? e['advice'] ?? '';
                    final date = e['created_at'] ?? e['date'] ?? '';

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
                            _typeIcon(type),
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
                                      date.toString().length > 10
                                          ? date.toString().substring(0, 10)
                                          : date.toString(),
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
                                        color: followed == true
                                            ? AgriChainTheme.primaryGreen
                                                  .withValues(alpha: 0.1)
                                            : Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        followed == true
                                            ? '✅ Followed'
                                            : '❌ Skipped',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: followed == true
                                              ? AgriChainTheme.primaryGreen
                                              : AgriChainTheme.greyText,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  advice.toString(),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    height: 1.3,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  savings is int && savings > 0
                                      ? '₹$savings saved'
                                      : '—',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: savings is int && savings > 0
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
