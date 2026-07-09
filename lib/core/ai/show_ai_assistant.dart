import 'package:flutter/material.dart';

import 'ai_assistant_panel.dart';

/// Opens the shared HR AI assistant chat dialog.
void showAiAssistantDialog(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (context) => const Dialog(
      backgroundColor: Colors.transparent,
      child: AiAssistantPanel(),
    ),
  );
}
