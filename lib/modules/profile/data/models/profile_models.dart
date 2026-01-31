import '../../../Branch/data/model/branches_model.dart';
import '../../../Clinics/data/model/clinics_model.dart';

class ProfileModel {
  ProfileModel({
    required this.id,
    required this.userType,
    required this.name,
    required this.username,
    required this.phone,
    required this.email,
    required this.clinic,
    required this.branch,
    required this.isActive,
    required this.lastLogin,
    required this.capabilities,
    required this.image,
    required this.createdAt,
    required this.updatedAt,
  });

  final String? id;
  final String? userType;
  final String? name;
  final String? username;
  final dynamic phone;
  final dynamic email;
  final Clinic? clinic;
  final Branch? branch;
  final bool? isActive;
  final DateTime? lastLogin;
  final List<String> capabilities;
  final String? image;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json["id"],
      userType: json["userType"],
      name: json["name"],
      username: json["username"],
      phone: json["phone"],
      email: json["email"],
      clinic: json["clinic"] == null ? null : Clinic.fromJson(json["clinic"]),
      branch: json["branch"] == null ? null : Branch.fromJson(json["branch"]),
      isActive: json["isActive"],
      lastLogin: DateTime.tryParse(json["lastLogin"] ?? ""),
      capabilities: json["capabilities"] == null
          ? []
          : List<String>.from(json["capabilities"]!.map((x) => x)),
      image: json["image"],
      createdAt: DateTime.tryParse(json["createdAt"] ?? ""),
      updatedAt: DateTime.tryParse(json["updatedAt"] ?? ""),
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "userType": userType,
        "name": name,
        "username": username,
        "phone": phone,
        "email": email,
        "clinic": clinic?.toJson(),
        "branch": branch,
        "isActive": isActive,
        "lastLogin": lastLogin?.toIso8601String(),
        "capabilities": capabilities.map((x) => x).toList(),
        "image": image,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
      };
}
