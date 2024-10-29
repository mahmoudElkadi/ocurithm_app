class DataModel {
  DataModel({
    required this.error,
    required this.message,
  });

  final String? error;
  final String? message;

  factory DataModel.fromJson(Map<String, dynamic> json) {
    return DataModel(
      error: json["error"],
      message: json["message"],
    );
  }

  Map<String, dynamic> toJson() => {
        "error": error,
        "message": message,
      };
}
