import 'package:flutter/material.dart';

/// Spacing scale from the Design System (section C). Always used via these
/// constants — never a bare number in a screen or widget.
class AppSpacing {
  static const double sm = 8;
  static const double md = 16;
  static const double edge = 24;
}

/// Color roles from the Design System (section A). Light-only: the
/// navy→plum gradient background is the whole visual identity, so there is
/// no dark theme fallback and no color should ever be hardcoded outside
/// this file.
class AppColors {
  static const background = Color(0xFF1A2332);
  static const backgroundGradientEnd = Color(0xFF241A32);
  static const primary = Color(0xFF4ECDC4);
  static const onPrimary = Color(0xFF1A2332);
  static const secondary = Color(0xFFFFB74D); // overdue flags, due-soon badges
  static const surface = Color(0xFF232B3D);
  static const onSurface = Color(0xFFEDF1F7);
  static const onSurfaceVariant = Color(0xFFA6ADBE);
  static const outline = Color(0xFF3A4358);

  /// Icon-avatar background on LoanCard (mockup: the muted teal square
  /// behind each item's icon). Not in the original palette table — added
  /// as a tint of `surface` rather than a new hue, so it stays inside the
  /// existing family instead of introducing an unreviewed color.
  static const avatarBackground = Color(0xFF243642);
}

final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: AppColors.background,
  fontFamily: 'Roboto', // Material 3 default — no google_fonts needed.
  colorScheme: const ColorScheme.dark(
    background: AppColors.background,
    primary: AppColors.primary,
    onPrimary: AppColors.onPrimary,
    secondary: AppColors.secondary,
    surface: AppColors.surface,
    onSurface: AppColors.onSurface,
    onSurfaceVariant: AppColors.onSurfaceVariant,
    outline: AppColors.outline,
  ),
  textTheme: const TextTheme(
    // Heading — screen titles, item name on Item Detail.
    headlineSmall: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: AppColors.onSurface,
    ),
    // Subheading — section labels ("Active Loans", "History").
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: AppColors.onSurface,
    ),
    // Body — notes, form labels, card details.
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: AppColors.onSurface,
    ),
    // Caption — due dates, days-out counters, helper text.
    labelSmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      color: AppColors.onSurfaceVariant,
    ),
  ),
  cardTheme: CardThemeData(
    color: AppColors.surface,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: const BorderSide(color: AppColors.outline),
    ),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.onPrimary,
    ),
  ),
);

/// The navy→plum gradient behind every screen (Design System, section A).
const backgroundGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [AppColors.background, AppColors.backgroundGradientEnd],
);
