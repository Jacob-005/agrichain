import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
    Timer(const Duration(milliseconds: 2500), () {
      if (mounted) {
        context.go('/language');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Indian flag stripes
            Container(
              width: 200,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Column(
                  children: [
                    Expanded(
                      child: Container(color: const Color(0xFFFF9933)), // Saffron
                    ),
                    Expanded(
                      child: Container(
                        color: Colors.white,
                        child: const Center(
                          child: Icon(Icons.eco,
                              color: AgriChainTheme.primaryGreen, size: 28),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                          color: const Color(0xFF138808)), // Green
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'AgriChain',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w800,
                color: AgriChainTheme.primaryGreen,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Farm to Market Intelligence',
              style: TextStyle(
                fontSize: 16,
                color: AgriChainTheme.greyText,
              ),
            ),
            const SizedBox(height: 48),
            const SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: AgriChainTheme.primaryGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
