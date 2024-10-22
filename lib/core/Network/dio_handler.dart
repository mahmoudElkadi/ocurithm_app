import 'dart:developer';
import 'dart:io';

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
