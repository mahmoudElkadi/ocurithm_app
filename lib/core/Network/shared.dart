import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../modules/Login/data/model/login_response.dart';

class CacheHelper {
  static late SharedPreferences sharedPreferences;

  static Future init() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }

  //for background shared prefs. (reload data)
  static Future refresh() async {
    await sharedPreferences.reload();
  }

  static Future<bool?> saveBoolean({required String key, required dynamic value}) async {
    return await sharedPreferences.setBool(key, value);
  }

  static Future<bool?> saveString({required String key, required dynamic value}) async {
    return await sharedPreferences.setString(key, value);
  }

  static Future<void> saveListOfMaps(String key, List<dynamic> list) async {
    String encodedString = jsonEncode(list);
    await sharedPreferences.setString(key, encodedString);
  }

  static List<dynamic> getListOfMaps(String key) {
    String jsonString = sharedPreferences.getString(key) ?? '[]';
    return jsonDecode(jsonString);
  }

  static Future<void> saveObject(String key, object) async {
    String encodedString = jsonEncode(object);
    await sharedPreferences.setString(key, encodedString);
  }

  // Get object from SharedPreferences
  static Map<String, dynamic> getObject(String key) {
    String jsonString = sharedPreferences.getString(key) ?? '{}';
    return jsonDecode(jsonString);
  }

  static Future<bool> saveUser(String key, User user) async {
    final String userJson = jsonEncode(user.toJson());
    return await sharedPreferences.setString(key, userJson);
  }

  // Get User object
  static User? getUser(String key) {
    final String? userJson = sharedPreferences.getString(key);
    if (userJson != null) {
      return User.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  static dynamic getData({
    required String key,
  }) {
    return sharedPreferences.get(key);
  }

  static Future<bool> saveStringList({required String key, required List<String> value}) async {
    return await sharedPreferences.setStringList(key, value);
  }

  /// Get list of strings from SharedPreferences
  static List<String> getStringList({
    required String key,
    List<String> defaultValue = const [],
  }) {
    return sharedPreferences.getStringList(key) ?? defaultValue;
  }

  static Future<bool?> removeData({required String key}) async {
    return await sharedPreferences.remove(key);
  }
}
