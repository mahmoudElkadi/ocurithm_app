import 'package:flutter_test/flutter_test.dart';
import 'package:ocurithm/modules/Order/data/models/order_model.dart';

/// Verification for Task 0.2 (Blocker 1). The backend hard-requires
/// `paymentMethod` on order create/update, and returns it either populated or
/// as a bare id string depending on the endpoint. These tests pin the tolerant
/// parsing and the write-back shape so the field can't quietly stop
/// round-tripping.
void main() {
  group('Order.fromJson paymentMethod', () {
    test('a populated object parses into a full PaymentMethod', () {
      final order = Order.fromJson({
        'items': [],
        'paymentMethod': {'id': 'pm1', 'title': 'Cash'},
      });

      expect(order.paymentMethod?.id, 'pm1');
      expect(order.paymentMethod?.title, 'Cash');
    });

    test('a bare id string is tolerated', () {
      final order = Order.fromJson({
        'items': [],
        'paymentMethod': 'pm1',
      });

      expect(order.paymentMethod?.id, 'pm1');
    });

    test('a missing paymentMethod stays null rather than throwing', () {
      final order = Order.fromJson({'items': []});

      expect(order.paymentMethod, isNull);
    });
  });

  group('Order.toJson', () {
    test('writes paymentMethod as a bare id', () {
      final order = Order.fromJson({
        'items': [],
        'paymentMethod': {'id': 'pm1', 'title': 'Cash'},
      });

      expect(order.toJson()['paymentMethod'], 'pm1');
    });
  });
}
