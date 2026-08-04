import 'package:flutter/foundation.dart';

import '../Network/shared.dart';

class ApiConstants {
  static const int connectionTimeout = 25000; // 15 seconds
  static const int receiveTimeout = 25000;
  static const int sendTimeout = 25000;

  /// Where clinic devices talk to. Baked in — never typed by a user.
  static const String productionBaseUrl = "https://ocurithm.com/api/";

  /// Build-time override, e.g.
  /// `flutter build apk --release --dart-define=API_BASE_URL=http://192.168.1.24:3000/api/`
  ///
  /// This is the only way a release build can be pointed somewhere else, which
  /// is what makes the owner's release-mode-APK-against-local-backend check
  /// possible without leaving a switch inside the shipped app.
  static const String _dartDefineBaseUrl =
      String.fromEnvironment('API_BASE_URL');

  /// Cache key holding a full base URL (`http://host:port/api/`), written by
  /// the login screen's dev affordance.
  static const String devBaseUrlKey = 'api_base_url';

  /// Pre-parity key that held a bare IP and assumed `http://<ip>:3000/api/`.
  /// Read once by [migrateLegacyDevOverride], then never again.
  static const String _legacyIpKey = 'ip_address';

  /// The stored dev override, or null when unset. Release builds always get
  /// null: a shipped app must not be redirectable at runtime.
  static String? get devBaseUrlOverride {
    if (kReleaseMode) return null;
    final stored = CacheHelper.getData(key: devBaseUrlKey);
    if (stored is! String || stored.trim().isEmpty) return null;
    return normalizeBaseUrl(stored);
  }

  // API Endpoints

  /// Resolution order: build-time define, then the dev override (debug and
  /// profile only), then production.
  static String get baseUrl {
    if (_dartDefineBaseUrl.trim().isNotEmpty) {
      return normalizeBaseUrl(_dartDefineBaseUrl);
    }
    return devBaseUrlOverride ?? productionBaseUrl;
  }

  /// Turns whatever a developer typed into a usable base URL. Accepts a bare
  /// IP, `host:port`, or a full URL with or without the `/api/` suffix, so the
  /// dev field does not become a source of its own bugs.
  ///
  /// `192.168.1.24`            -> `http://192.168.1.24:3000/api/`
  /// `192.168.1.24:3000`       -> `http://192.168.1.24:3000/api/`
  /// `https://staging.host`    -> `https://staging.host/api/`
  /// `http://h:3000/api/`      -> unchanged
  static String normalizeBaseUrl(String input) {
    var value = input.trim();
    if (value.isEmpty) return productionBaseUrl;

    // A bare host, IP or `host:port` has no scheme. Default those to http,
    // since the only reason to type one is a local backend.
    if (!value.contains('://')) {
      final hasPort = RegExp(r':\d+').hasMatch(value);
      value = 'http://$value${hasPort ? '' : ':3000'}';
    }

    final uri = Uri.tryParse(value);
    // Anything that is not a resolvable http(s) URL falls back to production
    // rather than producing a base URL that blows up later in Uri.origin.
    if (uri == null ||
        uri.host.isEmpty ||
        (uri.scheme != 'http' && uri.scheme != 'https')) {
      return productionBaseUrl;
    }

    // Keep any path the developer supplied (a staging backend may be mounted
    // under a prefix); only append `/api` when they left it off.
    var path = uri.path;
    if (!path.split('/').contains('api')) {
      path = path.endsWith('/') ? '${path}api' : '$path/api';
    }
    if (!path.endsWith('/')) path = '$path/';

    // Rebuilt rather than Uri.replace'd: replace() treats a null query or
    // fragment as "keep the original", which would carry junk into every
    // request path. Dart drops the port when it is the scheme default.
    return Uri(
      scheme: uri.scheme,
      host: uri.host,
      port: uri.port,
      path: path,
    ).toString();
  }

  /// Moves a pre-parity `ip_address` value onto [devBaseUrlKey]. Call once at
  /// startup, before anything reads [baseUrl].
  ///
  /// Release builds ignore the override entirely, so a clinic device upgrading
  /// with a stale LAN IP still lands on production — the migration only spares
  /// developers from re-typing their host.
  static Future<void> migrateLegacyDevOverride() async {
    final legacy = CacheHelper.getData(key: _legacyIpKey);
    if (legacy is! String || legacy.trim().isEmpty) return;

    final existing = CacheHelper.getData(key: devBaseUrlKey);
    if (existing is! String || existing.trim().isEmpty) {
      await CacheHelper.saveString(
        key: devBaseUrlKey,
        value: normalizeBaseUrl(legacy),
      );
    }
    await CacheHelper.removeData(key: _legacyIpKey);
  }

  static String get login => "auth/login";

  static String get me => "auth/me";

  static String get refreshToken => "auth/refresh";

  static String get logout => "auth/logout";

  static String get logoutAll => "auth/logout-all";

  static String get branches => "branches";

  static String get doctors => "doctors";

  static String get receptionists => "receptionists";

  static String get patients => "patients";

  static String get examinationTypes => "examinationTypes";

  static String get paymentMethods => "paymentMethods";

  static String get appointments => "appointments";

  static String get clinics => "clinics";

  static String get examination => "examinations";

  static String get capabilities => "capabilities";

  static String get medicines => "medicines/commercial-names";

  static String get activeIngredients => "medicines/active-ingredients";

  static String get analysis => "measurement-trends";

  static String get storageUpload => "storage/upload-multiple/patient-scan";

  /// Single-file upload for a given `FileCategory` (e.g. `category-image`,
  /// `product-image`). Returns `{key, publicUrl?}` — the `key` is what must be
  /// sent back as the entity's `image` field; the backend's own storage
  /// validates any write against this exact key prefix and rejects anything
  /// else (e.g. a third-party CDN URL) with a 400.
  static String storageUploadSingle(String category) =>
      "storage/upload/$category";

  static String get storageDelete => "storage";

  static String get storageBulkDelete => "storage/bulk";

  // Chat Module
  static String get chatUsers => "chat/users";

  static String get chatThreads => "chat/threads";

  static String chatThread(String threadId) => "chat/threads/$threadId";

  static String chatMessages(String threadId) =>
      "chat/threads/$threadId/messages";

  // WebSocket
  /// Socket.io wants a bare origin, not the API path. nginx proxies
  /// `/socket.io/` straight to the API on the same host, so the origin of
  /// [baseUrl] is the right target for both production and a local backend.
  ///
  /// Derived through [Uri] rather than a string replace: the old
  /// `replaceFirst('/api/', '')` silently produced a bad origin for any base
  /// URL that did not end in exactly `/api/`.
  static String get chatSocketUrl {
    final uri = Uri.tryParse(baseUrl);
    if (uri == null || uri.host.isEmpty) {
      return Uri.parse(productionBaseUrl).origin;
    }
    return uri.origin;
  }

  static String get chatSocketNamespace => "/chat";

  // Patient
  static String get checkDuplicatePatientName =>
      "patients/check-duplicate-name";

  static String get categories => "categories";

  static String get subCategories => "subCategories";
  static String get products => "products";
  static String get suppliers => "suppliers";
  static String get purchaseOrders => "purchase-orders";
  static String get poProductLookup => "purchase-orders/product-lookup";
  static String get orders => "orders";
  static String get orderProductLookup => "orders/product-lookup";
  static String get accounts => "accounts";
  static String get accountOwnerOptions => "accounts/owner-options";
  static String get transactions => "transactions";
}
