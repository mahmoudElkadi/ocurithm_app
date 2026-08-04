import 'package:flutter_test/flutter_test.dart';
import 'package:ocurithm/modules/SubCategory/data/models/sub_category_model.dart';

/// Verification for Task 3.1 (§9 W18) — see category_model_test.dart for the
/// full explanation. Sub-categories reuse `FileCategory.CATEGORY_IMAGE` on the
/// backend, so they share the exact same `{key,url,expiresAt}` read/write
/// contract as Category and Product.
void main() {
  group('SubCategory.fromJson', () {
    test('image object splits into a display url and a write-back key', () {
      final subCategory = SubCategory.fromJson({
        'id': 'sc1',
        'name': 'Sunglasses',
        'image': {
          'key': 'category-image/abc.png',
          'url': 'https://signed.example.com/abc.png?sig=1',
        },
      });

      expect(subCategory.image, 'https://signed.example.com/abc.png?sig=1');
      expect(subCategory.imageKey, 'category-image/abc.png');
    });

    test('null image stays null on both fields', () {
      final subCategory =
          SubCategory.fromJson({'id': 'sc1', 'name': 'Sunglasses'});

      expect(subCategory.image, isNull);
      expect(subCategory.imageKey, isNull);
    });
  });

  group('SubCategory.toJson', () {
    test('writes the storage key back, never the resolved url', () {
      final subCategory = SubCategory.fromJson({
        'id': 'sc1',
        'name': 'Sunglasses',
        'image': {
          'key': 'category-image/abc.png',
          'url': 'https://signed.example.com/abc.png?sig=1',
        },
      });

      final payload = subCategory.toJson();

      expect(payload['image'], 'category-image/abc.png');
    });
  });
}
