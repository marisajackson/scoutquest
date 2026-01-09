// lib/deep_links.dart
import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';

import 'utils/logger.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Splash can check this to avoid running its delayed navigation
/// after a deep link already navigated.
bool deepLinkNavigated = false;

class DeepLinkService {
  DeepLinkService._();
  static final DeepLinkService instance = DeepLinkService._();

  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _sub;

  Uri? _initialUri;
  bool _handledInitial = false;

  Future<void> init() async {
    // Cold start (terminated -> opened via link)
    _initialUri = await _appLinks.getInitialLink();
    if (_initialUri != null && !_handledInitial) {
      _handledInitial = true;
      _handleUri(_initialUri!);
    }

    // Warm start (app already running)
    _sub = _appLinks.uriLinkStream.listen(
      (Uri uri) {
        // Avoid re-processing the same initial URI if it gets emitted again
        if (_handledInitial &&
            _initialUri != null &&
            uri.toString() == _initialUri.toString()) {
          return;
        }

        _handleUri(uri);
      },
      onError: (Object err, StackTrace st) {
        Logger.log('Deep link stream error: $err');
      },
    );
  }

  void dispose() {
    _sub?.cancel();
    _sub = null;
  }

  void _handleUri(Uri uri) {
    Logger.log('Deep link received: $uri');

    final segments = uri.pathSegments;
    if (segments.isEmpty) return;

    // Right now you only care about: /quests (and /quests/anything)
    if (segments.first == 'quests') {
      Logger.log('Navigating to quests screen');

      deepLinkNavigated = true;

      // Replace the whole stack so Splash can't keep navigating later.
      navigatorKey.currentState?.pushNamedAndRemoveUntil(
        '/quests',
        (Route<dynamic> route) => false,
      );
      return;
    }

    // Optional default: send unknown links to quests too
    Logger.log('Unknown deep link path; sending to /quests');
    deepLinkNavigated = true;
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      '/quests',
      (Route<dynamic> route) => false,
    );
  }
}
