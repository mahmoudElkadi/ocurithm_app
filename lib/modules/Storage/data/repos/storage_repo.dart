import 'package:dio/dio.dart';
import '../../../../core/api/api_handler.dart';
import '../../../../core/api/api_constants.dart';
import '../model/upload_response_model.dart';

abstract class StorageRepo {
  Future<UploadResponse> uploadFile({
    required String filePath,
    required String category,
    ProgressCallback? onSendProgress,
  });

  Future<void> deleteFile({required String key});
}

class StorageRepoImpl implements StorageRepo {
  final ApiHandler _apiHandler = ApiHandler();

  @override
  Future<UploadResponse> uploadFile({
    required String filePath,
    required String category,
    ProgressCallback? onSendProgress,
  }) async {
    final response = await _apiHandler.uploadFile<UploadResponse>(
      "${ApiConstants.storageUpload}/$category",
      filePath,
      onSendProgress: onSendProgress,
      fromJson: (json) => UploadResponse.fromJson(json),
    );

    if (response.success && response.data != null) {
      return response.data!;
    } else {
      throw Exception(response.message ?? 'Failed to upload file');
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
}
