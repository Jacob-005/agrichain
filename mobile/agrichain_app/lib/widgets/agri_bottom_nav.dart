import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../app/providers.dart';
import '../app/theme.dart';

class AgriBottomNav extends ConsumerWidget {
  const AgriBottomNav({super.key});

  static const _tabs = [
    '/home',
    '/market',
    '/life',
    '/preservation',
  ];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    for (int i = 0; i < _tabs.length; i++) {
      if (location.startsWith(_tabs[i])) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = _currentIndex(context);

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        ref.read(appStateProvider.notifier).setNavIndex(index);
        context.go(_tabs[index]);
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.store_outlined),
          activeIcon: Icon(Icons.store),
          label: 'Market',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.timer_outlined),
          activeIcon: Icon(Icons.timer),
          label: 'Life',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.ac_unit_outlined),
          activeIcon: Icon(Icons.ac_unit),
          label: 'Preserve',
        ),
      ],
      selectedItemColor: AgriChainTheme.primaryGreen,
      unselectedItemColor: AgriChainTheme.greyText,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
    );
  }
}
