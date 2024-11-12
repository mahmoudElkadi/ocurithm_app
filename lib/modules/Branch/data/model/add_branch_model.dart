class AddBranchModel {
  AddBranchModel({
    this.code,
    this.name,
    this.address,
    this.phone,
    this.createdAt,
    this.updatedAt,
    this.id,
    this.openTime,
    this.closeTime,
    this.clinic,
    this.workDays,
    this.error,
  });

  String? code;
  String? name;
  String? address;
  String? phone;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? id;
  String? clinic;
  String? openTime;
  String? closeTime;
  List? workDays;
  String? error;

  factory AddBranchModel.fromJson(Map<String, dynamic> json) {
    return AddBranchModel(
      code: json["code"],
      name: json["name"],
      address: json["address"],
      phone: json["phone"],
      createdAt: DateTime.tryParse(json["createdAt"] ?? ""),
      updatedAt: DateTime.tryParse(json["updatedAt"] ?? ""),
      id: json["id"],
      openTime: json["openTime"],
      closeTime: json["closeTime"],
      workDays: json["workDays"] == null ? [] : List<dynamic>.from(json["workDays"]!.map((x) => x)),
      error: json["error"],
      clinic: json["clinic"],
    );
  }

  Map<String, dynamic> toJson() => {
        "code": code,
        "name": name,
        "address": address,
        "phone": phone,
        "openTime": openTime,
        "closeTime": closeTime,
        "clinic": clinic,
        "workDays": workDays?.map((x) => x).toList(),
      };
}

class ErrorModel {
  ErrorModel({
    required this.error,
    required this.statusCode,
  });

  final String? error;
  final String? statusCode;

  factory ErrorModel.fromJson(Map<String, dynamic> json) {
    return ErrorModel(
      error: json["error"],
      statusCode: json["statusCode"],
    );
  }

  Map<String, dynamic> toJson() => {
        "error": error,
      };
}
