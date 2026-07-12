import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_strings.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../core/api/api_result.dart';
import '../../../core/api/api_config.dart';
import '../../../core/repositories/employees_repository.dart';

class EmployeesScreen extends StatefulWidget {
  const EmployeesScreen({super.key});

  @override
  State<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends State<EmployeesScreen> {
  final _searchController = TextEditingController();
  List<EmployeeItem> _employees = [];
  bool _loading = true;
  bool _loadingMore = false;
  String? _error;
  String? _filterDepartment;
  String? _currentUserEmail;
  int _currentPage = 1;
  int _lastPage = 1;
  int _total = 0;

  Future<void> _deleteEmployee(EmployeeItem e) async {
    final l10n = AppStrings.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.delete),
        content: Text('${l10n.delete} ${e.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    final result = await EmployeesRepository.deleteEmployee(e.id);
    if (!mounted) return;
    if (result is ApiFailure<void>) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message), backgroundColor: AppColors.error),
      );
      return;
    }

    setState(() {
      _employees.removeWhere((x) => x.id == e.id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.delete), backgroundColor: AppColors.success),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _load();
  }

  Future<void> _loadCurrentUser() async {
    final u = await ApiConfig.getUser();
    if (!mounted) return;
    setState(() => _currentUserEmail = u?['email']?.toString());
  }

  Future<void> _load({bool reset = true}) async {
    if (reset) {
      setState(() { _loading = true; _error = null; _currentPage = 1; _employees = []; });
    }
    final result = await EmployeesRepository.getEmployeesPaged(
      page: _currentPage,
      search: _searchController.text.trim().isEmpty ? null : _searchController.text.trim(),
      department: _filterDepartment,
    );
    if (!mounted) return;
    switch (result) {
      case ApiSuccess(:final data):
        setState(() {
          if (reset) {
            _employees = data.items;
          } else {
            _employees = [..._employees, ...data.items];
          }
          _currentPage = data.currentPage;
          _lastPage = data.lastPage;
          _total = data.total;
          _loading = false;
          _loadingMore = false;
        });
      case ApiFailure(:final message):
        setState(() { _error = message; _loading = false; _loadingMore = false; });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message), backgroundColor: AppColors.error),
          );
        }
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore || _currentPage >= _lastPage) return;
    setState(() { _loadingMore = true; _currentPage++; });
    await _load(reset: false);
  }

  void _onSearchChanged(String _) {
    _currentPage = 1;
    _load();
  }

  void _showDepartmentFilter() {
    final l10n = AppStrings.of(context);
    // نجمع الأقسام من البيانات المحمّلة حالياً
    final depts = _employees.map((e) => e.department).whereType<String>().toSet().toList()..sort();
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(l10n.filterAllDepartments),
              leading: const Icon(Icons.clear_all),
              onTap: () {
                Navigator.pop(ctx);
                setState(() => _filterDepartment = null);
                _load();
              },
            ),
            const Divider(height: 1),
            ...depts.map((d) => ListTile(
              title: Text(d),
              selected: _filterDepartment == d,
              onTap: () {
                Navigator.pop(ctx);
                setState(() => _filterDepartment = d);
                _load();
              },
            )),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppStrings.of(context);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 640;
            final addBtn = FilledButton.icon(
              onPressed: () => context.push('/admin/employees/add'),
              icon: const Icon(Icons.add),
              label: Text(l10n.addEmployee),
            );
            final refreshBtn = IconButton(
              onPressed: _loading ? null : _load,
              icon: const Icon(Icons.refresh),
              tooltip: l10n.refreshAction,
            );
            if (isNarrow) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.employees, style: AppTypography.h1),
                  if (_total > 0)
                    Text('$_total ${l10n.employees}', style: AppTypography.caption),
                  const SizedBox(height: 12),
                  Wrap(spacing: 8, runSpacing: 8, children: [refreshBtn, addBtn]),
                ],
              );
            }
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.employees, style: AppTypography.h1),
                    if (_total > 0)
                      Text('$_total ${l10n.employees}', style: AppTypography.caption),
                  ],
                ),
                Row(children: [refreshBtn, addBtn]),
              ],
            );
          }),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: l10n.search,
                            prefixIcon: const Icon(Icons.search),
                            isDense: true,
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, size: 18),
                                    onPressed: () {
                                      _searchController.clear();
                                      _load();
                                    },
                                  )
                                : null,
                          ),
                          onChanged: _onSearchChanged,
                        ),
                      ),
                      const SizedBox(width: 16),
                      OutlinedButton.icon(
                        onPressed: _showDepartmentFilter,
                        icon: const Icon(Icons.filter_list),
                        label: Text(
                          _filterDepartment == null
                              ? l10n.filter
                              : l10n.filterDepartmentButton(_filterDepartment!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (_loading)
                    const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (_error != null)
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(_error!, style: AppTypography.bodyMedium.copyWith(color: AppColors.error)),
                    )
                  else ...[
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: [
                          DataColumn(label: Text(l10n.name)),
                          DataColumn(label: Text(l10n.email)),
                          DataColumn(label: Text(l10n.department)),
                          DataColumn(label: Text(l10n.position)),
                          DataColumn(label: Text(l10n.status)),
                          DataColumn(label: Text(l10n.actions)),
                        ],
                        rows: _employees.map((e) => _dataRow(context, e)).toList(),
                      ),
                    ),
                    if (_currentPage < _lastPage)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: _loadingMore
                            ? const CircularProgressIndicator()
                            : OutlinedButton.icon(
                                onPressed: _loadMore,
                                icon: const Icon(Icons.expand_more),
                                label: Text(
                                  '${l10n.viewAll} (${_employees.length}/$_total)',
                                ),
                              ),
                      ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  DataRow _dataRow(BuildContext context, EmployeeItem e) {
    final l10n = AppStrings.of(context);
    final isSelf = _currentUserEmail != null &&
        _currentUserEmail!.isNotEmpty &&
        e.email.toLowerCase() == _currentUserEmail!.toLowerCase();
    return DataRow(
      cells: [
        DataCell(Text(e.name, style: AppTypography.bodyMedium)),
        DataCell(Text(e.email, style: AppTypography.bodySmall)),
        DataCell(Text(e.department ?? '—', style: AppTypography.bodySmall)),
        DataCell(Text(e.position ?? '—', style: AppTypography.bodySmall)),
        DataCell(StatusBadge(
          label: e.active ? l10n.active : l10n.inactive,
          status: e.active ? StatusType.success : StatusType.neutral,
        )),
        DataCell(Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.visibility_outlined),
              onPressed: () => context.push('/admin/employees/${e.id}/view'),
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => context.push('/admin/employees/${e.id}'),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              color: AppColors.error,
              onPressed: isSelf ? null : () => _deleteEmployee(e),
              tooltip: isSelf ? l10n.cannotDeleteOwnAccount : l10n.delete,
            ),
          ],
        )),
      ],
    );
  }
}
