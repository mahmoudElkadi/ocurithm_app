import '../../../Branch/data/model/branches_model.dart';
import '../../../Clinics/data/model/clinics_model.dart';

class LoginModel {
  LoginModel({
    required this.message,
    required this.user,
    required this.token,
  });

  final String? message;
  final User? user;
  final String? token;

  factory LoginModel.fromJson(Map<String, dynamic> json) {
    return LoginModel(
      message: json["message"],
      user: json["user"] == null ? null : User.fromJson(json["user"]),
      token: json["token"],
    );
  }

  Map<String, dynamic> toJson() => {
        "message": message,
        "user": user?.toJson(),
        "token": token,
      };
}

class User {
  User({
    required this.clinic,
    required this.name,
    required this.phone,
    required this.image,
    required this.birthDate,
    required this.branch,
    required this.isActive,
    required this.capabilities,
    required this.createdAt,
    required this.updatedAt,
    required this.id,
  });

  final Clinic? clinic;
  final String? name;
  final String? phone;
  final String? image;
  final DateTime? birthDate;
  final Branch? branch;
  final bool? isActive;
  final List<Capability> capabilities;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? id;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      clinic: json["clinic"] == null ? null : Clinic.fromJson(json["clinic"]),
      name: json["name"],
      phone: json["phone"],
      image: json["image"],
      birthDate: DateTime.tryParse(json["birthDate"] ?? ""),
      branch: json["branch"] == null ? null : Branch.fromJson(json["branch"]),
      isActive: json["isActive"],
      capabilities: json["capabilities"] == null ? [] : List<Capability>.from(json["capabilities"]!.map((x) => Capability.fromJson(x))),
      createdAt: DateTime.tryParse(json["createdAt"] ?? ""),
      updatedAt: DateTime.tryParse(json["updatedAt"] ?? ""),
      id: json["id"],
    );
  }

  Map<String, dynamic> toJson() => {
        "clinic": clinic?.toJson(),
        "name": name,
        "phone": phone,
        "image": image,
        "birthDate": birthDate?.toIso8601String(),
        "branch": branch?.toJson(),
        "isActive": isActive,
        "capabilities": capabilities.map((x) => x?.toJson()).toList(),
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "id": id,
      };
}

class Capability {
  Capability({
    required this.isActive,
    required this.name,
    required this.id,
  });

  final bool? isActive;
  final String? name;
  final String? id;

  factory Capability.fromJson(Map<String, dynamic> json) {
    return Capability(
      isActive: json["isActive"],
      name: json["name"],
      id: json["id"],
    );
  }

  Map<String, dynamic> toJson() => {
        "isActive": isActive,
        "name": name,
        "id": id,
      };
}
