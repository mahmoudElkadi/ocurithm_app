import '../models/chat_model.dart';

class ChatMockData {
  static List<ChatModel> chats = [
    ChatModel(
      id: '1',
      name: 'Ahmed Mohamed',
      lastMessage: 'Hello, how are you today?',
      time: '12:30 PM',
      avatar: 'https://i.pravatar.cc/150?u=ahmed',
      unreadCount: 2,
    ),
    ChatModel(
      id: '2',
      name: 'Sarah Ali',
      lastMessage: 'The report is ready for review.',
      time: '11:45 AM',
      avatar: 'https://i.pravatar.cc/150?u=sarah',
      unreadCount: 0,
    ),
    ChatModel(
      id: '3',
      name: 'Dr. Khaled',
      lastMessage: 'Please check the patient status.',
      time: '昨天',
      avatar: 'https://i.pravatar.cc/150?u=khaled',
      unreadCount: 5,
    ),
    ChatModel(
      id: '4',
      name: 'Reception Team',
      lastMessage: 'New appointment scheduled at 3 PM.',
      time: 'Monday',
      avatar: 'https://i.pravatar.cc/150?u=team',
      unreadCount: 0,
    ),
  ];

  static List<MessageModel> messages = [
    MessageModel(
        id: '1',
        text: 'Hi Sarah!',
        time: DateTime.now().subtract(const Duration(minutes: 10)),
        isMe: true),
    MessageModel(
        id: '2',
        text: 'Hello! How is it going?',
        time: DateTime.now().subtract(const Duration(minutes: 9)),
        isMe: false),
    MessageModel(
        id: '3',
        text: 'Great, I finished the design for the new chat module.',
        time: DateTime.now().subtract(const Duration(minutes: 8)),
        isMe: true),
    MessageModel(
        id: '4',
        text: 'Awesome! Can I see it?',
        time: DateTime.now().subtract(const Duration(minutes: 7)),
        isMe: false),
    MessageModel(
        id: '5',
        text: 'Sure, I will send you the prototype link shortly.',
        time: DateTime.now().subtract(const Duration(minutes: 5)),
        isMe: true),
    MessageModel(
        id: '6',
        text: 'Perfect, waiting for it.',
        time: DateTime.now().subtract(const Duration(minutes: 2)),
        isMe: false),
  ];
}
