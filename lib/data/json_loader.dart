import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:scoutquest/utils/logger.dart';

Future<List?> loadJsonFromAsset(String assetPath) async {
  try {
    final jsonString = await rootBundle.loadString(assetPath);

    return json.decode(jsonString) as List;
  } catch (e) {
    Logger.log('Error loading JSON from asset: $e');
    return null;
  }
}
