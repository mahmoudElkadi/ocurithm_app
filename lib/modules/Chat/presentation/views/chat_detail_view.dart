import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/services_locator.dart';
import '../../data/models/chat_models.dart';
import '../manager/chat_messages_bloc/chat_messages_bloc.dart';
import '../manager/chat_socket_bloc/chat_socket_bloc.dart';
import '../manager/chat_threads_bloc/chat_threads_bloc.dart';

class ChatDetailView extends StatelessWidget {
  final ThreadModel thread;
  const ChatDetailView({super.key, required this.thread});

  @override
  Widget build(BuildContext context) {
    final socketBloc = sl<ChatSocketBloc>();
    final threadsBloc = sl<ChatThreadsBloc>();

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<ChatMessagesBloc>()
            ..add(FetchMessagesEvent(threadId: thread.id)),
        ),
        BlocProvider.value(value: socketBloc),
        BlocProvider.value(value: threadsBloc),
      ],
      child: _ChatDetailContent(thread: thread),
    );
  }
}

class _ChatDetailContent extends StatefulWidget {
  final ThreadModel thread;
  const _ChatDetailContent({required this.thread});

  @override
  State<_ChatDetailContent> createState() => _ChatDetailContentState();
}

class _ChatDetailContentState extends State<_ChatDetailContent>
    with WidgetsBindingObserver {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scrollController.addListener(_onScroll);

    // Mark thread as read when opening
    _markRead();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Clear active thread when leaving
    context.read<ChatSocketBloc>().add(ClearActiveThreadEvent());
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Re-mark as read when user returns to the app and this chat is open
      _markRead();
    }
  }

  void _markRead() {
    if (!mounted) return;
    context.read<ChatSocketBloc>().add(
          MarkReadViaSocketEvent(threadId: widget.thread.id),
        );
    // Set as active thread to silence notifications for this chat
    context.read<ChatSocketBloc>().add(
          SetActiveThreadEvent(threadId: widget.thread.id),
        );
    // Also update local threads state
    context.read<ChatThreadsBloc>().add(
          MarkThreadReadEvent(threadId: widget.thread.id),
        );
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<ChatMessagesBloc>().add(LoadMoreMessagesEvent());
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() {
    final content = _controller.text.trim();
    if (content.isEmpty) return;

    // 1. Optimistic update in messages list
    context.read<ChatMessagesBloc>().add(
          AddOptimisticMessageEvent(content: content),
        );

    // 2. Send via socket
    context.read<ChatSocketBloc>().add(
          SendMessageViaSocketEvent(
            threadId: widget.thread.id,
            content: content,
          ),
        );

    _controller.clear();

    // Scroll to bottom after sending
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChatSocketBloc, ChatSocketState>(
      listener: (context, socketState) {
        if (socketState.lastEventType == null) return;

        // Handle new messages from socket
        if (socketState.lastEventType == ChatSocketEventType.newMessage &&
            socketState.lastNewMessage != null) {
          final message = socketState.lastNewMessage!;
          if (message.threadId == widget.thread.id) {
            context
                .read<ChatMessagesBloc>()
                .add(AddMessageEvent(message: message));

            // Acknowledge delivery
            context
                .read<ChatSocketBloc>()
                .add(AckDeliveryEvent(messageId: message.id));

            // Auto-mark as read if this message is from the other person
            if (!message.isMine) {
              // Small delay to allow backend to finish processing the new message
              // before we query it for the "mark as read" update.
              Future.delayed(const Duration(milliseconds: 300), () {
                if (mounted) _markRead();
              });
            }

            _scrollToBottom();
          }
        }

        // Handle message sent confirmation (replaces optimistic message)
        if (socketState.lastEventType == ChatSocketEventType.messageSent &&
            socketState.lastSentMessage != null) {
          final message = socketState.lastSentMessage!;
          if (message.threadId == widget.thread.id) {
            context
                .read<ChatMessagesBloc>()
                .add(AddMessageEvent(message: message));
            _scrollToBottom();
          }
        }

        // Handle message status updates
        if (socketState.lastEventType == ChatSocketEventType.messageStatus &&
            socketState.lastStatusUpdate != null) {
          final update = socketState.lastStatusUpdate!;
          if (update['threadId'] == widget.thread.id) {
            final status = (update['status'] as String).toMessageStatus();
            context.read<ChatMessagesBloc>().add(
                  UpdateMessageStatusEvent(
                    messageId: update['messageId'],
                    status: status,
                  ),
                );
          }
        }

        // Handle messages read
        if (socketState.lastEventType == ChatSocketEventType.messagesRead &&
            socketState.lastMessagesRead != null) {
          final readData = socketState.lastMessagesRead!;
          if (readData['threadId'] == widget.thread.id) {
            final messageIds =
                (readData['messageIds'] as List?)?.cast<String>() ?? [];
            if (messageIds.isNotEmpty) {
              context.read<ChatMessagesBloc>().add(
                    MarkMessagesAsReadEvent(messageIds: messageIds),
                  );
            }
          }
        }
      },
      child: Scaffold(
        appBar: _buildAppBar(context),
        body: Column(
          children: [
            Expanded(child: _buildMessagesList()),
            _buildInput(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      titleSpacing: 0,
      title: BlocBuilder<ChatSocketBloc, ChatSocketState>(
        builder: (context, state) {
          final isOnline = state.isUserOnline(widget.thread.participant.id) ||
              widget.thread.participant.isOnline;

          return Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor:
                    Theme.of(context).primaryColor.withOpacity(0.2),
                child: Text(
                  widget.thread.participant.name.isNotEmpty
                      ? widget.thread.participant.name[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.thread.participant.name,
                    style: const TextStyle(fontSize: 16),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isOnline ? Colors.green : Colors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isOnline ? 'Online' : 'Offline',
                        style: TextStyle(
                          fontSize: 12,
                          color: isOnline ? Colors.green : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMessagesList() {
    return BlocBuilder<ChatMessagesBloc, ChatMessagesState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.isError || state.noConnection) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  state.noConnection ? Icons.wifi_off : Icons.error_outline,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  state.noConnection
                      ? 'No internet connection'
                      : state.errorMessage ?? 'Failed to load messages',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<ChatMessagesBloc>().add(
                          FetchMessagesEvent(threadId: widget.thread.id),
                        );
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state.messages.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text('No messages yet',
                    style:
                        TextStyle(color: Colors.grey.shade600, fontSize: 16)),
              ],
            ),
          );
        }

        return ListView.builder(
          controller: _scrollController,
          reverse: true,
          padding: const EdgeInsets.all(16),
          itemCount: state.messages.length + (state.isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == state.messages.length) {
              return const Center(
                  child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(strokeWidth: 2)));
            }
            final message = state.messages[index];
            return _MessageBubble(message: message);
          },
        );
      },
    );
  }

  Widget _buildInput() {
    return BlocBuilder<ChatSocketBloc, ChatSocketState>(
      builder: (context, socketState) {
        final isConnected = socketState.isConnected;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isConnected)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(strokeWidth: 2)),
                        const SizedBox(width: 8),
                        Text('Connecting...',
                            style: TextStyle(
                                fontSize: 12, color: Colors.orange.shade700)),
                      ],
                    ),
                  ),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: TextField(
                          controller: _controller,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _sendMessage(),
                          decoration: const InputDecoration(
                            hintText: 'Type a message...',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(Icons.send,
                          color: isConnected
                              ? Theme.of(context).primaryColor
                              : Colors.grey),
                      onPressed: isConnected ? _sendMessage : null,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final MessageModel message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Align(
        alignment:
            message.isMine ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints:
              BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: message.isMine
                ? Theme.of(context).primaryColor
                : Theme.of(context).cardColor,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(message.isMine ? 16 : 0),
              bottomRight: Radius.circular(message.isMine ? 0 : 16),
            ),
            boxShadow: [
              if (!message.isMine)
                BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 2,
                    offset: const Offset(0, 1)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                message.content,
                style: TextStyle(
                  color: message.isMine
                      ? Colors.white
                      : Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    DateFormat.jm().format(message.createdAt),
                    style: TextStyle(
                      fontSize: 11,
                      color: message.isMine
                          ? Colors.white70
                          : Colors.grey.shade500,
                    ),
                  ),
                  if (message.isMine) ...[
                    const SizedBox(width: 4),
                    _buildStatusIcon(context, message.status),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIcon(BuildContext context, MessageStatus status) {
    IconData icon;
    Color color = Colors.white70;

    switch (status) {
      case MessageStatus.sent:
        icon = Icons.done;
        break;
      case MessageStatus.delivered:
        icon = Icons.done_all;
        break;
      case MessageStatus.read:
        icon = Icons.done_all;
        color = const Color(0xFF34B7F1); // WhatsApp-style blue seen marks
        break;
    }

    return Icon(icon, size: 14, color: color);
  }
}
