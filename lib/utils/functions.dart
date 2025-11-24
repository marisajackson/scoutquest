import 'package:flutter/material.dart';

Color colorFromHex(String? hex, {Color fallback = Colors.white}) {
  if (hex == null) return fallback;
  try {
    final h = hex.replaceAll('#', '');
    if (h.length == 6) return Color(int.parse('0xFF$h'));
    if (h.length == 8) return Color(int.parse('0x$h')); // already has alpha
  } catch (_) {}
  return fallback;
}
