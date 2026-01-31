import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/chat_models.dart';
import '../../../data/repos/chat_repo.dart';

part 'chat_messages_state.dart';
part 'chat_messages_event.dart';

class ChatMessagesBloc extends Bloc<ChatMessagesEvent, ChatMessagesState> {
  final ChatRepo chatRepo;

  ChatMessagesBloc(this.chatRepo) : super(const ChatMessagesState()) {
    on<FetchMessagesEvent>(_onFetchMessages);
    on<LoadMoreMessagesEvent>(_onLoadMoreMessages);
    on<SendMessageEvent>(_onSendMessage);
    on<AddOptimisticMessageEvent>(_onAddOptimisticMessage);
    on<AddMessageEvent>(_onAddMessage);
    on<UpdateMessageStatusEvent>(_onUpdateMessageStatus);
    on<MarkMessagesAsReadEvent>(_onMarkMessagesAsRead);
    on<ClearMessagesEvent>(_onClearMessages);
    on<ResetMessagesEvent>(_onReset);
  }

  static ChatMessagesBloc get(BuildContext context) => BlocProvider.of(context);

  Future<void> _onFetchMessages(
    FetchMessagesEvent event,
    Emitter<ChatMessagesState> emit,
  ) async {
    try {
      if (state.messages.isEmpty) {
        emit(state.copyWith(
          status: ChatMessagesStatus.loading,
          threadId: event.threadId,
        ));
      } else {
        emit(state.copyWith(threadId: event.threadId));
      }

      final result = await chatRepo.getMessages(
        threadId: event.threadId,
        limit: 30,
      );

      if (result.success && result.data != null) {
        final data = result.data!;
        final messages = (data['messages'] as List<MessageModel>?) ?? [];
        final hasMore = data['hasMore'] as bool? ?? false;
        final nextCursor = data['nextCursor'] as String?;

        emit(state.copyWith(
          status: ChatMessagesStatus.success,
          messages: messages,
          hasMore: hasMore,
          nextCursor: nextCursor,
        ));
      } else {
        emit(state.copyWith(
          status: ChatMessagesStatus.error,
          errorMessage: result.message ?? 'Failed to fetch messages',
        ));
      }
    } catch (e) {
      if (e.toString().toLowerCase().contains('no internet connection')) {
        emit(state.copyWith(
          status: ChatMessagesStatus.noConnection,
          errorMessage: e.toString(),
        ));
        return;
      }
      emit(state.copyWith(
        status: ChatMessagesStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onLoadMoreMessages(
    LoadMoreMessagesEvent event,
    Emitter<ChatMessagesState> emit,
  ) async {
    if (state.isLoadingMore || !state.hasMore || state.threadId == null) return;

    try {
      emit(state.copyWith(isLoadingMore: true));

      final result = await chatRepo.getMessages(
        threadId: state.threadId!,
        limit: 30,
        before: state.nextCursor,
      );

      if (result.success && result.data != null) {
        final data = result.data!;
        final newMessages = (data['messages'] as List<MessageModel>?) ?? [];
        final hasMore = data['hasMore'] as bool? ?? false;
        final nextCursor = data['nextCursor'] as String?;

        final allMessages = [...state.messages, ...newMessages];

        emit(state.copyWith(
          messages: allMessages,
          hasMore: hasMore,
          nextCursor: nextCursor,
          isLoadingMore: false,
        ));
      } else {
        emit(state.copyWith(isLoadingMore: false));
      }
    } catch (e) {
      emit(state.copyWith(isLoadingMore: false));
    }
  }

  Future<void> _onSendMessage(
    SendMessageEvent event,
    Emitter<ChatMessagesState> emit,
  ) async {
    if (state.threadId == null) return;

    try {
      emit(state.copyWith(actionStatus: ChatMessagesActionStatus.sending));

      // Create optimistic message
      final tempMessage = MessageModel(
        id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
        content: event.content,
        senderId: '', // Will be filled by backend
        isMine: true,
        status: MessageStatus.sent,
        createdAt: DateTime.now(),
        threadId: state.threadId,
      );

      final messagesWithTemp = [tempMessage, ...state.messages];
      emit(state.copyWith(messages: messagesWithTemp));

      final result = await chatRepo.sendMessage(
        threadId: state.threadId!,
        content: event.content,
      );

      if (result.success && result.data != null) {
        final updatedMessages = state.messages.map((m) {
          if (m.id == tempMessage.id) {
            return result.data!;
          }
          return m;
        }).toList();

        emit(state.copyWith(
          actionStatus: ChatMessagesActionStatus.success,
          messages: updatedMessages,
          successMessage: 'Message sent',
        ));
      } else {
        final messagesWithoutTemp =
            state.messages.where((m) => m.id != tempMessage.id).toList();

        emit(state.copyWith(
          actionStatus: ChatMessagesActionStatus.error,
          messages: messagesWithoutTemp,
          errorMessage: result.message ?? 'Failed to send message',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        actionStatus: ChatMessagesActionStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onAddOptimisticMessage(
    AddOptimisticMessageEvent event,
    Emitter<ChatMessagesState> emit,
  ) async {
    final tempMessage = MessageModel(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      content: event.content,
      senderId: '',
      isMine: true,
      status: MessageStatus.sent,
      createdAt: DateTime.now(),
      threadId: state.threadId,
    );

    final updatedMessages = [tempMessage, ...state.messages];
    emit(state.copyWith(messages: updatedMessages));
  }

  Future<void> _onAddMessage(
    AddMessageEvent event,
    Emitter<ChatMessagesState> emit,
  ) async {
    // Check if it replaces an optimistic message (by content and proximity)
    // Actually, usually socket returns the full message including the temp ID if handled correctly,
    // but here we'll just check if a message with same content and isMine:true exists within last 5 seconds.

    // Better logic: if event.message.isMine is true, try to replace a 'temp_' message.
    if (event.message.isMine) {
      final tempIndex =
          state.messages.indexWhere((m) => m.id.startsWith('temp_'));
      if (tempIndex >= 0) {
        final updatedMessages = List<MessageModel>.from(state.messages);
        updatedMessages[tempIndex] = event.message;
        emit(state.copyWith(messages: updatedMessages));
        return;
      }
    }

    // Check if message already exists by ID
    if (state.messages.any((m) => m.id == event.message.id)) return;

    final updatedMessages = [event.message, ...state.messages];
    emit(state.copyWith(messages: updatedMessages));
  }

  Future<void> _onUpdateMessageStatus(
    UpdateMessageStatusEvent event,
    Emitter<ChatMessagesState> emit,
  ) async {
    final bool isRead = event.status == MessageStatus.read;
    DateTime? readUntil;

    if (isRead) {
      final target =
          state.messages.where((m) => m.id == event.messageId).firstOrNull;
      if (target != null) {
        readUntil = target.createdAt;
      }
    }

    final updatedMessages = state.messages.map((m) {
      if (m.id == event.messageId) {
        return m.copyWith(status: event.status);
      }
      // Best Practice: Cascading read status
      if (isRead &&
          m.isMine &&
          readUntil != null &&
          m.status != MessageStatus.read) {
        if (m.createdAt.isBefore(readUntil)) {
          return m.copyWith(status: MessageStatus.read);
        }
      }
      return m;
    }).toList();

    emit(state.copyWith(messages: updatedMessages));
  }

  Future<void> _onMarkMessagesAsRead(
    MarkMessagesAsReadEvent event,
    Emitter<ChatMessagesState> emit,
  ) async {
    // Find the latest message timestamp in the read set to apply cascade
    DateTime? latestReadTime;
    for (final id in event.messageIds) {
      final msg = state.messages.where((m) => m.id == id).firstOrNull;
      if (msg != null) {
        if (latestReadTime == null || msg.createdAt.isAfter(latestReadTime)) {
          latestReadTime = msg.createdAt;
        }
      }
    }

    final updatedMessages = state.messages.map((m) {
      if (event.messageIds.contains(m.id)) {
        return m.copyWith(status: MessageStatus.read);
      }
      // Best Practice: Cascading read status for bulk updates
      if (latestReadTime != null &&
          m.isMine &&
          m.status != MessageStatus.read) {
        if (m.createdAt.isBefore(latestReadTime)) {
          return m.copyWith(status: MessageStatus.read);
        }
      }
      return m;
    }).toList();

    emit(state.copyWith(messages: updatedMessages));
  }

  Future<void> _onClearMessages(
    ClearMessagesEvent event,
    Emitter<ChatMessagesState> emit,
  ) async {
    emit(state.copyWith(
      messages: [],
      threadId: null,
      hasMore: false,
      nextCursor: null,
    ));
  }

  Future<void> _onReset(
    ResetMessagesEvent event,
    Emitter<ChatMessagesState> emit,
  ) async {
    emit(const ChatMessagesState());
  }
}
