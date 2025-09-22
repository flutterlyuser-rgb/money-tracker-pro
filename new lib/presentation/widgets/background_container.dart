// lib/common/widgets/background_container.dart
import 'package:flutter/material.dart';

class BackgroundContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool safeArea;

  const BackgroundContainer({
    super.key,
    required this.child,
    this.padding,
    this.safeArea = true,
  });

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: padding ?? EdgeInsets.zero,
      child: child,
    );

    return SizedBox.expand( // ⬅️ forces full-screen
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/Background.jpg',
              fit: BoxFit.cover,
            ),
          ),
          if (safeArea) SafeArea(child: content) else content,
        ],
      ),
    );
  }
}
