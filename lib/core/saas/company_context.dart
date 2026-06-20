import 'package:flutter/foundation.dart';

import '../repositories/settings_repository.dart';
import '../api/api_result.dart';

/// اسم وبيانات الشركة الحالية (tenant) — تُحمَّل من Laravel API.
class CompanyContext extends ChangeNotifier {
  CompanyContext._();
  static final CompanyContext instance = CompanyContext._();

  CompanySettings? _settings;
  bool _loaded = false;

  CompanySettings? get settings => _settings;
  bool get isLoaded => _loaded;

  String get displayName {
    final name = _settings?.name.trim();
    if (name != null && name.isNotEmpty) return name;
    return '—';
  }

  String get email => _settings?.email ?? '';
  String get phone => _settings?.phone ?? '';
  String get address => _settings?.address ?? '';

  Future<void> load({bool force = false}) async {
    if (_loaded && !force) return;
    final result = await SettingsRepository.instance.getSettings();
    if (result is ApiSuccess<CompanySettings>) {
      _settings = result.data;
      _loaded = true;
      notifyListeners();
    }
  }

  void apply(CompanySettings settings) {
    _settings = settings;
    _loaded = true;
    notifyListeners();
  }

  void clear() {
    _settings = null;
    _loaded = false;
    notifyListeners();
  }
}
