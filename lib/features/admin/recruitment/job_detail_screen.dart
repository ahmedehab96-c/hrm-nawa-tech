import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/repositories/recruitment_repository.dart';
import '../../../core/api/api_result.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/widgets/status_badge.dart';

class JobDetailScreen extends StatefulWidget {
  const JobDetailScreen({super.key, this.jobId});

  final String? jobId;

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  JobItem? _job;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (widget.jobId == null) return;
    setState(() { _loading = true; _error = null; });
    final result = await RecruitmentRepository.instance.getJob(widget.jobId!);
    if (!mounted) return;
    switch (result) {
      case ApiSuccess(:final data):
        setState(() { _job = data; _loading = false; });
      case ApiFailure(:final message):
        setState(() { _error = message; _loading = false; });
    }
  }

  Future<void> _addCandidateDialog() async {
    if (_job == null) return;
    final l10n = AppLocalizations.of(context)!;
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.addCandidate),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameCtrl,
                  decoration: InputDecoration(labelText: l10n.candidateName),
                  validator: (v) => (v?.trim().isEmpty ?? true) ? l10n.fieldRequired : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: emailCtrl,
                  decoration: InputDecoration(labelText: l10n.candidateEmail),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: phoneCtrl,
                  decoration: InputDecoration(labelText: l10n.candidatePhone),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: notesCtrl,
                  decoration: InputDecoration(labelText: l10n.candidateNotes),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancel)),
          FilledButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.pop(ctx, true);
              }
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final result = await RecruitmentRepository.instance.addCandidate(
      _job!.id,
      name: nameCtrl.text.trim(),
      email: emailCtrl.text.trim().isEmpty ? null : emailCtrl.text.trim(),
      phone: phoneCtrl.text.trim().isEmpty ? null : phoneCtrl.text.trim(),
      notes: notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
    );

    if (!mounted) return;
    switch (result) {
      case ApiSuccess():
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(context)!.candidateAdded),
          backgroundColor: AppColors.success,
        ));
        _load();
      case ApiFailure(:final message):
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(message), backgroundColor: AppColors.error,
        ));
    }
  }

  Future<void> _updateStage(CandidateItem candidate, String newStage) async {
    if (_job == null) return;
    final result = await RecruitmentRepository.instance.updateCandidateStage(
      _job!.id, candidate.id, newStage,
    );
    if (!mounted) return;
    switch (result) {
      case ApiSuccess():
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(context)!.candidateStageUpdated),
          backgroundColor: AppColors.success,
        ));
        _load();
      case ApiFailure(:final message):
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(message), backgroundColor: AppColors.error,
        ));
    }
  }

  Future<void> _deleteCandidate(CandidateItem candidate) async {
    if (_job == null) return;
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.delete),
        content: Text('${l10n.delete} ${candidate.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancel)),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final result = await RecruitmentRepository.instance.deleteCandidate(_job!.id, candidate.id);
    if (!mounted) return;
    switch (result) {
      case ApiSuccess():
        _load();
      case ApiFailure(:final message):
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(message), backgroundColor: AppColors.error,
        ));
    }
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
              children: [
                IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
                const SizedBox(width: 8),
                Text(l10n.recruitmentJobDetailsTitle, style: AppTypography.h1),
              ],
            ),
            const SizedBox(height: 24),
            if (_loading)
              const Center(child: Padding(
                padding: EdgeInsets.all(40),
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
            else if (_job != null) ...[
              _JobInfoCard(job: _job!, onEdit: () async {
                await context.push(
                  '/admin/recruitment/add',
                  extra: _job,
                );
                _load();
              }),
              const SizedBox(height: 24),
              _CandidatesSection(
                job: _job!,
                onAddCandidate: _addCandidateDialog,
                onUpdateStage: _updateStage,
                onDelete: _deleteCandidate,
                onConvert: (c) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(l10n.convertEmployeeHint),
                    backgroundColor: AppColors.info,
                  ));
                  context.push('/admin/employees/add');
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Job Info Card ────────────────────────────────────────────────────────────

class _JobInfoCard extends StatelessWidget {
  const _JobInfoCard({required this.job, required this.onEdit});

  final JobItem job;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(job.title, style: AppTypography.h3)),
                StatusBadge(
                  label: job.status,
                  status: job.status == 'open' ? StatusType.success : StatusType.neutral,
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (job.department != null)
              _DetailRow(icon: Icons.business, label: l10n.department, value: job.department!),
            if (job.location != null)
              _DetailRow(icon: Icons.location_on, label: l10n.recruitmentLocationLabel, value: job.location!),
            _DetailRow(
              icon: Icons.people,
              label: l10n.recruitmentApplicantsLabel,
              value: job.candidatesCount.toString(),
            ),
            if (job.description != null && job.description!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(l10n.recruitmentDescriptionLabel, style: AppTypography.h4),
              const SizedBox(height: 8),
              Text(job.description!, style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
            ],
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onEdit,
              icon: const Icon(Icons.edit),
              label: Text(l10n.editJob),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textMuted),
          const SizedBox(width: 10),
          Text('$label: ', style: AppTypography.label),
          Expanded(child: Text(value, style: AppTypography.bodyMedium)),
        ],
      ),
    );
  }
}

