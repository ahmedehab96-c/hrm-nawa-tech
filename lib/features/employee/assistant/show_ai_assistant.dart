import 'package:flutter/material.dart';
import 'package:hrm_saas/core/widgets/responsive_helper.dart';
import 'package:hrm_saas/features/employee/assistant/ai_assistant_panel.dart';
import 'package:hrm_saas/features/employee/assistant/ai_assistant_service.dart';
import 'package:hrm_saas/l10n/app_strings.dart';

/// Opens the employee AI assistant when [AiAssistantService.featureEnabled].
/// Phones get a bottom sheet; tablets/desktop get a centered dialog.
void showAiAssistantDialog(BuildContext context) {
  if (!AiAssistantService.featureEnabled) {
    final l10n = AppStrings.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.tryAiAssistant)),
    );
    return;
  }

  final r = ResponsiveHelper.of(context);
  if (r.isMobile && !r.isLandscape) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final height = mathMinSheetHeight(context);
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: SizedBox(
            height: height,
            child: const AiAssistantPanel(),
          ),
        );
      },
    );
    return;
  }

  showDialog<void>(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: r.horizontalPadding,
        vertical: r.verticalPadding,
      ),
      child: const AiAssistantPanel(),
    ),
  );
}

double mathMinSheetHeight(BuildContext context) {
  final r = ResponsiveHelper.of(context);
  return r.dialogMaxHeight(fraction: 0.92);
}
