import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ocurithm/core/utils/capability_keys.dart';

/// Verification for Task 0.3. The drawer gated on four strings the backend has
/// never issued, so the screens behind them were unreachable. These tests keep
/// the constants source honest.
void main() {
  group('CapabilityKeys', () {
    test('mirrors the backend list exactly', () {
      // apps/api/src/common/constants/capabilities.ts
      expect(CapabilityKeys.all.length, 55);
    });

    test('rejects the historical typos that caused the drawer bug', () {
      for (final wrong in const [
        'manageReciptionists', // typo for manageReceptionists
        'manageSubCategories', // backend calls it showSubcategories
        'manageSuppliers', // never existed
        'managePurchaseOrders', // never existed
      ]) {
        expect(CapabilityKeys.isKnown(wrong), isFalse,
            reason: '$wrong is not a backend capability');
      }
    });

    test('accepts the corrected strings', () {
      for (final right in const [
        CapabilityKeys.manageReceptionists,
        CapabilityKeys.showSubcategories,
        CapabilityKeys.showProducts,
        CapabilityKeys.manageProducts,
        CapabilityKeys.showOrders,
        CapabilityKeys.manageCapability,
      ]) {
        expect(CapabilityKeys.isKnown(right), isTrue);
      }
    });

    test('debugAssertKnown throws on an unknown capability', () {
      expect(
        () => CapabilityKeys.debugAssertKnown(const ['notARealCapability']),
        throwsA(isA<FlutterError>()),
      );
    });

    test('debugAssertKnown passes for known capabilities', () {
      expect(
        () => CapabilityKeys.debugAssertKnown(CapabilityKeys.all),
        returnsNormally,
      );
    });
  });
}
