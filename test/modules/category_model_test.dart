import 'package:flutter_test/flutter_test.dart';
import 'package:ocurithm/modules/Category/data/models/category_model.dart';

/// Verification for Task 3.1 (§9 W18). The backend always returns `image` as
/// `{key, url, expiresAt}` (or null) on read, but requires exactly the raw
/// storage key back on write — never the resolved URL, and never the whole
/// object. Mobile used to parse `image` straight into a `String?`, which threw
/// the moment any category had an image (crash on read) and silently mis-wrote
/// the URL back on update (400 from the backend, confirmed live in this
/// session). These tests pin the fixed contract so it can't regress silently.
void main() {
  group('Category.fromJson', () {
    test('image object splits into a display url and a write-back key', () {
      final category = Category.fromJson({
        'id': 'c1',
        'name': 'Frames',
        'image': {
          'key': 'category-image/abc.png',
          'url': 'https://signed.example.com/abc.png?sig=1',
          'expiresAt': '2026-01-01T00:00:00.000Z',
        },
      });

      expect(category.image, 'https://signed.example.com/abc.png?sig=1');
      expect(category.imageKey, 'category-image/abc.png');
    });

    test('null image stays null on both fields', () {
      final category = Category.fromJson({'id': 'c1', 'name': 'Frames'});

      expect(category.image, isNull);
      expect(category.imageKey, isNull);
    });

    test('a bare string is tolerated defensively without crashing', () {
      final category = Category.fromJson({
        'id': 'c1',
        'name': 'Frames',
        'image': 'https://cdn.example.com/legacy.png',
      });

      expect(category.image, 'https://cdn.example.com/legacy.png');
      expect(category.imageKey, 'https://cdn.example.com/legacy.png');
    });
  });

  group('Category.toJson', () {
    test('writes the storage key back, never the resolved url', () {
      final category = Category.fromJson({
        'id': 'c1',
        'name': 'Frames',
        'image': {
          'key': 'category-image/abc.png',
          'url': 'https://signed.example.com/abc.png?sig=1',
        },
      });

      final payload = category.toJson();

      expect(payload['image'], 'category-image/abc.png');
    });
  });
}
