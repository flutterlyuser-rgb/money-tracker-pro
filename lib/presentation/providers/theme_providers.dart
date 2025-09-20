import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
// Use the core Riverpod package. See account_providers.dart for details.
import 'package:riverpod/riverpod.dart';

/// Holds the current [ThemeMode] for the application. By default the
/// Money Pro design uses a dark theme, but switching to a light theme
/// can be enabled by updating this provider.
final themeModeProvider = StateProvider<ThemeMode>((ref) {
  return ThemeMode.dark;
});