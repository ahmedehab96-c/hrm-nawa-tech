import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hrm_saas/core/theme/app_theme.dart';
import 'package:hrm_saas/core/theme/theme_notifier.dart';
import 'package:hrm_saas/core/theme/theme_scope.dart';
import 'package:hrm_saas/core/widgets/responsive_helper.dart';
import 'package:hrm_saas/l10n/app_strings.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Forces demo-mode repositories (no network) for widget tests.
Future<void> bootstrapDemoPrefs() async {
  SharedPreferences.setMockInitialValues({
    'api_use_server': false,
  });
}

class LayoutVariant {
  const LayoutVariant({
    required this.name,
    required this.size,
    required this.locale,
    this.textScale = 1.0,
    this.viewInsets = EdgeInsets.zero,
  });

  final String name;
  final Size size;
  final Locale locale;
  final double textScale;
  final EdgeInsets viewInsets;
}

const narrowAr = LayoutVariant(
  name: 'narrow_ar_1.3',
  size: Size(320, 640),
  locale: Locale('ar'),
  textScale: 1.3,
);

const narrowArStress = LayoutVariant(
  name: 'narrow_ar_2.0',
  size: Size(320, 640),
  locale: Locale('ar'),
  textScale: 2.0,
);

const phoneAr = LayoutVariant(
  name: 'phone_ar',
  size: Size(390, 844),
  locale: Locale('ar'),
);

const landscapeAr = LayoutVariant(
  name: 'landscape_ar_1.3',
  size: Size(844, 390),
  locale: Locale('ar'),
  textScale: 1.3,
);

const tabletEn = LayoutVariant(
  name: 'tablet_en',
  size: Size(768, 1024),
  locale: Locale('en'),
);

const desktopEn = LayoutVariant(
  name: 'desktop_en',
  size: Size(1280, 800),
  locale: Locale('en'),
);

const keyboardAr = LayoutVariant(
  name: 'narrow_ar_kb',
  size: Size(320, 640),
  locale: Locale('ar'),
  textScale: 1.3,
  viewInsets: EdgeInsets.only(bottom: 280),
);

Widget _adaptiveChrome({
  required Widget child,
  required LayoutVariant variant,
}) {
  final width = variant.size.width;
  final destinations = const [
    NavigationDestination(icon: Icon(Icons.home), label: 'الرئيسية'),
    NavigationDestination(icon: Icon(Icons.access_time), label: 'الحضور'),
    NavigationDestination(icon: Icon(Icons.event_note), label: 'الإجازات'),
    NavigationDestination(icon: Icon(Icons.receipt), label: 'الراتب'),
    NavigationDestination(icon: Icon(Icons.notifications), label: 'الإشعارات'),
    NavigationDestination(icon: Icon(Icons.person), label: 'الملف'),
  ];
  final railDestinations = [
    for (final d in destinations)
      NavigationRailDestination(
        icon: d.icon,
        label: Text(d.label),
      ),
  ];

  if (width >= Breakpoints.tablet) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: 0,
            destinations: railDestinations,
            onDestinationSelected: (_) {},
          ),
          const VerticalDivider(width: 1),
          Expanded(child: child),
        ],
      ),
    );
  }

  if (width >= Breakpoints.mobile) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: 0,
            labelType: NavigationRailLabelType.selected,
            destinations: railDestinations,
            onDestinationSelected: (_) {},
          ),
          const VerticalDivider(width: 1),
          Expanded(child: child),
        ],
      ),
    );
  }

  return Scaffold(
    body: child,
    bottomNavigationBar: NavigationBar(
      selectedIndex: 0,
      labelBehavior: width < Breakpoints.compactNav
          ? NavigationDestinationLabelBehavior.onlyShowSelected
          : NavigationDestinationLabelBehavior.alwaysShow,
      destinations: destinations,
    ),
  );
}

Future<void> pumpEmployeeScreen(
  WidgetTester tester, {
  required Widget child,
  required LayoutVariant variant,
  bool wrapShell = false,
}) async {
  await bootstrapDemoPrefs();

  final errors = <FlutterErrorDetails>[];
  final previous = FlutterError.onError;
  FlutterError.onError = (details) {
    errors.add(details);
    previous?.call(details);
  };

  tester.view.physicalSize = variant.size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
    FlutterError.onError = previous;
  });

  final body = wrapShell
      ? _adaptiveChrome(child: child, variant: variant)
      : child;

  await tester.pumpWidget(
    ThemeScope(
      notifier: ThemeNotifier(),
      child: MediaQuery(
        data: MediaQueryData(
          size: variant.size,
          textScaler: TextScaler.linear(variant.textScale),
          viewInsets: variant.viewInsets,
          padding: EdgeInsets.zero,
        ),
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          locale: variant.locale,
          supportedLocales: AppStrings.supportedLocales,
          localizationsDelegates: const [
            AppStrings.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: body,
        ),
      ),
    ),
  );

  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pump(const Duration(milliseconds: 400));

  final overflow = errors.where((e) {
    final msg = e.exceptionAsString();
    return msg.contains('overflowed') || msg.contains('OVERFLOWED');
  }).toList();

  expect(
    overflow,
    isEmpty,
    reason: 'Overflow in ${variant.name}: '
        '${overflow.map((e) => e.exceptionAsString()).join('\n')}',
  );
  await tester.pump(const Duration(seconds: 1));
  expect(tester.takeException(), isNull);
}
