import '../../../Clinics/data/model/clinics_model.dart';

class LoginModel {
  LoginModel({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    required this.user,
  });

  final String? accessToken;
  final String? refreshToken;
  final int? expiresIn;
  final User? user;

  factory LoginModel.fromJson(Map<String, dynamic> json) {
    return LoginModel(
      accessToken: json["accessToken"],
      refreshToken: json["refreshToken"],
      expiresIn: json["expiresIn"],
      user: json["user"] == null ? null : User.fromJson(json["user"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "accessToken": accessToken,
    "refreshToken": refreshToken,
    "expiresIn": expiresIn,
    "user": user?.toJson(),
  };
}

class User {
  User({
    required this.id,
    required this.name,
    required this.userType,
    required this.clinic,
    required this.capabilities,
    this.image,
  });

  final String? id;
  final String? name;
  final String? userType;
  final Clinic? clinic;
  final List<String> capabilities;
  final String? image;

  factory User.fromJson(Map<String, dynamic> json) {
    final rawCaps = json["capabilities"];

    List<String> parsedCapabilities = [];

    if (rawCaps != null && rawCaps is List) {
      parsedCapabilities = rawCaps.map<String>((cap) {

        // Case 1 → Already String
        if (cap is String) {
          return cap;
        }

        // Case 2 → Object → Extract name
        if (cap is Map<String, dynamic>) {
          return cap["name"] ?? "";
        }

        // Fallback safety
        return "";
      }).where((cap) => cap.isNotEmpty).toList();
    }

    return User(
      id: json["id"],
      name: json["name"],
      userType: json["userType"],
      clinic: json["clinic"] == null ? null : Clinic.fromJson(json["clinic"]),
      capabilities: parsedCapabilities,
      image: json["image"],
    );
  }


  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "userType": userType,
    "clinic": clinic?.toJson(),
    "capabilities": capabilities.map((x) => x).toList(),
    "image": image,
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
