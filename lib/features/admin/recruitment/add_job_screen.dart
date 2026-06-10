import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/repositories/recruitment_repository.dart';
import '../../../core/api/api_result.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';

class AddJobScreen extends StatefulWidget {
  const AddJobScreen({super.key, this.editJob});

  final JobItem? editJob;

  @override
  State<AddJobScreen> createState() => _AddJobScreenState();
}

class _AddJobScreenState extends State<AddJobScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _deptCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _descCtrl;
  String _status = 'open';
  bool _saving = false;

  bool get _isEditing => widget.editJob != null;

  @override
  void initState() {
    super.initState();
    final job = widget.editJob;
    _titleCtrl = TextEditingController(text: job?.title ?? '');
    _deptCtrl = TextEditingController(text: job?.department ?? '');
    _locationCtrl = TextEditingController(text: job?.location ?? '');
    _descCtrl = TextEditingController(text: job?.description ?? '');
    _status = job?.status ?? 'open';
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _deptCtrl.dispose();
    _locationCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);

    final l10n = AppLocalizations.of(context)!;

    ApiResult result;
    if (_isEditing) {
      result = await RecruitmentRepository.instance.updateJob(
        widget.editJob!.id,
        title: _titleCtrl.text.trim(),
        department: _deptCtrl.text.trim().isEmpty ? null : _deptCtrl.text.trim(),
        location: _locationCtrl.text.trim().isEmpty ? null : _locationCtrl.text.trim(),
        description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        status: _status,
      );
    } else {
      result = await RecruitmentRepository.instance.createJob(
        title: _titleCtrl.text.trim(),
        department: _deptCtrl.text.trim().isEmpty ? null : _deptCtrl.text.trim(),
        location: _locationCtrl.text.trim().isEmpty ? null : _locationCtrl.text.trim(),
        description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        status: _status,
      );
    }

    if (!mounted) return;
    setState(() => _saving = false);

    switch (result) {
      case ApiSuccess():
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(_isEditing ? l10n.jobUpdated : l10n.jobCreated),
          backgroundColor: AppColors.success,
        ));
        context.pop();
      case ApiFailure(:final message):
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(message),
          backgroundColor: AppColors.error,
        ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
              const SizedBox(width: 8),
              Text(_isEditing ? l10n.editJob : l10n.addJob, style: AppTypography.h1),
            ],
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _titleCtrl,
                      decoration: InputDecoration(
                        labelText: l10n.jobTitleField,
                        prefixIcon: const Icon(Icons.work),
                      ),
                      validator: (v) => (v?.trim().isEmpty ?? true) ? l10n.fieldRequired : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _deptCtrl,
                      decoration: InputDecoration(
                        labelText: l10n.department,
                        prefixIcon: const Icon(Icons.business),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _locationCtrl,
                      decoration: InputDecoration(
                        labelText: l10n.jobLocationField,
                        prefixIcon: const Icon(Icons.location_on),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descCtrl,
                      decoration: InputDecoration(
                        labelText: l10n.jobDescriptionField,
                        prefixIcon: const Icon(Icons.description),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 4,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      key: ValueKey(_status),
                      initialValue: _status,
                      decoration: InputDecoration(
                        labelText: l10n.status,
                        prefixIcon: const Icon(Icons.flag_outlined),
                      ),
                      items: [
                        DropdownMenuItem(value: 'open', child: Text(l10n.jobStatusOpen)),
                        DropdownMenuItem(value: 'closed', child: Text(l10n.jobStatusClosed)),
                        DropdownMenuItem(value: 'draft', child: Text(l10n.jobStatusDraft)),
                      ],
                      onChanged: (v) => setState(() => _status = v ?? 'open'),
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _saving ? null : _save,
                      child: _saving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : Text(l10n.save),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
