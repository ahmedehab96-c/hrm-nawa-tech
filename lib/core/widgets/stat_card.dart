import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'animations.dart';

// ─── StatCard ─────────────────────────────────────────────────────────────────
/// A stat card used in the Dashboard. Animates on hover and counts up numeric values.
/// بطاقة إحصاء تُستخدم في الـ Dashboard، تتحرك عند hover وتعدّ الأرقام تلقائياً.
///
/// - [title]     — Card heading (e.g. "Employees") | عنوان البطاقة (مثال: "الموظفون")
/// - [value]     — Main value; numbers are counted up via [CountUpText] | القيمة الرئيسية؛ الأرقام تُعدّ من 0
/// - [subtitle]  — Small descriptive text below the value | نص توضيحي صغير أسفل القيمة
/// - [icon]      — Leading icon | الأيقونة اليسرى
/// - [iconColor] — Icon color (default: primary) | لون الأيقونة (الافتراضي: اللون الأساسي)
/// - [trend]     — Trend string (e.g. "+5%"), shown in green | نص الاتجاه يُعرض باللون الأخضر
class StatCard extends StatefulWidget {
  const StatCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    this.icon,
    this.iconColor,
    this.trend,
  });

  final String    title;
  final String    value;
  final String?   subtitle;
  final IconData? icon;
  final Color?    iconColor;
  final String?   trend;

  @override
  State<StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<StatCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.iconColor ?? AppColors.primary;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      cursor:  SystemMouseCursors.click,
      child: AnimatedScale(
        scale:    _hovered ? 1.025 : 1.0,
        duration: const Duration(milliseconds: 180),
        curve:    Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: _hovered
                ? [BoxShadow(color: color.withValues(alpha: 0.18), blurRadius: 20, offset: const Offset(0, 6))]
                : [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))],
          ),
          child: Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Card header: icon + title | رأس البطاقة: أيقونة + عنوان
                  Row(
                    children: [
                      if (widget.icon != null) ...[
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: _hovered ? 0.18 : 0.10),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(widget.icon, color: color, size: 24),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: Text(widget.title, style: AppTypography.label),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Main value with count-up animation | القيمة الرئيسية (count-up animation)
                  CountUpText(widget.value, style: AppTypography.h2),
                  // subtitle + trend indicator | subtitle + مؤشر الاتجاه
                  if (widget.subtitle != null || widget.trend != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (widget.subtitle != null)
                          Expanded(
                            child: Text(
                              widget.subtitle!,
                              style: AppTypography.caption,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        if (widget.trend != null)
                          Text(
                            widget.trend!,
                            style: AppTypography.caption.copyWith(color: AppColors.success),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
