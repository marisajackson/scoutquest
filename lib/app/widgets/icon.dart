import 'package:flutter/material.dart';

class IconUtil {
  static IconData getIconForClueType(String icon) {
    switch (icon) {
      case 'Text Clue':
        return Icons.text_fields;
      case 'Image Clue':
        return Icons.image;
      case 'Audio Clue':
        return Icons.audiotrack;
      default:
        return Icons
            .text_fields; // Default to text_fields icon if the specified icon is not found
    }
  }

  static IconData getIconFromString(String icon) {
    switch (icon) {
      case 'music_note':
        return Icons.music_note;
      case 'park':
        return Icons.park;
      case 'water':
        return Icons.water;
      case 'account_balance':
        return Icons.account_balance;
      case 'flight':
        return Icons.flight;
      case 'pets':
        return Icons.pets;
      case 'cake':
        return Icons.cake;
      case 'calendar_month':
        return Icons.calendar_month;
      default:
        return Icons.text_fields;
    }
  }
}
