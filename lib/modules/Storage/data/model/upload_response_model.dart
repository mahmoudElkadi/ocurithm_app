class UploadResponse {
  final String key;
  final String? localPath; // Added for local display

  UploadResponse({
    required this.key,
    this.localPath,
  });

  factory UploadResponse.fromJson(Map<String, dynamic> json) {
    return UploadResponse(
      key: json['key'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
    };
  }
}
