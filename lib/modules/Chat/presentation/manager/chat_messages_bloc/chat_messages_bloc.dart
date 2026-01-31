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
    on<ResetMessagesEvent>(_onResetMessages);
    on<AddPendingMessagesEvent>(_onAddPendingMessages);
  }

  void _sortMessages(List<MessageModel> messages) {
    messages.sort((a, b) => b.createdAt.compareTo(a.createdAt));
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

        // Find the latest read timestamp from history
        DateTime? historicalReadAt;
        for (final m in messages) {
          if (m.status == MessageStatus.read) {
            if (historicalReadAt == null ||
                m.createdAt.isAfter(historicalReadAt)) {
              historicalReadAt = m.createdAt;
            }
          }
        }

        // Merge with existing pending messages to preserve local-only state
        final List<MessageModel> mergedMessages =
            List<MessageModel>.from(messages);
        final pendingMessages =
            state.messages.where((m) => m.status == MessageStatus.pending);

        for (final pending in pendingMessages) {
          bool alreadyExists = mergedMessages.any((m) => m.id == pending.id);
          if (!alreadyExists) {
            alreadyExists = mergedMessages.any((m) =>
                m.content == pending.content &&
                m.isMine &&
                m.createdAt.difference(pending.createdAt).inMinutes.abs() < 1);
          }
          if (!alreadyExists) {
            mergedMessages.insert(0, pending);
          }
        }

        // Sort: Newest first (index 0)
        _sortMessages(mergedMessages);

        emit(state.copyWith(
          status: ChatMessagesStatus.success,
          messages: mergedMessages,
          hasMore: hasMore,
          nextCursor: nextCursor,
          lastReadAt: historicalReadAt,
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

        final allMessages = List<MessageModel>.from(state.messages);
        for (final msg in newMessages) {
          if (!allMessages.any((m) => m.id == msg.id)) {
            allMessages.add(msg);
          }
        }
        _sortMessages(allMessages);

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
      _sortMessages(messagesWithTemp);
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
      id: event.tempId ?? 'temp_${DateTime.now().millisecondsSinceEpoch}',
      content: event.content,
      senderId: '',
      isMine: true,
      status: MessageStatus.pending,
      createdAt: DateTime.now(),
      threadId: state.threadId,
    );

    final updatedMessages = [tempMessage, ...state.messages];
    _sortMessages(updatedMessages);
    emit(state.copyWith(messages: updatedMessages));
  }

  Future<void> _onAddPendingMessages(
    AddPendingMessagesEvent event,
    Emitter<ChatMessagesState> emit,
  ) async {
    final updatedMessages = List<MessageModel>.from(state.messages);

    for (final pending in event.messages) {
      // Deduplicate by ID OR (content + proximity)
      bool exists = updatedMessages.any((m) => m.id == pending.id);
      if (!exists && pending.id.startsWith('temp_')) {
        exists = updatedMessages.any((m) =>
            m.content == pending.content &&
            m.isMine &&
            m.createdAt.difference(pending.createdAt).inMinutes.abs() < 1);
      }

      if (!exists) {
        updatedMessages.insert(0, pending);
      }
    }

    // Sort: Newest first (index 0)
    _sortMessages(updatedMessages);

    emit(state.copyWith(messages: updatedMessages));
  }

  Future<void> _onAddMessage(
    AddMessageEvent event,
    Emitter<ChatMessagesState> emit,
  ) async {
    MessageModel messageToAdd = event.message;

    // Apply global read status if this message is mine and sent AFTER a read event was already processed
    if (messageToAdd.isMine && state.lastReadAt != null) {
      if (messageToAdd.createdAt.isBefore(state.lastReadAt!) ||
          messageToAdd.createdAt.isAtSameMomentAs(state.lastReadAt!)) {
        messageToAdd = messageToAdd.copyWith(status: MessageStatus.read);
      }
    }

    // Check if it replaces an optimistic message (by specific tempId or content proximity)
    if (messageToAdd.isMine) {
      int tempIndex = -1;

      if (event.tempId != null) {
        tempIndex = state.messages.indexWhere((m) => m.id == event.tempId);
      }

      // Fallback: search by content if tempId not found (for robustness)
      if (tempIndex == -1) {
        tempIndex = state.messages.indexWhere((m) =>
            m.id.startsWith('temp_') && m.content == messageToAdd.content);
      }

      if (tempIndex >= 0) {
        final updatedMessages = List<MessageModel>.from(state.messages);
        updatedMessages[tempIndex] = messageToAdd;
        _sortMessages(updatedMessages);
        emit(state.copyWith(messages: updatedMessages));
        return;
      }
    }

    // Check if message already exists by ID (to avoid duplicates from multiple listeners)
    if (state.messages.any((m) => m.id == messageToAdd.id)) return;

    final updatedMessages = [messageToAdd, ...state.messages];
    // Sort to handle out-of-order socket events
    _sortMessages(updatedMessages);

    emit(state.copyWith(messages: updatedMessages));
  }

  Future<void> _onUpdateMessageStatus(
    UpdateMessageStatusEvent event,
    Emitter<ChatMessagesState> emit,
  ) async {
    final bool isRead = event.status == MessageStatus.read;
    DateTime? readUntil = state.lastReadAt;

    if (isRead) {
      final target =
          state.messages.where((m) => m.id == event.messageId).firstOrNull;
      if (target != null) {
        if (readUntil == null || target.createdAt.isAfter(readUntil)) {
          readUntil = target.createdAt;
        }
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
        if (m.createdAt.isBefore(readUntil) ||
            m.createdAt.isAtSameMomentAs(readUntil)) {
          return m.copyWith(status: MessageStatus.read);
        }
      }
      return m;
    }).toList();

    emit(state.copyWith(
      messages: updatedMessages,
      lastReadAt: readUntil,
    ));
  }

  Future<void> _onMarkMessagesAsRead(
    MarkMessagesAsReadEvent event,
    Emitter<ChatMessagesState> emit,
  ) async {
    // Find the latest message timestamp in the read set to apply cascade
    DateTime? latestReadTime = state.lastReadAt;
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
        if (m.createdAt.isBefore(latestReadTime) ||
            m.createdAt.isAtSameMomentAs(latestReadTime)) {
          return m.copyWith(status: MessageStatus.read);
        }
      }
      return m;
    }).toList();

    emit(state.copyWith(
      messages: updatedMessages,
      lastReadAt: latestReadTime,
    ));
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

  Future<void> _onResetMessages(
    ResetMessagesEvent event,
    Emitter<ChatMessagesState> emit,
  ) async {
    emit(const ChatMessagesState());
  }
}
