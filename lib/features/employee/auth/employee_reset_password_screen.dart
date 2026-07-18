import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_result.dart';
import 'package:hrm_saas/features/employee/auth/data/auth_repository.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/text_direction_helper.dart';
import '../../../core/widgets/hrm_logo.dart';
import '../../../core/widgets/responsive_page.dart';
import '../../../l10n/app_strings.dart';

class EmployeeResetPasswordScreen extends StatefulWidget {
  const EmployeeResetPasswordScreen({
    super.key,
    required this.token,
    required this.email,
  });

  final String token;
  final String email;

  @override
  State<EmployeeResetPasswordScreen> createState() => _EmployeeResetPasswordScreenState();
}

class _EmployeeResetPasswordScreenState extends State<EmployeeResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;
  bool _done = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppStrings.of(context);
    final hasToken = widget.token.isNotEmpty && widget.email.isNotEmpty;

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
                child: !hasToken
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Icon(Icons.link_off_outlined, size: 48, color: AppColors.error),
                          const SizedBox(height: 16),
                          Text(l10n.resetLinkInvalid, style: AppTypography.h2, textAlign: TextAlign.center),
                          const SizedBox(height: 8),
                          Text(
                            l10n.resetLinkInvalidBody,
                            style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          FilledButton(
                            onPressed: () => context.go('/forgot-password'),
                            child: Text(l10n.forgotPassword),
                          ),
                        ],
                      )
                    : _done
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Icon(Icons.check_circle_outline, size: 48, color: AppColors.primary),
                              const SizedBox(height: 16),
                              Text(l10n.passwordResetSuccess, style: AppTypography.h2, textAlign: TextAlign.center),
                              const SizedBox(height: 8),
                              Text(
                                l10n.passwordResetSuccessBody,
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
                                Text(l10n.resetPasswordTitle, style: AppTypography.h1),
                                const SizedBox(height: 8),
                                Text(
                                  l10n.resetPasswordBody(widget.email),
                                  style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                                ),
                                const SizedBox(height: 24),
                                TextFormField(
                                  initialValue: widget.email,
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    labelText: l10n.email,
                                    prefixIcon: const Icon(Icons.email_outlined),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  decoration: InputDecoration(
                                    labelText: l10n.newPassword,
                                    prefixIcon: const Icon(Icons.lock_outline),
                                    suffixIcon: IconButton(
                                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                    ),
                                  ),
                                  validator: (v) {
                                    if (v == null || v.length < 8) {
                                      return l10n.passwordMinLength;
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _confirmController,
                                  obscureText: _obscureConfirm,
                                  decoration: InputDecoration(
                                    labelText: l10n.confirmNewPassword,
                                    prefixIcon: const Icon(Icons.lock_outline),
                                    suffixIcon: IconButton(
                                      icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility),
                                      onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                                    ),
                                  ),
                                  validator: (v) {
                                    if (v != _passwordController.text) {
                                      return l10n.passwordsDoNotMatch;
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 24),
                                FilledButton(
                                  onPressed: _isLoading ? null : _submit,
                                  child: _isLoading
                                      ? const SizedBox(
                                          height: 22,
                                          width: 22,
                                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                        )
                                      : Text(l10n.saveNewPassword),
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

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);
    final result = await AuthRepository.resetPassword(
      email: widget.email,
      token: widget.token,
      password: _passwordController.text,
      passwordConfirmation: _confirmController.text,
    );
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result is ApiSuccess<String>) {
      setState(() => _done = true);
      return;
    }

    if (result is ApiFailure<String>) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message), backgroundColor: AppColors.error),
      );
    }
  }
}
