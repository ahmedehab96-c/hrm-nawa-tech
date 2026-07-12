import 'open_external_link_stub.dart'
    if (dart.library.js_interop) 'open_external_link_web.dart';

Future<void> openExternalLink(String url) => openExternalLinkImpl(url);
