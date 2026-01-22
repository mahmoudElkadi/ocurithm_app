class ApiConstants {
  static const int connectionTimeout = 15000; // 15 seconds
  static const int receiveTimeout = 15000;
  static const int sendTimeout = 15000;

  // API Endpoints

  // static String get baseUrl => "https://ocurithm.com/api/";

  static String get baseUrl => "http://192.168.1.4:3000/api/";

  static String get login => "auth/login";

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
  static String get storageUpload => "storage/upload";
  static String get storageDelete => "storage";
}
