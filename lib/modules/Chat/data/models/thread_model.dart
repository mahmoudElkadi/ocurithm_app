import 'participant_model.dart';
import 'last_message_model.dart';

/// Model representing a chat thread/conversation
class ThreadModel {
  final String id;
  final ParticipantModel participant;
  final LastMessageModel? lastMessage;
  final int unreadCount;
  final bool isActive;
  final DateTime updatedAt;
  final DateTime? createdAt;

  ThreadModel({
    required this.id,
    required this.participant,
    this.lastMessage,
    required this.unreadCount,
    required this.isActive,
    required this.updatedAt,
    this.createdAt,
  });

  factory ThreadModel.fromJson(Map<String, dynamic> json) {
    return ThreadModel(
      id: json['id'] ?? '',
      participant: ParticipantModel.fromJson(json['participant'] ?? {}),
      lastMessage: json['lastMessage'] != null
          ? LastMessageModel.fromJson(json['lastMessage'])
          : null,
      unreadCount: json['unreadCount'] ?? 0,
      isActive: json['isActive'] ?? true,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'participant': participant.toJson(),
      'lastMessage': lastMessage?.toJson(),
      'unreadCount': unreadCount,
      'isActive': isActive,
      'updatedAt': updatedAt.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  ThreadModel copyWith({
    String? id,
    ParticipantModel? participant,
    LastMessageModel? lastMessage,
    int? unreadCount,
    bool? isActive,
    DateTime? updatedAt,
    DateTime? createdAt,
  }) {
    return ThreadModel(
      id: id ?? this.id,
      participant: participant ?? this.participant,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      isActive: isActive ?? this.isActive,
      updatedAt: updatedAt ?? this.updatedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
