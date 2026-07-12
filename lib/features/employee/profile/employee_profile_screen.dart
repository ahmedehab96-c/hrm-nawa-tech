import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/locale/locale_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_scope.dart';
import '../../../core/utils/text_direction_helper.dart';
import '../../../core/api/api_result.dart';
import '../../../core/api/api_config.dart';
import '../../../core/repositories/auth_repository.dart';
import '../../../core/repositories/employees_repository.dart';
import '../../../l10n/app_strings.dart';

class EmployeeProfileScreen extends StatefulWidget {
  const EmployeeProfileScreen({super.key});

  @override
  State<EmployeeProfileScreen> createState() => _EmployeeProfileScreenState();
}

class _EmployeeProfileScreenState extends State<EmployeeProfileScreen> {
  bool _loading = true;
  EmployeeItem? _employee;
  String? _error;
  bool _useApi = false;
  final TextEditingController _baseUrlCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadApiSettings();
    _load();
  }

  @override
  void dispose() {
    _baseUrlCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadApiSettings() async {
    await ApiConfig.load();
    if (!mounted) return;
    setState(() {
      _useApi = ApiConfig.useApi;
      _baseUrlCtrl.text = ApiConfig.baseUrl ?? '';
    });
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final res = await EmployeesRepository.getMyEmployee();
    if (!mounted) return;

    if (res is ApiSuccess<EmployeeItem>) {
      setState(() {
        _employee = res.data;
        _loading = false;
      });
    } else {
      setState(() {
        _error = (res as ApiFailure<EmployeeItem>).message;
        _loading = false;
      });
    }
  }

  Future<void> _saveApiSettings() async {
    final l10n = AppStrings.of(context);
    final code = ApiConfig.validateBaseUrl(_baseUrlCtrl.text);
    if (_useApi && code != null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(code == 'needs_https' ? l10n.apiHttpsRequired : l10n.invalidApiUrl)),
      );
      return;
    }
    await ApiConfig.setBaseUrl(_baseUrlCtrl.text);
    await ApiConfig.setUseApi(_useApi);
    await _load();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.serverSettingsSaved)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppStrings.of(context);
    final name = _employee?.name ?? '';
    final trimmed = name.trim();
    final avatarChar = trimmed.isEmpty ? '—' : trimmed[0];
    return Directionality(
      textDirection: textDirectionForContext(context),
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.profileQuickLabel),
        ),
        body: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 48,
                      child: Text(
                        avatarChar,
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(name.isEmpty ? '—' : name, style: AppTypography.h3),
                    Text(_employee?.position ?? '—', style: AppTypography.bodySmall),
                    Text(_employee?.department ?? '—', style: AppTypography.caption),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Text(l10n.personalInfo, style: AppTypography.h4),
              const SizedBox(height: 16),
              Card(
                child: _loading
                    ? const Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : Column(
                        children: [
                          _ProfileItem(
                            icon: Icons.email,
                            label: l10n.email,
                            value: _employee?.email ?? '—',
                          ),
                          const Divider(height: 1),
                          _ProfileItem(
                            icon: Icons.phone,
                            label: l10n.phone,
                            value: _employee?.phone ?? '—',
                          ),
                          const Divider(height: 1),
                          _ProfileItem(
                            icon: Icons.calendar_today,
                            label: l10n.hireDate,
                            value: _employee?.hireDate ?? '—',
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: 24),
              Text(l10n.documentsSection, style: AppTypography.h4),
              const SizedBox(height: 16),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.description),
                      title: Text(l10n.employmentContract),
                      trailing: const Icon(Icons.download),
                      onTap: _loading ? null : () {},
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.description),
                      title: Text(l10n.payslipJanuaryDoc),
                      trailing: const Icon(Icons.download),
                      onTap: _loading ? null : () {},
                    ),
                  ],
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(_error!, style: AppTypography.bodySmall.copyWith(color: AppColors.error)),
              ],
              const SizedBox(height: 32),

              // ── App settings: language + theme ────────────────────────
              Text(l10n.appearance, style: AppTypography.h4),
              const SizedBox(height: 16),
              Card(
                child: Column(
                  children: [
                    // Dark / light mode toggle
                    Builder(builder: (ctx) {
                      final notifier = ThemeScope.of(ctx);
                      return SwitchListTile(
                        secondary: Icon(
                          notifier.isDark ? Icons.dark_mode : Icons.light_mode,
                          color: AppColors.primary,
                        ),
                        title: Text(l10n.darkMode, style: AppTypography.bodyMedium),
                        subtitle: Text(
                          notifier.isDark ? l10n.darkModeOn : l10n.darkModeOff,
                          style: AppTypography.caption,
                        ),
                        value: notifier.isDark,
                        onChanged: (v) =>
                            notifier.setMode(v ? ThemeMode.dark : ThemeMode.light),
                      );
                    }),
                    const Divider(height: 1),
                    // Language toggle
                    Builder(builder: (ctx) {
                      final locale = Localizations.localeOf(ctx);
                      final isAr   = locale.languageCode == 'ar';
                      return ListTile(
                        leading: const Icon(Icons.language, color: AppColors.primary),
                        title: Text(l10n.language, style: AppTypography.bodyMedium),
                        subtitle: Text(
                          isAr ? l10n.arabic : l10n.english,
                          style: AppTypography.caption,
                        ),
                        trailing: SegmentedButton<String>(
                          segments: [
                            ButtonSegment(value: 'ar', label: Text(l10n.arabic)),
                            ButtonSegment(value: 'en', label: Text(l10n.english)),
                          ],
                          selected: {isAr ? 'ar' : 'en'},
                          onSelectionChanged: (s) =>
                              LocaleController.instance.setLocale(Locale(s.first)),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(l10n.serverBindingTitle, style: AppTypography.h4),
              const SizedBox(height: 8),
              Text(
                l10n.serverBindingDescription,
                style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(l10n.useServer),
                        subtitle: Text(
                          _useApi ? l10n.serverEnabled : l10n.serverDisabled,
                          style: AppTypography.caption,
                        ),
                        value: _useApi,
                        onChanged: (v) => setState(() => _useApi = v),
                      ),
                      TextField(
                        controller: _baseUrlCtrl,
                        enabled: _useApi,
                        decoration: InputDecoration(
                          labelText: l10n.baseUrlLabel,
                          hintText: l10n.baseUrlHint,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _saveApiSettings,
                          child: Text(l10n.save),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () async {
                    await AuthRepository.logout();
                    if (!context.mounted) return;
                    context.go('/login');
                  },
                  icon: const Icon(Icons.logout),
                  label: Text(l10n.logout),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
          ),
        ),
      ),
    );
  }
}

class _ProfileItem extends StatelessWidget {
  const _ProfileItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(label, style: AppTypography.caption),
      subtitle: Text(value, style: AppTypography.bodyMedium),
    );
  }
}
