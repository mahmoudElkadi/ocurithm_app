import '../Network/shared.dart';

class ApiConstants {
  static const int connectionTimeout = 25000; // 15 seconds
  static const int receiveTimeout = 25000;
  static const int sendTimeout = 25000;

  // API Endpoints

  // static String get baseUrl => "https://beta.ocurithm.com/api/";

  // static String get baseUrl => "http://192.168.1.13:3000/api/";

  static String get baseUrl {
    String? ip = CacheHelper.getData(key: 'ip_address');
    if (ip != null && ip.isNotEmpty) {
      return "http://$ip:3000/api/";
    }
    return "http://192.168.1.6:3000/api/";
  }

  static String get login => "auth/login";

  static String get me => "auth/me";

  static String get refreshToken => "auth/refresh";

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

  static String get storageDelete => "storage";

  static String get storageBulkDelete => "storage/bulk";

  // Chat Module
  static String get chatUsers => "chat/users";

  static String get chatThreads => "chat/threads";

  static String chatThread(String threadId) => "chat/threads/$threadId";

  static String chatMessages(String threadId) =>
      "chat/threads/$threadId/messages";

  // WebSocket
  static String get chatSocketUrl => baseUrl.replaceFirst('/api/', '');

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
