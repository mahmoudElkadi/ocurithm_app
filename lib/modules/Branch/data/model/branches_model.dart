class BranchesModel {
  BranchesModel({
    required this.branches,
    this.total,
    this.totalPages,
    this.error,
  });

  List<Branch> branches;
  num? total;
  num? totalPages;
  String? error;

  factory BranchesModel.fromJson(Map<String, dynamic> json) {
    return BranchesModel(
      branches: json["branches"] == null ? [] : List<Branch>.from(json["branches"]!.map((x) => Branch.fromJson(x))),
      total: json["total"],
      totalPages: json["totalPages"],
      error: json["error"],
    );
  }

  Map<String, dynamic> toJson() => {
        "branches": branches.map((x) => x?.toJson()).toList(),
        "total": total,
        "totalPages": totalPages,
      };
}

class Branch {
  Branch({
    this.code,
    this.name,
    this.address,
    this.phone,
    this.createdAt,
    this.updatedAt,
    this.id,
  });

  String? code;
  String? name;
  String? address;
  String? phone;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? id;

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      code: json["code"],
      name: json["name"],
      address: json["address"],
      phone: json["phone"],
      createdAt: DateTime.tryParse(json["createdAt"] ?? ""),
      updatedAt: DateTime.tryParse(json["updatedAt"] ?? ""),
      id: json["id"],
    );
  }

  Map<String, dynamic> toJson() => {
        "code": code,
        "name": name,
        "address": address,
        "phone": phone,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "id": id,
      };
}
