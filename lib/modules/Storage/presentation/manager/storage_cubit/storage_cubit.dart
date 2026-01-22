import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repos/storage_repo.dart';
import '../../../data/model/upload_response_model.dart';

part 'storage_state.dart';

class StorageCubit extends Cubit<StorageState> {
  final StorageRepo storageRepo;

  StorageCubit(this.storageRepo) : super(const StorageState());

  Future<List<UploadResponse>> uploadMultipleFiles({
    required List<String> filePaths,
    required String category,
  }) async {
    emit(state.copyWith(
      status: StorageStatus.uploading,
      progress: 0.0,
      totalFiles: filePaths.length,
      currentFileIndex: 0,
      uploadedFiles: [],
    ));

    List<UploadResponse> results = [];

    try {
      for (int i = 0; i < filePaths.length; i++) {
        emit(state.copyWith(currentFileIndex: i + 1, progress: 0.0));

        double lastEmittedProgress = 0.0;

        final result = await storageRepo.uploadFile(
          filePath: filePaths[i],
          category: category,
          onSendProgress: (sent, total) {
            if (total > 0) {
              double currentProgress = sent / total;
              // Only emit if progress has increased by at least 1%
              if ((currentProgress - lastEmittedProgress).abs() > 0.01 ||
                  currentProgress == 1.0) {
                lastEmittedProgress = currentProgress;
                emit(state.copyWith(progress: currentProgress));
              }
            }
          },
        );
        results.add(result);
      }

      emit(state.copyWith(
        status: StorageStatus.success,
        uploadedFiles: results,
        progress: 1.0,
      ));
      return results;
    } catch (e) {
      emit(state.copyWith(
        status: StorageStatus.error,
        errorMessage: e.toString(),
      ));
      rethrow;
    }
  }

  Future<void> deleteFile(String key) async {
    // Optionally remove from current list if needed
    try {
      emit(state.copyWith(status: StorageStatus.deleting));
      await storageRepo.deleteFile(key: key);

      final updatedList = List<UploadResponse>.from(state.uploadedFiles)
        ..removeWhere((f) => f.key == key);

      emit(state.copyWith(
        status: StorageStatus.initial, // Or another relevant status
        uploadedFiles: updatedList,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: StorageStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void reset() {
    emit(const StorageState());
  }
}
