import 'package:flutter/material.dart';
import '../app/theme.dart';

/// Reusable loading indicator for API calls.
class LoadingIndicator extends StatelessWidget {
  final String message;
  final String? emoji;

  const LoadingIndicator({super.key, this.message = 'Loading...', this.emoji});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (emoji != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(emoji!, style: const TextStyle(fontSize: 40)),
              ),
            const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: AgriChainTheme.primaryGreen,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: AgriChainTheme.greyText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
