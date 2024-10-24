import 'dart:developer';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ApiService {
  static final Dio _dio = Dio();

  static Future<T?> request<T>({
    required String url,
    required String method,
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    T Function(dynamic)? fromJson,
    bool showError = true,
    Duration timeout = const Duration(seconds: 60),
  }) async {
    try {
      final response = await _dio.request<dynamic>(
        url,
        data: data,
        queryParameters: queryParameters,
        options: Options(
          method: method,
          headers: headers ?? {'Content-Type': 'application/json'},
          sendTimeout: timeout,
          receiveTimeout: timeout,
          validateStatus: (status) => status! <= 500,
        ),
      );

      log(response.data.toString());
      log(response.realUri.toString());

      if (!showError) {
        if (response.data != null && response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
          if (fromJson != null) {
            return fromJson(response.data);
          } else {
            return response.data as T;
          }
        } else if (response.statusCode != null && response.statusCode! >= 400 && response.statusCode! <= 500) {
          return response.data as T;
        } else {
          log("HTTP error with status code: ${response.statusCode}");
          //_handleHttpError(response.statusCode);
          return null;
        }
      } else {
        if (response.data != null && response.statusCode != null && response.statusCode! >= 200 && response.statusCode! <= 500 && fromJson != null) {
          return fromJson(response.data);
        } else {
          log("HTTP error with status code: ${response.statusCode}");
          //_handleHttpError(response.statusCode);
          return null;
        }
      }
    } on DioException catch (e) {
      return _handleDioError<T>(e);
    } on SocketException catch (e) {
      return _handleSocketException<T>(e);
    } catch (e) {
      return _handleUnexpectedError<T>(e);
    }
  }

  static T? _handleDioError<T>(DioException e) {
    log("DioException: ${e.message}");
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        _showErrorSnackbar("Timeout", "The request timed out. Please try again later.");
        break;
      case DioExceptionType.badResponse:
        _handleHttpError(e.response?.statusCode);
        break;
      case DioExceptionType.cancel:
        _showErrorSnackbar("Request Cancelled", "The request was cancelled.");
        break;
      case DioExceptionType.connectionError:
        _showErrorSnackbar("Connection Error", "Please check your internet connection and try again.");
        break;
      default:
        _showErrorSnackbar("Connection Error", "An unexpected error occurred. Please try again.");
    }
    return null;
  }

  static T? _handleSocketException<T>(SocketException e) {
    log("SocketException: $e");
    _showErrorSnackbar("No Internet", "Please check your internet connection and try again.");
    return null;
  }

  static T? _handleUnexpectedError<T>(dynamic e) {
    log("Unexpected error: $e");
    _showErrorSnackbar("Connection Error", "An unexpected error occurred. Please try again.");
    return null;
  }

  static void _handleHttpError(int? statusCode) {
    switch (statusCode) {
      case 400:
        _showErrorSnackbar("Bad Request", "The request was invalid.");
        break;
      case 401:
        _showErrorSnackbar("Unauthorized", "Please log in to access this resource.");
        break;
      case 403:
        _showErrorSnackbar("Forbidden", "You don't have permission to access this resource.");
        break;
      case 404:
        _showErrorSnackbar("Not Found", "The requested resource was not found.");
        break;
      case 500:
        _showErrorSnackbar("Server Error", "An internal server error occurred. Please try again later.");
        break;
      default:
        _showErrorSnackbar("HTTP Error", "An HTTP error occurred. Status code: $statusCode");
    }
  }

  static void _showErrorSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      colorText: Colors.white,
      backgroundColor: Colors.red,
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}

abstract class ApiFailure {
  final String title;
  final String message;

  ApiFailure(
    this.title,
    this.message,
  );
}

class NetworkFailure extends ApiFailure {
  NetworkFailure() : super('Network Error', 'Please check your internet connection and try again.');
}

class TimeoutFailure extends ApiFailure {
  TimeoutFailure() : super('Timeout', 'The request timed out. Please try again later.');
}

class ServerFailure extends ApiFailure {
  final int? statusCode;
  ServerFailure(String title, String message, {this.statusCode}) : super(title, message);
}

class UnexpectedFailure extends ApiFailure {
  UnexpectedFailure() : super('Unexpected Error', 'An unexpected error occurred. Please try again.');
}

class EitherService {
  static final Dio _dio = Dio();

  static Future<Either<ApiFailure, T>> request<T>({
    required String url,
    required String method,
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    T Function(dynamic)? fromJson,
    bool showError = true,
    Duration timeout = const Duration(seconds: 60),
  }) async {
    try {
      final response = await _dio.request<dynamic>(
        url,
        data: data,
        queryParameters: queryParameters,
        options: Options(
          method: method,
          headers: headers ?? {'Content-Type': 'application/json'},
          sendTimeout: timeout,
          receiveTimeout: timeout,
          validateStatus: (status) => status! <= 500,
        ),
      );

      log(response.data.toString());
      log(response.realUri.toString());

      // Handle successful responses
      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        if (response.data != null) {
          try {
            final result = fromJson != null ? fromJson(response.data) : response.data as T;
            return Right(result);
          } catch (e) {
            log("Data parsing error: $e");
            return Left(UnexpectedFailure());
          }
        }
      }

      // Handle error responses
      final failure = _createFailureFromStatus(response.statusCode);
      if (showError) {
        _showErrorSnackbar(failure.title, failure.message);
      }
      return Left(failure);
    } on DioException catch (e) {
      final failure = _handleDioError(e);
      if (showError) {
        _showErrorSnackbar(failure.title, failure.message);
      }
      return Left(failure);
    } on SocketException catch (e) {
      log("SocketException: $e");
      final failure = NetworkFailure();
      if (showError) {
        _showErrorSnackbar(failure.title, failure.message);
      }
      return Left(failure);
    } catch (e) {
      log("Unexpected error: $e");
      final failure = UnexpectedFailure();
      if (showError) {
        _showErrorSnackbar(failure.title, failure.message);
      }
      return Left(failure);
    }
  }

  static ApiFailure _handleDioError(DioException e) {
    log("DioException: ${e.message}");
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutFailure();
      case DioExceptionType.badResponse:
        return _createFailureFromStatus(e.response?.statusCode);
      case DioExceptionType.connectionError:
        return NetworkFailure();
      default:
        return UnexpectedFailure();
    }
  }

  static ApiFailure _createFailureFromStatus(int? statusCode) {
    switch (statusCode) {
      case 400:
        return ServerFailure('Bad Request', 'The request was invalid.', statusCode: statusCode);
      case 401:
        return ServerFailure('Unauthorized', 'Please log in to access this resource.', statusCode: statusCode);
      case 403:
        return ServerFailure('Forbidden', "You don't have permission to access this resource.", statusCode: statusCode);
      case 404:
        return ServerFailure('Not Found', 'The requested resource was not found.', statusCode: statusCode);
      case 500:
        return ServerFailure('Server Error', 'An internal server error occurred. Please try again later.', statusCode: statusCode);
      default:
        return ServerFailure('HTTP Error', 'An HTTP error occurred. Status code: $statusCode', statusCode: statusCode);
    }
  }

  static void _showErrorSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      colorText: Colors.white,
      backgroundColor: Colors.red,
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
