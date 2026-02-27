import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../app/theme.dart';
import '../app/providers.dart';
import '../widgets/location_picker.dart';

class AgriHeader extends ConsumerWidget implements PreferredSizeWidget {
  const AgriHeader({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = ref.watch(locationProvider);

    return SafeArea(
      bottom: false,
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Location label — tappable
            GestureDetector(
              onTap: () {
                LocationPicker.show(
                  context,
                  onLocationSelected: (district, lat, lng) {
                    ref
                        .read(locationProvider.notifier)
                        .update(district, lat, lng);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('📍 Location changed to $district'),
                        backgroundColor: AgriChainTheme.primaryGreen,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                );
              },
              child: Row(
                children: [
                  const Text('📍', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 4),
                  Text(
                    location.district,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AgriChainTheme.darkText,
                    ),
                  ),
                  const Icon(
                    Icons.keyboard_arrow_down,
                    size: 20,
                    color: AgriChainTheme.greyText,
                  ),
                ],
              ),
            ),

            // Right-side icons
            Row(
              children: [
                // Advice history
                IconButton(
                  icon: const Icon(
                    Icons.history,
                    color: AgriChainTheme.primaryGreen,
                  ),
                  tooltip: 'Advice History',
                  onPressed: () => context.push('/advice-history'),
                ),
                // Notifications with badge
                Stack(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.notifications_outlined,
                        color: AgriChainTheme.primaryGreen,
                      ),
                      tooltip: 'Notifications',
                      onPressed: () => context.push('/notifications'),
                    ),
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: AgriChainTheme.dangerRed,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
                // Profile
                IconButton(
                  icon: const Icon(
                    Icons.account_circle_outlined,
                    color: AgriChainTheme.primaryGreen,
                  ),
                  tooltip: 'Profile',
                  onPressed: () => context.push('/profile'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
