class LoginModel {
  LoginModel({
    required this.token,
    required this.user,
    required this.message,
  });

  final String? token;
  final String? message;
  final User? user;

  factory LoginModel.fromJson(Map<String, dynamic> json) {
    return LoginModel(
      token: json["token"],
      message: json["message"],
      user: json["user"] == null ? null : User.fromJson(json["user"]),
    );
  }

  Map<String, dynamic> toJson() => {
        "token": token,
        "message": message,
        "user": user?.toJson(),
      };
}

class User {
  User({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.username,
    required this.password,
    required this.role,
    required this.token,
    required this.imageId,
    required this.status,
    required this.branch,
  });

  final String? userId;
  final String? fullName;
  final String? email;
  final String? phone;
  final String? username;
  final String? password;
  final String? role;
  final dynamic token;
  final dynamic imageId;
  final String? status;
  final String? branch;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json["user_id"],
      fullName: json["full_name"],
      email: json["email"],
      phone: json["phone"],
      username: json["username"],
      password: json["password"],
      role: json["role"],
      token: json["token"],
      imageId: json["image_id"],
      status: json["status"],
      branch: json["branch_name"],
    );
  }

  Map<String, dynamic> toJson() => {
        "user_id": userId,
        "full_name": fullName,
        "email": email,
        "phone": phone,
        "username": username,
        "password": password,
        "role": role,
        "token": token,
        "image_id": imageId,
        "status": status,
        "branch_name": branch,
      };
}
