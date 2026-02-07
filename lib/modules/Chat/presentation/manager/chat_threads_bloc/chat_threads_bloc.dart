import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/chat_models.dart';
import '../../../data/repos/chat_repo.dart';

part 'chat_threads_state.dart';
part 'chat_threads_event.dart';

class ChatThreadsBloc extends Bloc<ChatThreadsEvent, ChatThreadsState> {
  final ChatRepo chatRepo;

  ChatThreadsBloc(this.chatRepo) : super(const ChatThreadsState()) {
    on<FetchThreadsEvent>(_onFetchThreads);
    on<RefreshThreadsEvent>(_onRefreshThreads);
    on<LoadMoreThreadsEvent>(_onLoadMoreThreads);
    on<CreateThreadEvent>(_onCreateThread);
    on<UpdateThreadEvent>(_onUpdateThread);
    on<HandleSocketNewMessageEvent>(_onHandleSocketNewMessage);
    on<MarkThreadReadEvent>(_onMarkThreadRead);
    on<HandleMessagesReadEvent>(_onHandleMessagesRead);
    on<SearchThreadsEvent>(_onSearchThreads);
    on<ClearActiveThreadRefEvent>(_onClearActiveThreadRef);
    on<ResetThreadsEvent>(_onReset);
  }

  static ChatThreadsBloc get(BuildContext context) => BlocProvider.of(context);

