import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:go_router/go_router.dart';

import 'deep_link_paths.dart';

/// Listens for password-reset deep links and navigates the app router.
class DeepLinkHandler {
  DeepLinkHandler(this._router);

  final GoRouter _router;
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _subscription;

  Future<void> init() async {
    final initial = await _appLinks.getInitialLink();
    if (initial != null) {
      _navigate(initial);
    }

    _subscription = _appLinks.uriLinkStream.listen(_navigate);
  }

  void _navigate(Uri uri) {
    final path = DeepLinkPaths.fromUri(uri);
    if (path != null) {
      _router.go(path);
    }
  }

  void dispose() {
    unawaited(_subscription?.cancel());
    _subscription = null;
  }
}
