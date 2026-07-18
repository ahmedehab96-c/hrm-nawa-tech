import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_result.dart';
import '../../../core/auth/auth_session.dart';
import 'package:hrm_saas/features/employee/auth/data/auth_repository.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/text_direction_helper.dart';
import '../../../core/widgets/hrm_logo.dart';
import '../../../core/widgets/responsive_page.dart';
import '../../../l10n/app_strings.dart';

class EmployeeVerifyEmailScreen extends StatefulWidget {
  const EmployeeVerifyEmailScreen({
    super.key,
    this.verifyId,
    this.verifyHash,
    this.verifyExpires,
    this.verifySignature,
  });

  final String? verifyId;
  final String? verifyHash;
  final String? verifyExpires;
  final String? verifySignature;

  @override
  State<EmployeeVerifyEmailScreen> createState() => _EmployeeVerifyEmailScreenState();
}

class _EmployeeVerifyEmailScreenState extends State<EmployeeVerifyEmailScreen> {
  bool _isLoading = false;
  bool _sent = false;
  bool _linkVerified = false;
  String? _linkError;

  bool get _hasLinkParams =>
      (widget.verifyId?.isNotEmpty ?? false) && (widget.verifyHash?.isNotEmpty ?? false);

  @override
  void initState() {
    super.initState();
    if (_hasLinkParams) {
      _verifyFromLink();
    }
  }

  Future<void> _verifyFromLink() async {
    setState(() {
      _isLoading = true;
      _linkError = null;
    });

    final result = await AuthRepository.verifyEmailFromLink(
      id: widget.verifyId!,
      hash: widget.verifyHash!,
      expires: widget.verifyExpires,
      signature: widget.verifySignature,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (result is ApiSuccess<String>) {
        _linkVerified = true;
      } else if (result is ApiFailure<String>) {
        _linkError = result.message;
      }
    });

    if (!mounted) return;
    if (_linkVerified && AuthSession.instance.hasSession && AuthSession.instance.emailVerified) {
      context.go('/employee');
    }
  }

  Future<void> _refreshVerificationState() async {
    final result = await AuthRepository.fetchCurrentUser();
    if (!mounted) return;
    if (result is ApiSuccess<Map<String, dynamic>> && result.data['email_verified'] == true) {
      context.go('/employee');
    }
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
          actions: [
            if (AuthSession.instance.hasSession)
              TextButton(
                onPressed: () async {
                  await AuthRepository.logout();
                  if (!context.mounted) return;
                  context.go('/login');
                },
                child: Text(l10n.logout),
              ),
          ],
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      _linkVerified
                          ? Icons.verified_outlined
                          : Icons.mark_email_unread_outlined,
                      size: 48,
                      color: _linkError != null ? AppColors.error : AppColors.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _linkVerified ? l10n.verifyEmailSuccess : l10n.verifyEmailTitle,
                      style: AppTypography.h1,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isLoading && _hasLinkParams
                          ? l10n.verifyingEmail
                          : _linkError ?? (_sent ? l10n.verificationLinkSent : l10n.verifyEmailBody),
                      style: AppTypography.bodyMedium.copyWith(
                        color: _linkError != null ? AppColors.error : AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    if (_isLoading && _hasLinkParams)
                      const Center(
                        child: SizedBox(
                          height: 28,
                          width: 28,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    else ...[
                      if (!_linkVerified)
                        FilledButton(
                          onPressed: _isLoading
                              ? null
                              : () async {
                                  setState(() => _isLoading = true);
                                  final result = await AuthRepository.resendVerification();
                                  if (!mounted) return;
                                  setState(() {
                                    _isLoading = false;
                                    if (result is ApiSuccess<String>) _sent = true;
                                  });
                                  if (!context.mounted) return;
                                  if (result is ApiFailure<String>) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(result.message),
                                        backgroundColor: AppColors.error,
                                      ),
                                    );
                                  }
                                },
                          child: Text(l10n.resendVerificationLink),
                        ),
                      if (!_linkVerified) const SizedBox(height: 12),
                      if (_linkVerified)
                        FilledButton(
                          onPressed: () => context.go(
                            AuthSession.instance.hasSession ? '/employee' : '/login',
                          ),
                          child: Text(AuthSession.instance.hasSession ? l10n.verifyContinueButton : l10n.login),
                        )
                      else
                        OutlinedButton(
                          onPressed: _refreshVerificationState,
                          child: Text(l10n.verifyContinueButton),
                        ),
                    ],
                  ],
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
