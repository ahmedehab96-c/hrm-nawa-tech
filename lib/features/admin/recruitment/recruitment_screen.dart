import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/repositories/recruitment_repository.dart';
import '../../../core/api/api_result.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/widgets/status_badge.dart';

class RecruitmentScreen extends StatefulWidget {
  const RecruitmentScreen({super.key});

  @override
  State<RecruitmentScreen> createState() => _RecruitmentScreenState();
}

class _RecruitmentScreenState extends State<RecruitmentScreen> {
  List<JobItem>? _jobs;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    final result = await RecruitmentRepository.instance.getJobs();
    if (!mounted) return;
    switch (result) {
      case ApiSuccess(:final data):
        setState(() { _jobs = data; _loading = false; });
      case ApiFailure(:final message):
        setState(() { _error = message; _loading = false; });
    }
  }

  Future<void> _deleteJob(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete job?'),
        content: const Text('This will also delete all candidates for this job.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await RecruitmentRepository.instance.deleteJob(id);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return RefreshIndicator(
      onRefresh: _load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.recruitment, style: AppTypography.h1),
                FilledButton.icon(
                  onPressed: () async {
                    await context.push('/admin/recruitment/add');
                    _load();
                  },
                  icon: const Icon(Icons.add),
                  label: Text(l10n.addJob),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(l10n.jobListings, style: AppTypography.h4),
            const SizedBox(height: 16),
            if (_loading)
              const Center(child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ))
            else if (_error != null)
              Center(child: Column(
                children: [
                  Text(_error!, style: AppTypography.bodyMedium.copyWith(color: AppColors.error)),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _load,
                    icon: const Icon(Icons.refresh),
                    label: Text(l10n.retryAction),
                  ),
                ],
              ))
            else if (_jobs == null || _jobs!.isEmpty)
              Center(child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(Icons.work_outline, size: 48, color: AppColors.textMuted),
                    const SizedBox(height: 12),
                    Text(l10n.noJobsYet, style: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted)),
                  ],
                ),
              ))
            else
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: _jobs!.map((job) => _JobCard(
                  job: job,
                  onDelete: () => _deleteJob(job.id),
                  onTap: () async {
                    await context.push('/admin/recruitment/job/${job.id}');
                    _load();
                  },
                )).toList(),
              ),
            const SizedBox(height: 32),
            if (_jobs != null && _jobs!.isNotEmpty) ...[
              Text(l10n.candidates, style: AppTypography.h4),
              const SizedBox(height: 16),
              _CandidatePipelineRow(jobs: _jobs!),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Job Card ─────────────────────────────────────────────────────────────────

class _JobCard extends StatelessWidget {
  const _JobCard({required this.job, required this.onTap, required this.onDelete});

  final JobItem job;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            width: 280,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(job.title, style: AppTypography.h4)),
                    StatusBadge(
                      label: job.status,
                      status: job.status == 'open' ? StatusType.success : StatusType.neutral,
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18),
                      color: AppColors.error,
                      onPressed: onDelete,
                      tooltip: l10n.delete,
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
                if (job.department != null) ...[
                  const SizedBox(height: 4),
                  Text(job.department!, style: AppTypography.bodySmall),
                ],
                if (job.location != null) ...[
                  const SizedBox(height: 4),
                  Row(children: [
                    Icon(Icons.location_on_outlined, size: 14, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text(job.location!, style: AppTypography.caption),
                  ]),
                ],
                const SizedBox(height: 8),
                Text(
                  l10n.recruitmentApplicantsCount(job.candidatesCount),
                  style: AppTypography.caption,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Pipeline summary row ─────────────────────────────────────────────────────

class _CandidatePipelineRow extends StatelessWidget {
  const _CandidatePipelineRow({required this.jobs});

  final List<JobItem> jobs;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final all = jobs.expand((j) => j.candidates).toList();
    final stages = [
      ('new', l10n.recruitmentStageNew, AppColors.textMuted),
      ('interview', l10n.recruitmentStageInterview, AppColors.warning),
      ('offer', l10n.recruitmentStageOffer, AppColors.info),
      ('hired', l10n.recruitmentStageHired, AppColors.success),
    ];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: stages.map((s) {
        final (key, label, color) = s;
        final candidates = all.where((c) => c.stage == key).toList();
        return Expanded(child: _KanbanColumn(
          title: label,
          candidates: candidates,
          color: color,
        ));
      }).toList(),
    );
  }
}

class _KanbanColumn extends StatelessWidget {
  const _KanbanColumn({required this.title, required this.candidates, required this.color});

  final String title;
  final List<CandidateItem> candidates;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(title, style: AppTypography.label)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('${candidates.length}', style: AppTypography.bodySmall),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...candidates.take(3).map((c) => Card(
            margin: const EdgeInsets.only(bottom: 6),
            child: ListTile(
              dense: true,
              leading: const CircleAvatar(radius: 16, child: Icon(Icons.person, size: 16)),
              title: Text(c.name, style: AppTypography.bodySmall),
              subtitle: c.email != null ? Text(c.email!, style: AppTypography.caption) : null,
            ),
          )),
          if (candidates.length > 3)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '+${candidates.length - 3} more',
                style: AppTypography.caption.copyWith(color: AppColors.textMuted),
              ),
            ),
        ],
      ),
    );
  }
}
