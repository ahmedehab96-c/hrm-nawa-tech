import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Canonical breakpoints for the employee app across phone, tablet, and desktop.
abstract final class Breakpoints {
  static const double mobile = 600;
  static const double tablet = 1024;
  static const double compactNav = 420;
  static const double narrow = 400;
  static const double tiny = 360;
  static const double contentPhone = 640;
  static const double contentWide = 1100;
  static const double railLabelsAll = 800;
  static const double sideNavWide = 1280;
  static const double sideNavCompactWidth = 220;
  static const double sideNavExpandedWidth = 260;
}

/// Shared spacing scale — prefer these over magic numbers.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
}

enum ScreenType { mobile, tablet, desktop }

/// Layout chrome used by [EmployeeShell].
enum NavLayout { bottomBar, navigationRail, sideNav }

/// Central responsive API — prefer this over ad-hoc MediaQuery checks.
class ResponsiveHelper {
  ResponsiveHelper._(this.context);

  factory ResponsiveHelper.of(BuildContext context) => ResponsiveHelper._(context);

  final BuildContext context;

  Size get size => MediaQuery.sizeOf(context);
  double get width => size.width;
  double get height => size.height;
  double get screenWidth => width;
  double get screenHeight => height;
  double get shortestSide => size.shortestSide;
  Orientation get orientation => MediaQuery.orientationOf(context);
  bool get isLandscape => orientation == Orientation.landscape;
  EdgeInsets get viewInsets => MediaQuery.viewInsetsOf(context);
  EdgeInsets get padding => MediaQuery.paddingOf(context);
  double get textScale => MediaQuery.textScalerOf(context).scale(1);

  bool get isMobile => width < Breakpoints.mobile;
  bool get isTablet => width >= Breakpoints.mobile && width < Breakpoints.tablet;
  bool get isDesktop => width >= Breakpoints.tablet;
  bool get isNarrow => width < Breakpoints.narrow;
  bool get isTiny => width < Breakpoints.tiny;

  ScreenType get screenType {
    if (isDesktop) return ScreenType.desktop;
    if (isTablet) return ScreenType.tablet;
    return ScreenType.mobile;
  }

  /// Phone → bottom bar; tablet / short landscape → rail; desktop → side nav.
  NavLayout get navLayout {
    if (isDesktop) return NavLayout.sideNav;
    if (isTablet || (isLandscape && width >= Breakpoints.mobile)) {
      return NavLayout.navigationRail;
    }
    return NavLayout.bottomBar;
  }

  double get sideNavWidth =>
      width >= Breakpoints.sideNavWide
          ? Breakpoints.sideNavExpandedWidth
          : Breakpoints.sideNavCompactWidth;

  bool get railShowAllLabels => width >= Breakpoints.railLabelsAll;

  double get pageMaxWidth {
    if (isDesktop) return Breakpoints.contentWide;
    if (isTablet) return 760;
    return Breakpoints.contentPhone;
  }

  double get formMaxWidth {
    if (isDesktop) return 520;
    if (isTablet) return 480;
    return 480;
  }

  double get horizontalPadding {
    if (isDesktop) return 32;
    if (isTablet) return 24;
    if (isTiny) return 12;
    return 16;
  }

  double get verticalPadding {
    if (isDesktop) return 28;
    if (isTablet) return 24;
    return 20;
  }

  EdgeInsets get pagePadding => EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      );

  /// Alias matching the architecture brief.
  EdgeInsets get adaptivePadding => pagePadding;

  double spacing(double base) {
    if (isDesktop) return base * 1.25;
    if (isTiny) return math.max(8, base * 0.85);
    return base;
  }

  double get adaptiveSpacing => spacing(AppSpacing.lg);

  double fontSize(double base) {
    if (isDesktop) return base * 1.05;
    if (isTiny) return base * 0.92;
    return base;
  }

  double get adaptiveFont => fontSize(14);

  /// Minimum comfortable tap target (Material guideline).
  double get minTouchSize => 48;

  double get iconSize {
    if (isDesktop) return 26;
    if (isTiny) return 20;
    return 24;
  }

  double get heroIconSize {
    if (isDesktop) return 72;
    if (isTablet) return 64;
    if (isTiny) return 48;
    return 56;
  }

  /// Grid columns for action / card grids.
  int gridColumns({int mobile = 2, int tablet = 3, int desktop = 5}) {
    if (isDesktop) return desktop;
    if (isTablet) return tablet;
    if (isTiny) return math.min(2, mobile);
    return mobile;
  }

  int get adaptiveGrid => gridColumns();

  /// Preferred max extent for [SliverGridDelegateWithMaxCrossAxisExtent].
  double get gridMaxCrossAxisExtent {
    if (isDesktop) return 220;
    if (isTablet) return 200;
    return 180;
  }

  double gridAspectRatio({double base = 1.35, double minRatio = 0.85}) {
    final narrowed = isTiny ? 0.12 : 0.0;
    return math.max(minRatio, base / textScale - narrowed);
  }

  /// Prefer two-pane layouts on tablet+ (or wide landscape phones).
  bool get useTwoPane => isTablet || isDesktop || (isLandscape && width >= 700);

  /// Dialog width that fits phones and desktops.
  double dialogWidth({double preferred = 480}) {
    return math.min(preferred, width - horizontalPadding * 2);
  }

  double dialogMaxHeight({double fraction = 0.9}) {
    final available = height - viewInsets.bottom - padding.vertical;
    return math.max(280, available * fraction);
  }

  /// Value picker that scales with breakpoints.
  T value<T>({required T mobile, required T tablet, required T desktop}) {
    if (isDesktop) return desktop;
    if (isTablet) return tablet;
    return mobile;
  }
}

/// Convenience extensions so call sites stay short.
extension ResponsiveContext on BuildContext {
  ResponsiveHelper get responsive => ResponsiveHelper.of(this);
}
