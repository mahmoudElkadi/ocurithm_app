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

    try {
      final results = await storageRepo.uploadMultipleFiles(
        filePaths: filePaths,
        category: category,
        onSendProgress: (sent, total) {
          if (total > 0) {
            emit(state.copyWith(progress: sent / total));
          }
        },
      );

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

  Future<void> deleteFiles(List<String> keys) async {
    try {
      emit(state.copyWith(status: StorageStatus.deleting));
      await storageRepo.deleteFiles(keys: keys);
      emit(state.copyWith(status: StorageStatus.initial));
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
