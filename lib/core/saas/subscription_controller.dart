import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// طبقة اشتراك مبسّطة للعرض والتجربة (SaaS). الفوترة الحقيقية تُربَط لاحقاً ببوابة دفع وـ Laravel.
class SubscriptionController extends ChangeNotifier {
  SubscriptionController._();
  static final SubscriptionController instance = SubscriptionController._();

  static const _key = 'saas_plan_id';

  /// `starter` | `growth` | `enterprise`
  String _planId = 'starter';
  String get planId => _planId;

  int get maxEmployees => switch (_planId) {
        'enterprise' => 200,
        'growth' => 50,
        _ => 25,
      };

  bool get recruitmentEnabled => _planId != 'starter';

  /// جاهز لاحقاً لربط OpenAI / مزوّد خارجي
  bool get aiCloudFeaturesEnabled => _planId == 'enterprise';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getString(_key);
    if (v != null && (v == 'starter' || v == 'growth' || v == 'enterprise')) {
      _planId = v;
    }
  }

  Future<void> setPlan(String id) async {
    if (id != 'starter' && id != 'growth' && id != 'enterprise') return;
    _planId = id;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, id);
    notifyListeners();
  }
}
