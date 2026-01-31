part of 'chat_messages_bloc.dart';

enum ChatMessagesStatus { initial, loading, success, error, noConnection }

enum ChatMessagesActionStatus { initial, sending, success, error }

extension ChatMessagesStatusX on ChatMessagesState {
  bool get isInitial => status == ChatMessagesStatus.initial;
  bool get isLoading => status == ChatMessagesStatus.loading;
  bool get isSuccess => status == ChatMessagesStatus.success;
  bool get isError => status == ChatMessagesStatus.error;
  bool get noConnection => status == ChatMessagesStatus.noConnection;
}

extension ChatMessagesActionStatusX on ChatMessagesState {
  bool get isSending => actionStatus == ChatMessagesActionStatus.sending;
  bool get isSendSuccess => actionStatus == ChatMessagesActionStatus.success;
  bool get isSendError => actionStatus == ChatMessagesActionStatus.error;
}

@immutable
class ChatMessagesState {
  final ChatMessagesStatus status;
  final ChatMessagesActionStatus actionStatus;
  final List<MessageModel> messages;
  final String? threadId;
  final String? errorMessage;
  final String? successMessage;
  final bool hasMore;
  final String? nextCursor;
  final bool isLoadingMore;

  const ChatMessagesState({
    this.status = ChatMessagesStatus.initial,
    this.actionStatus = ChatMessagesActionStatus.initial,
    this.messages = const [],
    this.threadId,
    this.errorMessage,
    this.successMessage,
    this.hasMore = false,
    this.nextCursor,
    this.isLoadingMore = false,
  });

  ChatMessagesState copyWith({
    ChatMessagesStatus? status,
    ChatMessagesActionStatus? actionStatus,
    List<MessageModel>? messages,
    String? threadId,
    String? errorMessage,
    String? successMessage,
    bool? hasMore,
    String? nextCursor,
    bool? isLoadingMore,
  }) {
    return ChatMessagesState(
      status: status ?? this.status,
      actionStatus: actionStatus ?? this.actionStatus,
      messages: messages ?? this.messages,
      threadId: threadId ?? this.threadId,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
      hasMore: hasMore ?? this.hasMore,
      nextCursor: nextCursor ?? this.nextCursor,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}
