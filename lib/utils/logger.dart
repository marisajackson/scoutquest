// ignore_for_file: avoid_print

import 'package:flutter/foundation.dart';

class Logger {
  static void log(String message) {
    if (kReleaseMode) {
      // Log to a framework or service (e.g., Firebase, Sentry, etc.)
      // Implement the logic to send logs to your desired framework here.
      // Example: FirebaseCrashlytics.instance.log(message);
    } else {
      print(message);
    }
  }
}
