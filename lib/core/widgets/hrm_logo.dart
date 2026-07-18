import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../../l10n/app_strings.dart';
import 'responsive_helper.dart';

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
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
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
                  AppStrings.of(context).appTagline,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: height * 0.22,
                    fontWeight: FontWeight.w500,
                    color:
                        taglineColor ??
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
      ),
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
        colors: [const Color(0xFF2563EB), const Color(0xFF1D4ED8)],
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
        colors: [Colors.white.withValues(alpha: 0.18), Colors.transparent],
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

  void _drawPerson(
    Canvas canvas,
    Paint paint,
    double cx,
    double cy,
    double scale,
  ) {
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

// ─── Full Nawa Tech × HRM identity — used on login / splash ─────────────────
/// Renders the complete brand lockup matching the Nawa Tech design:
///   • Stylised gradient "N" letterform
///   • "Nawa Tech" wordmark
///   • "Smart IT Solutions, Better Future" tagline
///   • HRM hexagon badge
///   • "HRM / Human Resource Management" subtitle
class NawaTechFullLogo extends StatelessWidget {
  const NawaTechFullLogo({
    super.key,
    this.onDark = false,
    this.compact = false,
  });

  final bool onDark;
  final bool compact;

  // Light-mode palette
  static const _navy = Color(0xFF1A2B5E);
  static const _teal = Color(0xFF14B8A6);
  // On-dark palette — bright so they pop against dark navy/teal backgrounds
  static const _darkN1 = Colors.white; // "N" gradient start
  static const _darkN2 = Color(0xFF2DD4BF); // "N" gradient end
  static const _darkTech = Color(0xFF5EEAD4); // "Tech" word
  static const _darkLine = Color(0xFF2DD4BF); // tagline lines

  @override
  Widget build(BuildContext context) {
    final isCompact = compact || ResponsiveHelper.of(context).isMobile;
    final nGradStart = onDark ? _darkN1 : _navy;
    final nGradEnd = onDark ? _darkN2 : _teal;
    final nawaColor = onDark ? Colors.white : _navy;
    final techColor = onDark ? _darkTech : _teal;
    final lineColor = onDark ? _darkLine : _teal;
    final taglineColor = onDark ? Colors.white60 : const Color(0xFF64748B);
    final hrmColor = onDark ? Colors.white : _navy;
    final subtitleColor = onDark ? Colors.white60 : _navy;
    final hexStart = onDark ? const Color(0xFF2DD4BF) : _navy;
    final hexEnd = onDark ? Colors.white.withValues(alpha: 0.92) : _teal;
    final nSize = isCompact ? 40.0 : 84.0;
    final wordSize = isCompact ? 17.0 : 28.0;
    final tagSize = isCompact ? 8.0 : 11.0;
    final hexW = isCompact ? 42.0 : 78.0;
    final hexH = isCompact ? 46.0 : 84.0;
    final iconSize = isCompact ? 20.0 : 36.0;
    final hrmSize = isCompact ? 18.0 : 28.0;
    final subSize = isCompact ? 8.0 : 12.0;

    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ShaderMask(
            shaderCallback: (b) => LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [nGradStart, nGradEnd],
            ).createShader(b),
            child: Text(
              'N',
              style: TextStyle(
                fontSize: nSize,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                height: 1.0,
                fontFamily: 'Cairo',
              ),
            ),
          ),
          SizedBox(height: isCompact ? 1 : 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Nawa',
                    style: TextStyle(
                      fontSize: wordSize,
                      fontWeight: FontWeight.w900,
                      color: nawaColor,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  SizedBox(width: isCompact ? 4 : 7),
                  Text(
                    'Tech',
                    style: TextStyle(
                      fontSize: wordSize,
                      fontWeight: FontWeight.w900,
                      color: techColor,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: isCompact ? 2 : 7),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Container(
                  width: isCompact ? 12 : 24,
                  height: 1.5,
                  color: lineColor,
                ),
                SizedBox(width: isCompact ? 4 : 8),
                Expanded(
                  child: Text(
                    'Smart IT Solutions, Better Future',
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: tagSize,
                      color: taglineColor,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ),
                SizedBox(width: isCompact ? 4 : 8),
                Container(
                  width: isCompact ? 12 : 24,
                  height: 1.5,
                  color: lineColor,
                ),
              ],
            ),
          ),
          SizedBox(height: isCompact ? 8 : 28),
          SizedBox(
            width: hexW,
            height: hexH,
            child: CustomPaint(
              painter: _HexPainter(hexStart, hexEnd),
              child: Center(
                child: Icon(
                  Icons.groups_outlined,
                  color: onDark ? _navy : Colors.white,
                  size: iconSize,
                ),
              ),
            ),
          ),
          SizedBox(height: isCompact ? 4 : 12),
          Text(
            'HRM',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: hrmSize,
              fontWeight: FontWeight.w900,
              color: hrmColor,
              fontFamily: 'Cairo',
              letterSpacing: 1,
            ),
          ),
          SizedBox(height: isCompact ? 1 : 3),
          Text(
            'Human Resource Management',
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: subSize,
              fontWeight: FontWeight.w500,
              color: subtitleColor,
              fontFamily: 'Cairo',
            ),
          ),
        ],
      ),
    );
  }
}

class _HexPainter extends CustomPainter {
  const _HexPainter(this.start, this.end);
  final Color start, end;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [start, end],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = math.min(size.width, size.height) / 2 * 0.94;
    final path = Path();

    for (int i = 0; i < 6; i++) {
      final angle = -math.pi / 2 + i * math.pi / 3;
      final x = cx + r * math.cos(angle);
      final y = cy + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _HexPainter old) =>
      old.start != start || old.end != end;
}

// ─── Compact horizontal logo for navbar / topbar ─────────────────────────────
/// Shows "N" lettermark + "Nawa Tech" stacked + "HRM" — all in one row.
/// Designed to fit inside a 64–72 px height navbar.
class NawaTechNavLogo extends StatelessWidget {
  const NawaTechNavLogo({super.key, this.onDark = false});

  final bool onDark;

  static const _navy = Color(0xFF1A2B5E);
  static const _teal = Color(0xFF14B8A6);

  @override
  Widget build(BuildContext context) {
    final nStart = onDark ? Colors.white : _navy;
    final nEnd = onDark ? const Color(0xFF2DD4BF) : _teal;
    final nawaColor = onDark ? Colors.white : _navy;
    final techColor = onDark ? const Color(0xFF5EEAD4) : _teal;
    final hrmColor = onDark ? Colors.white : _navy;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Gradient "N"
          ShaderMask(
            shaderCallback: (b) => LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [nStart, nEnd],
            ).createShader(b),
            child: const Text(
              'N',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                height: 1.0,
                fontFamily: 'Cairo',
              ),
            ),
          ),
          const SizedBox(width: 8),
          // "Nawa Tech" + "HRM" stacked
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Nawa',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: nawaColor,
                      fontFamily: 'Cairo',
                      height: 1,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Tech',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: techColor,
                      fontFamily: 'Cairo',
                      height: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 1),
              Text(
                'HRM',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: hrmColor,
                  fontFamily: 'Cairo',
                  letterSpacing: 1.0,
                  height: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
