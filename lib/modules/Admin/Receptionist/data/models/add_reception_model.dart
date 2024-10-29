class AddReceptionistsModel {
  AddReceptionistsModel({
    required this.name,
    required this.image,
    required this.phone,
    required this.birthDate,
    required this.branch,
    required this.isActive,
    required this.capabilities,
    required this.createdAt,
    required this.updatedAt,
    required this.id,
    required this.error,
  });

  final String? name;
  final String? image;
  final String? phone;
  final DateTime? birthDate;
  final String? branch;
  final bool? isActive;
  final List<String> capabilities;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? id;
  final String? error;

  factory AddReceptionistsModel.fromJson(Map<String, dynamic> json) {
    return AddReceptionistsModel(
      name: json["name"],
      image: json["image"],
      phone: json["phone"],
      birthDate: DateTime.tryParse(json["birthDate"] ?? ""),
      branch: json["branch"],
      isActive: json["isActive"],
      capabilities: json["capabilities"] == null ? [] : List<String>.from(json["capabilities"]!.map((x) => x)),
      createdAt: DateTime.tryParse(json["createdAt"] ?? ""),
      updatedAt: DateTime.tryParse(json["updatedAt"] ?? ""),
      id: json["id"],
      error: json["error"],
    );
  }

  Map<String, dynamic> toJson() => {
        "name": name,
        "image": image,
        "phone": phone,
        "birthDate": birthDate?.toIso8601String(),
        "branch": branch,
        "isActive": isActive,
        "capabilities": capabilities.map((x) => x).toList(),
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "id": id,
        "error": error,
      };
}
