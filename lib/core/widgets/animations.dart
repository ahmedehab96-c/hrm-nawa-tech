import 'package:flutter/material.dart';

// ─── Global animation constants — edit here to tune the whole app ─────────────
// ─── قيم افتراضية قابلة للتعديل من مكان واحد ────────────────────────────────
const Duration kAnimEnter = Duration(milliseconds: 420);
const Duration kAnimStep  = Duration(milliseconds: 75);
const Duration kAnimCount = Duration(milliseconds: 900);
const Curve    kAnimCurve = Curves.easeOutCubic;

// ─── FadeSlideIn ──────────────────────────────────────────────────────────────
/// Reveals any widget with a fade + gentle upward slide on first build.
/// يُظهر أي widget بتأثير fade + انزلاق خفيف للأعلى عند أول بناء.
///
/// [delay]    — Delay before the animation starts (use for stagger sequences).
///              تأخير قبل بدء الأنيميشن (لعمل تتابع stagger).
/// [dy]       — Slide distance as a fraction (0.0–1.0); default 0.06.
///              مسافة الانزلاق كنسبة (0.0–1.0); الافتراضي 0.06.
/// [duration] — Animation duration; default [kAnimEnter].
///              مدة الأنيميشن; الافتراضي [kAnimEnter].
class FadeSlideIn extends StatefulWidget {
  const FadeSlideIn({
    super.key,
    required this.child,
    this.delay    = Duration.zero,
    this.dy       = 0.06,
    this.duration = kAnimEnter,
  });

  final Widget   child;
  final Duration delay;
  final double   dy;
  final Duration duration;

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl  = AnimationController(vsync: this, duration: widget.duration);
    _fade  = CurvedAnimation(parent: _ctrl, curve: kAnimCurve);
    _slide = Tween(begin: Offset(0, widget.dy), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: kAnimCurve));

    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: _fade,
        child: SlideTransition(position: _slide, child: widget.child),
      );
}

// ─── StaggeredList ────────────────────────────────────────────────────────────
/// Wraps each child in [FadeSlideIn] with incrementally increasing delays.
/// يُغلّف كل عنصر في [children] بـ [FadeSlideIn] مع تأخير متصاعد.
///
/// [step]    — Delay increment between each child. | الفرق في الـ delay بين كل عنصر وما يليه.
/// [initial] — Delay before the first child. | تأخير قبل بدء أول عنصر.
///
/// Example | مثال:
/// ```dart
/// StaggeredList(children: [CardA(), CardB(), CardC()])
/// ```
class StaggeredList extends StatelessWidget {
  const StaggeredList({
    super.key,
    required this.children,
    this.step               = kAnimStep,
    this.initial            = Duration.zero,
    this.mainAxisSize       = MainAxisSize.min,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  final List<Widget>    children;
  final Duration        step;
  final Duration        initial;
  final MainAxisSize    mainAxisSize;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: mainAxisSize,
        crossAxisAlignment: crossAxisAlignment,
        children: [
          for (var i = 0; i < children.length; i++)
            FadeSlideIn(
              delay: initial + step * i,
              child: children[i],
            ),
        ],
      );
}

// ─── CountUpText ──────────────────────────────────────────────────────────────
/// Animates the first integer in [value] counting up from 0 to its real value.
/// يُحرّك أول رقم صحيح في [value] من 0 إلى قيمته الحقيقية.
///
/// Preserves prefix and suffix (e.g. "94%" → counts to 94, keeps the "%").
/// يحافظ على الـ prefix و suffix كما هي (مثال: "94%" → يعدّ حتى 94 ثم يثبت).
/// Non-numeric values fade in instead. | القيم غير الرقمية تُعرض بـ fade بسيط.
///
/// Example | مثال:
/// ```dart
/// CountUpText('128', style: AppTypography.h2)
/// CountUpText('94%', style: AppTypography.h2)
/// CountUpText('جاهز', style: AppTypography.h2)  // fade only | fade فقط
/// ```
class CountUpText extends StatefulWidget {
  const CountUpText(
    this.value, {
    super.key,
    this.style,
    this.duration = kAnimCount,
  });

  final String     value;
  final TextStyle? style;
  final Duration   duration;

  @override
  State<CountUpText> createState() => _CountUpTextState();
}

class _CountUpTextState extends State<CountUpText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  // Split into a bool flag + non-nullable int to avoid Dart callback smart-cast limitations.
  // نفصل بين "هل القيمة رقمية" و"قيمة الهدف" لتجنّب nullable داخل callbacks.
  late final bool   _isNumeric;
  late final int    _target; // valid only when _isNumeric | صالح فقط إذا _isNumeric == true
  late final String _prefix;
  late final String _suffix;

  @override
  void initState() {
    super.initState();
    final match  = RegExp(r'\d+').firstMatch(widget.value);
    final parsed = match != null ? int.tryParse(match.group(0) ?? '') : null;

    _isNumeric = parsed != null;
    if (_isNumeric) {
      _target = parsed!;
      _prefix = widget.value.substring(0, match!.start);
      _suffix = widget.value.substring(match.end);
    } else {
      _target = 0; // unused placeholder | غير مستخدمة
      _prefix = widget.value;
      _suffix = '';
    }

    _ctrl = AnimationController(vsync: this, duration: widget.duration)
      ..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Non-numeric value → simple fade | قيمة غير رقمية → fade بسيط
    if (!_isNumeric) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
        child: Text(widget.value, style: widget.style),
      );
    }
    // Numeric value → count from 0 to _target (non-nullable, safe in callback)
    // قيمة رقمية → عدّ من 0 إلى _target (non-nullable, آمن داخل callback)
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        final v = (_target * Curves.easeOut.transform(_ctrl.value)).round();
        return Text('$_prefix$v$_suffix', style: widget.style);
      },
    );
  }
}
