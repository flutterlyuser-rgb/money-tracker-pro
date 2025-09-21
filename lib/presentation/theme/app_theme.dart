import 'package:flutter/material.dart';

/// Defines the global color palette and theming for the application.
///
/// This class centralizes all theme definitions so that styles can be
/// maintained consistently across the app and adjusted from a single
/// location. It includes both dark and light variants, with the dark
/// theme matching the Money Pro design and serving as the default.
class AppTheme {
  // Core colors for the dark theme. These values were chosen to
  // approximate the Money Pro color palette (dark blue backgrounds
  // with brighter highlights). Adjust these values to tweak the look
  // of the app globally.
  static const Color _darkScaffold = Color(0xFF01304B);
  static const Color _darkPrimary = Color(0xFF01304B);
  static const Color _darkCard = Color(0xFF0D4467);
  static const Color _darkAccent = Color(0xFF0FC0F0);

  /// The dark theme used across the app. Includes overrides for
  /// scaffolds, app bars, cards, and color scheme to provide a
  /// coherent dark appearance.
  static final ThemeData darkTheme = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: _darkScaffold,
    primaryColor: _darkPrimary,
    cardColor: _darkCard,
    colorScheme: const ColorScheme.dark().copyWith(
      primary: _darkPrimary,
      secondary: _darkAccent,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: _darkScaffold,
      elevation: 0,
    ),
    // Elevated button styling for consistency.
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _darkAccent,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    // Input decorations: used in forms like adding transactions.
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _darkCard,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _darkAccent),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      labelStyle: const TextStyle(color: Colors.white70),
    ),
    // Slider theme: used in budget pages for progress bars.
    sliderTheme: SliderThemeData(
      activeTrackColor: _darkAccent,
      thumbColor: _darkAccent,
      inactiveTrackColor: _darkAccent.withOpacity(0.3),
    ),
    // Tab bar theme placeholder (unused currently but ready for future).
    tabBarTheme: const TabBarThemeData(
      indicatorColor: Colors.white,
    ),
  );

  /// The light theme variant. While Money Pro uses a dark interface, a
  /// light theme is provided for completeness and potential future
  /// toggling support. It adheres to Material defaults with subtle
  /// customizations for cards and primary colors.
  static final ThemeData lightTheme = ThemeData.light().copyWith(
    scaffoldBackgroundColor: Colors.white,
    primaryColor: Colors.blueGrey,
    cardColor: Colors.white,
    colorScheme: const ColorScheme.light().copyWith(
      primary: Colors.blueGrey,
      secondary: Colors.teal,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.blueGrey,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
  );
}