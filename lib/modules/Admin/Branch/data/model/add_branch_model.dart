class AddBranchModel {
  AddBranchModel({
    this.code,
    this.name,
    this.address,
    this.phone,
    this.createdAt,
    this.updatedAt,
    this.id,
    this.error,
  });

  String? code;
  String? name;
  String? address;
  String? phone;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? id;
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
      error: json["error"],
    );
  }

  Map<String, dynamic> toJson() => {
        "code": code,
        "name": name,
        "address": address,
        "phone": phone,
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
