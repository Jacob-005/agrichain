import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../app/providers.dart';
import '../../app/theme.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkOnboardingAndNavigate();
  }

  Future<void> _checkOnboardingAndNavigate() async {
    final storage = ref.read(storageServiceProvider);
    bool isComplete = false;

    try {
      // ── RESET: Force onboarding to run fresh ──
      await storage.saveOnboardingComplete(false);

      isComplete = await storage.isOnboardingComplete();

      // Restore persisted data into providers
      if (isComplete) {
        final profile = await storage.getUserProfile();
        if (profile != null) {
          ref
              .read(userStateProvider.notifier)
              .setProfile(name: profile['name'], phone: profile['phone']);
          ref
              .read(locationProvider.notifier)
              .update(profile['district'], profile['lat'], profile['lng']);
        }
        final crops = await storage.getSelectedCrops();
        if (crops != null && crops.isNotEmpty) {
          ref.read(selectedCropsProvider.notifier).setCrops(crops);
        }
        final soil = await storage.getSoilType();
        if (soil != null) {
          ref.read(soilTypeProvider.notifier).state = soil;
        }
      }
    } catch (e) {
      // If restore fails, just proceed with defaults
      debugPrint('Error restoring onboarding data: $e');
    }

    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;

    if (isComplete) {
      context.go('/home');
    } else {
      context.go('/language');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final barWidth = screenWidth * 0.6;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ── App icon ──
            Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AgriChainTheme.primaryGreen.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.eco,
                    size: 44,
                    color: AgriChainTheme.primaryGreen,
                  ),
                )
                .animate()
                .scale(
                  begin: const Offset(0.5, 0.5),
                  end: const Offset(1.0, 1.0),
                  duration: 500.ms,
                  curve: Curves.easeOutBack,
                )
                .fadeIn(duration: 400.ms),

            const SizedBox(height: 24),

            // ── Title ──
            const Text(
              'AgriChain',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w800,
                color: AgriChainTheme.primaryGreen,
                letterSpacing: 1.5,
              ),
            ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

            const SizedBox(height: 32),

            // ── Indian flag stripes (staggered animation) ──
            // Saffron stripe
            _AnimatedStripe(
              color: const Color(0xFFFF9933),
              width: barWidth,
              delay: const Duration(milliseconds: 300),
            ),
            const SizedBox(height: 6),
            // White stripe with Ashoka Chakra
            _AnimatedStripe(
              color: Colors.white,
              borderColor: const Color(0xFFE0E0E0),
              width: barWidth,
              delay: const Duration(milliseconds: 600),
              child: const Icon(
                Icons.brightness_7,
                size: 16,
                color: Color(0xFF000080),
              ),
            ),
            const SizedBox(height: 6),
            // Green stripe
            _AnimatedStripe(
              color: const Color(0xFF138808),
              width: barWidth,
              delay: const Duration(milliseconds: 900),
            ),

            const SizedBox(height: 32),

            // ── Subtitle ──
            const Text(
              '🌾 Farm to Market Intelligence',
              style: TextStyle(fontSize: 16, color: AgriChainTheme.greyText),
            ).animate().fadeIn(delay: 1200.ms, duration: 400.ms),

            const SizedBox(height: 48),

            // ── Loader ──
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: AgriChainTheme.primaryGreen,
              ),
            ).animate().fadeIn(delay: 1500.ms, duration: 300.ms),
          ],
        ),
      ),
    );
  }
}

/// A horizontal bar that animates from width 0 to [width].
class _AnimatedStripe extends StatelessWidget {
  final Color color;
  final Color? borderColor;
  final double width;
  final Duration delay;
  final Widget? child;

  const _AnimatedStripe({
    required this.color,
    required this.width,
    required this.delay,
    this.borderColor,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
          height: 18,
          width: width,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(9),
            border: borderColor != null
                ? Border.all(color: borderColor!, width: 1)
                : null,
          ),
          child: child != null ? Center(child: child) : null,
        )
        .animate()
        .scaleX(
          begin: 0,
          end: 1,
          duration: 500.ms,
          delay: delay,
          curve: Curves.easeOutCubic,
        )
        .fadeIn(duration: 300.ms, delay: delay);
  }
}
