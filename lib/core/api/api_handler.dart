import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;

import '../../modules/Login/presentation/view/login_view.dart';
import '../Network/shared.dart';
import '../utils/network_connection.dart';
import 'api_constants.dart';
import 'api_interceptor.dart';
import 'api_model.dart';

class ApiHandler {
  static final ApiHandler _instance = ApiHandler._internal();

  factory ApiHandler() => _instance;

  late Dio _dio;

  // Store cancel tokens by key
  final Map<String, CancelToken> _cancelTokens = {};
  final String? token = CacheHelper.getData(key: "token");

  ApiHandler._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(
          milliseconds: ApiConstants.connectionTimeout,
        ),
        receiveTimeout: const Duration(
          milliseconds: ApiConstants.receiveTimeout,
        ),
        sendTimeout: const Duration(milliseconds: ApiConstants.sendTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Cookie': 'ocurithmToken=$token'
        },
      ),
    );

    _setupInterceptors();
  }

  void _setupInterceptors() {
    final authInterceptor = AuthInterceptor(
      getToken: _getToken,
      refreshToken: refreshToken,
      onRefreshFailed: _onRefreshFailed,
    );

    // Set the Dio instance on the auth interceptor
    authInterceptor.setDio(_dio);

    _dio.interceptors.addAll([
      LoggingInterceptor(),
      authInterceptor,
      RetryInterceptor(dio: _dio),
    ]);
  }

  // Mock token getter - replace with your actual token storage
  Future<String?> _getToken() async {
    final accessToken = CacheHelper.getData(key: 'token');
    return accessToken;
  }

  Future<void> refreshToken() async {
    final refreshToken = CacheHelper.getData(key: 'refreshToken');
    if (refreshToken == null) {
      throw Exception('No refresh token available');
    }

    try {
      // Use the existing dio instance
      // Authentication headers are skipped for auth/refresh in AuthInterceptor
      final response = await _dio.post(
        ApiConstants.refreshToken,
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        // Adjust these keys based on your API response structure
        // Usually it's either data['accessToken'] or data['data']['accessToken']
        final newAccessToken = data['accessToken'] ??
            (data['data'] is Map ? data['data']['accessToken'] : null);
        final newRefreshToken = data['refreshToken'] ??
            (data['data'] is Map ? data['data']['refreshToken'] : null);

        if (newAccessToken != null) {
          await CacheHelper.saveString(key: "token", value: newAccessToken);
          if (newRefreshToken != null) {
            await CacheHelper.saveString(
                key: "refreshToken", value: newRefreshToken);
          }
          log('Token refreshed successfully');
        } else {
          throw Exception('No access token in response');
        }
      } else {
        throw Exception('Failed to refresh token: ${response.statusCode}');
      }
    } catch (e) {
      log('Error during token refresh: $e');
      rethrow;
    }
  }

  // Callback when refresh token fails - clear data and navigate to login
  Future<void> _onRefreshFailed() async {
    // Navigate to login screen using GetX
    try {
      log('User session expired. Please login again.');
      await _clearAuthData();
      Get.offAll(() => const LoginView());
    } catch (e) {
      log('Error during logout navigation: $e');
    }
  }

  // Clear all authentication data
  Future<void> _clearAuthData() async {
    await CacheHelper.removeData(key: 'user');
    await CacheHelper.removeData(key: 'notifications');
    await CacheHelper.removeData(key: 'token');
    await CacheHelper.removeData(key: 'accessToken');
    await CacheHelper.removeData(key: 'refreshToken');
    await CacheHelper.removeData(key: 'id');
    await CacheHelper.removeData(key: 'domain');
    await CacheHelper.removeData(key: 'capabilities');
  }

  // Update base URL dynamically
  void updateBaseUrl(String newBaseUrl) {
    _dio.options.baseUrl = newBaseUrl;
  }

  // Update headers dynamically
  void updateHeaders(Map<String, dynamic> headers) {
    _dio.options.headers.addAll(headers);
  }

  // ==================== Authentication Methods ====================

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await _getToken();
    return token != null && token.isNotEmpty;
  }

  // ==================== Cancel Token Management ====================

  /// Get or create a cancel token for the given key
  /// If a token already exists for this key, cancel it first
  CancelToken _getCancelToken(String? cancelKey) {
    if (cancelKey != null && cancelKey.isNotEmpty) {
      // Cancel previous request with same key
      if (_cancelTokens.containsKey(cancelKey)) {
        _cancelTokens[cancelKey]?.cancel(
          'Cancelled by new request with same key',
        );
        _cancelTokens.remove(cancelKey);
      }

      // Create new cancel token
      final newToken = CancelToken();
      _cancelTokens[cancelKey] = newToken;
      return newToken;
    }

    // No key provided, create a token without storing it
    return CancelToken();
  }

  /// Remove cancel token after request completes
  void _removeCancelToken(String? cancelKey) {
    if (cancelKey != null && cancelKey.isNotEmpty) {
      _cancelTokens.remove(cancelKey);
    }
  }

  /// Manually cancel a request by key
  void cancelRequest(String cancelKey) {
    if (_cancelTokens.containsKey(cancelKey)) {
      _cancelTokens[cancelKey]?.cancel('Cancelled manually');
      _cancelTokens.remove(cancelKey);
    }
  }

  /// Cancel all pending requests
  void cancelAllRequests() {
    for (var token in _cancelTokens.values) {
      token.cancel('Cancelled all requests');
    }
    _cancelTokens.clear();
  }

  // ==================== Helper Methods ====================

  /// Merge retry configuration into options
  Options _mergeOptions(Options? options, int? maxRetries) {
    final extra = <String, dynamic>{...?options?.extra};

    // Add retry count if specified
    if (maxRetries != null) {
      extra['max_retries'] = maxRetries;
    }

    return Options(
      method: options?.method,
      sendTimeout: options?.sendTimeout,
      receiveTimeout: options?.receiveTimeout,
      extra: extra,
      headers: options?.headers,
      responseType: options?.responseType,
      contentType: options?.contentType,
      validateStatus: options?.validateStatus,
      receiveDataWhenStatusError: options?.receiveDataWhenStatusError,
      followRedirects: options?.followRedirects,
      maxRedirects: options?.maxRedirects,
      persistentConnection: options?.persistentConnection,
      requestEncoder: options?.requestEncoder,
      responseDecoder: options?.responseDecoder,
      listFormat: options?.listFormat,
    );
  }

  // ==================== Generic Request Methods ====================

  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? data,
    Options? options,
    String? cancelKey,
    int? maxRetries, // Number of retries for this request (null = use default)
    T Function(dynamic)? fromJson,
  }) async {
    CancelToken? cancelToken;

    try {
      cancelToken = _getCancelToken(cancelKey);

      // Merge retry config into options
      final mergedOptions = _mergeOptions(options, maxRetries);

      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        data: data,
        options: mergedOptions,
        cancelToken: cancelToken,
      );

      _removeCancelToken(cancelKey);
      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      _removeCancelToken(cancelKey);
      return _handleError<T>(e);
    }
  }

  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    String? cancelKey,
    int? maxRetries, // Number of retries for this request (null = use default)
    T Function(dynamic)? fromJson,
  }) async {
    CancelToken? cancelToken;

    try {
      cancelToken = _getCancelToken(cancelKey);

      // Merge retry config into options
      final mergedOptions = _mergeOptions(options, maxRetries);

      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: mergedOptions,
        cancelToken: cancelToken,
      );

      _removeCancelToken(cancelKey);
      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      _removeCancelToken(cancelKey);
      return _handleError<T>(e);
    }
  }

  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    String? cancelKey,
    int? maxRetries, // Number of retries for this request (null = use default)
    T Function(dynamic)? fromJson,
  }) async {
    CancelToken? cancelToken;

    try {
      cancelToken = _getCancelToken(cancelKey);

      // Merge retry config into options
      final mergedOptions = _mergeOptions(options, maxRetries);

      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: mergedOptions,
        cancelToken: cancelToken,
      );

      _removeCancelToken(cancelKey);
      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      _removeCancelToken(cancelKey);
      return _handleError<T>(e);
    }
  }

  Future<ApiResponse<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    String? cancelKey,
    int? maxRetries, // Number of retries for this request (null = use default)
    T Function(dynamic)? fromJson,
  }) async {
    CancelToken? cancelToken;

    try {
      cancelToken = _getCancelToken(cancelKey);

      // Merge retry config into options
      final mergedOptions = _mergeOptions(options, maxRetries);

      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: mergedOptions,
        cancelToken: cancelToken,
      );

      _removeCancelToken(cancelKey);
      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      _removeCancelToken(cancelKey);
      return _handleError<T>(e);
    }
  }

  Future<ApiResponse<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    String? cancelKey,
    int? maxRetries, // Number of retries for this request (null = use default)
    T Function(dynamic)? fromJson,
  }) async {
    CancelToken? cancelToken;

    try {
      cancelToken = _getCancelToken(cancelKey);

      // Merge retry config into options
      final mergedOptions = _mergeOptions(options, maxRetries);

      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: mergedOptions,
        cancelToken: cancelToken,
      );

      _removeCancelToken(cancelKey);
      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      _removeCancelToken(cancelKey);
      return _handleError<T>(e);
    }
  }

  // ==================== File Upload ====================

  Future<ApiResponse<T>> uploadFile<T>(
    String path,
    String filePath, {
    String fieldName = 'file',
    Map<String, dynamic>? additionalData,
    ProgressCallback? onSendProgress,
    String? cancelKey,
    int? maxRetries, // Number of retries for this request (null = use default)
    T Function(dynamic)? fromJson,
  }) async {
    CancelToken? cancelToken;

    try {
      cancelToken = _getCancelToken(cancelKey);

      final fileName = filePath.split('/').last;
      final formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(filePath, filename: fileName),
        ...?additionalData,
      });

      // Create options with retry config
      final options = _mergeOptions(null, maxRetries);

      final response = await _dio.post(
        path,
        data: formData,
        onSendProgress: onSendProgress,
        cancelToken: cancelToken,
        options: options,
      );

      _removeCancelToken(cancelKey);
      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      _removeCancelToken(cancelKey);
      return _handleError<T>(e);
    }
  }

  Future<ApiResponse<T>> uploadMultipleFiles<T>(
    String path,
    List<String> filePaths, {
    required String fieldName,
    Map<String, dynamic>? additionalData,
    ProgressCallback? onSendProgress,
    String? cancelKey,
    int? maxRetries,
    T Function(dynamic)? fromJson,
  }) async {
    CancelToken? cancelToken;

    try {
      cancelToken = _getCancelToken(cancelKey);

      final List<MultipartFile> files = [];
      for (var path in filePaths) {
        final fileName = path.split('/').last;
        files.add(await MultipartFile.fromFile(path, filename: fileName));
      }

      final formData = FormData.fromMap({
        fieldName: files,
        ...?additionalData,
      });

      final options = _mergeOptions(null, maxRetries);

      final response = await _dio.post(
        path,
        data: formData,
        onSendProgress: onSendProgress,
        cancelToken: cancelToken,
        options: options,
      );

      _removeCancelToken(cancelKey);
      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      _removeCancelToken(cancelKey);
      return _handleError<T>(e);
    }
  }

  // ==================== File Download ====================

  Future<ApiResponse<String>> downloadFile(
    String urlPath,
    String savePath, {
    ProgressCallback? onReceiveProgress,
    String? cancelKey,
    int? maxRetries, // Number of retries for this request (null = use default)
  }) async {
    CancelToken? cancelToken;

    try {
      cancelToken = _getCancelToken(cancelKey);

      // Create options with retry config
      final options = _mergeOptions(null, maxRetries);

      await _dio.download(
        urlPath,
        savePath,
        onReceiveProgress: onReceiveProgress,
        cancelToken: cancelToken,
        options: options,
      );

      _removeCancelToken(cancelKey);
      return ApiResponse.success(
        savePath,
        message: 'File downloaded successfully',
      );
    } catch (e) {
      _removeCancelToken(cancelKey);
      return _handleError<String>(e);
    }
  }

  // ==================== Response & Error Handlers ====================

  ApiResponse<T> _handleResponse<T>(
    Response response,
    T Function(dynamic)? fromJson,
  ) {
    // Check for invalid token message (similar to dio_handler.dart)
    if (response.data is Map && response.data['message'] == "Invalid token") {
      // Clear authentication data
      CacheHelper.removeData(key: "token");
      CacheHelper.removeData(key: "id");
      CacheHelper.removeData(key: "domain");
      CacheHelper.removeData(key: "accessToken");
      CacheHelper.removeData(key: "refreshToken");
      CacheHelper.removeData(key: "user");

      // Navigate to login using GetX
      try {
        Get.offAll(() => const LoginView());
      } catch (e) {
        log('Error navigating to login: $e');
      }

      return ApiResponse.error(
        'Invalid token. Please login again.',
        statusCode: 401,
      );
    }

    if (response.statusCode! >= 200 && response.statusCode! < 300) {
      T? data;

      if (fromJson != null && response.data != null) {
        data = fromJson(response.data);
      } else if (response.data is T) {
        data = response.data as T;
      }

      return ApiResponse.success(
        data as T,
        message: response.statusMessage,
        statusCode: response.statusCode,
      );
    } else {
      return ApiResponse.error(
        response.statusMessage ?? 'Unknown error occurred',
        statusCode: response.statusCode,
        rawData: response.data,
      );
    }
  }

  Future<ApiResponse<T>> _handleError<T>(dynamic error) async {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return ApiResponse.error(
            'Connection timeout. Please check your internet connection.',
            statusCode: 408,
          );

        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          String message = 'Request failed';
          if (error.response?.data != null) {
            // Try to extract error message from response
            final data = error.response?.data;
            if (data is Map && data.containsKey('message')) {
              message = data['message'].toString();
            } else if (data is Map && data.containsKey('error')) {
              message = data['error'].toString();
            }
          } else if (statusCode == 401) {
            message = 'Unauthorized. Please login again.';
          } else if (statusCode == 403) {
            message = 'Access forbidden.';
          } else if (statusCode == 404) {
            message = 'Resource not found.';
          } else if (statusCode == 500) {
            message = 'Internal server error.';
          } else if (error.response?.data != null) {
            // Try to extract error message from response
            final data = error.response?.data;
            if (data is Map && data.containsKey('message')) {
              message = data['message'].toString();
            } else if (data is Map && data.containsKey('error')) {
              message = data['error'].toString();
            }
          }

          return ApiResponse.error(message, statusCode: statusCode);

        case DioExceptionType.cancel:
          return ApiResponse.error('Request cancelled', statusCode: 499);

        case DioExceptionType.connectionError:
          final hasInternet = await NetworkStatus().hasInternetConnection();
          if (!hasInternet) {
            return ApiResponse.error(
                'No internet connection. Please check your network.',
                statusCode: 503);
          }
          return ApiResponse.error('Server error. Please try again later.',
              statusCode: 503);

        default:
          return ApiResponse.error(
            error.message ?? 'An unexpected error occurred',
          );
      }
    }

    return ApiResponse.error(
      'An unexpected error occurred: ${error.toString()}',
    );
  }
}
