import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/locale/locale_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_scope.dart';
import '../../../core/utils/text_direction_helper.dart';
import '../../../core/api/api_result.dart';
import '../../../core/api/api_config.dart';
import 'package:hrm_saas/features/employee/auth/data/auth_repository.dart';
import 'package:hrm_saas/features/employee/profile/data/employees_repository.dart';
import '../../../core/widgets/responsive_page.dart';
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
        body: ResponsivePage(
          child: Builder(
            builder: (context) {
              final r = context.responsive;
              final header = Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: r.value(mobile: 48.0, tablet: 56.0, desktop: 64.0),
                      child: Text(
                        avatarChar,
                        style: TextStyle(
                          fontSize: r.fontSize(36),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: r.spacing(16)),
                    Text(
                      name.isEmpty ? '—' : name,
                      style: AppTypography.h3,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      _employee?.position ?? '—',
                      style: AppTypography.bodySmall,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      _employee?.department ?? '—',
                      style: AppTypography.caption,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );

              final personalCard = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.personalInfo, style: AppTypography.h4),
                  SizedBox(height: r.spacing(16)),
                  Card(
                    child: _loading
                        ? Padding(
                            padding: EdgeInsets.all(r.spacing(24)),
                            child: const Center(child: CircularProgressIndicator()),
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
                ],
              );

              final docsCard = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.documentsSection, style: AppTypography.h4),
                  SizedBox(height: r.spacing(16)),
                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.description),
                          title: Text(
                            l10n.employmentContract,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: const Icon(Icons.download),
                          onTap: _loading ? null : () {},
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.description),
                          title: Text(
                            l10n.payslipJanuaryDoc,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: const Icon(Icons.download),
                          onTap: _loading ? null : () {},
                        ),
                      ],
                    ),
                  ),
                ],
              );

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  header,
                  SizedBox(height: r.spacing(32)),
                  if (r.useTwoPane)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: personalCard),
                        SizedBox(width: r.spacing(16)),
                        Expanded(child: docsCard),
                      ],
                    )
                  else ...[
                    personalCard,
                    SizedBox(height: r.spacing(24)),
                    docsCard,
                  ],
                  if (_error != null) ...[
                    SizedBox(height: r.spacing(16)),
                    Text(
                      _error!,
                      style: AppTypography.bodySmall.copyWith(color: AppColors.error),
                    ),
                  ],
                  SizedBox(height: r.spacing(32)),
                  Text(l10n.appearance, style: AppTypography.h4),
                  SizedBox(height: r.spacing(16)),
                  Card(
                    child: Column(
                      children: [
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
                        Builder(builder: (ctx) {
                          final locale = Localizations.localeOf(ctx);
                          final isAr = locale.languageCode == 'ar';
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.language, color: AppColors.primary),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(l10n.language, style: AppTypography.bodyMedium),
                                          Text(
                                            isAr ? l10n.arabic : l10n.english,
                                            style: AppTypography.caption,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                SegmentedButton<String>(
                                  segments: [
                                    ButtonSegment(value: 'ar', label: Text(l10n.arabic)),
                                    ButtonSegment(value: 'en', label: Text(l10n.english)),
                                  ],
                                  selected: {isAr ? 'ar' : 'en'},
                                  onSelectionChanged: (s) => LocaleController.instance
                                      .setLocale(Locale(s.first)),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  SizedBox(height: r.spacing(24)),
                  Text(l10n.serverBindingTitle, style: AppTypography.h4),
                  SizedBox(height: r.spacing(8)),
                  Text(
                    l10n.serverBindingDescription,
                    style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                  ),
                  SizedBox(height: r.spacing(16)),
                  ResponsiveFormFrame(
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(r.spacing(16)),
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
                            SizedBox(height: r.spacing(12)),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: _saveApiSettings,
                                style: FilledButton.styleFrom(
                                  minimumSize: Size.fromHeight(r.minTouchSize),
                                ),
                                child: Text(l10n.save),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: r.spacing(32)),
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
                        minimumSize: Size.fromHeight(r.minTouchSize),
                        padding: EdgeInsets.symmetric(vertical: r.spacing(14)),
                      ),
                    ),
                  ),
                  SizedBox(height: r.spacing(24)),
                ],
              );
            },
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
      title: Text(
        label,
        style: AppTypography.caption,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        value,
        style: AppTypography.bodyMedium,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
