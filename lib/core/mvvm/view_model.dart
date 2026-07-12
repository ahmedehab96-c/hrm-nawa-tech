import 'package:flutter/foundation.dart';

/// Base class for feature ViewModels (MVVM).
///
/// - Holds UI state and commands
/// - Talks to repositories / services (Model layer)
/// - Never imports Flutter widgets (only `foundation`)
abstract class ViewModel extends ChangeNotifier {
  bool _disposed = false;
  bool get isDisposed => _disposed;

  /// Mutate state then notify listeners (only while alive).
  @protected
  void update(VoidCallback fn) {
    if (_disposed) return;
    fn();
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

/// Lightweight async UI status shared across ViewModels.
enum ViewStatus { idle, loading, ready, error }
