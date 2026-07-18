import 'package:flutter/material.dart';
import 'package:hrm_saas/features/employee/assistant/ai_assistant_panel.dart';
import 'package:hrm_saas/features/employee/assistant/ai_assistant_service.dart';
import 'package:hrm_saas/l10n/app_strings.dart';

/// Opens the employee AI assistant when [AiAssistantService.featureEnabled].
void showAiAssistantDialog(BuildContext context) {
  if (!AiAssistantService.featureEnabled) {
    final l10n = AppStrings.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.tryAiAssistant)),
    );
    return;
  }

  showDialog<void>(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
      child: const AiAssistantPanel(),
    ),
  );
}
