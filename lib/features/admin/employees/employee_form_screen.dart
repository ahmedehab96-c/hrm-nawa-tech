import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_result.dart';
import '../../../core/repositories/employees_repository.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_strings.dart';

class EmployeeFormScreen extends StatefulWidget {
  const EmployeeFormScreen({super.key, this.employeeId});
  final String? employeeId;

  @override
  State<EmployeeFormScreen> createState() => _EmployeeFormScreenState();
}

class _EmployeeFormScreenState extends State<EmployeeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _birthDate = TextEditingController();
  final _department = TextEditingController();
  final _position = TextEditingController();
  final _hireDate = TextEditingController();
  final _baseSalary = TextEditingController();
  final _allowances = TextEditingController();
  final _deductions = TextEditingController();
  final _insurancePolicy = TextEditingController();
  final _coverageStart = TextEditingController();
  final _coverageEnd = TextEditingController();
  final _appPassword = TextEditingController();
  final _appPasswordConfirm = TextEditingController();

  String _status = 'active';
  bool _loadingEmp = true;
  bool _saving = false;
  bool _enableAppLogin = false;
  bool _appLoginEnabledInitial = false;
  bool _obscureAppPassword = true;
  bool _obscureAppPasswordConfirm = true;

  @override
  void initState() {
    super.initState();
    _loadEmployee();
  }

  @override
  void dispose() {
    for (final c in [
      _name,
      _email,
      _phone,
      _birthDate,
      _department,
      _position,
      _hireDate,
      _baseSalary,
      _allowances,
      _deductions,
      _insurancePolicy,
      _coverageStart,
      _coverageEnd,
      _appPassword,
      _appPasswordConfirm,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _loadEmployee() async {
    final id = widget.employeeId;
    if (id == null) {
      setState(() => _loadingEmp = false);
      return;
    }
    final res = await EmployeesRepository.getEmployee(id);
    if (!mounted) return;
    if (res is ApiSuccess<EmployeeItem>) {
      final e = res.data;
      _name.text = e.name;
      _email.text = e.email;
      _phone.text = e.phone ?? '';
      _birthDate.text = e.birthDate ?? '';
      _department.text = e.department ?? '';
      _position.text = e.position ?? '';
      _hireDate.text = e.hireDate ?? '';
      _status = e.active ? 'active' : 'inactive';
      _baseSalary.text = e.baseSalary ?? '';
      _allowances.text = e.allowances ?? '';
      _deductions.text = e.deductions ?? '';
      _insurancePolicy.text = e.insurancePolicyNumber ?? '';
      _coverageStart.text = e.coverageStart ?? '';
      _coverageEnd.text = e.coverageEnd ?? '';
      _appLoginEnabledInitial = e.appLoginEnabled ?? false;
      _enableAppLogin = _appLoginEnabledInitial;
    }
    setState(() => _loadingEmp = false);
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final now = DateTime.now();
    DateTime initial = now;
    if (controller.text.isNotEmpty) {
      initial = DateTime.tryParse(controller.text) ?? now;
    }
    final selected = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1950),
      lastDate: DateTime(2100),
    );
    if (selected == null) return;
    controller.text = _fmtDate(selected);
    setState(() {});
  }

  String _fmtDate(DateTime d) {
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return '${d.year}-$mm-$dd';
  }

  bool _validateAppLoginForSave(AppStrings l10n) {
    if (!_enableAppLogin) return true;
    final needPassword = widget.employeeId == null || !_appLoginEnabledInitial || _appPassword.text.isNotEmpty;
    if (!needPassword) return true;
    if (_appPassword.text.length < 8 || _appPassword.text != _appPasswordConfirm.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.appAccessPasswordMismatch), backgroundColor: AppColors.error),
      );
      return false;
    }
    return true;
  }

  Future<bool> _syncAppAccessAfterProfileSave() async {
    if (widget.employeeId == null) return true;
    final id = widget.employeeId!;
    if (!_enableAppLogin && _appLoginEnabledInitial) {
      final r = await EmployeesRepository.setEmployeeAppAccess(id, enabled: false);
      return r is! ApiFailure;
    }
    if (!_enableAppLogin) return true;
    final needPassword = !_appLoginEnabledInitial || _appPassword.text.isNotEmpty;
    if (!needPassword) return true;
    final r = await EmployeesRepository.setEmployeeAppAccess(
      id,
      enabled: true,
      password: _appPassword.text,
      passwordConfirmation: _appPasswordConfirm.text,
    );
    return r is! ApiFailure;
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final l10n = AppStrings.of(context);
    if (!_validateAppLoginForSave(l10n)) return;
    setState(() => _saving = true);

    final body = <String, dynamic>{
      'name': _name.text.trim(),
      'email': _email.text.trim(),
      'phone': _phone.text.trim(),
      'birth_date': _birthDate.text.trim().isEmpty ? null : _birthDate.text.trim(),
      'department': _department.text.trim(),
      'position': _position.text.trim(),
      'hire_date': _hireDate.text.trim().isEmpty ? null : _hireDate.text.trim(),
      'is_active': _status == 'active',
      'insurance_policy_number': _insurancePolicy.text.trim(),
      'coverage_start': _coverageStart.text.trim().isEmpty ? null : _coverageStart.text.trim(),
      'coverage_end': _coverageEnd.text.trim().isEmpty ? null : _coverageEnd.text.trim(),
      'base_salary': _baseSalary.text.trim().isEmpty ? 0 : _baseSalary.text.trim(),
      'allowances': _allowances.text.trim().isEmpty ? 0 : _allowances.text.trim(),
      'deductions': _deductions.text.trim().isEmpty ? 0 : _deductions.text.trim(),
    };
    if (widget.employeeId == null && _enableAppLogin) {
      body['enable_app_login'] = true;
      body['password'] = _appPassword.text;
      body['password_confirmation'] = _appPasswordConfirm.text;
    }

    final ApiResult<void> res = widget.employeeId != null
        ? await EmployeesRepository.updateEmployee(widget.employeeId!, body)
        : await EmployeesRepository.createEmployee(body);

    if (!mounted) return;
    setState(() => _saving = false);
    if (res is ApiFailure<void>) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res.message), backgroundColor: AppColors.error),
      );
      return;
    }
    if (widget.employeeId != null) {
      final syncOk = await _syncAppAccessAfterProfileSave();
      if (!syncOk || !mounted) return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.formSavedSuccess), backgroundColor: AppColors.success),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppStrings.of(context);
    if (_loadingEmp) {
      return const Center(child: Padding(padding: EdgeInsets.all(48), child: CircularProgressIndicator()));
    }
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
              const SizedBox(width: 8),
              Text(widget.employeeId != null ? l10n.editEmployee : l10n.addEmployee, style: AppTypography.h1),
            ],
          ),
          const SizedBox(height: 24),
          Card(
            child: DefaultTabController(
              length: 5,
              child: Column(
                children: [
                  TabBar(
                    labelColor: AppColors.primary,
                    isScrollable: true,
                    tabs: [
                      Tab(text: l10n.personalInfo),
                      Tab(text: l10n.jobInfo),
                      Tab(text: l10n.salaryInfo),
                      Tab(text: l10n.insuranceInfo),
                      Tab(text: l10n.employeeAppLoginTab),
                    ],
                  ),
                  SizedBox(
                    height: 430,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: TabBarView(
                          children: [
                            Wrap(spacing: 16, runSpacing: 16, children: [
                              _textField(_name, l10n.fullName, requiredField: true),
                              _textField(_email, l10n.email, requiredField: true, email: true),
                              _textField(_phone, l10n.phone),
                              _dateField(_birthDate, l10n.birthDate),
                            ]),
                            Wrap(spacing: 16, runSpacing: 16, children: [
                              _textField(_department, l10n.department, requiredField: true),
                              _textField(_position, l10n.position, requiredField: true),
                              _dateField(_hireDate, l10n.hireDate),
                              SizedBox(
                                width: 250,
                                child: DropdownButtonFormField<String>(
                                  key: ValueKey(_status),
                                  initialValue: _status,
                                  decoration: InputDecoration(labelText: l10n.status),
                                  items: [
                                    DropdownMenuItem(value: 'active', child: Text(l10n.active)),
                                    DropdownMenuItem(value: 'inactive', child: Text(l10n.inactive)),
                                  ],
                                  onChanged: (v) => setState(() => _status = v ?? 'active'),
                                ),
                              ),
                            ]),
                            Wrap(spacing: 16, runSpacing: 16, children: [
                              _textField(_baseSalary, l10n.breakdownBase, numeric: true),
                              _textField(_allowances, l10n.breakdownAllowances, numeric: true),
                              _textField(_deductions, l10n.breakdownDeductions, numeric: true),
                            ]),
                            Wrap(spacing: 16, runSpacing: 16, children: [
                              _textField(_insurancePolicy, l10n.policyNumber),
                              _dateField(_coverageStart, l10n.coverageStart),
                              _dateField(_coverageEnd, l10n.coverageEnd),
                            ]),
                            _AppLoginSection(
                              enableAppLogin: _enableAppLogin,
                              onEnableChanged: (v) => setState(() => _enableAppLogin = v),
                              appPassword: _appPassword,
                              appPasswordConfirm: _appPasswordConfirm,
                              obscureAppPassword: _obscureAppPassword,
                              obscureAppPasswordConfirm: _obscureAppPasswordConfirm,
                              onToggleObscureApp: () => setState(() => _obscureAppPassword = !_obscureAppPassword),
                              onToggleObscureAppConfirm: () => setState(() => _obscureAppPasswordConfirm = !_obscureAppPasswordConfirm),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(l10n.save),
              ),
              const SizedBox(width: 16),
              OutlinedButton(onPressed: _saving ? null : () => context.pop(), child: Text(l10n.cancel)),
            ],
          ),
        ],
      ),
    );
  }

  SizedBox _textField(
    TextEditingController c,
    String label, {
    bool requiredField = false,
    bool email = false,
    bool numeric = false,
  }) {
    final l10n = AppStrings.of(context);
    return SizedBox(
      width: 250,
      child: TextFormField(
        controller: c,
        keyboardType: email
            ? TextInputType.emailAddress
            : (numeric ? const TextInputType.numberWithOptions(decimal: true) : null),
        decoration: InputDecoration(labelText: label),
        validator: requiredField ? (v) => v?.isEmpty ?? true ? l10n.fieldRequired : null : null,
      ),
    );
  }

  SizedBox _dateField(TextEditingController c, String label) {
    final l10n = AppStrings.of(context);
    return SizedBox(
      width: 250,
      child: TextFormField(
        controller: c,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (c.text.isNotEmpty)
                IconButton(
                  tooltip: l10n.clearAction,
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    c.clear();
                    setState(() {});
                  },
                ),
              IconButton(
                icon: const Icon(Icons.calendar_today_outlined),
                onPressed: () => _pickDate(c),
              ),
            ],
          ),
          suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        ),
        onTap: () => _pickDate(c),
      ),
    );
  }
}


