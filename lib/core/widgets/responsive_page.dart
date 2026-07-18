import 'package:flutter/material.dart';
import 'package:hrm_saas/core/widgets/responsive_helper.dart';

export 'responsive_helper.dart';

/// Shared responsive body wrapper used across employee screens.
///
/// Centers content up to [maxWidth], applies adaptive horizontal padding,
/// and optionally scrolls so keyboard / small heights never overflow.
class ResponsivePage extends StatelessWidget {
  const ResponsivePage({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
    this.scrollable = true,
    this.physics,
  });

  final Widget child;
  final double? maxWidth;
  final EdgeInsetsGeometry? padding;
  final bool scrollable;
  final ScrollPhysics? physics;

  static EdgeInsets adaptivePadding(BuildContext context, {double? vertical}) {
    final r = ResponsiveHelper.of(context);
    return EdgeInsets.symmetric(
      horizontal: r.horizontalPadding,
      vertical: vertical ?? r.verticalPadding,
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = ResponsiveHelper.of(context);
    final resolvedMaxWidth = maxWidth ?? r.pageMaxWidth;
    final resolvedPadding = padding ?? adaptivePadding(context);
    final content = Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: resolvedMaxWidth),
        child: Padding(
          padding: resolvedPadding,
          child: child,
        ),
      ),
    );

    if (!scrollable) return content;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: physics,
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: content,
          ),
        );
      },
    );
  }
}

/// Centers a form card on tablet/desktop; full width on phones.
class ResponsiveFormFrame extends StatelessWidget {
  const ResponsiveFormFrame({
    super.key,
    required this.child,
    this.maxWidth,
  });

  final Widget child;
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    final r = ResponsiveHelper.of(context);
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth ?? r.formMaxWidth),
        child: child,
      ),
    );
  }
}

/// Label / value row that never overflows on narrow widths or large text.
class LabeledValueRow extends StatelessWidget {
  const LabeledValueRow({
    super.key,
    required this.label,
    required this.value,
    this.labelStyle,
    this.valueStyle,
    this.spacing = 12,
  });

  final String label;
  final String value;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: labelStyle,
              softWrap: true,
            ),
          ),
          SizedBox(width: spacing),
          Flexible(
            child: Text(
              value,
              style: valueStyle,
              textAlign: TextAlign.end,
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}

/// Computes a grid aspect ratio that grows taller when text scale increases.
double responsiveGridAspectRatio(
  BuildContext context, {
  double base = 1.35,
  double minRatio = 0.85,
}) {
  return ResponsiveHelper.of(context).gridAspectRatio(
    base: base,
    minRatio: minRatio,
  );
}

/// Whether the current viewport is considered narrow for chrome density.
bool isNarrowWidth(BuildContext context, {double breakpoint = Breakpoints.narrow}) {
  return MediaQuery.sizeOf(context).width < breakpoint;
}

/// Adaptive grid that picks column count from [ResponsiveHelper].
class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({
    super.key,
    required this.children,
    this.mobileColumns = 2,
    this.tabletColumns = 3,
    this.desktopColumns = 5,
    this.spacing,
    this.runSpacing,
    this.childAspectRatio,
    this.shrinkWrap = true,
    this.physics = const NeverScrollableScrollPhysics(),
  });

  final List<Widget> children;
  final int mobileColumns;
  final int tabletColumns;
  final int desktopColumns;
  final double? spacing;
  final double? runSpacing;
  final double? childAspectRatio;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    final r = ResponsiveHelper.of(context);
    final gap = spacing ?? r.spacing(AppSpacing.md);
    final runGap = runSpacing ?? gap;
    final cols = r.gridColumns(
      mobile: mobileColumns,
      tablet: tabletColumns,
      desktop: desktopColumns,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        // Prefer Wrap so short card grids never fight nested scroll views.
        final itemWidth = (constraints.maxWidth - gap * (cols - 1)) / cols;
        return Wrap(
          spacing: gap,
          runSpacing: runGap,
          children: [
            for (final child in children)
              SizedBox(
                width: itemWidth,
                child: childAspectRatio == null
                    ? child
                    : AspectRatio(
                        aspectRatio: childAspectRatio!,
                        child: child,
                      ),
              ),
          ],
        );
      },
    );
  }
}

/// Horizontal scroll wrapper for wide tables / dense rows on phones.
class ResponsiveHorizontalScroll extends StatelessWidget {
  const ResponsiveHorizontalScroll({
    super.key,
    required this.child,
    this.minWidth = 560,
  });

  final Widget child;
  final double minWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final needsScroll = constraints.maxWidth < minWidth;
        final content = ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: needsScroll ? minWidth : constraints.maxWidth,
          ),
          child: child,
        );
        if (!needsScroll) return content;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: content,
        );
      },
    );
  }
}
