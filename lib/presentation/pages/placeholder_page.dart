import 'package:flutter/material.dart';

/// A simple screen used for pages that haven't been implemented yet.
///
/// The [title] is displayed in the center of the page. This widget
/// intentionally has no functionality beyond providing a placeholder to
/// demonstrate the navigation layout.
class PlaceholderPage extends StatelessWidget {
  final String title;

  const PlaceholderPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF01304B),
      child: Center(
        child: Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 24),
        ),
      ),
    );
  }
}