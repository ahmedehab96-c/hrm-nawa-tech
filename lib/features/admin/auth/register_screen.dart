import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_config.dart';
import '../../../core/api/api_result.dart';
import '../../../core/repositories/auth_repository.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/text_direction_helper.dart';
import '../../../core/widgets/hrm_logo.dart';
import '../../../l10n/app_strings.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _companyController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _loading = false;

  @override
  void dispose() {
    _companyController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit(AppStrings l10n) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await ApiConfig.load();
    if (!ApiConfig.useApi || ApiConfig.baseUrl == null || ApiConfig.baseUrl!.isEmpty) {
      if (!mounted) return;
      final isAr = Localizations.localeOf(context).languageCode == 'ar';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isAr
              ? 'فعّل الاتصال بالخادم من الإعدادات لتسجيل شركة جديدة'
              : 'Enable server connection in Settings to register a new company'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    setState(() => _loading = true);
    final result = await AuthRepository.register(
      companyName: _companyController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
    if (!mounted) return;
    setState(() => _loading = false);
    if (result is ApiSuccess<Map<String, dynamic>>) {
      final data = result.data;
      if (data['token'] != null) {
        context.go('/admin');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.registerSuccessServer),
            backgroundColor: AppColors.success,
          ),
        );
        context.go('/login');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text((result as ApiFailure).message),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppStrings.of(context);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Directionality(
      textDirection: textDirectionForContext(context),
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.background,
                AppColors.primary.withValues(alpha: 0.08),
              ],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: Column(
                    children: [
                      const HrmLogo(height: 56),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.textMuted.withValues(alpha: 0.18),
                              blurRadius: 24,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(l10n.registerCompany, style: AppTypography.h1),
                              const SizedBox(height: 8),
                              Text(
                                l10n.registerSubtitle,
                                style: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                isAr
                                    ? 'تجربة مجانية 14 يوم — بدون بطاقة ائتمان'
                                    : '14-day free trial — no credit card required',
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 24),
                              TextFormField(
                                controller: _companyController,
                                decoration: InputDecoration(
                                  labelText: l10n.companyName,
                                  prefixIcon: const Icon(Icons.business_outlined),
                                ),
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) {
                                    return isAr ? 'أدخل اسم الشركة' : 'Enter company name';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _emailController,
                                decoration: InputDecoration(
                                  labelText: l10n.email,
                                  prefixIcon: const Icon(Icons.email_outlined),
                                ),
                                keyboardType: TextInputType.emailAddress,
                                validator: (v) =>
                                    v == null || v.trim().isEmpty ? l10n.enterEmail : null,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                decoration: InputDecoration(
                                  labelText: l10n.password,
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  suffixIcon: IconButton(
                                    icon: Icon(_obscurePassword
                                        ? Icons.visibility_off
                                        : Icons.visibility),
                                    onPressed: () => setState(
                                        () => _obscurePassword = !_obscurePassword),
                                  ),
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty) return l10n.enterPassword;
                                  if (v.length < 8) {
                                    return isAr
                                        ? 'كلمة المرور 8 أحرف على الأقل'
                                        : 'Password must be at least 8 characters';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _confirmController,
                                obscureText: _obscureConfirm,
                                decoration: InputDecoration(
                                  labelText: isAr ? 'تأكيد كلمة المرور' : 'Confirm password',
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  suffixIcon: IconButton(
                                    icon: Icon(_obscureConfirm
                                        ? Icons.visibility_off
                                        : Icons.visibility),
                                    onPressed: () => setState(
                                        () => _obscureConfirm = !_obscureConfirm),
                                  ),
                                ),
                                validator: (v) {
                                  if (v != _passwordController.text) {
                                    return isAr
                                        ? 'كلمتا المرور غير متطابقتين'
                                        : 'Passwords do not match';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 24),
                              FilledButton(
                                onPressed: _loading ? null : () => _submit(l10n),
                                child: _loading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(isAr ? 'ابدأ التجربة المجانية' : 'Start free trial'),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    isAr ? 'لديك حساب؟' : 'Already have an account?',
                                    style: AppTypography.bodySmall,
                                  ),
                                  TextButton(
                                    onPressed: () => context.go('/login'),
                                    child: Text(l10n.login),
                                  ),
                                ],
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
          ),
        ),
      ),
    );
  }
}
