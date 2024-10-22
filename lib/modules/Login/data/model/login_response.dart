class LoginModel {
  LoginModel({
    required this.message,
    required this.user,
    required this.token,
  });

  String? message;
  User? user;
  String? token;

  factory LoginModel.fromJson(Map<String, dynamic> json) {
    return LoginModel(
      message: json["message"],
      token: json["token"],
      user: json["user"] == null ? null : User.fromJson(json["user"]),
    );
  }

  Map<String, dynamic> toJson() => {
        "message": message,
        "token": token,
        "user": user?.toJson(),
      };
}

class User {
  User({
    required this.name,
    required this.username,
    required this.password,
    required this.capabilities,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
    required this.id,
  });

  String? name;
  String? username;
  String? password;
  List<String> capabilities;
  DateTime? createdAt;
  DateTime? updatedAt;
  bool? isActive;
  String? id;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json["name"],
      username: json["username"],
      password: json["password"],
      capabilities: json["capabilities"] == null ? [] : List<String>.from(json["capabilities"]!.map((x) => x)),
      createdAt: DateTime.tryParse(json["createdAt"] ?? ""),
      updatedAt: DateTime.tryParse(json["updatedAt"] ?? ""),
      isActive: json["isActive"],
      id: json["id"],
    );
  }

  Map<String, dynamic> toJson() => {
        "name": name,
        "username": username,
        "password": password,
        "capabilities": capabilities.map((x) => x).toList(),
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "isActive": isActive,
        "id": id,
      };
}
