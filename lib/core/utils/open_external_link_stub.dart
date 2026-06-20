import 'package:flutter/services.dart';

Future<void> openExternalLinkImpl(String url) async {
  await Clipboard.setData(ClipboardData(text: url));
}
