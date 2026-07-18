import 'package:flutter/material.dart';

import '../../../core/api/api_result.dart';
import 'package:hrm_saas/features/employee/leave/data/leave_repository.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/text_direction_helper.dart';
import '../../../core/widgets/responsive_page.dart';
import '../../../l10n/app_strings.dart';

class LeaveRequestScreen extends StatefulWidget {
  const LeaveRequestScreen({super.key});

  @override
  State<LeaveRequestScreen> createState() => _LeaveRequestScreenState();
}

class _LeaveRequestScreenState extends State<LeaveRequestScreen> {
  String _type = 'annual';
  DateTime? _from;
  DateTime? _to;
  final _notes = TextEditingController();
  final _fromDisplay = TextEditingController();
  final _toDisplay = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _notes.dispose();
    _fromDisplay.dispose();
    _toDisplay.dispose();
    super.dispose();
  }

  Future<void> _pickFrom() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _from ?? DateTime.now(),
      firstDate: DateTime(DateTime.now().year - 1),
      lastDate: DateTime(DateTime.now().year + 1),
    );
    if (d != null) {
      setState(() {
        _from = d;
        _fromDisplay.text = d.toIso8601String().split('T').first;
      });
    }
  }

  Future<void> _pickTo() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _to ?? _from ?? DateTime.now(),
      firstDate: _from ?? DateTime(DateTime.now().year - 1),
      lastDate: DateTime(DateTime.now().year + 1),
    );
    if (d != null) {
      setState(() {
        _to = d;
        _toDisplay.text = d.toIso8601String().split('T').first;
      });
    }
  }

  Future<void> _submit() async {
    final l10n = AppStrings.of(context);
    if (_from == null || _to == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.fieldRequired), backgroundColor: AppColors.error),
      );
      return;
    }
    final days = _to!.difference(_from!).inDays + 1;
    if (days < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.fieldRequired), backgroundColor: AppColors.error),
      );
      return;
    }

    setState(() => _submitting = true);
    final res = await LeaveRepository.createLeaveRequest({
      'type': _type,
      'from': _from!.toIso8601String().split('T').first,
      'to': _to!.toIso8601String().split('T').first,
      'days': days,
      'notes': _notes.text.trim(),
    });
    if (!mounted) return;
    setState(() => _submitting = false);

    if (res is ApiSuccess<void>) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.formSavedSuccess), backgroundColor: AppColors.success),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text((res as ApiFailure<void>).message),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppStrings.of(context);
    return Directionality(
      textDirection: textDirectionForContext(context),
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.requestLeave),
        ),
        body: ResponsivePage(
          child: ResponsiveFormFrame(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<String>(
                  key: ValueKey(_type),
                  isExpanded: true,
                  initialValue: _type,
                  decoration: InputDecoration(
                    labelText: l10n.leaveType,
                    prefixIcon: const Icon(Icons.event_note),
                  ),
                  items: [
                    DropdownMenuItem(value: 'annual', child: Text(l10n.annualShort)),
                    DropdownMenuItem(value: 'sick', child: Text(l10n.sickShort)),
                    DropdownMenuItem(value: 'emergency', child: Text(l10n.emergencyShort)),
                  ],
                  onChanged: (v) => setState(() => _type = v ?? 'annual'),
                ),
                SizedBox(height: context.responsive.spacing(16)),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final sideBySide = constraints.maxWidth >= 420;
                    final fromField = TextFormField(
                      decoration: InputDecoration(
                        labelText: l10n.leaveColFrom,
                        prefixIcon: const Icon(Icons.calendar_today),
                      ),
                      readOnly: true,
                      controller: _fromDisplay,
                      onTap: _pickFrom,
                    );
                    final toField = TextFormField(
                      decoration: InputDecoration(
                        labelText: l10n.leaveColTo,
                        prefixIcon: const Icon(Icons.calendar_today),
                      ),
                      readOnly: true,
                      controller: _toDisplay,
                      onTap: _pickTo,
                    );
                    if (!sideBySide) {
                      return Column(
                        children: [
                          fromField,
                          SizedBox(height: context.responsive.spacing(16)),
                          toField,
                        ],
                      );
                    }
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: fromField),
                        SizedBox(width: context.responsive.spacing(12)),
                        Expanded(child: toField),
                      ],
                    );
                  },
                ),
                SizedBox(height: context.responsive.spacing(16)),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: l10n.leaveNotes,
                    alignLabelWithHint: true,
                  ),
                  maxLines: 3,
                  controller: _notes,
                ),
                SizedBox(height: context.responsive.spacing(32)),
                FilledButton(
                  onPressed: _submitting ? null : _submit,
                  style: FilledButton.styleFrom(
                    minimumSize: Size(double.infinity, context.responsive.minTouchSize),
                  ),
                  child: _submitting
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.save),
                ),
                SizedBox(height: context.responsive.spacing(12)),
                OutlinedButton(
                  onPressed: _submitting ? null : () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size(double.infinity, context.responsive.minTouchSize),
                  ),
                  child: Text(l10n.cancel),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
