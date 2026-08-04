import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ocurithm/core/Network/shared.dart';
import 'package:ocurithm/Main/presentation/manger/main_cubit.dart';

/// Verification for Task 3.3. `getStatusList` already self-validates every
/// drawer entry's capability strings via `CapabilityKeys.debugAssertKnown`
/// (added in Task 0.3, after `manageReciptionists`/`manageSubCategories`/
/// `manageSuppliers`/`managePurchaseOrders` made whole screens unreachable).
/// This test exercises that real runtime path so a future typo fails a test
/// run instead of silently hiding a menu entry again.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await CacheHelper.init();
  });

  test('every drawer entry capability string is a known backend capability',
      () async {
    final cubit = MainCubit();
    await expectLater(cubit.getStatusList(), completes);
  });
}
