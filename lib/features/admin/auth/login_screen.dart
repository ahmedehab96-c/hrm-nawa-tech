import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/text_direction_helper.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/widgets/hrm_logo.dart';
import '../../../core/repositories/auth_repository.dart';
import '../../../core/api/api_result.dart';
import '../../../core/auth/user_role.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoFloat;
  late final Animation<Offset> _leftSlide;
  late final Animation<Offset> _rightSlide;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _hoverLogin = false;
  bool _pressLogin = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.9, curve: Curves.easeOut),
    );
    _logoScale = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.1, 0.8, curve: Curves.easeOutBack),
      ),
    );
    _logoFloat = Tween<double>(begin: -4, end: 4).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.45, 1.0, curve: Curves.easeInOut),
      ),
    );
    _leftSlide = Tween<Offset>(begin: const Offset(-0.12, 0), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.05, 0.75, curve: Curves.easeOutCubic),
      ),
    );
    _rightSlide = Tween<Offset>(begin: const Offset(0.12, 0), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.15, 0.9, curve: Curves.easeOutCubic),
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
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.background,
                    AppColors.primary.withValues(alpha: 0.08),
                    AppColors.secondary.withValues(alpha: 0.07),
                  ],
                ),
              ),
            ),
            Positioned(
              top: -80,
              left: -80,
              child: _DecorCircle(
                size: 220,
                color: AppColors.primary.withValues(alpha: 0.20),
              ),
            ),
            Positioned(
              bottom: -90,
              right: -70,
              child: _DecorCircle(
                size: 260,
                color: AppColors.secondary.withValues(alpha: 0.14),
              ),
            ),
            FadeTransition(
              opacity: _fade,
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: SlideTransition(
                      position: _leftSlide,
                      child: Container(
                        margin: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF0F1E45), Color(0xFF1A2B5E), Color(0xFF0E7A70)],
                          ),
                          borderRadius: BorderRadius.circular(26),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1A2B5E).withValues(alpha: 0.45),
                              blurRadius: 36,
                              offset: const Offset(0, 16),
                            ),
                          ],
                        ),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 48),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ScaleTransition(
                                scale: _logoScale,
                                child: AnimatedBuilder(
                                  animation: _controller,
                                  builder: (context, child) => Transform.translate(
                                    offset: Offset(0, _logoFloat.value),
                                    child: child,
                                  ),
                                  child: const NawaTechFullLogo(onDark: true),
                                ),
                              ),
                              const SizedBox(height: 40),
                              Text(
                                l10n.loginBrandingTitle,
                                textAlign: TextAlign.center,
                                style: AppTypography.h3.copyWith(color: Colors.white),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                l10n.loginBrandingSubtitle,
                                textAlign: TextAlign.center,
                                style: AppTypography.bodyMedium.copyWith(
                                  color: Colors.white.withValues(alpha: 0.80),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: SlideTransition(
                      position: _rightSlide,
                      child: Center(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(48),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 430),
                            child: Container(
                              padding: const EdgeInsets.all(30),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.84),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.7)),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.textMuted.withValues(alpha: 0.22),
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
                                    _StaggeredReveal(
                                      delayMs: 40,
                                      child: Text(l10n.login, style: AppTypography.h1),
                                    ),
                                    const SizedBox(height: 8),
                                    _StaggeredReveal(
                                      delayMs: 80,
                                      child: Text(
                                        l10n.loginFormSubtitle,
                                        style: AppTypography.bodyMedium.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 26),
                                    _StaggeredReveal(
                                      delayMs: 120,
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
                                    _StaggeredReveal(
                                      delayMs: 170,
                                      child: TextFormField(
                                        controller: _passwordController,
                                        obscureText: _obscurePassword,
                                        decoration: InputDecoration(
                                          labelText: l10n.password,
                                          prefixIcon: const Icon(Icons.lock_outline),
                                          suffixIcon: IconButton(
                                            icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                          ),
                                        ),
                                        validator: (v) => v?.isEmpty ?? true ? l10n.enterPassword : null,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    _StaggeredReveal(
                                      delayMs: 220,
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: TextButton(
                                          onPressed: () => context.push('/forgot-password'),
                                          child: Text(l10n.forgotPassword),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    _StaggeredReveal(
                                      delayMs: 270,
                                      child: MouseRegion(
                                        onEnter: (_) => setState(() => _hoverLogin = true),
                                        onExit: (_) => setState(() {
                                          _hoverLogin = false;
                                          _pressLogin = false;
                                        }),
                                        child: Listener(
                                          onPointerDown: (_) => setState(() => _pressLogin = true),
                                          onPointerUp: (_) => setState(() => _pressLogin = false),
                                          child: AnimatedScale(
                                            duration: const Duration(milliseconds: 140),
                                            scale: _pressLogin
                                                ? 0.975
                                                : (_hoverLogin ? 1.018 : 1.0),
                                            child: FilledButton(
                                              onPressed: _isLoading
                                                  ? null
                                                  : () async {
                                                      if (_formKey.currentState?.validate() ?? false) {
                                                        setState(() => _isLoading = true);
                                                        final result = await AuthRepository.login(
                                                          _emailController.text.trim(),
                                                          _passwordController.text,
                                                          surface: LoginSurface.webAdmin,
                                                        );
                                                        if (!mounted) return;
                                                        setState(() => _isLoading = false);
                                                        if (!mounted) return;
                                                        if (result is ApiSuccess) {
                                                          // ignore: use_build_context_synchronously
                                                          context.go('/admin');
                                                        } else {
                                                          // ignore: use_build_context_synchronously
                                                          ScaffoldMessenger.of(context).showSnackBar(
                                                            SnackBar(
                                                              content: Text((result as ApiFailure).message),
                                                              backgroundColor: AppColors.error,
                                                            ),
                                                          );
                                                        }
                                                      }
                                                    },
                                              child: _isLoading
                                                  ? const SizedBox(
                                                      height: 20,
                                                      width: 20,
                                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                                    )
                                                  : Text(l10n.login),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    _StaggeredReveal(
                                      delayMs: 320,
                                      child: OutlinedButton(
                                        onPressed: () => context.push('/register'),
                                        child: Text(l10n.registerCompany),
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
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DecorCircle extends StatelessWidget {
  const _DecorCircle({
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
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}

class _StaggeredReveal extends StatefulWidget {
  const _StaggeredReveal({
    required this.child,
    required this.delayMs,
  });

  final Widget child;
  final int delayMs;

  @override
  State<_StaggeredReveal> createState() => _StaggeredRevealState();
}

class _StaggeredRevealState extends State<_StaggeredReveal> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(Duration(milliseconds: widget.delayMs), () {
      if (!mounted) return;
      setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      opacity: _visible ? 1 : 0,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        offset: _visible ? Offset.zero : const Offset(0, 0.04),
        child: widget.child,
      ),
    );
  }
}
