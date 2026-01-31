/// Message status enum matching backend
enum MessageStatus { sent, delivered, read }

/// Extension to convert string to MessageStatus
extension MessageStatusExtension on String {
  MessageStatus toMessageStatus() {
    switch (toLowerCase()) {
      case 'delivered':
        return MessageStatus.delivered;
      case 'read':
        return MessageStatus.read;
      case 'sent':
      default:
        return MessageStatus.sent;
    }
  }
}

/// Extension to convert MessageStatus to string
extension MessageStatusToString on MessageStatus {
  String toStatusString() {
    switch (this) {
      case MessageStatus.delivered:
        return 'delivered';
      case MessageStatus.read:
        return 'read';
      case MessageStatus.sent:
        return 'sent';
    }
  }
}

/// Model representing a chat message
class MessageModel {
  final String id;
  final String content;
  final String senderId;
  final bool isMine;
  final MessageStatus status;
  final DateTime createdAt;
  final String? threadId;
  final String? senderName;

  MessageModel({
    required this.id,
    required this.content,
    required this.senderId,
    required this.isMine,
    required this.status,
    required this.createdAt,
    this.threadId,
    this.senderName,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] ?? '',
      content: json['content'] ?? '',
      senderId: json['senderId'] ?? '',
      isMine: json['isMine'] ?? false,
      status:
          (json['status'] as String?)?.toMessageStatus() ?? MessageStatus.sent,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      threadId: json['threadId'],
      senderName: json['senderName'],
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
      'threadId': threadId,
      'senderName': senderName,
    };
  }

  MessageModel copyWith({
    String? id,
    String? content,
    String? senderId,
    bool? isMine,
    MessageStatus? status,
    DateTime? createdAt,
    String? threadId,
    String? senderName,
  }) {
    return MessageModel(
      id: id ?? this.id,
      content: content ?? this.content,
      senderId: senderId ?? this.senderId,
      isMine: isMine ?? this.isMine,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      threadId: threadId ?? this.threadId,
      senderName: senderName ?? this.senderName,
    );
  }
}
