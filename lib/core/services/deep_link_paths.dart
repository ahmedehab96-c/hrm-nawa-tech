/// Maps incoming URIs (custom scheme or https) to in-app GoRouter paths.
class DeepLinkPaths {
  const DeepLinkPaths._();

  static String? fromUri(Uri uri) {
    final reset = _resetPasswordPath(uri);
    if (reset != null) {
      return reset;
    }

    return _verifyEmailPath(uri);
  }

  static String? _resetPasswordPath(Uri uri) {
    if (!_isResetPassword(uri)) {
      return null;
    }

    final token = uri.queryParameters['token']?.trim();
    final email = uri.queryParameters['email']?.trim();
    if (token == null || token.isEmpty || email == null || email.isEmpty) {
      return null;
    }

    return Uri(
      path: '/reset-password',
      queryParameters: {'token': token, 'email': email},
    ).toString();
  }

  static String? _verifyEmailPath(Uri uri) {
    String? id;
    String? hash;

    if (uri.host == 'verify-email') {
      id = uri.queryParameters['id']?.trim();
      hash = uri.queryParameters['hash']?.trim();
    } else {
      final match = RegExp(r'/email/verify/(\d+)/([^/?#]+)').firstMatch(uri.path);
      if (match != null) {
        id = match.group(1);
        hash = match.group(2);
      }
    }

    if (id == null || id.isEmpty || hash == null || hash.isEmpty) {
      return null;
    }

    final params = <String, String>{
      'id': id,
      'hash': hash,
    };

    final expires = uri.queryParameters['expires']?.trim();
    final signature = uri.queryParameters['signature']?.trim();
    if (expires != null && expires.isNotEmpty) {
      params['expires'] = expires;
    }
    if (signature != null && signature.isNotEmpty) {
      params['signature'] = signature;
    }

    return Uri(path: '/verify-email', queryParameters: params).toString();
  }

  static bool _isResetPassword(Uri uri) {
    if (uri.path == '/reset-password' || uri.path.endsWith('/reset-password')) {
      return true;
    }

    return uri.host == 'reset-password';
  }
}
