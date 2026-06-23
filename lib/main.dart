import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/theme_notifier.dart';
import 'core/theme/theme_scope.dart';
import 'core/router/app_router.dart';
import 'core/api/api_config.dart';
import 'core/auth/auth_session.dart';
import 'core/locale/locale_controller.dart';
import 'core/saas/company_context.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiConfig.load();
  await ApiConfig.applyDebugWebDefaults();
  await AuthSession.instance.syncFromStorage();
  await LocaleController.instance.load();
  if (AuthSession.instance.hasSession) {
    await CompanyContext.instance.load();
  }
  runApp(const HrmSaasApp());
}

class HrmSaasApp extends StatefulWidget {
  const HrmSaasApp({super.key});

  @override
  State<HrmSaasApp> createState() => _HrmSaasAppState();
}

class _HrmSaasAppState extends State<HrmSaasApp> {
  final ThemeNotifier _themeNotifier = ThemeNotifier();
  late final GoRouter _router = createAppRouter();

  @override
  void initState() {
    super.initState();
    _themeNotifier.addListener(() => setState(() {}));
    LocaleController.instance.addListener(_onLocale);
  }

  void _onLocale() => setState(() {});

  @override
  void dispose() {
    LocaleController.instance.removeListener(_onLocale);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ThemeScope(
      notifier: _themeNotifier,
      child: MaterialApp.router(
        title: 'Nawa Tech HRM',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: _themeNotifier.mode,
        routerConfig: _router,
        locale: LocaleController.instance.locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
      ),
    );
  }
}
