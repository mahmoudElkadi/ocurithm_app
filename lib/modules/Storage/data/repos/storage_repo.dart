import 'dart:developer';

import 'package:dio/dio.dart';
import '../../../../core/api/api_handler.dart';
import '../../../../core/api/api_constants.dart';
import '../model/upload_response_model.dart';

abstract class StorageRepo {
  Future<List<UploadResponse>> uploadMultipleFiles({
    required List<String> filePaths,
    required String category,
    ProgressCallback? onSendProgress,
  });

  Future<void> deleteFile({required String key});
  Future<void> deleteFiles({required List<String> keys});
}

class StorageRepoImpl implements StorageRepo {
  final ApiHandler _apiHandler = ApiHandler();

  @override
  Future<List<UploadResponse>> uploadMultipleFiles({
    required List<String> filePaths,
    required String category,
    ProgressCallback? onSendProgress,
  }) async {
    log('filePaths $filePaths');

    final response =
        await _apiHandler.uploadMultipleFiles<List<UploadResponse>>(
      ApiConstants.storageUpload,
      filePaths,
      fieldName: 'files', // "send it like image"
      onSendProgress: onSendProgress,
      fromJson: (json) {
        if (json is List) {
          return json.map((e) => UploadResponse.fromJson(e)).toList();
        } else if (json is Map && json['files'] is List) {
          return (json['files'] as List)
              .map((e) => UploadResponse.fromJson(e))
              .toList();
        }
        return [];
      },
    );

    if (response.success && response.data != null) {
      return response.data!;
    } else {
      throw Exception(response.message ?? 'Failed to upload files');
    }
  }

  @override
  Future<void> deleteFile({required String key}) async {
    final response = await _apiHandler.delete(
      ApiConstants.storageDelete,
      queryParameters: {'key': key},
    );

    if (!response.success) {
      throw Exception(response.message ?? 'Failed to delete file');
    }
  }

  @override
  Future<void> deleteFiles({required List<String> keys}) async {
    final response = await _apiHandler.delete(
      ApiConstants.storageBulkDelete,
      data: {'keys': keys},
    );

    if (!response.success) {
      throw Exception(response.message ?? 'Failed to delete files');
    }
  }
}
