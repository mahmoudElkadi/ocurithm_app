class UploadResponse {
  final String key;
  final String publicUrl;

  UploadResponse({
    required this.key,
    required this.publicUrl,
  });

  factory UploadResponse.fromJson(Map<String, dynamic> json) {
    return UploadResponse(
      key: json['key'] ?? '',
      publicUrl: json['publicUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'publicUrl': publicUrl,
    };
  }
}
