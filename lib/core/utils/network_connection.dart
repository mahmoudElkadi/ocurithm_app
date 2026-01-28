import 'package:dio/dio.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class NetworkStatus {
  final Dio _dio = Dio();

  Future<bool> hasInternetConnection() async {
    try {
      // First check
      final hasInternet = await InternetConnection().hasInternetAccess;
      if (hasInternet) {
        // Already confirmed internet access
        return true;
      }

      // Second check (fallback)
      final response = await _dio.head(
        'https://www.google.com',
        options: Options(validateStatus: (_) => true, sendTimeout: const Duration(seconds: 5)),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}