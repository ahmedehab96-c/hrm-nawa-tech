import 'package:flutter/widgets.dart';

import 'view_model.dart';

/// Binds a [ViewModel] to the widget tree and disposes it with the State.
mixin ViewModelMixin<T extends StatefulWidget, VM extends ViewModel> on State<T> {
  late final VM viewModel;

  /// Create the ViewModel once when the State is inserted.
  VM createViewModel();

  @override
  void initState() {
    super.initState();
    viewModel = createViewModel();
  }

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }
}
