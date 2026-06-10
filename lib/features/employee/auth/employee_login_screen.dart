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
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.14),
                    AppColors.background,
                    AppColors.secondary.withValues(alpha: 0.10),
                  ],
                ),
              ),
            ),
            Positioned(
              top: -70,
              right: -50,
              child: _MobileDecor(
                size: 170,
                color: AppColors.primary.withValues(alpha: 0.20),
              ),
            ),
            Positioned(
              bottom: -90,
              left: -60,
              child: _MobileDecor(
                size: 220,
                color: AppColors.secondary.withValues(alpha: 0.14),
              ),
            ),
            SafeArea(
              child: FadeTransition(
                opacity: _fade,
                child: SlideTransition(
                  position: _formSlide,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.88),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.76)),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.textMuted.withValues(alpha: 0.20),
                            blurRadius: 22,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 20),
                            ScaleTransition(
                              scale: _logoScale,
                              child: Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.identity()
                                  ..setEntry(3, 2, 0.002)
                                  ..rotateX(0.03)
                                  ..rotateY(-0.05),
                                child: const HrmLogo(height: 78, showTagline: true),
                              ),
                            ),
                            const SizedBox(height: 36),
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
              ),
            ),
          ],
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

class _MobileDecor extends StatelessWidget {
  const _MobileDecor({
    required this.size,
    required this.color,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
