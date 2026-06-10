import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_config.dart';
import '../../../core/api/api_result.dart';
import '../../../core/auth/auth_session.dart';
import '../../../core/locale/locale_controller.dart';
import '../../../core/repositories/settings_repository.dart';
import '../../../core/saas/subscription_controller.dart';
import '../../../core/services/wifi_attendance_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_scope.dart';
import '../../../l10n/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _companyController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _wifiSsidController;
  late final TextEditingController _apiBaseUrlController;
  bool _useApi = false;
  bool _savingCompany = false;
  bool _savingWifi = false;
  bool _loadingSettings = false;

  @override
  void initState() {
    super.initState();
    _companyController = TextEditingController(text: 'شركة النموذج');
    _emailController = TextEditingController(text: 'info@company.com');
    _phoneController = TextEditingController(text: '+966 50 123 4567');
    _addressController = TextEditingController(
      text: 'الرياض، المملكة العربية السعودية',
    );
    _wifiSsidController = TextEditingController(
      text: WifiAttendanceService.companyWifiSsid,
    );
    _apiBaseUrlController = TextEditingController(
      text: ApiConfig.baseUrl ?? '',
    );
    _useApi = ApiConfig.useApi;
    _loadCompanySettings();
  }

  Future<void> _loadCompanySettings() async {
    setState(() => _loadingSettings = true);
    final result = await SettingsRepository.instance.getSettings();
    if (!mounted) return;
    setState(() => _loadingSettings = false);
    if (result is ApiSuccess<CompanySettings>) {
      final s = result.data;
      _companyController.text = s.name;
      _emailController.text = s.email ?? '';
      _phoneController.text = s.phone ?? '';
      _addressController.text = s.address ?? '';
      if (s.wifiSsid != null && s.wifiSsid!.isNotEmpty) {
        _wifiSsidController.text = s.wifiSsid!;
        WifiAttendanceService.setCompanyWifiSsid(s.wifiSsid!);
      }
    }
  }

  @override
  void dispose() {
    _companyController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _wifiSsidController.dispose();
    _apiBaseUrlController.dispose();
    super.dispose();
  }

  String? _validateApiUrl(AppLocalizations l10n, String url) {
    if (!_useApi) return null;
    if (url.isEmpty) return l10n.apiUrlRequired;
    final err = ApiConfig.validateBaseUrl(url);
    if (err == 'needs_https') return l10n.apiHttpsRequired;
    if (err == 'invalid') return l10n.invalidApiUrl;
    return null;
  }

  Future<void> _applyServerSwitch(AppLocalizations l10n, bool enable) async {
    final url = _apiBaseUrlController.text.trim();
    if (enable) {
      if (url.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.apiUrlRequired),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
      final err = ApiConfig.validateBaseUrl(url);
      if (err == 'needs_https') {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.apiHttpsRequired),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
      if (err == 'invalid') {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.invalidApiUrl),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
    }
    await ApiConfig.setBaseUrl(url.isEmpty ? null : url);
    await ApiConfig.setUseApi(enable);
    AuthSession.instance.notifyEnvironmentChanged();
    if (!mounted) return;
    setState(() => _useApi = enable);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(enable ? l10n.serverEnabled : l10n.serverDisabled),
        backgroundColor: AppColors.success,
      ),
    );
  }

  Future<void> _saveCompanySettings(AppLocalizations l10n) async {
    setState(() => _savingCompany = true);
    final result = await SettingsRepository.instance.saveSettings(
      name: _companyController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
    );
    if (!mounted) return;
    setState(() => _savingCompany = false);
    switch (result) {
      case ApiSuccess():
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(l10n.formSavedSuccess),
          backgroundColor: AppColors.success,
        ));
      case ApiFailure(:final message):
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(message),
          backgroundColor: AppColors.error,
        ));
    }
  }

  Future<void> _saveWifiSettings(AppLocalizations l10n) async {
    final ssid = _wifiSsidController.text.trim();
    setState(() => _savingWifi = true);
    WifiAttendanceService.setCompanyWifiSsid(ssid);
    final result = await SettingsRepository.instance.saveSettings(wifiSsid: ssid);
    if (!mounted) return;
    setState(() => _savingWifi = false);
    switch (result) {
      case ApiSuccess():
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(l10n.wifiSettingsSaved),
          backgroundColor: AppColors.success,
        ));
      case ApiFailure(:final message):
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(message),
          backgroundColor: AppColors.error,
        ));
    }
  }

  Future<void> _saveServerSettings(AppLocalizations l10n) async {
    final url = _apiBaseUrlController.text.trim();
    if (_useApi) {
      final msg = _validateApiUrl(l10n, url);
      if (msg != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: AppColors.error),
        );
        return;
      }
    }
    await ApiConfig.setBaseUrl(url.isEmpty ? null : url);
    await ApiConfig.setUseApi(_useApi);
    AuthSession.instance.notifyEnvironmentChanged();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.serverSettingsSaved),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);

    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.settings, style: AppTypography.h1),
            const SizedBox(height: 32),
            _SectionCard(
              title: l10n.appearance,
              icon: Icons.palette_outlined,
              child: Row(
                children: [
                  Icon(
                    ThemeScope.of(context).isDark
                        ? Icons.dark_mode
                        : Icons.light_mode,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.darkMode, style: AppTypography.bodyMedium),
                        Text(
                          ThemeScope.of(context).isDark
                              ? l10n.darkModeOn
                              : l10n.darkModeOff,
                          style: AppTypography.caption,
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: ThemeScope.of(context).isDark,
                    onChanged: (v) {
                      ThemeScope.of(
                        context,
                      ).setMode(v ? ThemeMode.dark : ThemeMode.light);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _SectionCard(
              title: l10n.languageTitle,
              icon: Icons.language,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.language, style: AppTypography.bodyMedium),
                        Text(
                          locale.languageCode == 'ar'
                              ? l10n.arabic
                              : l10n.english,
                          style: AppTypography.caption,
                        ),
                      ],
                    ),
                  ),
                  SegmentedButton<String>(
                    segments: [
                      ButtonSegment(value: 'ar', label: Text(l10n.arabic)),
                      ButtonSegment(value: 'en', label: Text(l10n.english)),
                    ],
                    selected: {locale.languageCode == 'en' ? 'en' : 'ar'},
                    onSelectionChanged: (s) {
                      final code = s.first;
                      LocaleController.instance.setLocale(Locale(code));
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _SectionCard(
              title: l10n.serverBindingTitle,
              icon: Icons.cloud_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.serverBindingDescription,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _apiBaseUrlController,
                    decoration: InputDecoration(
                      labelText: l10n.baseUrlLabel,
                      hintText: l10n.baseUrlHint,
                      prefixIcon: const Icon(Icons.link),
                    ),
                    keyboardType: TextInputType.url,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.useServer,
                              style: AppTypography.bodyMedium,
                            ),
                            Text(
                              _useApi
                                  ? l10n.dataFromServer
                                  : l10n.dataLocalDemo,
                              style: AppTypography.caption,
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _useApi,
                        onChanged: (v) => _applyServerSwitch(l10n, v),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () => _saveServerSettings(l10n),
                    child: Text(l10n.save),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _SectionCard(
              title: l10n.companyInfo,
              icon: Icons.business,
              child: _loadingSettings
                  ? const Center(child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: CircularProgressIndicator(),
                    ))
                  : Column(
                children: [
                  TextFormField(
                    controller: _companyController,
                    decoration: InputDecoration(labelText: l10n.companyName),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(labelText: l10n.email),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    decoration: InputDecoration(labelText: l10n.phone),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _addressController,
                    decoration: InputDecoration(labelText: l10n.address),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _savingCompany ? null : () => _saveCompanySettings(l10n),
                    child: _savingCompany
                        ? const SizedBox(
                            width: 20, height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(l10n.save),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _SectionCard(
              title: l10n.wifiAttendanceTitle,
              icon: Icons.wifi,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.wifiAttendanceBody,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _wifiSsidController,
                    decoration: InputDecoration(
                      labelText: l10n.wifiSsidLabel,
                      prefixIcon: const Icon(Icons.wifi),
                      hintText: l10n.wifiSsidHint,
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _savingWifi ? null : () => _saveWifiSettings(l10n),
                    child: _savingWifi
                        ? const SizedBox(
                            width: 20, height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(l10n.save),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _SectionCard(
              title: l10n.rolesPermissions,
              icon: Icons.security,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    leading: const Icon(Icons.admin_panel_settings),
                    title: Text(l10n.roleAdminTitle),
                    subtitle: Text(l10n.roleAdminSubtitle),
                    trailing: const Icon(Icons.chevron_left),
                    onTap: () => context.push('/admin/settings/role/admin'),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.people),
                    title: Text(l10n.roleHrTitle),
                    subtitle: Text(l10n.roleHrSubtitle),
                    trailing: const Icon(Icons.chevron_left),
                    onTap: () => context.push('/admin/settings/role/hr'),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(l10n.roleEmployeeTitle),
                    subtitle: Text(l10n.roleEmployeeSubtitle),
                    trailing: const Icon(Icons.chevron_left),
                    onTap: () => context.push('/admin/settings/role/employee'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            AnimatedBuilder(
              animation: SubscriptionController.instance,
              builder: (context, _) {
                final sub = SubscriptionController.instance;
                return _SectionCard(
                  title: l10n.subscriptionBilling,
                  icon: Icons.credit_card,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.saasPlanSection, style: AppTypography.label),
                      const SizedBox(height: 8),
                      SegmentedButton<String>(
                        showSelectedIcon: false,
                        segments: [
                          ButtonSegment(
                            value: 'starter',
                            label: Text(l10n.planStarter),
                          ),
                          ButtonSegment(
                            value: 'growth',
                            label: Text(l10n.planGrowth),
                          ),
                          ButtonSegment(
                            value: 'enterprise',
                            label: Text(l10n.planEnterprise),
                          ),
                        ],
                        selected: {sub.planId},
                        onSelectionChanged: (s) async {
                          if (s.isEmpty) return;
                          await sub.setPlan(s.first);
                        },
                      ),
                      const SizedBox(height: 8),
                      Text(
                        sub.planId == 'enterprise'
                            ? l10n.planEnterpriseDesc
                            : sub.planId == 'growth'
                            ? l10n.planGrowthDesc
                            : l10n.planStarterDesc,
                        style: AppTypography.caption,
                      ),
                      const SizedBox(height: 12),
                      Card(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: AppColors.primary,
                                size: 40,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      sub.planId == 'enterprise'
                                          ? l10n.planEnterprise
                                          : sub.planId == 'growth'
                                          ? l10n.planGrowth
                                          : l10n.planStarter,
                                      style: AppTypography.h4,
                                    ),
                                    Text(
                                      sub.planId == 'enterprise'
                                          ? l10n.planEnterpriseDesc
                                          : sub.planId == 'growth'
                                          ? l10n.planGrowthDesc
                                          : l10n.planStarterDesc,
                                      style: AppTypography.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              OutlinedButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(l10n.paymentPortalLater),
                                      backgroundColor: AppColors.info,
                                    ),
                                  );
                                },
                                child: Text(l10n.upgradePlan),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _FeatureChip(l10n.featureEmployees, true),
                          _FeatureChip(l10n.featureAttendance, true),
                          _FeatureChip(l10n.featureLeave, true),
                          _FeatureChip(l10n.featurePayroll, true),
                          _FeatureChip(
                            l10n.featureRecruitment,
                            sub.recruitmentEnabled,
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary),
                const SizedBox(width: 12),
                Text(title, style: AppTypography.h4),
              ],
            ),
            const SizedBox(height: 20),
            child,
          ],
        ),
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  const _FeatureChip(this.label, this.enabled);

  final String label;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Chip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              enabled ? Icons.check_circle : Icons.cancel,
              size: 16,
              color: enabled ? AppColors.success : AppColors.textMuted,
            ),
            const SizedBox(width: 4),
            Text(label),
          ],
        ),
      ),
    );
  }
}
