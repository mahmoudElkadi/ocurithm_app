part of 'chat_socket_bloc.dart';

enum ChatSocketStatus { disconnected, connecting, connected, error }

enum ChatSocketEventType {
  newMessage,
  messageSent,
  messageStatus,
  messagesRead,
  userOnline,
  userOffline,
  threadUpdated,
  error,
}

extension ChatSocketStatusX on ChatSocketState {
  bool get isDisconnected => status == ChatSocketStatus.disconnected;
  bool get isConnecting => status == ChatSocketStatus.connecting;
  bool get isConnected => status == ChatSocketStatus.connected;
  bool get isError => status == ChatSocketStatus.error;
}

@immutable
class ChatSocketState {
  final ChatSocketStatus status;
  final String? errorMessage;
  final Set<String> onlineUsers;
  final ChatSocketEventType? lastEventType;

  // Last received events data
  final MessageModel? lastNewMessage;
  final MessageModel? lastSentMessage;
  final String? lastSentTempId;
  final Map<String, dynamic>? lastStatusUpdate;
  final Map<String, dynamic>? lastMessagesRead;
  final Map<String, dynamic>? lastThreadUpdate;

  // A timestamp to ensure state changes even if the event data is identical
  final DateTime? lastEventTimestamp;

  // Currently opened thread ID (null if chat is closed or on chat list)
  final String? activeThreadId;

  // Queue of messages waiting for connection to send
  final List<MessageModel> pendingMessages;

  // Track messages currently being emitted to avoid rapid duplicate sends
  final Set<String> sendingMessageIds;

  const ChatSocketState({
    this.status = ChatSocketStatus.disconnected,
    this.errorMessage,
    this.onlineUsers = const {},
    this.lastEventType,
    this.lastNewMessage,
    this.lastSentMessage,
    this.lastSentTempId,
    this.lastStatusUpdate,
    this.lastMessagesRead,
    this.lastThreadUpdate,
    this.lastEventTimestamp,
    this.activeThreadId,
    this.pendingMessages = const [],
    this.sendingMessageIds = const {},
  });

  ChatSocketState copyWith({
    ChatSocketStatus? status,
    String? errorMessage,
    Set<String>? onlineUsers,
    ChatSocketEventType? lastEventType,
    MessageModel? lastNewMessage,
    MessageModel? lastSentMessage,
    String? lastSentTempId,
    Map<String, dynamic>? lastStatusUpdate,
    Map<String, dynamic>? lastMessagesRead,
    Map<String, dynamic>? lastThreadUpdate,
    String? activeThreadId,
    List<MessageModel>? pendingMessages,
    Set<String>? sendingMessageIds,
    bool clearEvent = false,
    bool clearActiveThread = false,
  }) {
    return ChatSocketState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      onlineUsers: onlineUsers ?? this.onlineUsers,
      lastEventType: clearEvent ? null : (lastEventType ?? this.lastEventType),
      lastNewMessage:
          clearEvent ? null : (lastNewMessage ?? this.lastNewMessage),
      lastSentMessage:
          clearEvent ? null : (lastSentMessage ?? this.lastSentMessage),
      lastSentTempId:
          clearEvent ? null : (lastSentTempId ?? this.lastSentTempId),
      lastStatusUpdate:
          clearEvent ? null : (lastStatusUpdate ?? this.lastStatusUpdate),
      lastMessagesRead:
          clearEvent ? null : (lastMessagesRead ?? this.lastMessagesRead),
      lastThreadUpdate:
          clearEvent ? null : (lastThreadUpdate ?? this.lastThreadUpdate),
      lastEventTimestamp: clearEvent
          ? null
          : (lastEventType != null ? DateTime.now() : lastEventTimestamp),
      activeThreadId:
          clearActiveThread ? null : (activeThreadId ?? this.activeThreadId),
      pendingMessages: pendingMessages ?? this.pendingMessages,
      sendingMessageIds: sendingMessageIds ?? this.sendingMessageIds,
    );
  }

  /// Check if a user is online
  bool isUserOnline(String userId) => onlineUsers.contains(userId);
}
