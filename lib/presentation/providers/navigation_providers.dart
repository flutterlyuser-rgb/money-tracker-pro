// Use the core Riverpod package instead of flutter_riverpod. See
// account_providers.dart for details.
import 'package:flutter_riverpod/legacy.dart';
import 'package:riverpod/riverpod.dart';
import 'package:flutter/material.dart';

/// A provider that holds the current selected index for the bottom
/// navigation bar. This enables global access to the navigation state
/// and allows multiple widgets to react to navigation changes without
/// keeping local state in the [HomeScreen].
final navIndexProvider = StateProvider<int>((ref) => 0);

/// A simple model representing an item in the bottom navigation bar.
///
/// Each item has a [label] and an [icon] used for display.
class NavItem {
  final String label;
  final IconData icon;
  const NavItem({required this.label, required this.icon});
}