import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../../l10n/app_localizations.dart';

class HrmLogo extends StatelessWidget {
  const HrmLogo({
    super.key,
    this.height = 48,
    this.showTagline = false,
    this.taglineColor,
    this.onDark = false,
  });

  final double height;
  final bool showTagline;
  final Color? taglineColor;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _LogoMark(size: height),
        const SizedBox(width: 10),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nawa Tech',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: height * 0.26,
                fontWeight: FontWeight.w600,
                color: onDark
                    ? Colors.white.withValues(alpha: 0.7)
                    : AppColors.primaryLight,
                letterSpacing: 0.5,
                height: 1,
              ),
            ),
            Text(
              'HRM',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: height * 0.52,
                fontWeight: FontWeight.w900,
                color: onDark ? Colors.white : AppColors.primary,
                letterSpacing: -0.5,
                height: 1,
              ),
            ),
            if (showTagline)
              Text(
                AppLocalizations.of(context)?.appTagline ?? 'راحة الإدارة',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: height * 0.22,
                  fontWeight: FontWeight.w500,
                  color: taglineColor ??
                      (onDark
                          ? Colors.white.withValues(alpha: 0.65)
                          : AppColors.textSecondary),
                  letterSpacing: 0.2,
                  height: 1.2,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

// ─── Logo Mark — الشعار الرمزي ────────────────────────────────────────────────

class _LogoMark extends StatelessWidget {
  const _LogoMark({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        'assets/images/hrm_logo.png',
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => SizedBox(
          width: size,
          height: size,
          child: CustomPaint(painter: _LogoPainter()),
        ),
      ),
    );
  }
}

// ─── Fallback painter (used if image fails to load) ──────────────────────────

class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;

    final bgPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF2563EB),
          const Color(0xFF1D4ED8),
        ],
      ).createShader(Rect.fromLTWH(0, 0, s, s));

    final bgRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, s, s),
      Radius.circular(s * 0.22),
    );
    canvas.drawRRect(bgRect, bgPaint);

    final shinePaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.6, -0.6),
        radius: 0.8,
        colors: [
          Colors.white.withValues(alpha: 0.18),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, s, s));
    canvas.drawRRect(bgRect, shinePaint);

    final personPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    _drawPerson(canvas, personPaint, s * 0.5, s * 0.5, s * 0.18);

    final sidePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.65)
      ..style = PaintingStyle.fill;
    _drawPerson(canvas, sidePaint, s * 0.26, s * 0.54, s * 0.13);
    _drawPerson(canvas, sidePaint, s * 0.74, s * 0.54, s * 0.13);

    final barPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;

    final barRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(s * 0.14, s * 0.76, s * 0.72, s * 0.06),
      const Radius.circular(3),
    );
    canvas.drawRRect(barRRect, barPaint);
  }

  void _drawPerson(Canvas canvas, Paint paint, double cx, double cy, double scale) {
    canvas.drawCircle(Offset(cx, cy - scale * 0.9), scale * 0.38, paint);

    final bodyPath = Path();
    bodyPath.moveTo(cx - scale * 0.72, cy + scale * 0.58);
    bodyPath.quadraticBezierTo(
      cx,
      cy + scale * 0.06,
      cx + scale * 0.72,
      cy + scale * 0.58,
    );
    bodyPath.close();
    canvas.drawPath(bodyPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── Compact icon-only variant (for collapsed sidebar) ─────────────────────

class HrmLogoIcon extends StatelessWidget {
  const HrmLogoIcon({super.key, this.size = 36});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        'assets/images/hrm_logo.png',
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => SizedBox(
          width: size,
          height: size,
          child: CustomPaint(painter: _LogoPainter()),
        ),
      ),
    );
  }
}

// ─── Animated logo for splash ─────────────────────────────────────────────────

class HrmLogoAnimated extends StatefulWidget {
  const HrmLogoAnimated({super.key, this.size = 80, this.onDark = true});

  final double size;
  final bool onDark;

  @override
  State<HrmLogoAnimated> createState() => _HrmLogoAnimatedState();
}

class _HrmLogoAnimatedState extends State<HrmLogoAnimated>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _scale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: ScaleTransition(
        scale: _scale,
        child: HrmLogo(
          height: widget.size,
          showTagline: true,
          onDark: widget.onDark,
          taglineColor: widget.onDark
              ? Colors.white.withValues(alpha: 0.7)
              : AppColors.textSecondary,
        ),
      ),
    );
  }
}

// ─── Rotating accent ring (decorative) ────────────────────────────────────────

class HrmLogoWithRing extends StatefulWidget {
  const HrmLogoWithRing({super.key, this.size = 100});

  final double size;

  @override
  State<HrmLogoWithRing> createState() => _HrmLogoWithRingState();
}

class _HrmLogoWithRingState extends State<HrmLogoWithRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size * 1.3,
      height: widget.size * 1.3,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _ctrl,
            builder: (_, _) => Transform.rotate(
              angle: _ctrl.value * 2 * math.pi,
              child: CustomPaint(
                size: Size(widget.size * 1.3, widget.size * 1.3),
                painter: _RingPainter(),
              ),
            ),
          ),
          _LogoMark(size: widget.size),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..shader = SweepGradient(
        colors: [
          Colors.white.withValues(alpha: 0.0),
          Colors.white.withValues(alpha: 0.6),
          Colors.white.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, paint);

    final dotPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(center.dx + radius, center.dy),
      3,
      dotPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
