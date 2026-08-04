import 'package:flutter_test/flutter_test.dart';
import 'package:ocurithm/core/api/api_constants.dart';

/// Verification for Task 0.1. The dev override used to be a bare IP that was
/// always slotted into `http://$ip:3000/api/`, which is why the app could not
/// reach an https host. These cases pin the replacement's behaviour.
void main() {
  group('ApiConstants.normalizeBaseUrl', () {
    test('bare IP gets the dev scheme, port and /api/ suffix', () {
      expect(ApiConstants.normalizeBaseUrl('192.168.1.24'),
          'http://192.168.1.24:3000/api/');
    });

    test('host:port keeps the given port', () {
      expect(ApiConstants.normalizeBaseUrl('192.168.43.34:3000'),
          'http://192.168.43.34:3000/api/');
    });

    test('a full local URL is left alone', () {
      expect(ApiConstants.normalizeBaseUrl('http://192.168.1.24:3000/api/'),
          'http://192.168.1.24:3000/api/');
    });

    test('an https host gains /api/ and keeps its scheme', () {
      expect(ApiConstants.normalizeBaseUrl('https://staging.ocurithm.com'),
          'https://staging.ocurithm.com/api/');
    });

    test('a missing trailing slash is added', () {
      expect(ApiConstants.normalizeBaseUrl('https://ocurithm.com/api'),
          'https://ocurithm.com/api/');
    });

    test('the production URL round-trips unchanged', () {
      expect(ApiConstants.normalizeBaseUrl(ApiConstants.productionBaseUrl),
          ApiConstants.productionBaseUrl);
    });

    test('surrounding whitespace is tolerated', () {
      expect(ApiConstants.normalizeBaseUrl('  192.168.1.24  '),
          'http://192.168.1.24:3000/api/');
    });

    test('query and fragment are dropped', () {
      expect(ApiConstants.normalizeBaseUrl('https://h/api/?x=1#frag'),
          'https://h/api/');
    });

    test('empty input falls back to production', () {
      expect(ApiConstants.normalizeBaseUrl('   '),
          ApiConstants.productionBaseUrl);
    });

    test('a non-http scheme falls back to production instead of crashing', () {
      expect(ApiConstants.normalizeBaseUrl('ftp://somewhere'),
          ApiConstants.productionBaseUrl);
    });
  });

  group('socket origin derivation', () {
    // chatSocketUrl reads the cache, so exercise the derivation it performs.
    // The old replaceFirst('/api/','') produced a broken origin for anything
    // that did not end in exactly '/api/'.
    String originOf(String input) =>
        Uri.parse(ApiConstants.normalizeBaseUrl(input)).origin;

    test('production resolves to a bare https origin', () {
      expect(originOf(ApiConstants.productionBaseUrl), 'https://ocurithm.com');
    });

    test('a local backend keeps its port', () {
      expect(originOf('192.168.43.34:3000'), 'http://192.168.43.34:3000');
    });

    test('a host without the /api/ suffix still yields a clean origin', () {
      expect(originOf('https://staging.ocurithm.com'),
          'https://staging.ocurithm.com');
    });
  });
}
