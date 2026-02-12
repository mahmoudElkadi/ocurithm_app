import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import '../../../../../core/utils/audio_services.dart';
import '../../../../../core/Network/shared.dart';
import '../../../../../core/api/api_constants.dart';
import '../../../../../core/api/api_handler.dart';
import '../../../../../core/utils/services_locator.dart';
import '../../../data/models/message_model.dart';

part 'chat_socket_event.dart';
part 'chat_socket_state.dart';

class ChatSocketBloc extends Bloc<ChatSocketEvent, ChatSocketState> {
  IO.Socket? _socket;
  String? _currentUserId;
  StreamSubscription<InternetStatus>? _connectivitySubscription;

  ChatSocketBloc() : super(const ChatSocketState()) {
    on<ConnectSocketEvent>(_onConnect);
    on<DisconnectSocketEvent>(_onDisconnect);
    on<SendMessageViaSocketEvent>(_onSendMessage);
    on<MarkReadViaSocketEvent>(_onMarkRead);
    on<AckDeliveryEvent>(_onAckDelivery);
    on<ClearSocketEventsEvent>(_onClearEvents);
    on<SetActiveThreadEvent>(_onSetActiveThread);
    on<ClearActiveThreadEvent>(_onClearActiveThread);
    on<RetryPendingMessagesEvent>(_onRetryPendingMessages);
    on<_LoadPendingMessagesEvent>(_onLoadPendingMessages);

    // Initial load of pending messages
    add(const _LoadPendingMessagesEvent());

    // Internal socket events
    on<_SocketConnectedEvent>((event, emit) {
      emit(state.copyWith(status: ChatSocketStatus.connected));
      // Auto-retry pending messages on connection
      add(RetryPendingMessagesEvent());
    });
    on<_SocketDisconnectedEvent>((event, emit) => emit(state.copyWith(
        status: ChatSocketStatus.disconnected, clearEvent: true)));
    on<_SocketErrorEvent>((event, emit) => emit(state.copyWith(
        status: ChatSocketStatus.error,
        errorMessage: event.error,
        sendingMessageIds: {}))); // Clear sending queue on error to allow retry
    on<SocketNewMessageEvent>(_onNewMessage);
    on<SocketMessageSentEvent>(_onMessageSent);
    on<SocketMessageStatusEvent>(_onMessageStatus);
    on<SocketMessagesReadEvent>(_onMessagesRead);
    on<SocketUserOnlineEvent>(_onUserOnline);
    on<SocketUserOfflineEvent>(_onUserOffline);
    on<SocketThreadUpdatedEvent>(_onThreadUpdated);

    // Initial load of pending messages
    add(const _LoadPendingMessagesEvent());

    // Listen for internet connection changes to auto-reconnect
    _connectivitySubscription =
        InternetConnection().onStatusChange.listen((status) {
      if (status == InternetStatus.connected) {
        if (_socket == null || !_socket!.connected) {
          print('🌐 [ChatSocket] Internet restored, attempting reconnection');
          add(ConnectSocketEvent());
        }
      }
    });
  }

  @override
  Future<void> close() {
    _connectivitySubscription?.cancel();
    _socket?.disconnect();
    _socket?.dispose();
    return super.close();
  }

