part of 'chat_socket_bloc.dart';

@immutable
abstract class ChatSocketEvent {
  const ChatSocketEvent();
}

/// Event to connect to chat socket
class ConnectSocketEvent extends ChatSocketEvent {}

/// Event to disconnect from chat socket
class DisconnectSocketEvent extends ChatSocketEvent {}

/// Event to send message via socket
class SendMessageViaSocketEvent extends ChatSocketEvent {
  final String threadId;
  final String content;
  final String? tempId;
  const SendMessageViaSocketEvent({
    required this.threadId,
    required this.content,
    this.tempId,
  });
}

/// Event to mark thread as read via socket
class MarkReadViaSocketEvent extends ChatSocketEvent {
  final String threadId;
  const MarkReadViaSocketEvent({required this.threadId});
}

/// Event to acknowledge message delivery
class AckDeliveryEvent extends ChatSocketEvent {
  final String messageId;
  const AckDeliveryEvent({required this.messageId});
}

/// Event when new message received from server
class SocketNewMessageEvent extends ChatSocketEvent {
  final Map<String, dynamic> payload;
  const SocketNewMessageEvent({required this.payload});
}

/// Event when message sent confirmation received
class SocketMessageSentEvent extends ChatSocketEvent {
  final Map<String, dynamic> payload;
  const SocketMessageSentEvent({required this.payload});
}

/// Event when message status updated
class SocketMessageStatusEvent extends ChatSocketEvent {
  final Map<String, dynamic> payload;
  const SocketMessageStatusEvent({required this.payload});
}

/// Event when messages marked as read
class SocketMessagesReadEvent extends ChatSocketEvent {
  final Map<String, dynamic> payload;
  const SocketMessagesReadEvent({required this.payload});
}

/// Event when user comes online
class SocketUserOnlineEvent extends ChatSocketEvent {
  final Map<String, dynamic> payload;
  const SocketUserOnlineEvent({required this.payload});
}

/// Event when user goes offline
class SocketUserOfflineEvent extends ChatSocketEvent {
  final Map<String, dynamic> payload;
  const SocketUserOfflineEvent({required this.payload});
}

/// Event when thread updated
class SocketThreadUpdatedEvent extends ChatSocketEvent {
  final Map<String, dynamic> payload;
  const SocketThreadUpdatedEvent({required this.payload});
}

/// Event to clear socket event data
class ClearSocketEventsEvent extends ChatSocketEvent {}

/// Event to set the currently active thread (opened in UI)
class SetActiveThreadEvent extends ChatSocketEvent {
  final String threadId;
  const SetActiveThreadEvent({required this.threadId});
}

/// Event to clear the currently active thread
class ClearActiveThreadEvent extends ChatSocketEvent {}

/// Event to retry sending messages that failed due to connection issues
class RetryPendingMessagesEvent extends ChatSocketEvent {}

class _LoadPendingMessagesEvent extends ChatSocketEvent {
  const _LoadPendingMessagesEvent();
}

// --- Internal Socket Events ---

class _SocketConnectedEvent extends ChatSocketEvent {
  const _SocketConnectedEvent();
}

class _SocketDisconnectedEvent extends ChatSocketEvent {
  const _SocketDisconnectedEvent();
}

class _SocketErrorEvent extends ChatSocketEvent {
  final String error;
  const _SocketErrorEvent(this.error);
}
