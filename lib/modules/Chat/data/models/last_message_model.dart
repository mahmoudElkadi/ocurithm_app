import '../../../../core/utils/format_helper.dart';
import 'message_model.dart';

/// Model representing the last message preview in a thread
class LastMessageModel {
  final String? id;
  final String content;
  final String senderId;
  final bool isMine;
  final MessageStatus status;
  final DateTime createdAt;

  LastMessageModel({
    this.id,
    required this.content,
    required this.senderId,
    required this.isMine,
    required this.status,
    required this.createdAt,
  });

  factory LastMessageModel.fromJson(Map<String, dynamic> json) {
    return LastMessageModel(
      id: json['id'],
      content: json['content'] ?? '',
      senderId: json['senderId'] ?? '',
      isMine: json['isMine'] ?? false,
      status:
          (json['status'] as String?)?.toMessageStatus() ?? MessageStatus.sent,
      createdAt:
          FormatHelper.formatUtcTime(json['createdAt']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'senderId': senderId,
      'isMine': isMine,
      'status': status.toStatusString(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