  Future<void> _onConnect(
    ConnectSocketEvent event,
    Emitter<ChatSocketState> emit,
  ) async {
    if (_socket != null && _socket!.connected) return;

    try {
      emit(state.copyWith(status: ChatSocketStatus.connecting));

      final token = CacheHelper.getData(key: 'token');
      _currentUserId = CacheHelper.getUser('user')?.id;

      if (token == null) {
        emit(state.copyWith(
          status: ChatSocketStatus.error,
          errorMessage: 'No authentication token found',
        ));
        return;
      }

      final socketUrl = ApiConstants.chatSocketUrl;
      final namespace = ApiConstants.chatSocketNamespace;

      print('🔌 [ChatSocket] Connecting to $socketUrl$namespace');
      log('[ChatSocket] Connecting to $socketUrl$namespace');

      _socket = IO.io(
        '$socketUrl$namespace',
        IO.OptionBuilder()
            .setTransports(['websocket', 'polling'])
            .setAuth({'token': token})
            .enableAutoConnect()
            .enableReconnection()
            .setReconnectionAttempts(10)
            .setReconnectionDelay(2000)
            .build(),
      );

      _setupSocketListeners();
      _socket!.connect();
    } catch (e) {
      print('❌ [ChatSocket] Connection error: $e');
      log('[ChatSocket] Connection error: $e');
      emit(state.copyWith(
        status: ChatSocketStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void _setupSocketListeners() {
    if (_socket == null) return;

    _socket!.onConnect((_) {
      print('✅ [ChatSocket] Connected successfully');
      log('[ChatSocket] Connected');
      add(const _SocketConnectedEvent());
    });

    _socket!.onDisconnect((reason) {
      print('⚠️ [ChatSocket] Disconnected. Reason: $reason');
      log('[ChatSocket] Disconnected');
      add(const _SocketDisconnectedEvent());
    });

    _socket!.onConnectError((data) {
      print('❌ [ChatSocket] Connection Error: $data');
      log('[ChatSocket] Connection Error: $data');
      add(_SocketErrorEvent(data.toString()));
    });

    _socket!.on('error', (data) async {
      print('❌ [ChatSocket] Socket logic error: $data');
      log('[ChatSocket] Error event: $data');

      // Handle Unauthorized error - trigger token refresh and reconnect
      if (data is Map && data['code'] == 'UNAUTHORIZED') {
        print(
            '🔐 [ChatSocket] Unauthorized error detected. Attempting to refresh token...');
        try {
          await sl<ApiHandler>().refreshToken();
          print('✅ [ChatSocket] Token refreshed successfully. Reconnecting...');

          // Disconnect and reconnect with new token
          _socket?.disconnect();
          add(ConnectSocketEvent());
          return;
        } catch (e) {
          print('❌ [ChatSocket] Failed to refresh token: $e');
        }
      }

      if (data is Map && data.containsKey('message')) {
        add(_SocketErrorEvent(data['message']));
      }
    });

    _socket!.on('new_message', (data) {
      print('📩 [ChatSocket] RECEIVED new_message: $data');
      log('[ChatSocket] new_message: $data');
      final payload = _extractData(data);
      if (payload != null) {
        add(SocketNewMessageEvent(payload: payload));
      }
    });

    _socket!.on('message_sent', (data) {
      print('📤 [ChatSocket] RECEIVED message_sent confirmation: $data');
      log('[ChatSocket] message_sent: $data');
      final payload = _extractData(data);
      if (payload != null) {
        add(SocketMessageSentEvent(payload: payload));
      }
    });

    _socket!.on('message_status', (data) {
      print('📈 [ChatSocket] RECEIVED message_status update: $data');
      log('[ChatSocket] message_status: $data');
      final payload = _extractData(data);
      if (payload != null) {
        add(SocketMessageStatusEvent(payload: payload));
      }
    });

    _socket!.on('messages_read', (data) {
      print('📖 [ChatSocket] RECEIVED messages_read notification: $data');
      log('[ChatSocket] messages_read: $data');
      final payload = _extractData(data);
      if (payload != null) {
        add(SocketMessagesReadEvent(payload: payload));
      }
    });

    _socket!.on('user_online', (data) {
      print('🟢 [ChatSocket] USER ONLINE: $data');
      log('[ChatSocket] user_online: $data');
      final payload = _extractData(data);
      if (payload != null) {
        add(SocketUserOnlineEvent(payload: payload));
      }
    });

    _socket!.on('user_offline', (data) {
      print('⚪ [ChatSocket] USER OFFLINE: $data');
      log('[ChatSocket] user_offline: $data');
      final payload = _extractData(data);
      if (payload != null) {
        add(SocketUserOfflineEvent(payload: payload));
      }
    });

    _socket!.on('thread_updated', (data) {
      print('🔄 [ChatSocket] THREAD UPDATED: $data');
      log('[ChatSocket] thread_updated: $data');
      final payload = _extractData(data);
      if (payload != null) {
        add(SocketThreadUpdatedEvent(payload: payload));
      }
    });
  }

  Map<String, dynamic>? _extractData(dynamic data) {
    if (data == null) return null;
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    if (data is List && data.isNotEmpty) {
      return _extractData(data[0]);
    }
    return null;
  }

  Future<void> _onDisconnect(
    DisconnectSocketEvent event,
    Emitter<ChatSocketState> emit,
  ) async {
    _socket?.disconnect();
  }

  Future<void> _onSendMessage(
    SendMessageViaSocketEvent event,
    Emitter<ChatSocketState> emit,
  ) async {
    // Generate a temporary message for pending tracking
    final tempId =
        event.tempId ?? 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final pendingMsg = MessageModel(
      id: tempId,
      content: event.content,
      senderId: _currentUserId ?? '',
      isMine: true,
      status: MessageStatus.pending,
      createdAt: DateTime.now(),
      threadId: event.threadId,
    );

    if (_socket == null || !_socket!.connected) {
      print('⚠️ [ChatSocket] Socket not connected, adding to pending queue');
      log('[ChatSocket] Socket not connected, adding to pending queue');

      final updatedPending = List<MessageModel>.from(state.pendingMessages)
        ..add(pendingMsg);
      emit(state.copyWith(pendingMessages: updatedPending));
      _savePendingMessages(updatedPending);

      add(ConnectSocketEvent());
      return;
    }

    // Prevent duplicate emits if already sending
    if (state.sendingMessageIds.contains(tempId)) return;

    print('📤 [ChatSocket] SENDING message to thread: ${event.threadId}');
    log('[ChatSocket] Sending message to thread: ${event.threadId}');

    final newSendingIds = Set<String>.from(state.sendingMessageIds)
      ..add(tempId);
    emit(state.copyWith(sendingMessageIds: newSendingIds));

    _socket!.emit('send_message', {
      'threadId': event.threadId,
      'content': event.content,
      'tempId': tempId, // Use the same tempId
    });
  }

  Future<void> _onRetryPendingMessages(
    RetryPendingMessagesEvent event,
    Emitter<ChatSocketState> emit,
  ) async {
    if (_socket == null || !_socket!.connected || state.pendingMessages.isEmpty)
      return;

    print(
        '🔄 [ChatSocket] RETRYING ${state.pendingMessages.length} pending messages');

    final updatedSendingIds = Set<String>.from(state.sendingMessageIds);
    bool shouldEmit = false;

    for (final msg in state.pendingMessages) {
      if (!updatedSendingIds.contains(msg.id)) {
        updatedSendingIds.add(msg.id);
        shouldEmit = true;
        _socket!.emit('send_message', {
          'threadId': msg.threadId,
          'content': msg.content,
          'tempId': msg.id,
        });
      }
    }

    if (shouldEmit) {
      emit(state.copyWith(sendingMessageIds: updatedSendingIds));
    }
  }

  Future<void> _onMarkRead(
    MarkReadViaSocketEvent event,
    Emitter<ChatSocketState> emit,
  ) async {
    if (_socket == null || !_socket!.connected) return;

    print('📖 [ChatSocket] SENDING mark_read for thread: ${event.threadId}');
    _socket!.emit('mark_read', {
      'threadId': event.threadId,
    });
  }

  Future<void> _onAckDelivery(
    AckDeliveryEvent event,
    Emitter<ChatSocketState> emit,
  ) async {
    if (_socket == null || !_socket!.connected) return;

    _socket!.emit('ack_delivery', {
      'messageId': event.messageId,
    });
  }

  Future<void> _onNewMessage(
    SocketNewMessageEvent event,
    Emitter<ChatSocketState> emit,
  ) async {
    final message = MessageModel.fromJson(event.payload);
    final updatedMessage = message.copyWith(
      isMine: message.senderId == _currentUserId,
    );

    // Sound notification logic:
    // 1. Never play sound for my own messages
    if (updatedMessage.isMine == false) {
      print('🔔 [ChatSocket] New message notification check:');
      print('   - Message Thread ID: ${message.threadId}');
      print('   - Active Thread ID: ${state.activeThreadId}');

      if (message.threadId == state.activeThreadId) {
        // Message is in the CURRENTLY OPEN chat
        print('🎵 [ChatSocket] Playing ACTIVE chat sound (msg.mp3)...');
        AudioServices().playAsset('sounds/msg.mp3');
      } else {
        // Message is in another thread or chat is closed
        print(
            '🎵 [ChatSocket] Playing BACKGROUND notification (notification.mp3)...');
        AudioServices().playAsset('sounds/notification.mp3');
      }
    } else {
      print('🔇 [ChatSocket] No sound for self-sent message');
    }

    emit(state.copyWith(
      lastNewMessage: updatedMessage,
      lastEventType: ChatSocketEventType.newMessage,
    ));
  }

  Future<void> _onMessageSent(
    SocketMessageSentEvent event,
    Emitter<ChatSocketState> emit,
  ) async {
    final message = MessageModel.fromJson(event.payload);

    // Check if this matches a pending message and remove it
    final tempId = event.payload['tempId'];
    List<MessageModel> updatedPending =
        List<MessageModel>.from(state.pendingMessages);
    final updatedSendingIds = Set<String>.from(state.sendingMessageIds);

    if (tempId != null) {
      updatedPending.removeWhere((m) => m.id == tempId);
      updatedSendingIds.remove(tempId);
    } else {
      // Robust Fallback: Match by content, thread, and sender if tempId not provided
      // Use a timestamp margin of 1 minute to avoid matching very old messages
      final toRemove = updatedPending
          .where((m) =>
              m.threadId == message.threadId &&
              m.content == message.content &&
              m.isMine == true &&
              m.createdAt.difference(message.createdAt).inMinutes.abs() < 1)
          .toList();

      for (var f in toRemove) {
        updatedPending.remove(f);
        updatedSendingIds.remove(f.id);
      }
    }

    emit(state.copyWith(
      pendingMessages: updatedPending,
      sendingMessageIds: updatedSendingIds,
      lastSentMessage: message.copyWith(isMine: true),
      lastSentTempId: tempId,
      lastEventType: ChatSocketEventType.messageSent,
    ));

    if (updatedPending.length != state.pendingMessages.length) {
      _savePendingMessages(updatedPending);
    }
  }

  Future<void> _onLoadPendingMessages(
    _LoadPendingMessagesEvent event,
    Emitter<ChatSocketState> emit,
  ) async {
    try {
      final pendingData = CacheHelper.getListOfMaps('pending_chat_messages');
      final pendingMessages =
          pendingData.map((m) => MessageModel.fromJson(m)).toList();
      emit(state.copyWith(pendingMessages: pendingMessages));
    } catch (e) {
      log('Error loading pending messages: $e');
    }
  }

  void _savePendingMessages(List<MessageModel> messages) {
    try {
      final data = messages.map((m) => m.toJson()).toList();
      CacheHelper.saveListOfMaps('pending_chat_messages', data);
    } catch (e) {
      log('Error saving pending messages: $e');
    }
  }

  Future<void> _onMessageStatus(
    SocketMessageStatusEvent event,
    Emitter<ChatSocketState> emit,
  ) async {
    emit(state.copyWith(
      lastStatusUpdate: event.payload,
      lastEventType: ChatSocketEventType.messageStatus,
    ));
  }

  Future<void> _onMessagesRead(
    SocketMessagesReadEvent event,
    Emitter<ChatSocketState> emit,
  ) async {
    emit(state.copyWith(
      lastMessagesRead: event.payload,
      lastEventType: ChatSocketEventType.messagesRead,
    ));
  }

  Future<void> _onUserOnline(
    SocketUserOnlineEvent event,
    Emitter<ChatSocketState> emit,
  ) async {
    final userId = event.payload['userId'] as String?;
    if (userId != null) {
      final onlineUsers = Set<String>.from(state.onlineUsers)..add(userId);
      emit(state.copyWith(
        onlineUsers: onlineUsers,
        lastEventType: ChatSocketEventType.userOnline,
      ));
    }
  }

  Future<void> _onUserOffline(
    SocketUserOfflineEvent event,
    Emitter<ChatSocketState> emit,
  ) async {
    final userId = event.payload['userId'] as String?;
    if (userId != null) {
      final onlineUsers = Set<String>.from(state.onlineUsers)..remove(userId);
      emit(state.copyWith(
        onlineUsers: onlineUsers,
        lastEventType: ChatSocketEventType.userOffline,
      ));
    }
  }

  Future<void> _onThreadUpdated(
    SocketThreadUpdatedEvent event,
    Emitter<ChatSocketState> emit,
  ) async {
    emit(state.copyWith(
      lastThreadUpdate: event.payload,
      lastEventType: ChatSocketEventType.threadUpdated,
    ));
  }

  Future<void> _onClearEvents(
    ClearSocketEventsEvent event,
    Emitter<ChatSocketState> emit,
  ) async {
    emit(state.copyWith(clearEvent: true));
  }

  Future<void> _onSetActiveThread(
    SetActiveThreadEvent event,
    Emitter<ChatSocketState> emit,
  ) async {
    emit(state.copyWith(activeThreadId: event.threadId));
  }

  Future<void> _onClearActiveThread(
    ClearActiveThreadEvent event,
    Emitter<ChatSocketState> emit,
  ) async {
    emit(state.copyWith(clearActiveThread: true));
  }
}
