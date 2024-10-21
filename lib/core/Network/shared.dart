import 'dart:convert';
import 'dart:developer';

import 'package:shared_preferences/shared_preferences.dart';

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

  static dynamic getData({
    required String key,
  }) {
    return sharedPreferences.get(key);
  }

  static Future<bool?> removeData({required String key}) async {
    return await sharedPreferences.remove(key);
  }
}
