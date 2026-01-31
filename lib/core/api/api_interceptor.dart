// ==================== Logging Interceptor ====================
import 'dart:developer';

import 'package:dio/dio.dart';

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    log('REQUEST[${options.method}] => PATH: ${options.path}');
    log('Headers: ${options.headers}');
    log('Query Parameters: ${options.queryParameters}');
    log('Body: ${options.data}');
    log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    log(
      'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}',
    );
    log('Data: ${response.data}');
    log('headers: ${response.requestOptions.headers}');
    log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    log(
      'ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}',
    );
    log('Message: ${err.message}');
    log('Response: ${err.response?.data}');
    log('headers: ${err.response?.requestOptions.headers}');
    log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    super.onError(err, handler);
  }
}

// ==================== Auth Interceptor ====================
class AuthInterceptor extends Interceptor {
  final Future<String?> Function() getToken;
  final Future<void> Function() refreshToken;
  final Future<void> Function()? onRefreshFailed;

  // Mutex to prevent concurrent refresh token requests
  bool _isRefreshing = false;
  final List<_RequestHolder> _pendingRequests = [];

  // Store reference to the Dio instance
  Dio? _dio;

  AuthInterceptor({
    required this.getToken,
    required this.refreshToken,
    this.onRefreshFailed,
  });

  // Method to set the Dio instance
  void setDio(Dio dio) {
    _dio = dio;
  }

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth for login and refresh endpoints
    if (options.path.contains('auth/login') ||
        options.path.contains('auth/refresh')) {
      return super.onRequest(options, handler);
    }

    // Skip if this is a retried request (already has the new token)
    if (options.extra['_is_retry'] == true) {
      return super.onRequest(options, handler);
    }

    final token = await getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
      options.headers['Cookie'] = 'ocurithmToken=$token';
    }
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Handle 401 Unauthorized errors
    if (err.response?.statusCode == 401) {
      final requestPath = err.requestOptions.path;
      log('Received 401 error for path: $requestPath');

      // Don't retry if it's the refresh or login endpoint itself
      if (requestPath.contains('auth/refresh')) {
        log(
          'Refresh token endpoint returned 401 - refresh token is invalid/expired',
        );
        // Call logout callback if provided
        if (onRefreshFailed != null) {
          await onRefreshFailed!();
        }
        return super.onError(err, handler);
      }

      if (requestPath.contains('auth/login')) {
        log('Login endpoint returned 401 - invalid credentials');
        return super.onError(err, handler);
      }

      // If already refreshing, queue this request
      if (_isRefreshing) {
        log('Token refresh already in progress, queuing request');
        _pendingRequests.add(
          _RequestHolder(requestOptions: err.requestOptions, handler: handler),
        );
        return;
      }

      // Start refresh process
      _isRefreshing = true;
      log('Starting token refresh process...');

      try {
        // Attempt to refresh the token
        await refreshToken();

        // Get the new token
        final newToken = await getToken();
        if (newToken != null && newToken.isNotEmpty) {
          log('Token refresh successful, retrying original request');
          // Retry the original request with new token
          final response = await _retryRequest(err.requestOptions, newToken);
          handler.resolve(response);

          // Retry all pending requests
          await _retryPendingRequests(newToken);
        } else {
          throw Exception('Failed to get new token after refresh');
        }
      } catch (e) {
        log('Token refresh failed: $e');

        // Reject all pending requests
        _rejectPendingRequests(err);

        // Call logout callback if provided
        if (onRefreshFailed != null) {
          await onRefreshFailed!();
        }

        // Pass the original error
        return super.onError(err, handler);
      } finally {
        _isRefreshing = false;
        _pendingRequests.clear();
        log('Token refresh process completed');
      }

      return;
    }

    super.onError(err, handler);
  }

  Future<Response> _retryRequest(
    RequestOptions requestOptions,
    String token,
  ) async {
    if (_dio == null) {
      throw Exception('Dio instance not set in AuthInterceptor');
    }

    // Update the authorization header with the new token
    requestOptions.headers['Authorization'] = 'Bearer $token';
    requestOptions.headers['Cookie'] = 'ocurithmToken=$token';

    // Mark this as a retry to skip the auth interceptor
    requestOptions.extra['_is_retry'] = true;

    // Use the existing Dio instance to retry the request
    // This preserves the base URL and other configurations
    return _dio!.request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: Options(
        method: requestOptions.method,
        headers: requestOptions.headers,
        contentType: requestOptions.contentType,
        responseType: requestOptions.responseType,
        receiveDataWhenStatusError: requestOptions.receiveDataWhenStatusError,
        followRedirects: requestOptions.followRedirects,
        maxRedirects: requestOptions.maxRedirects,
        validateStatus: requestOptions.validateStatus,
        receiveTimeout: requestOptions.receiveTimeout,
        sendTimeout: requestOptions.sendTimeout,
        extra: requestOptions.extra,
      ),
    );
  }

  Future<void> _retryPendingRequests(String token) async {
    for (var holder in _pendingRequests) {
      try {
        final response = await _retryRequest(holder.requestOptions, token);
        holder.handler.resolve(response);
      } catch (e) {
        holder.handler.reject(
          DioException(requestOptions: holder.requestOptions, error: e),
        );
      }
    }
  }

  void _rejectPendingRequests(DioException originalError) {
    for (var holder in _pendingRequests) {
      holder.handler.reject(
        DioException(
          requestOptions: holder.requestOptions,
          error: 'Token refresh failed',
          response: originalError.response,
          type: DioExceptionType.badResponse,
        ),
      );
    }
  }
}

// Helper class to hold pending requests during token refresh
class _RequestHolder {
  final RequestOptions requestOptions;
  final ErrorInterceptorHandler handler;

  _RequestHolder({required this.requestOptions, required this.handler});
}

// ==================== Retry Interceptor ====================
class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int maxRetries;
  final Duration retryDelay;

  RetryInterceptor({
    required this.dio,
    this.maxRetries = 0, // Default: no retries
    this.retryDelay = const Duration(seconds: 1),
  });

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final retryCount = err.requestOptions.extra['retry_count'] ?? 0;

    // Check if request has custom retry count, otherwise use default
    final requestMaxRetries =
        err.requestOptions.extra['max_retries'] ?? maxRetries;

    if (_shouldRetry(err) && retryCount < requestMaxRetries) {
      err.requestOptions.extra['retry_count'] = retryCount + 1;

      log(
        'Retrying request (${retryCount + 1}/$requestMaxRetries): ${err.requestOptions.path}',
      );

      await Future.delayed(retryDelay * (retryCount + 1));

      try {
        final response = await dio.fetch(err.requestOptions);
        return handler.resolve(response);
      } catch (e) {
        return super.onError(err, handler);
      }
    }
    super.onError(err, handler);
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        (err.response?.statusCode ?? 0) >= 500;
  }
}
