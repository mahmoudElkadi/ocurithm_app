class ChatModel {
  final String id;
  final String name;
  final String lastMessage;
  final String time;
  final String avatar;
  final int unreadCount;

  ChatModel({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.avatar,
    this.unreadCount = 0,
  });
}

class MessageModel {
  final String id;
  final String text;
  final DateTime time;
  final bool isMe;

  MessageModel({
    required this.id,
    required this.text,
    required this.time,
    required this.isMe,
  });
}