// ─── Candidates Section ───────────────────────────────────────────────────────

class _CandidatesSection extends StatelessWidget {
  const _CandidatesSection({
    required this.job,
    required this.onAddCandidate,
    required this.onUpdateStage,
    required this.onDelete,
    required this.onConvert,
  });

  final JobItem job;
  final VoidCallback onAddCandidate;
  final Future<void> Function(CandidateItem, String) onUpdateStage;
  final Future<void> Function(CandidateItem) onDelete;
  final void Function(CandidateItem) onConvert;

  static const _stages = [
    ('new', Icons.fiber_new_outlined),
    ('interview', Icons.event_outlined),
    ('offer', Icons.description_outlined),
    ('hired', Icons.check_circle_outline),
    ('rejected', Icons.cancel_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l10n.candidates, style: AppTypography.h4),
            FilledButton.icon(
              onPressed: onAddCandidate,
              icon: const Icon(Icons.person_add_outlined, size: 18),
              label: Text(l10n.addCandidate),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (job.candidates.isEmpty)
          Center(child: Padding(
            padding: const EdgeInsets.all(32),
            child: Text(
              'No candidates yet.',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
            ),
          ))
        else
          ...job.candidates.map((c) => _CandidateCard(
            candidate: c,
            stages: _stages,
            onUpdateStage: (stage) => onUpdateStage(c, stage),
            onDelete: () => onDelete(c),
            onConvert: () => onConvert(c),
          )),
      ],
    );
  }
}

class _CandidateCard extends StatelessWidget {
  const _CandidateCard({
    required this.candidate,
    required this.stages,
    required this.onUpdateStage,
    required this.onDelete,
    required this.onConvert,
  });

  final CandidateItem candidate;
  final List<(String, IconData)> stages;
  final void Function(String) onUpdateStage;
  final VoidCallback onDelete;
  final VoidCallback onConvert;

  Color _stageColor(String stage) => switch (stage) {
        'interview' => AppColors.warning,
        'offer' => AppColors.info,
        'hired' => AppColors.success,
        'rejected' => AppColors.error,
        _ => AppColors.textMuted,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final color = _stageColor(candidate.stage);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: color.withValues(alpha: 0.15),
                  child: Icon(Icons.person, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(candidate.name, style: AppTypography.bodyLarge),
                      if (candidate.email != null)
                        Text(candidate.email!, style: AppTypography.caption),
                      if (candidate.phone != null)
                        Text(candidate.phone!, style: AppTypography.caption),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    candidate.stage,
                    style: AppTypography.caption.copyWith(color: color, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            if (candidate.notes != null && candidate.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(candidate.notes!, style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                ...stages.map((s) {
                  final (key, icon) = s;
                  final isActive = candidate.stage == key;
                  return ActionChip(
                    avatar: Icon(icon, size: 14),
                    label: Text(key, style: AppTypography.caption),
                    backgroundColor: isActive ? _stageColor(key).withValues(alpha: 0.15) : null,
                    side: isActive ? BorderSide(color: _stageColor(key)) : null,
                    onPressed: isActive ? null : () => onUpdateStage(key),
                  );
                }),
                if (candidate.stage == 'hired')
                  ActionChip(
                    avatar: const Icon(Icons.person_add, size: 14),
                    label: Text(l10n.convertToEmployee, style: AppTypography.caption),
                    onPressed: onConvert,
                  ),
                ActionChip(
                  avatar: Icon(Icons.delete_outline, size: 14, color: AppColors.error),
                  label: Text(l10n.delete, style: AppTypography.caption.copyWith(color: AppColors.error)),
                  onPressed: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
