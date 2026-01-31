/// Model representing a participant in a chat thread
class ParticipantModel {
  final String id;
  final String name;
  final String userType;
  final bool isOnline;

  ParticipantModel({
    required this.id,
    required this.name,
    required this.userType,
    required this.isOnline,
  });

  factory ParticipantModel.fromJson(Map<String, dynamic> json) {
    return ParticipantModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      userType: json['userType'] ?? '',
      isOnline: json['isOnline'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'userType': userType,
      'isOnline': isOnline,
    };
  }
}