class _AppLoginSection extends StatelessWidget {
  const _AppLoginSection({
    required this.enableAppLogin,
    required this.onEnableChanged,
    required this.appPassword,
    required this.appPasswordConfirm,
    required this.obscureAppPassword,
    required this.obscureAppPasswordConfirm,
    required this.onToggleObscureApp,
    required this.onToggleObscureAppConfirm,
  });

  final bool enableAppLogin;
  final ValueChanged<bool> onEnableChanged;
  final TextEditingController appPassword;
  final TextEditingController appPasswordConfirm;
  final bool obscureAppPassword;
  final bool obscureAppPasswordConfirm;
  final VoidCallback onToggleObscureApp;
  final VoidCallback onToggleObscureAppConfirm;

  @override
  Widget build(BuildContext context) {
    final l10n = AppStrings.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.employeeAppLoginSectionHint,
          style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.enableEmployeeAppLogin),
          value: enableAppLogin,
          onChanged: onEnableChanged,
        ),
        if (enableAppLogin) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              SizedBox(
                width: 280,
                child: TextFormField(
                  controller: appPassword,
                  obscureText: obscureAppPassword,
                  decoration: InputDecoration(
                    labelText: l10n.employeeAppPassword,
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(obscureAppPassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: onToggleObscureApp,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 280,
                child: TextFormField(
                  controller: appPasswordConfirm,
                  obscureText: obscureAppPasswordConfirm,
                  decoration: InputDecoration(
                    labelText: l10n.employeeAppPasswordConfirm,
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureAppPasswordConfirm ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: onToggleObscureAppConfirm,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
