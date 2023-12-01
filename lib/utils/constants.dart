import 'package:flutter/material.dart';

ThemeData buildAppTheme() {
  return ThemeData(
    fontFamily: 'Quicksand',
    colorScheme: scoutQuestColorScheme,
  );
}

const scoutQuestColorScheme = ColorScheme(
  primary: ScoutQuestColors.primaryAction,
  secondary: ScoutQuestColors.secondaryAction,
  background: ScoutQuestColors.primaryBackground,
  surface: ScoutQuestColors.primaryBackground,
  error: Colors.red, // Customize as needed
  onPrimary: ScoutQuestColors.primaryText,
  onSecondary: ScoutQuestColors.secondaryText,
  onBackground: ScoutQuestColors.primaryText,
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

// default input decoration
const InputDecoration defaultInputDecoration = InputDecoration(
  labelStyle: TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 24.0,
  ),
  hintStyle: TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 24.0,
  ),
  border: OutlineInputBorder(),
  enabledBorder: OutlineInputBorder(
    borderSide:
        BorderSide(color: Colors.black, width: 1.0), // Define border style
  ),
);
