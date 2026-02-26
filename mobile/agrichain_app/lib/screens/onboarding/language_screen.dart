import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../app/providers.dart';
import '../../app/theme.dart';

class LanguageScreen extends ConsumerStatefulWidget {
  const LanguageScreen({super.key});

  @override
  ConsumerState<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends ConsumerState<LanguageScreen> {
  String? _selectedCode;

  static const _languages = [
    {'code': 'en', 'native': 'English', 'english': 'English', 'icon': '🇬🇧'},
    {'code': 'hi', 'native': 'हिन्दी', 'english': 'Hindi', 'icon': '🇮🇳'},
    {'code': 'mr', 'native': 'मराठी', 'english': 'Marathi', 'icon': '🌺'},
    {'code': 'gu', 'native': 'ગુજરાતી', 'english': 'Gujarati', 'icon': '🦁'},
    {'code': 'bn', 'native': 'বাংলা', 'english': 'Bengali', 'icon': '🐅'},
    {'code': 'ur', 'native': 'اردو', 'english': 'Urdu', 'icon': '☪️'},
    {'code': 'pa', 'native': 'ਪੰਜਾਬੀ', 'english': 'Punjabi', 'icon': '🌾'},
    {'code': 'te', 'native': 'తెలుగు', 'english': 'Telugu', 'icon': '🎬'},
  ];

  Future<void> _selectLanguage(String code) async {
    setState(() => _selectedCode = code);

    final storage = ref.read(storageServiceProvider);
    await storage.saveLanguage(code);
    ref.read(userStateProvider.notifier).setLanguage(code);

    // Brief visual feedback before navigating
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) context.go('/otp');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 32),

              // ── Header icon ──
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AgriChainTheme.primaryGreen.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.translate,
                    size: 32, color: AgriChainTheme.primaryGreen),
              ),
              const SizedBox(height: 20),

              // ── Title (dual language) ──
              const Text(
                'Choose Your Language',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AgriChainTheme.darkText,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'अपनी भाषा चुनें',
                style: TextStyle(
                  fontSize: 20,
                  color: AgriChainTheme.greyText,
                ),
              ),
              const SizedBox(height: 28),

              // ── Language grid ──
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.5,
                  ),
                  itemCount: _languages.length,
                  itemBuilder: (context, i) {
                    final lang = _languages[i];
                    final isSelected = _selectedCode == lang['code'];

                    return _LanguageCard(
                      nativeLabel: lang['native']!,
                      englishLabel: lang['english']!,
                      icon: lang['icon']!,
                      isSelected: isSelected,
                      onTap: () => _selectLanguage(lang['code']!),
                    )
                        .animate()
                        .fadeIn(
                          delay: Duration(milliseconds: 80 * i),
                          duration: 300.ms,
                        )
                        .slideY(
                          begin: 0.15,
                          end: 0,
                          delay: Duration(milliseconds: 80 * i),
                          duration: 300.ms,
                          curve: Curves.easeOut,
                        );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  final String nativeLabel;
  final String englishLabel;
  final String icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageCard({
    required this.nativeLabel,
    required this.englishLabel,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected
          ? AgriChainTheme.primaryGreen.withValues(alpha: 0.08)
          : Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? AgriChainTheme.primaryGreen
                  : const Color(0xFFE0E0E0),
              width: isSelected ? 2 : 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Stack(
            children: [
              // Content
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    nativeLabel,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? AgriChainTheme.primaryGreen
                          : AgriChainTheme.darkText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    englishLabel,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AgriChainTheme.greyText,
                    ),
                  ),
                ],
              ),
              // Icon top-right
              Positioned(
                top: 0,
                right: 0,
                child: Text(icon, style: const TextStyle(fontSize: 22)),
              ),
              // Checkmark when selected
              if (isSelected)
                const Positioned(
                  bottom: 0,
                  right: 0,
                  child: Icon(
                    Icons.check_circle,
                    color: AgriChainTheme.primaryGreen,
                    size: 22,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
