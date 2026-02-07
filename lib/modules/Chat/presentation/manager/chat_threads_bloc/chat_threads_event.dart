part of 'chat_threads_bloc.dart';

@immutable
abstract class ChatThreadsEvent {}

/// Event to fetch threads from API
class FetchThreadsEvent extends ChatThreadsEvent {}

/// Event to refresh threads (re-fetch first page)
class RefreshThreadsEvent extends ChatThreadsEvent {}

/// Event to load more threads (pagination)
class LoadMoreThreadsEvent extends ChatThreadsEvent {}

/// Event to create a new thread with a participant
class CreateThreadEvent extends ChatThreadsEvent {
  final String participantId;
  CreateThreadEvent({required this.participantId});
}

/// Event to update a single thread in the list (local or from socket)
class UpdateThreadEvent extends ChatThreadsEvent {
  final ThreadModel thread;
  UpdateThreadEvent({required this.thread});
}

/// Event to handle new message received via socket (updates last message and unread count)
class HandleSocketNewMessageEvent extends ChatThreadsEvent {
  final MessageModel message;
  HandleSocketNewMessageEvent({required this.message});
}

/// Event to mark a thread as read locally
class MarkThreadReadEvent extends ChatThreadsEvent {
  final String threadId;
  MarkThreadReadEvent({required this.threadId});
}

/// Event to update last message status to 'read' based on socket event
class HandleMessagesReadEvent extends ChatThreadsEvent {
  final String threadId;
  HandleMessagesReadEvent({required this.threadId});
}

/// Event to reset state
class ResetThreadsEvent extends ChatThreadsEvent {}
