/// Model representing a user available for chat
class ChatUserModel {
  final String id;
  final String name;
  final String userType;
  final bool isOnline;
  final String? threadId; // Existing thread ID if any

  ChatUserModel({
    required this.id,
    required this.name,
    required this.userType,
    required this.isOnline,
    this.threadId,
  });

  factory ChatUserModel.fromJson(Map<String, dynamic> json) {
    return ChatUserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      userType: json['userType'] ?? '',
      isOnline: json['isOnline'] ?? false,
      threadId: json['threadId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'userType': userType,
      'isOnline': isOnline,
      'threadId': threadId,
    };
  }
}
