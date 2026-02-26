import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../app/theme.dart';

class AgriHeader extends StatelessWidget implements PreferredSizeWidget {
  const AgriHeader({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
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
            // Location label
            GestureDetector(
              onTap: () {
                // TODO: open location picker
              },
              child: const Row(
                children: [
                  Text('📍', style: TextStyle(fontSize: 20)),
                  SizedBox(width: 4),
                  Text(
                    'Nagpur',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AgriChainTheme.darkText,
                    ),
                  ),
                  Icon(Icons.keyboard_arrow_down,
                      size: 20, color: AgriChainTheme.greyText),
                ],
              ),
            ),

            // Right-side icons
            Row(
              children: [
                // Advice history / ROI
                IconButton(
                  icon: const Icon(Icons.history,
                      color: AgriChainTheme.primaryGreen),
                  tooltip: 'Advice History',
                  onPressed: () => context.push('/advice-history'),
                ),
                // Notifications with badge
                Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined,
                          color: AgriChainTheme.primaryGreen),
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
                  icon: const Icon(Icons.account_circle_outlined,
                      color: AgriChainTheme.primaryGreen),
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
