class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final int? statusCode;
  final dynamic rawData;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.statusCode,
    this.rawData,
  });

  factory ApiResponse.success(T data, {String? message, int? statusCode}) {
    return ApiResponse(
      success: true,
      data: data,
      message: message,
      statusCode: statusCode,
    );
  }

  factory ApiResponse.error(String message, {int? statusCode, dynamic rawData}) {
    return ApiResponse(
      success: false,
      message: message,
      statusCode: statusCode,
      rawData: rawData,
    );
  }
}