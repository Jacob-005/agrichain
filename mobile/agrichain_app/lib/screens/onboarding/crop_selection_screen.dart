import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../app/providers.dart';
import '../../app/theme.dart';

class CropSelectionScreen extends ConsumerStatefulWidget {
  const CropSelectionScreen({super.key});

  @override
  ConsumerState<CropSelectionScreen> createState() =>
      _CropSelectionScreenState();
}

class _CropSelectionScreenState extends ConsumerState<CropSelectionScreen>
    with TickerProviderStateMixin {
  final Set<String> _selected = {};
  List<Map<String, dynamic>> _allCrops = [];
  List<String> _categories = [];
  TabController? _tabController;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCrops();
  }

  Future<void> _loadCrops() async {
    final api = ref.read(apiServiceProvider);
    final result = await api.getCrops();

    if (result.success && result.data != null) {
      final raw = result.data!;
      // Handle multiple response shapes:
      // Mock:  {crops: [{category: "Vegetables", ...}, ...]}
      // Real:  {success: true, data: {categories: [{name: "Vegetables", crops: [...]}, ...]}}
      List<Map<String, dynamic>> crops = [];

      if (raw['crops'] is List) {
        // Mock format: flat list with category per crop
        crops = List<Map<String, dynamic>>.from(raw['crops']);
      } else if (raw['data'] is Map && raw['data']['categories'] is List) {
        // Real backend format: nested categories
        final categories = raw['data']['categories'] as List;
        for (final cat in categories) {
          final catName = cat['name'] ?? 'Other';
          final catCrops = (cat['crops'] as List?) ?? [];
          for (final c in catCrops) {
            final crop = Map<String, dynamic>.from(c);
            crop['category'] = catName;
            // Map icon_url → icon for consistency
            if (crop['icon_url'] != null && crop['icon'] == null) {
              crop['icon'] = crop['icon_url'];
            }
            crops.add(crop);
          }
        }
      } else if (raw['data'] is List) {
        crops = List<Map<String, dynamic>>.from(raw['data']);
      } else if (raw['data'] is Map && raw['data']['crops'] is List) {
        crops = List<Map<String, dynamic>>.from(raw['data']['crops']);
      }

      final cats = crops
          .map((c) => c['category'] as String? ?? 'Other')
          .toSet()
          .toList();

      if (cats.isEmpty) {
        setState(() => _loading = false);
        return;
      }

      setState(() {
        _allCrops = crops;
        _categories = cats;
        _tabController = TabController(length: cats.length, vsync: this);
        _loading = false;
      });
    } else {
      // API failed — stop loading and show error
      setState(() => _loading = false);
    }
  }

  List<Map<String, dynamic>> _cropsForCategory(String category) {
    return _allCrops.where((c) => c['category'] == category).toList();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(color: AgriChainTheme.primaryGreen),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: AgriChainTheme.darkText,
                    ),
                    onPressed: () => context.go('/personal-info'),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'What Do You Grow?',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'आप क्या उगाते हैं?',
                    style: TextStyle(
                      fontSize: 18,
                      color: AgriChainTheme.greyText,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Category tabs ──
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade200, width: 1),
                ),
              ),
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                labelColor: AgriChainTheme.primaryGreen,
                unselectedLabelColor: AgriChainTheme.greyText,
                labelStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: const TextStyle(fontSize: 15),
                indicatorColor: AgriChainTheme.primaryGreen,
                indicatorWeight: 3,
                tabAlignment: TabAlignment.start,
                tabs: _categories.map((c) => Tab(text: c)).toList(),
              ),
            ),

            // ── Crop grid ──
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: _categories.map((category) {
                  final crops = _cropsForCategory(category);
                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.85,
                        ),
                    itemCount: crops.length,
                    itemBuilder: (context, i) {
                      final crop = crops[i];
                      final id = crop['id'] as String;
                      final isSelected = _selected.contains(id);

                      return GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  _selected.remove(id);
                                } else {
                                  _selected.add(id);
                                }
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AgriChainTheme.primaryGreen.withValues(
                                        alpha: 0.08,
                                      )
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected
                                      ? AgriChainTheme.primaryGreen
                                      : Colors.grey.shade300,
                                  width: isSelected ? 2.5 : 1,
                                ),
                              ),
                              child: Stack(
                                children: [
                                  Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          crop['icon'] ?? '🌱',
                                          style: const TextStyle(fontSize: 32),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          crop['name_hi'] ?? crop['name'],
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: isSelected
                                                ? FontWeight.w700
                                                : FontWeight.w500,
                                            color: isSelected
                                                ? AgriChainTheme.primaryGreen
                                                : AgriChainTheme.darkText,
                                          ),
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          crop['name'] ?? '',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: AgriChainTheme.greyText,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isSelected)
                                    const Positioned(
                                      top: 6,
                                      right: 6,
                                      child: Icon(
                                        Icons.check_circle,
                                        color: AgriChainTheme.primaryGreen,
                                        size: 20,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          )
                          .animate()
                          .fadeIn(
                            delay: Duration(milliseconds: 50 * i),
                            duration: 250.ms,
                          )
                          .scale(
                            begin: const Offset(0.9, 0.9),
                            end: const Offset(1, 1),
                            delay: Duration(milliseconds: 50 * i),
                            duration: 250.ms,
                          );
                    },
                  );
                }).toList(),
              ),
            ),

            // ── Sticky bottom bar ──
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    // Selection count
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: _selected.isEmpty
                            ? Colors.grey.shade100
                            : AgriChainTheme.primaryGreen.withValues(
                                alpha: 0.1,
                              ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 18,
                            color: _selected.isEmpty
                                ? AgriChainTheme.greyText
                                : AgriChainTheme.primaryGreen,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${_selected.length} selected',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: _selected.isEmpty
                                  ? AgriChainTheme.greyText
                                  : AgriChainTheme.primaryGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: _selected.isEmpty
                              ? null
                              : () {
                                  // Save selected crops to provider and storage
                                  final selectedCropData = _allCrops
                                      .where((c) => _selected.contains(c['id']))
                                      .map(
                                        (c) => {
                                          'id': c['id'] as String,
                                          'name': c['name'] as String,
                                          'icon':
                                              (c['icon'] as String?) ?? '🌱',
                                        },
                                      )
                                      .toList();
                                  ref
                                      .read(selectedCropsProvider.notifier)
                                      .setCrops(selectedCropData);

                                  // Persist to storage
                                  final storage = ref.read(
                                    storageServiceProvider,
                                  );
                                  storage.saveSelectedCrops(selectedCropData);

                                  context.go('/soil-selection');
                                },
                          icon: const Icon(Icons.arrow_forward, size: 20),
                          label: const Text(
                            'Next →',
                            style: TextStyle(fontSize: 17),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
