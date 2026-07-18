import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_result.dart';
import 'package:hrm_saas/features/employee/auth/data/auth_repository.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/text_direction_helper.dart';
import '../../../core/widgets/hrm_logo.dart';
import '../../../core/widgets/responsive_page.dart';
import '../../../l10n/app_strings.dart';

class EmployeeForgotPasswordScreen extends StatefulWidget {
  const EmployeeForgotPasswordScreen({super.key});

  @override
  State<EmployeeForgotPasswordScreen> createState() => _EmployeeForgotPasswordScreenState();
}

class _EmployeeForgotPasswordScreenState extends State<EmployeeForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _sent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppStrings.of(context);

    return Directionality(
      textDirection: textDirectionForContext(context),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/login'),
          ),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            context.responsive.horizontalPadding,
            0,
            context.responsive.horizontalPadding,
            32,
          ).add(EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom)),
          child: ResponsiveFormFrame(
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(child: NawaTechFullLogo()),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: _sent
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Icon(Icons.mark_email_read_outlined, size: 48, color: AppColors.primary),
                          const SizedBox(height: 16),
                          Text(l10n.resetLinkSent, style: AppTypography.h2, textAlign: TextAlign.center),
                          const SizedBox(height: 8),
                          Text(
                            l10n.resetLinkSentBody,
                            style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          FilledButton(
                            onPressed: () => context.go('/login'),
                            child: Text(l10n.login),
                          ),
                        ],
                      )
                    : Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(l10n.forgotPasswordTitle, style: AppTypography.h1),
                            const SizedBox(height: 8),
                            Text(
                              l10n.forgotPasswordBody,
                              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 24),
                            TextFormField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                labelText: l10n.email,
                                prefixIcon: const Icon(Icons.email_outlined),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) => v?.isEmpty ?? true ? l10n.enterEmail : null,
                            ),
                            const SizedBox(height: 24),
                            FilledButton(
                              onPressed: _isLoading
                                  ? null
                                  : () async {
                                      if (!(_formKey.currentState?.validate() ?? false)) return;
                                      setState(() => _isLoading = true);
                                      final result = await AuthRepository.forgotPassword(
                                        _emailController.text.trim(),
                                      );
                                      if (!mounted) return;
                                      setState(() => _isLoading = false);
                                      if (!context.mounted) return;
                                      if (result is ApiSuccess<String>) {
                                        setState(() => _sent = true);
                                      } else if (result is ApiFailure<String>) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(result.message),
                                            backgroundColor: AppColors.error,
                                          ),
                                        );
                                      }
                                    },
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 22,
                                      width: 22,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    )
                                  : Text(l10n.sendResetLink),
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
          ),
        ),
      ),
    );
  }
}
