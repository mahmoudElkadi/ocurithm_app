import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

import '../../../../core/Network/shared.dart';
import '../../../../core/utils/capability_services.dart';
import '../../../../core/utils/services_locator.dart';
import '../manager/chat_socket_bloc/chat_socket_bloc.dart';
import '../manager/chat_threads_bloc/chat_threads_bloc.dart';
import '../views/chat_list_view.dart';

class FloatingChatWrapper extends StatefulWidget {
  final Widget child;

  const FloatingChatWrapper({super.key, required this.child});

  @override
  State<FloatingChatWrapper> createState() => _FloatingChatWrapperState();
}

class _FloatingChatWrapperState extends State<FloatingChatWrapper>
    with WidgetsBindingObserver {
  Offset position = Offset.zero;
  bool isDragging = false;
  bool isInitialized = false;
  bool isChatOpen = false;
  ChatSocketStatus? _lastSocketStatus;

  late ChatThreadsBloc _threadsBloc;
  late ChatSocketBloc _socketBloc;

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _threadsBloc = sl<ChatThreadsBloc>();
    _socketBloc = sl<ChatSocketBloc>();
    _lastSocketStatus = _socketBloc.state.status;

    // Connect to socket
    _socketBloc.add(ConnectSocketEvent());

    // Initial fetch
    _threadsBloc.add(FetchThreadsEvent());

    // Periodic check for connection, identity, and route
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      final token = CacheHelper.getData(key: 'token');
      final hasChatCapability = CapabilityServices.hasCapability("chat");

      if (token != null && hasChatCapability) {
        // Ensure socket is connected if we should have chat
        if (_socketBloc.state.isDisconnected) {
          log('[FloatingChat] Reconnecting socket via periodic timer');
          _socketBloc.add(ConnectSocketEvent());
        }

        // Fetch once if we have no threads loaded yet
        if (_threadsBloc.state.status == ChatThreadsStatus.initial) {
          _threadsBloc.add(FetchThreadsEvent());
        }
      }

      // Re-evaluate visibility (route, token, capability)
      setState(() {});
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Small delay to ensure network is fully restored by OS
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted) return;

        // Refresh chats when app comes to foreground to catch up on missed messages
        final token = CacheHelper.getData(key: 'token');
        if (token != null) {
          _threadsBloc.add(RefreshThreadsEvent());

          // Also ensure socket is connected
          if (!_socketBloc.state.isConnected) {
            _socketBloc.add(ConnectSocketEvent());
          }
        }
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!isInitialized) {
      final size = MediaQuery.of(context).size;
      position = Offset(size.width - 80, size.height - 150);
      isInitialized = true;
    }
  }

  void _showChatList() async {
    if (isChatOpen) return;

    setState(() => isChatOpen = true);

    await Get.bottomSheet(
      const ChatListView(),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      ignoreSafeArea: false,
      enterBottomSheetDuration: const Duration(milliseconds: 200),
      exitBottomSheetDuration: const Duration(milliseconds: 200),
    );

    if (mounted) {
      setState(() => isChatOpen = false);
      // Optional: clear socket events when closing list to avoid re-triggering
      _socketBloc.add(ClearSocketEventsEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _threadsBloc),
        BlocProvider.value(value: _socketBloc),
      ],
      child: BlocListener<ChatSocketBloc, ChatSocketState>(
        listenWhen: (previous, current) {
          return previous.lastNewMessage != current.lastNewMessage ||
              previous.lastThreadUpdate != current.lastThreadUpdate ||
              previous.lastMessagesRead != current.lastMessagesRead ||
              previous.lastEventType != current.lastEventType ||
              previous.status != current.status;
        },
        listener: (context, socketState) {
          // Handle reconnection
          if (_lastSocketStatus != ChatSocketStatus.connected &&
              socketState.status == ChatSocketStatus.connected) {
            final token = CacheHelper.getData(key: 'token');
            if (token != null) {
              _threadsBloc.add(FetchThreadsEvent());
            }
          }
          _lastSocketStatus = socketState.status;

          // Listen for new messages to update the badge in real-time
          if (socketState.lastEventType == ChatSocketEventType.newMessage &&
              socketState.lastNewMessage != null) {
            _threadsBloc.add(HandleSocketNewMessageEvent(
              message: socketState.lastNewMessage!,
            ));
          }

          // Handle thread updates from socket
          if (socketState.lastEventType == ChatSocketEventType.threadUpdated) {
            _threadsBloc.add(RefreshThreadsEvent());
          }

          // Handle messages read
          if (socketState.lastEventType == ChatSocketEventType.messagesRead &&
              socketState.lastMessagesRead != null) {
            final threadId = socketState.lastMessagesRead!['threadId'];
            if (threadId != null) {
              _threadsBloc.add(HandleMessagesReadEvent(threadId: threadId));
            }
          }
        },
        child: Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              widget.child,
              Builder(builder: (context) {
                final token = CacheHelper.getData(key: 'token');
                final currentRoute = Get.currentRoute;

                final bool isAuthScreen = currentRoute == '/LoginView' ||
                    currentRoute == '/SplashScreen' ||
                    currentRoute == '/LoadingScreen' ||
                    currentRoute == '' ||
                    currentRoute == '/';

                final bool hasChatCapability =
                    CapabilityServices.hasCapability("chat");

                if (token == null || isAuthScreen || !hasChatCapability) {
                  return const SizedBox.shrink();
                }

                return AnimatedPositioned(
                  duration: isDragging
                      ? Duration.zero
                      : const Duration(milliseconds: 300),
                  curve: Curves.easeOutBack,
                  left: position.dx,
                  top: position.dy,
                  child: IgnorePointer(
                    ignoring: isChatOpen,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: isChatOpen ? 0.0 : 1.0,
                      child: GestureDetector(
                        onPanStart: (_) => setState(() => isDragging = true),
                        onPanUpdate: (details) {
                          setState(() {
                            position += details.delta;
                          });
                        },
                        onPanEnd: (details) {
                          setState(() => isDragging = false);
                          _snapToEdge();
                        },
                        onTap: _showChatList,
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: BlocBuilder<ChatThreadsBloc, ChatThreadsState>(
                            builder: (context, state) {
                              final unreadCount = state.totalUnreadCount;
                              return _ChatBubble(
                                isDragging: isDragging,
                                unreadCount: unreadCount,
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  void _snapToEdge() {
    final size = MediaQuery.of(context).size;
    double targetX = position.dx;

    if (position.dx < size.width / 2) {
      targetX = 16;
    } else {
      targetX = size.width - 76;
    }

    double targetY = position.dy.clamp(50.0, size.height - 100.0);

    setState(() {
      position = Offset(targetX, targetY);
    });
  }
}

class _ChatBubble extends StatelessWidget {
  final bool isDragging;
  final int unreadCount;

  const _ChatBubble({required this.isDragging, required this.unreadCount});

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: isDragging ? 1.1 : 1.0,
      duration: const Duration(milliseconds: 100),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withValues(alpha: 0.8),
                  Theme.of(context).primaryColor.withBlue(255).withRed(100),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.chat_bubble_outline_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          if (unreadCount > 0)
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 20,
                  minHeight: 20,
                ),
                child: Center(
                  child: Text(
                    unreadCount > 9 ? '9+' : unreadCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
