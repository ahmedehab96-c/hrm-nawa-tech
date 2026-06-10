import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_result.dart';
import '../../../core/auth/user_role.dart';
import '../../../core/repositories/auth_repository.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/text_direction_helper.dart';
import '../../../core/widgets/hrm_logo.dart';
import '../../../l10n/app_localizations.dart';

class EmployeeLoginScreen extends StatefulWidget {
  const EmployeeLoginScreen({super.key});

  @override
  State<EmployeeLoginScreen> createState() => _EmployeeLoginScreenState();
}

class _EmployeeLoginScreenState extends State<EmployeeLoginScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _logoScale;
  late final Animation<Offset> _formSlide;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _pressLogin = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.9, curve: Curves.easeOut),
    );
    _logoScale = Tween<double>(begin: 0.88, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.1, 0.8, curve: Curves.easeOutBack),
      ),
    );
    _formSlide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
      ),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Directionality(
      textDirection: textDirectionForContext(context),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: FadeTransition(
          opacity: _fade,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Brand header ─────────────────────────────────────────
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      stops: [0.0, 0.55, 1.0],
                      colors: [
                        Color(0xFF0C1731),
                        Color(0xFF152244),
                        Color(0xFF0B5E54),
                      ],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft:  Radius.circular(36),
                      bottomRight: Radius.circular(36),
                    ),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
                      child: ScaleTransition(
                        scale: _logoScale,
                        child: const NawaTechFullLogo(onDark: true),
                      ),
                    ),
                  ),
                ),
                // ── Login form card ───────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                  child: SlideTransition(
                    position: _formSlide,
                    child: Container(
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
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _Reveal(
                              delayMs: 50,
                              child: Text(
                                l10n.login,
                                style: AppTypography.h1,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _Reveal(
                              delayMs: 90,
                              child: Text(
                                l10n.employeeAppSubtitle,
                                style: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            _Reveal(
                              delayMs: 130,
                              child: Text(
                                l10n.employeeLoginCredentialsHint,
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 28),
                            _Reveal(
                              delayMs: 180,
                              child: TextFormField(
                                controller: _emailController,
                                decoration: InputDecoration(
                                  labelText: l10n.email,
                                  prefixIcon: const Icon(Icons.email_outlined),
                                ),
                                keyboardType: TextInputType.emailAddress,
                                validator: (v) => v?.isEmpty ?? true ? l10n.enterEmail : null,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _Reveal(
                              delayMs: 240,
                              child: TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                decoration: InputDecoration(
                                  labelText: l10n.password,
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                    ),
                                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                  ),
                                ),
                                validator: (v) => v?.isEmpty ?? true ? l10n.enterPassword : null,
                              ),
                            ),
                            const SizedBox(height: 28),
                            _Reveal(
                              delayMs: 300,
                              child: Listener(
                                onPointerDown: (_) => setState(() => _pressLogin = true),
                                onPointerUp: (_) => setState(() => _pressLogin = false),
                                child: AnimatedScale(
                                  duration: const Duration(milliseconds: 130),
                                  scale: _pressLogin ? 0.975 : 1.0,
                                  child: FilledButton(
                                    onPressed: _isLoading
                                        ? null
                                        : () async {
                                            if (!(_formKey.currentState?.validate() ?? false)) return;
                                            setState(() => _isLoading = true);
                                            final result = await AuthRepository.login(
                                              _emailController.text.trim(),
                                              _passwordController.text,
                                              surface: LoginSurface.mobileEmployee,
                                            );
                                            if (!mounted) return;
                                            setState(() => _isLoading = false);
                                            if (!mounted) return;
                                            if (result is ApiSuccess<Map<String, dynamic>>) {
                                              // ignore: use_build_context_synchronously
                                              context.go('/employee');
                                            } else if (result is ApiFailure<Map<String, dynamic>>) {
                                              // ignore: use_build_context_synchronously
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text(result.message),
                                                  backgroundColor: AppColors.error,
                                                ),
                                              );
                                            }
                                          },
                                    style: FilledButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                    ),
                                    child: _isLoading
                                        ? const SizedBox(
                                            height: 22,
                                            width: 22,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : Text(l10n.login),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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

class _Reveal extends StatefulWidget {
  const _Reveal({
    required this.child,
    required this.delayMs,
  });

  final Widget child;
  final int delayMs;

  @override
  State<_Reveal> createState() => _RevealState();
}

class _RevealState extends State<_Reveal> {
  bool _show = false;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(Duration(milliseconds: widget.delayMs), () {
      if (!mounted) return;
      setState(() => _show = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOut,
      opacity: _show ? 1 : 0,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
        offset: _show ? Offset.zero : const Offset(0, 0.05),
        child: widget.child,
      ),
    );
  }
}

