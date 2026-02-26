import 'package:flutter/material.dart';
import '../../app/theme.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = [
      {
        'type': 'alert',
        'icon': '⚠️',
        'title': 'Heatwave Warning',
        'body':
            'Temperature expected to reach 42°C tomorrow. Your tomato crop may spoil 30% faster.',
        'time': '2 hours ago',
        'unread': true,
      },
      {
        'type': 'price',
        'icon': '💰',
        'title': 'Price Alert: Tomato',
        'body':
            'Tomato price at Wardha Mandi rose by 18% to ₹22/kg. Good time to sell!',
        'time': '5 hours ago',
        'unread': true,
      },
      {
        'type': 'harvest',
        'icon': '🌾',
        'title': 'Harvest Reminder',
        'body':
            'Your tomato crop harvest score is 78/100. Market conditions are favorable for harvest.',
        'time': '1 day ago',
        'unread': false,
      },
      {
        'type': 'info',
        'icon': '🎉',
        'title': 'Welcome to AgriChain!',
        'body':
            'Your profile is set up. Start by checking your Harvest Score on the Home tab.',
        'time': '2 days ago',
        'unread': false,
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Notifications 🔔'),
        backgroundColor: Colors.white,
        foregroundColor: AgriChainTheme.darkText,
        elevation: 0,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: notifications.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final n = notifications[i];
          final isUnread = n['unread'] as bool;
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isUnread
                  ? Colors.blue.withValues(alpha: 0.04)
                  : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Unread dot
                if (isUnread)
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(top: 6, right: 8),
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                  )
                else
                  const SizedBox(width: 16),

                // Icon
                Text(n['icon'] as String, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 10),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        n['title'] as String,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isUnread
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        n['body'] as String,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AgriChainTheme.greyText,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        n['time'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
