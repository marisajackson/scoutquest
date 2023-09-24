import 'package:flutter/material.dart';

class IconUtil {
  static IconData getIconForClueType(String icon) {
    switch (icon) {
      case 'Text Clue':
        return Icons.text_fields;
      case 'Image Clue':
        return Icons.image;
      // Add more cases for other icons as needed
      default:
        return Icons
            .text_fields; // Default to text_fields icon if the specified icon is not found
    }
  }
}
