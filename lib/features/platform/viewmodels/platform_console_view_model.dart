import '../../../core/api/api_result.dart';
import '../../../core/mvvm/view_model.dart';
import '../../../core/repositories/auth_repository.dart';
import '../data/platform_repository.dart';
import '../models/platform_models.dart';

/// ViewModel for the platform (super_admin) console.
class PlatformConsoleViewModel extends ViewModel {
  PlatformConsoleViewModel({
    PlatformRepository? repository,
  }) : _repo = repository ?? const PlatformRepository();

  final PlatformRepository _repo;

  ViewStatus status = ViewStatus.loading;
  String? errorMessage;
  PlatformOverview? overview;
  List<PlatformCompany> companies = const [];
  String searchQuery = '';
  String? actionMessage;
  bool actionBusy = false;

  Future<void> load() async {
    update(() {
      status = ViewStatus.loading;
      errorMessage = null;
    });

    final results = await Future.wait([
      _repo.overview(),
      _repo.companies(search: searchQuery.trim()),
    ]);
    if (isDisposed) return;

    final overviewRes = results[0];
    final companiesRes = results[1];

    if (overviewRes is ApiFailure<dynamic> || companiesRes is ApiFailure<dynamic>) {
      update(() {
        status = ViewStatus.error;
        errorMessage = overviewRes is ApiFailure<dynamic>
            ? (overviewRes as ApiFailure<dynamic>).message
            : (companiesRes as ApiFailure<dynamic>).message;
      });
      return;
    }

    update(() {
      status = ViewStatus.ready;
      overview = (overviewRes as ApiSuccess<PlatformOverview>).data;
      companies = (companiesRes as ApiSuccess<List<PlatformCompany>>).data;
    });
  }

  void setSearchQuery(String value) {
    searchQuery = value;
  }

  Future<void> search() => load();

  Future<String?> setCompanyStatus(PlatformCompany company, String statusValue) {
    return _runAction(
      () => _repo.updateCompany(company.id, status: statusValue),
    );
  }

  Future<String?> extendTrial(PlatformCompany company) {
    return _runAction(
      () => _repo.updateCompany(company.id, extendTrialDays: 14),
    );
  }

  Future<String?> activatePlan(PlatformCompany company, String plan) {
    return _runAction(
      () => _repo.activatePlanManual(company.id, plan),
    );
  }

  Future<void> logout() => AuthRepository.logout();

  Future<String?> _runAction(Future<ApiResult<dynamic>> Function() action) async {
    update(() {
      actionBusy = true;
      actionMessage = null;
    });
    final res = await action();
    if (isDisposed) return null;

    if (res is ApiFailure<dynamic>) {
      final msg = res.message;
      update(() {
        actionBusy = false;
        actionMessage = msg;
      });
      return msg;
    }

    update(() => actionBusy = false);
    await load();
    return null;
  }
}
