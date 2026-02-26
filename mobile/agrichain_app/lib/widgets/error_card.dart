import 'package:flutter/material.dart';
import '../app/theme.dart';

/// Reusable error card with retry button — never shows raw errors to users.
class ErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorCard({
    super.key,
    this.message = 'Something went wrong. Please try again.',
    this.onRetry,
  });

  /// Convert raw error strings to friendly messages.
  static String friendlyMessage(String raw) {
    final lower = raw.toLowerCase();
    if (lower.contains('timeout')) {
      return 'AI is busy thinking. Please wait and retry. 🤔';
    }
    if (lower.contains('connection') ||
        lower.contains('socketexception') ||
        lower.contains('network')) {
      return 'Cannot connect to server. Check your network. 📡';
    }
    if (lower.contains('500')) {
      return 'Server error. We\'re working on it! 🔧';
    }
    if (lower.contains('401') || lower.contains('403')) {
      return 'Session expired. Please log in again. 🔒';
    }
    return 'Something went wrong. Please try again.';
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AgriChainTheme.dangerRed.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('⚠️', style: TextStyle(fontSize: 32)),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: AgriChainTheme.darkText,
                height: 1.5,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              SizedBox(
                height: 44,
                child: ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh, size: 20),
                  label: const Text(
                    'Try Again 🔄',
                    style: TextStyle(fontSize: 15),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AgriChainTheme.primaryGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
