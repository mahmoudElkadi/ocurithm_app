part of 'chat_messages_bloc.dart';

@immutable
abstract class ChatMessagesEvent {}

class FetchMessagesEvent extends ChatMessagesEvent {
  final String threadId;
  FetchMessagesEvent({required this.threadId});
}

class LoadMoreMessagesEvent extends ChatMessagesEvent {}

class SendMessageEvent extends ChatMessagesEvent {
  final String content;
  SendMessageEvent({required this.content});
}

class AddOptimisticMessageEvent extends ChatMessagesEvent {
  final String content;
  final String? tempId;
  AddOptimisticMessageEvent({required this.content, this.tempId});
}

class AddPendingMessagesEvent extends ChatMessagesEvent {
  final List<MessageModel> messages;
  AddPendingMessagesEvent({required this.messages});
}

class AddMessageEvent extends ChatMessagesEvent {
  final MessageModel message;
  final String? tempId;
  AddMessageEvent({required this.message, this.tempId});
}

class UpdateMessageStatusEvent extends ChatMessagesEvent {
  final String messageId;
  final MessageStatus status;
  UpdateMessageStatusEvent({required this.messageId, required this.status});
}

class MarkMessagesAsReadEvent extends ChatMessagesEvent {
  final List<String> messageIds;
  MarkMessagesAsReadEvent({required this.messageIds});
}

class ClearMessagesEvent extends ChatMessagesEvent {}

class ResetMessagesEvent extends ChatMessagesEvent {}
