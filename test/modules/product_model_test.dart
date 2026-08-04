import 'package:flutter_test/flutter_test.dart';
import 'package:ocurithm/modules/Product/data/models/product_model.dart';

/// Verification for Task 3.1 (§9 W18) — see category_model_test.dart for the
/// full explanation. Same contract, same bug, same fix, for products.
void main() {
  group('Product.fromJson', () {
    test('image object splits into a display url and a write-back key', () {
      final product = Product.fromJson({
        'id': 'p1',
        'name': 'Lens Cleaner',
        'image': {
          'key': 'product-image/abc.png',
          'url': 'https://signed.example.com/abc.png?sig=1',
        },
      });

      expect(product.image, 'https://signed.example.com/abc.png?sig=1');
      expect(product.imageKey, 'product-image/abc.png');
    });

    test('null image stays null on both fields', () {
      final product = Product.fromJson({'id': 'p1', 'name': 'Lens Cleaner'});

      expect(product.image, isNull);
      expect(product.imageKey, isNull);
    });
  });

  group('Product.toJson', () {
    test('writes the storage key back, never the resolved url', () {
      final product = Product.fromJson({
        'id': 'p1',
        'name': 'Lens Cleaner',
        'image': {
          'key': 'product-image/abc.png',
          'url': 'https://signed.example.com/abc.png?sig=1',
        },
      });

      final payload = product.toJson();

      expect(payload['image'], 'product-image/abc.png');
    });
  });
}
