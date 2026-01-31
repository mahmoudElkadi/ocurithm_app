part of 'chat_threads_bloc.dart';

enum ChatThreadsStatus { initial, loading, success, error, noConnection }

enum ChatThreadsActionStatus { initial, loading, success, error, noConnection }

extension ChatThreadsStatusX on ChatThreadsState {
  bool get isInitial => status == ChatThreadsStatus.initial;
  bool get isLoading => status == ChatThreadsStatus.loading;
  bool get isSuccess => status == ChatThreadsStatus.success;
  bool get isError => status == ChatThreadsStatus.error;
  bool get noConnection => status == ChatThreadsStatus.noConnection;
}

extension ChatThreadsActionStatusX on ChatThreadsState {
  bool get isActionLoading => actionStatus == ChatThreadsActionStatus.loading;
  bool get isActionSuccess => actionStatus == ChatThreadsActionStatus.success;
  bool get isActionError => actionStatus == ChatThreadsActionStatus.error;
  bool get actionNoConnection =>
      actionStatus == ChatThreadsActionStatus.noConnection;
}

@immutable
class ChatThreadsState {
  final ChatThreadsStatus status;
  final ChatThreadsActionStatus actionStatus;
  final List<ThreadModel> threads;
  final ThreadModel? activeThread;
  final String? errorMessage;
  final String? successMessage;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;

  const ChatThreadsState({
    this.status = ChatThreadsStatus.initial,
    this.actionStatus = ChatThreadsActionStatus.initial,
    this.threads = const [],
    this.activeThread,
    this.errorMessage,
    this.successMessage,
    this.currentPage = 1,
    this.hasMore = false,
    this.isLoadingMore = false,
  });

  ChatThreadsState copyWith({
    ChatThreadsStatus? status,
    ChatThreadsActionStatus? actionStatus,
    List<ThreadModel>? threads,
    ThreadModel? activeThread,
    String? errorMessage,
    String? successMessage,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return ChatThreadsState(
      status: status ?? this.status,
      actionStatus: actionStatus ?? this.actionStatus,
      threads: threads ?? this.threads,
      activeThread: activeThread ?? this.activeThread,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}
