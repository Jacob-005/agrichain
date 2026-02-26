import 'package:flutter/material.dart';
import '../app/theme.dart';

/// Voice input FAB for chat / AI assistant.
class VoiceButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isListening;

  const VoiceButton({
    super.key,
    this.onPressed,
    this.isListening = false,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor:
          isListening ? AgriChainTheme.dangerRed : AgriChainTheme.primaryGreen,
      child: Icon(
        isListening ? Icons.stop : Icons.mic,
        color: Colors.white,
        size: 28,
      ),
    );
  }
}
