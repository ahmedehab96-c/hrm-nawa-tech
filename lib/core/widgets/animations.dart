import 'package:flutter/material.dart';

// ─── قيم افتراضية قابلة للتعديل من مكان واحد ─────────────────────────────────
const Duration kAnimEnter = Duration(milliseconds: 420);
const Duration kAnimStep  = Duration(milliseconds: 75);
const Duration kAnimCount = Duration(milliseconds: 900);
const Curve    kAnimCurve = Curves.easeOutCubic;

// ─── FadeSlideIn ──────────────────────────────────────────────────────────────
/// يُظهر أي widget بتأثير fade + انزلاق خفيف للأعلى عند أول بناء.
///
/// [delay]    — تأخير قبل بدء الأنيميشن (لعمل تتابع stagger).
/// [dy]       — مسافة الانزلاق كنسبة (0.0–1.0); الافتراضي 0.06.
/// [duration] — مدة الأنيميشن; الافتراضي [kAnimEnter].
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
/// يُغلّف كل عنصر في [children] بـ [FadeSlideIn] مع تأخير متصاعد.
///
/// [step]    — الفرق في الـ delay بين كل عنصر وما يليه.
/// [initial] — تأخير قبل بدء أول عنصر.
///
/// مثال:
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
/// يُحرّك أول رقم صحيح في [value] من 0 إلى قيمته الحقيقية.
///
/// يحافظ على الـ prefix و suffix كما هي (مثال: "94%" → يعدّ حتى 94 ثم يثبت).
/// القيم غير الرقمية تُعرض بـ fade بسيط.
///
/// مثال:
/// ```dart
/// CountUpText('128', style: AppTypography.h2)
/// CountUpText('94%', style: AppTypography.h2)
/// CountUpText('جاهز', style: AppTypography.h2)  // fade فقط
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
  late final int?    _target;
  late final String  _prefix;
  late final String  _suffix;

  @override
  void initState() {
    super.initState();
    final match = RegExp(r'\d+').firstMatch(widget.value);
    if (match != null) {
      _target = int.tryParse(match.group(0) ?? '');
      _prefix = widget.value.substring(0, match.start);
      _suffix = widget.value.substring(match.end);
    } else {
      _target = null;
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
    // قيمة غير رقمية → fade بسيط
    if (_target == null) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
        child: Text(widget.value, style: widget.style),
      );
    }
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        final v = (_target * Curves.easeOut.transform(_ctrl.value)).round();
        return Text('$_prefix$v$_suffix', style: widget.style);
      },
    );
  }
}
