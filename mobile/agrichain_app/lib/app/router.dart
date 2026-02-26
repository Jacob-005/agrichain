import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/onboarding/splash_screen.dart';
import '../screens/onboarding/language_screen.dart';
import '../screens/onboarding/otp_screen.dart';
import '../screens/onboarding/personal_info_screen.dart';
import '../screens/onboarding/crop_selection_screen.dart';
import '../screens/onboarding/soil_selection_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/market/market_screen.dart';
import '../screens/life/life_screen.dart';
import '../screens/preservation/preservation_screen.dart';
import '../screens/shared/profile_screen.dart';
import '../screens/shared/notification_screen.dart';
import '../screens/shared/advice_history_screen.dart';
import '../widgets/agri_header.dart';
import '../widgets/agri_bottom_nav.dart';

// Navigator keys for ShellRoute
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
  routes: [
    // ─── Onboarding (no bottom nav) ────────────────────────────────────
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/language',
      builder: (context, state) => const LanguageScreen(),
    ),
    GoRoute(
      path: '/otp',
      builder: (context, state) => const OtpScreen(),
    ),
    GoRoute(
      path: '/personal-info',
      builder: (context, state) => const PersonalInfoScreen(),
    ),
    GoRoute(
      path: '/crop-selection',
      builder: (context, state) => const CropSelectionScreen(),
    ),
    GoRoute(
      path: '/soil-selection',
      builder: (context, state) => const SoilSelectionScreen(),
    ),

    // ─── Main shell with bottom nav + header ───────────────────────────
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return _MainShell(child: child);
      },
      routes: [
        GoRoute(
          path: '/home',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: HomeScreen(),
          ),
        ),
        GoRoute(
          path: '/market',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: MarketScreen(),
          ),
        ),
        GoRoute(
          path: '/life',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: LifeScreen(),
          ),
        ),
        GoRoute(
          path: '/preservation',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: PreservationScreen(),
          ),
        ),
      ],
    ),

    // ─── Standalone screens (pushed on top of shell) ───────────────────
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/notifications',
      builder: (context, state) => const NotificationScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/advice-history',
      builder: (context, state) => const AdviceHistoryScreen(),
    ),
  ],
);

/// Wrapper Scaffold providing the header and bottom navigation for main tabs.
class _MainShell extends StatelessWidget {
  final Widget child;
  const _MainShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const AgriHeader(),
          Expanded(child: child),
        ],
      ),
      bottomNavigationBar: const AgriBottomNav(),
    );
  }
}
