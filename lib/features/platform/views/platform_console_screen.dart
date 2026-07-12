import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/mvvm/view_model.dart';
import '../../../core/mvvm/view_model_mixin.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/stat_card.dart';
import '../../../l10n/app_strings.dart';
import '../models/platform_models.dart';
import '../viewmodels/platform_console_view_model.dart';

/// View — binds to [PlatformConsoleViewModel].
class PlatformConsoleScreen extends StatefulWidget {
  const PlatformConsoleScreen({super.key});

  @override
  State<PlatformConsoleScreen> createState() => _PlatformConsoleScreenState();
}

class _PlatformConsoleScreenState extends State<PlatformConsoleScreen>
    with ViewModelMixin<PlatformConsoleScreen, PlatformConsoleViewModel> {
  final _searchCtrl = TextEditingController();

  @override
  PlatformConsoleViewModel createViewModel() => PlatformConsoleViewModel();

  @override
  void initState() {
    super.initState();
    viewModel.load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _onAction(Future<String?> Function() action) async {
    final err = await action();
    if (!mounted || err == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(err), backgroundColor: AppColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppStrings.of(context);

    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final vm = viewModel;
        final o = vm.overview;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text(l10n.platformConsoleTitle),
            actions: [
              IconButton(
                tooltip: l10n.refreshTooltip,
                onPressed: vm.status == ViewStatus.loading ? null : vm.load,
                icon: const Icon(Icons.refresh),
              ),
              IconButton(
                tooltip: l10n.logout,
                onPressed: () async {
                  await vm.logout();
                  if (context.mounted) context.go('/login');
                },
                icon: const Icon(Icons.logout),
              ),
            ],
          ),
          body: switch (vm.status) {
            ViewStatus.loading => const Center(child: CircularProgressIndicator()),
            ViewStatus.error => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(vm.errorMessage ?? '', textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: vm.load,
                        child: Text(l10n.retryAction),
                      ),
                    ],
                  ),
                ),
              ),
            ViewStatus.idle || ViewStatus.ready => RefreshIndicator(
                onRefresh: vm.load,
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    Text(l10n.platformOverview, style: AppTypography.h2),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        SizedBox(
                          width: 180,
                          child: StatCard(
                            title: l10n.platformCompanies,
                            value: '${o?.companies ?? 0}',
                            icon: Icons.business_outlined,
                          ),
                        ),
                        SizedBox(
                          width: 180,
                          child: StatCard(
                            title: l10n.platformUsers,
                            value: '${o?.users ?? 0}',
                            icon: Icons.people_outline,
                          ),
                        ),
                        SizedBox(
                          width: 180,
                          child: StatCard(
                            title: l10n.platformTrialsActive,
                            value: '${o?.trialsActive ?? 0}',
                            icon: Icons.hourglass_top_outlined,
                          ),
                        ),
                        SizedBox(
                          width: 180,
                          child: StatCard(
                            title: l10n.platformTrialsExpired,
                            value: '${o?.trialsExpired ?? 0}',
                            icon: Icons.hourglass_bottom_outlined,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Text(l10n.platformCompanies, style: AppTypography.h2),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _searchCtrl,
                      decoration: InputDecoration(
                        hintText: l10n.platformSearchCompanies,
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.arrow_forward),
                          onPressed: () {
                            vm.setSearchQuery(_searchCtrl.text);
                            vm.search();
                          },
                        ),
                      ),
                      onSubmitted: (v) {
                        vm.setSearchQuery(v);
                        vm.search();
                      },
                    ),
                    const SizedBox(height: 16),
                    if (vm.companies.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Text(
                          l10n.platformNoCompanies,
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      )
                    else
                      ...vm.companies.map(
                        (c) => _CompanyTile(
                          company: c,
                          l10n: l10n,
                          busy: vm.actionBusy,
                          onSuspend: () => _onAction(
                            () => vm.setCompanyStatus(c, 'suspended'),
                          ),
                          onActivate: () => _onAction(
                            () => vm.setCompanyStatus(c, 'active'),
                          ),
                          onExtendTrial: () => _onAction(() => vm.extendTrial(c)),
                          onSetStarter: () =>
                              _onAction(() => vm.activatePlan(c, 'starter')),
                          onSetGrowth: () =>
                              _onAction(() => vm.activatePlan(c, 'growth')),
                        ),
                      ),
                  ],
                ),
              ),
          },
        );
      },
    );
  }
}

class _CompanyTile extends StatelessWidget {
  const _CompanyTile({
    required this.company,
    required this.l10n,
    required this.busy,
    required this.onSuspend,
    required this.onActivate,
    required this.onExtendTrial,
    required this.onSetStarter,
    required this.onSetGrowth,
  });

  final PlatformCompany company;
  final AppStrings l10n;
  final bool busy;
  final VoidCallback onSuspend;
  final VoidCallback onActivate;
  final VoidCallback onExtendTrial;
  final VoidCallback onSetStarter;
  final VoidCallback onSetGrowth;

  @override
  Widget build(BuildContext context) {
    final suspended = company.isSuspended;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(company.name, style: AppTypography.h3),
                ),
                Chip(
                  label: Text(company.plan.toUpperCase()),
                  visualDensity: VisualDensity.compact,
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text(company.status),
                  backgroundColor: suspended
                      ? AppColors.error.withValues(alpha: 0.12)
                      : AppColors.success.withValues(alpha: 0.12),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            if (company.email != null) ...[
              const SizedBox(height: 4),
              Text(company.email!, style: AppTypography.caption),
            ],
            const SizedBox(height: 4),
            Text(
              '${l10n.employees}: ${company.employeeCount ?? 0}'
              '${company.employeeLimit != null ? ' / ${company.employeeLimit}' : ''}',
              style: AppTypography.caption,
            ),
            if (company.trialEndsAt != null) ...[
              const SizedBox(height: 4),
              Text(
                l10n.trialEndsOn(company.trialEndsAt!.split('T').first),
                style: AppTypography.caption,
              ),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (suspended)
                  OutlinedButton(
                    onPressed: busy ? null : onActivate,
                    child: Text(l10n.platformActivateCompany),
                  )
                else
                  OutlinedButton(
                    onPressed: busy ? null : onSuspend,
                    child: Text(l10n.platformSuspendCompany),
                  ),
                OutlinedButton(
                  onPressed: busy ? null : onExtendTrial,
                  child: Text(l10n.platformExtendTrial),
                ),
                FilledButton.tonal(
                  onPressed: busy ? null : onSetStarter,
                  child: Text(l10n.platformSetStarter),
                ),
                FilledButton.tonal(
                  onPressed: busy ? null : onSetGrowth,
                  child: Text(l10n.platformSetGrowth),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
