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
    required this.name,
    required this.username,
    required this.capabilities,
    required this.createdAt,
    required this.updatedAt,
    required this.id,
  });

  final String? name;
  final String? username;
  final List<Capability> capabilities;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? id;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json["name"],
      username: json["username"],
      capabilities: json["capabilities"] == null ? [] : List<Capability>.from(json["capabilities"]!.map((x) => Capability.fromJson(x))),
      createdAt: DateTime.tryParse(json["createdAt"] ?? ""),
      updatedAt: DateTime.tryParse(json["updatedAt"] ?? ""),
      id: json["id"],
    );
  }

  Map<String, dynamic> toJson() => {
        "name": name,
        "username": username,
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
