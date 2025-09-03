import 'package:flutter/material.dart';

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: false,
    fontFamily: 'Quicksand',
    colorScheme: scoutQuestColorScheme,
  );
}

const scoutQuestColorScheme = ColorScheme(
  primary: ScoutQuestColors.primaryAction,
  secondary: ScoutQuestColors.secondaryAction,
  surface: ScoutQuestColors.primaryBackground,
  error: Colors.red, // Customize as needed
  onPrimary: ScoutQuestColors.primaryText,
  onSecondary: ScoutQuestColors.secondaryText,
  onSurface: ScoutQuestColors.primaryText,
  onError: Colors.white, // Customize as needed
  brightness:
      Brightness.light, // You can set it to Brightness.dark for a dark theme
);

extension ScoutQuestColors on Colors {
  static const Color primaryBackground = Color(0xFF001017);
  static const Color primaryText = Color(0xFFF8F8F8);
  static const Color primaryAction = Color(0xFFF54E00);

  static const Color secondaryBackground = Color(0xFF9EE9E4);
  static const Color secondaryText = Color(0xFF001017);
  static const Color secondaryAction = Color(0xFFD4F553);

  static const Color accentBackground = Color(0xFFD984D9);
  static const Color accentText = Color(0xFF001017);
  static const Color accentAction = Color(0xFFF54E00);
}

// Font sizes based on clue_detail_screen usage
extension ScoutQuestFontSizes on TextStyle {
  static const double headerLarge = 26.0; // Clue label
  static const double headerMedium = 24.0; // Modal titles, input decoration
  static const double headerSmall = 22.0; // Dialog titles

  static const double bodyLarge =
      20.0; // Hint preview, draggable items, content
  static const double bodyMedium = 19.0; // "I need a hint!" button
  static const double bodyRegular = 18.0; // Hint text, default text
  static const double bodySmall = 16.0; // Dialog content, buttons

  static const double inputLarge = 24.0; // Text field input
  static const double buttonLarge = 24.0; // Submit buttons
  static const double buttonMedium = 20.0; // Back to Quest button
  static const double buttonSmall = 16.0; // Cancel, Accept Penalty buttons
}

// default input decoration
const InputDecoration defaultInputDecoration = InputDecoration(
  labelStyle: TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: ScoutQuestFontSizes.headerMedium,
  ),
  hintStyle: TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: ScoutQuestFontSizes.headerMedium,
  ),
  border: OutlineInputBorder(),
  enabledBorder: OutlineInputBorder(
    borderSide:
        BorderSide(color: Colors.black, width: 1.0), // Define border style
  ),
);
