import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../../../../../core/utils/audio_services.dart';
import '../../../../../core/Network/shared.dart';
import '../../../../../core/api/api_constants.dart';
import '../../../data/models/message_model.dart';

part 'chat_socket_event.dart';
part 'chat_socket_state.dart';

class ChatSocketBloc extends Bloc<ChatSocketEvent, ChatSocketState> {
  IO.Socket? _socket;
  String? _currentUserId;

  ChatSocketBloc() : super(const ChatSocketState()) {
    on<ConnectSocketEvent>(_onConnect);
    on<DisconnectSocketEvent>(_onDisconnect);
    on<SendMessageViaSocketEvent>(_onSendMessage);
    on<MarkReadViaSocketEvent>(_onMarkRead);
    on<AckDeliveryEvent>(_onAckDelivery);
    on<ClearSocketEventsEvent>(_onClearEvents);
    on<SetActiveThreadEvent>(_onSetActiveThread);
    on<ClearActiveThreadEvent>(_onClearActiveThread);

    // Internal socket events
    on<_SocketConnectedEvent>((event, emit) =>
        emit(state.copyWith(status: ChatSocketStatus.connected)));
    on<_SocketDisconnectedEvent>((event, emit) => emit(state.copyWith(
        status: ChatSocketStatus.disconnected, clearEvent: true)));
    on<_SocketErrorEvent>((event, emit) => emit(state.copyWith(
        status: ChatSocketStatus.error, errorMessage: event.error)));
    on<SocketNewMessageEvent>(_onNewMessage);
    on<SocketMessageSentEvent>(_onMessageSent);
    on<SocketMessageStatusEvent>(_onMessageStatus);
    on<SocketMessagesReadEvent>(_onMessagesRead);
    on<SocketUserOnlineEvent>(_onUserOnline);
    on<SocketUserOfflineEvent>(_onUserOffline);
    on<SocketThreadUpdatedEvent>(_onThreadUpdated);
  }

  @override
  Future<void> close() {
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

    _socket!.on('error', (data) {
      print('❌ [ChatSocket] Socket logic error: $data');
      log('[ChatSocket] Error event: $data');
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
    if (_socket == null || !_socket!.connected) {
      print('⚠️ [ChatSocket] Cannot send message: socket not connected');
      log('[ChatSocket] Cannot send message: socket not connected');
      add(ConnectSocketEvent());
      return;
    }

    print('📤 [ChatSocket] SENDING message to thread: ${event.threadId}');
    log('[ChatSocket] Sending message to thread: ${event.threadId}');
    _socket!.emit('send_message', {
      'threadId': event.threadId,
      'content': event.content,
    });
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
    final updatedMessage = message.copyWith(isMine: true);

    emit(state.copyWith(
      lastSentMessage: updatedMessage,
      lastEventType: ChatSocketEventType.messageSent,
    ));
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
