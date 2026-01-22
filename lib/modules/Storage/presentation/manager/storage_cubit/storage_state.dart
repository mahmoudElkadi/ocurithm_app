part of 'storage_cubit.dart';

enum StorageStatus { initial, uploading, success, error, deleting }

class StorageState {
  final StorageStatus status;
  final double progress; // 0.0 to 1.0
  final List<UploadResponse> uploadedFiles;
  final String? errorMessage;
  final int currentFileIndex;
  final int totalFiles;

  const StorageState({
    this.status = StorageStatus.initial,
    this.progress = 0.0,
    this.uploadedFiles = const [],
    this.errorMessage,
    this.currentFileIndex = 0,
    this.totalFiles = 0,
  });

  StorageState copyWith({
    StorageStatus? status,
    double? progress,
    List<UploadResponse>? uploadedFiles,
    String? errorMessage,
    int? currentFileIndex,
    int? totalFiles,
  }) {
    return StorageState(
      status: status ?? this.status,
      progress: progress ?? this.progress,
      uploadedFiles: uploadedFiles ?? this.uploadedFiles,
      errorMessage: errorMessage ?? this.errorMessage,
      currentFileIndex: currentFileIndex ?? this.currentFileIndex,
      totalFiles: totalFiles ?? this.totalFiles,
    );
  }
}