  Future<void> _onFetchThreads(
    FetchThreadsEvent event,
    Emitter<ChatThreadsState> emit,
  ) async {
    try {
      if (state.threads.isEmpty) {
        emit(state.copyWith(status: ChatThreadsStatus.loading));
      }

      final result =
          await chatRepo.getThreads(page: 1, limit: 20, search: state.searchQuery);

      if (result.success && result.data != null) {
        emit(state.copyWith(
          status: ChatThreadsStatus.success,
          threads: result.data,
          currentPage: 1,
          hasMore: result.data!.length >= 20,
        ));
      } else {
        emit(state.copyWith(
          status: ChatThreadsStatus.error,
          errorMessage: result.message ?? 'Failed to fetch threads',
        ));
      }
    } catch (e) {
      if (e.toString().toLowerCase().contains('no internet connection')) {
        emit(state.copyWith(
          status: ChatThreadsStatus.noConnection,
          errorMessage: e.toString(),
        ));
        return;
      }
      emit(state.copyWith(
        status: ChatThreadsStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onRefreshThreads(
    RefreshThreadsEvent event,
    Emitter<ChatThreadsState> emit,
  ) async {
    // We don't call FetchThreads directly to avoid double emit of loading state if not needed
    // But for simplicity in this project's pattern:
    add(FetchThreadsEvent());
  }

  Future<void> _onLoadMoreThreads(
    LoadMoreThreadsEvent event,
    Emitter<ChatThreadsState> emit,
  ) async {
    if (state.isLoadingMore || !state.hasMore) return;

    try {
      emit(state.copyWith(isLoadingMore: true));

      final nextPage = state.currentPage + 1;
      final result = await chatRepo.getThreads(
          page: nextPage, limit: 20, search: state.searchQuery);

      if (result.success && result.data != null) {
        final newThreads = [...state.threads, ...result.data!];
        emit(state.copyWith(
          threads: newThreads,
          currentPage: nextPage,
          hasMore: result.data!.length >= 20,
          isLoadingMore: false,
        ));
      } else {
        emit(state.copyWith(isLoadingMore: false));
      }
    } catch (e) {
      emit(state.copyWith(isLoadingMore: false));
    }
  }

  Future<void> _onCreateThread(
    CreateThreadEvent event,
    Emitter<ChatThreadsState> emit,
  ) async {
    try {
      emit(state.copyWith(
        actionStatus: ChatThreadsActionStatus.loading,
        loadingActionId: event.participantId,
      ));

      final result =
          await chatRepo.createThread(participantId: event.participantId);

      if (result.success && result.data != null) {
        final threads = List<ThreadModel>.from(state.threads);
        final existingIndex =
            threads.indexWhere((t) => t.id == result.data!.id);

        if (existingIndex >= 0) {
          threads[existingIndex] = result.data!;
        } else {
          threads.insert(0, result.data!);
        }

        // Set as active thread immediately for socket context
        emit(state.copyWith(
          actionStatus: ChatThreadsActionStatus.success,
          threads: threads,
          activeThread: result.data,
          successMessage: 'Thread created successfully',
          clearActionId: true,
        ));
      } else {
        emit(state.copyWith(
          actionStatus: ChatThreadsActionStatus.error,
          errorMessage: result.message ?? 'Failed to create thread',
          clearActionId: true,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        actionStatus: ChatThreadsActionStatus.error,
        errorMessage: e.toString(),
        clearActionId: true,
      ));
    }
  }

  Future<void> _onUpdateThread(
    UpdateThreadEvent event,
    Emitter<ChatThreadsState> emit,
  ) async {
    final threads = List<ThreadModel>.from(state.threads);
    final index = threads.indexWhere((t) => t.id == event.thread.id);

    if (index >= 0) {
      threads[index] = event.thread;
      // Re-sort by updatedAt
      threads.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    } else {
      threads.insert(0, event.thread);
    }

    emit(state.copyWith(threads: threads));
  }

  Future<void> _onHandleSocketNewMessage(
    HandleSocketNewMessageEvent event,
    Emitter<ChatThreadsState> emit,
  ) async {
    final threads = List<ThreadModel>.from(state.threads);
    final index = threads.indexWhere((t) => t.id == event.message.threadId);

    if (index >= 0) {
      final thread = threads[index];

      // Prevent duplicate processing of the same message (e.g. if socket emits twice)
      if (thread.lastMessage?.id == event.message.id) {
        return;
      }

      // Update the thread's last message and unread count
      final updatedThread = thread.copyWith(
        lastMessage: LastMessageModel(
          id: event.message.id,
          content: event.message.content,
          senderId: event.message.senderId,
          isMine: event.message.isMine,
          status: event.message.status,
          createdAt: event.message.createdAt,
        ),
        unreadCount:
            event.message.isMine ? thread.unreadCount : thread.unreadCount + 1,
        updatedAt: event.message.createdAt,
      );

      threads.removeAt(index);
      threads.insert(0, updatedThread);

      emit(state.copyWith(threads: threads));
    } else {
      // If thread not found, it might be a new conversation starting.
      // Easiest is to refresh from API to get the full thread details.
      add(RefreshThreadsEvent());
    }
  }

  Future<void> _onMarkThreadRead(
    MarkThreadReadEvent event,
    Emitter<ChatThreadsState> emit,
  ) async {
    final threads = List<ThreadModel>.from(state.threads);
    final index = threads.indexWhere((t) => t.id == event.threadId);

    if (index >= 0) {
      final thread = threads[index];
      if (thread.unreadCount > 0) {
        threads[index] = thread.copyWith(unreadCount: 0);
        emit(state.copyWith(threads: threads));
      }
    }
  }

  Future<void> _onHandleMessagesRead(
    HandleMessagesReadEvent event,
    Emitter<ChatThreadsState> emit,
  ) async {
    final threads = List<ThreadModel>.from(state.threads);
    final index = threads.indexWhere((t) => t.id == event.threadId);

    if (index >= 0) {
      final thread = threads[index];
      if (thread.lastMessage != null &&
          thread.lastMessage!.isMine &&
          thread.lastMessage!.status != MessageStatus.read) {
        // Update the last message status to read
        final updatedLastMessage =
            thread.lastMessage!.copyWith(status: MessageStatus.read);

        threads[index] = thread.copyWith(lastMessage: updatedLastMessage);
        emit(state.copyWith(threads: threads));
      }
    }
  }

  Future<void> _onSearchThreads(
    SearchThreadsEvent event,
    Emitter<ChatThreadsState> emit,
  ) async {
    emit(state.copyWith(searchQuery: event.query));
    add(FetchThreadsEvent());
  }

  Future<void> _onClearActiveThreadRef(
    ClearActiveThreadRefEvent event,
    Emitter<ChatThreadsState> emit,
  ) async {
    emit(state.copyWith(clearActiveThread: true));
  }

  Future<void> _onReset(
    ResetThreadsEvent event,
    Emitter<ChatThreadsState> emit,
  ) async {
    emit(const ChatThreadsState());
  }
}
