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
}
