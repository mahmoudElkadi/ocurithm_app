enum MessageStatus { sent, delivered, seen }

class ChatModel {
  final String id;
  final String name;
  final String lastMessage;
  final String time;
  final String avatar;
  final int unreadCount;
  final MessageStatus?
      status; // Null usually means received message or no status tracking

  ChatModel({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.avatar,
    this.unreadCount = 0,
    this.status,
  });
}

class MessageModel {
  final String id;
  final String text;
  final DateTime time;
  final bool isMe;
  final MessageStatus? status;

  MessageModel({
    required this.id,
    required this.text,
    required this.time,
    required this.isMe,
    this.status,
  });
}
