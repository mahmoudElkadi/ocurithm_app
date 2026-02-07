import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/services_locator.dart';
import '../../data/models/chat_models.dart';
import '../manager/chat_threads_bloc/chat_threads_bloc.dart';
import '../manager/get_chat_users_bloc/get_chat_users_bloc.dart';
import '../manager/chat_socket_bloc/chat_socket_bloc.dart';
import 'chat_detail_view.dart';

class ChatListView extends StatelessWidget {
  const ChatListView({super.key});

  @override
  Widget build(BuildContext context) {
    // Use existing singleton instances, don't create new ones
    final threadsBloc = sl<ChatThreadsBloc>();
    final socketBloc = sl<ChatSocketBloc>();

    return MultiBlocProvider(
      providers: [
        // Use existing singleton blocs
        BlocProvider.value(value: threadsBloc),
        BlocProvider.value(value: socketBloc),
        // Create a new instance for users (not a singleton)
        BlocProvider(
          create: (_) => sl<GetChatUsersBloc>()..add(FetchChatUsersEvent()),
        ),
      ],
      child: const _ChatListContent(),
    );
  }
}

class _ChatListContent extends StatefulWidget {
  const _ChatListContent();

  @override
  State<_ChatListContent> createState() => _ChatListContentState();
}

class _ChatListContentState extends State<_ChatListContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Refresh threads when opening chat list
    context.read<ChatThreadsBloc>().add(RefreshThreadsEvent());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChatThreadsBloc, ChatThreadsState>(
      listener: (context, state) {
        if (state.isActionSuccess &&
            state.activeThread != null &&
            state.loadingActionId == null) {
          Get.to(() => ChatDetailView(thread: state.activeThread!));
        }
      },
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Messages',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color:
                          Theme.of(context).primaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(Icons.close,
                          color: Theme.of(context).primaryColor),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ),
            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.light
                      ? Colors.grey.shade100
                      : Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    if (_tabController.index == 1) {
                      context
                          .read<GetChatUsersBloc>()
                          .add(SearchChatUsersEvent(value));
                    }
                  },
                  decoration: const InputDecoration(
                    icon: Icon(Icons.search, size: 20, color: Colors.grey),
                    hintText: 'Search...',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            // Tabs
            TabBar(
              controller: _tabController,
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Theme.of(context).primaryColor,
              tabs: const [
                Tab(text: 'Chats'),
                Tab(text: 'New Chat'),
              ],
            ),
            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildThreadsList(),
                  _buildUsersList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThreadsList() {
    return BlocBuilder<ChatThreadsBloc, ChatThreadsState>(
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
                      : state.errorMessage ?? 'Failed to load chats',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<ChatThreadsBloc>().add(FetchThreadsEvent());
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state.threads.isEmpty) {
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
                Text(
                  'No chats yet',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Start a new conversation!',
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            context.read<ChatThreadsBloc>().add(RefreshThreadsEvent());
          },
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            itemCount: state.threads.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final thread = state.threads[index];
              return _ThreadTile(thread: thread);
            },
          ),
        );
      },
    );
  }

  Widget _buildUsersList() {
    return BlocBuilder<ChatThreadsBloc, ChatThreadsState>(
      builder: (context, threadsState) {
        return BlocBuilder<GetChatUsersBloc, GetChatUsersState>(
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
                          : state.errorMessage ?? 'Failed to load users',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context
                            .read<GetChatUsersBloc>()
                            .add(FetchChatUsersEvent());
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            // Filter users: Exclude those who already have a thread
            final filteredUsers = state.users.where((user) {
              // 1. Check if user model says they have a thread
              if (user.threadId != null) return false;

              // 2. Double check against loaded threads to be sure
              final hasThread = threadsState.threads
                  .any((t) => t.participant.id == user.id);
              return !hasThread;
            }).toList();

            if (filteredUsers.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No new users found',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<GetChatUsersBloc>().add(FetchChatUsersEvent());
              },
              child: ListView.separated(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                itemCount: filteredUsers.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final user = filteredUsers[index];
                  return _UserTile(user: user);
                },
              ),
            );
          },
        );
      },
    );
  }
}

class _ThreadTile extends StatelessWidget {
  final ThreadModel thread;
  const _ThreadTile({required this.thread});

  @override
  Widget build(BuildContext context) {
    final socketBloc = sl<ChatSocketBloc>();
    final isOnline = socketBloc.state.isUserOnline(thread.participant.id) ||
        thread.participant.isOnline;

    return InkWell(
      onTap: () {
        Get.to(() => ChatDetailView(thread: thread));
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            // Avatar with online indicator
            Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor:
                      Theme.of(context).primaryColor.withValues(alpha: 0.2),
                  child: Text(
                    thread.participant.name.isNotEmpty
                        ? thread.participant.name[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                if (isOnline)
                  Positioned(
                    right: 2,
                    bottom: 2,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          thread.participant.name,
                          style: TextStyle(
                            fontWeight: thread.unreadCount > 0
                                ? FontWeight.bold
                                : FontWeight.w600,
                                fontSize: 16,
                              ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        _formatTime(thread.updatedAt),
                        style: TextStyle(
                          color: thread.unreadCount > 0
                              ? Theme.of(context).primaryColor
                              : Colors.grey.shade500,
                          fontSize: 12,
                          fontWeight: thread.unreadCount > 0
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (thread.lastMessage != null &&
                          thread.lastMessage!.isMine) ...[
                        _buildStatusIcon(context, thread.lastMessage!.status),
                        const SizedBox(width: 4),
                      ],
                      Expanded(
                        child: Text(
                          thread.lastMessage?.content ?? 'No messages yet',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: thread.unreadCount > 0
                                ? Theme.of(context).textTheme.bodyLarge?.color
                                : Colors.grey.shade600,
                            fontWeight: thread.unreadCount > 0
                                ? FontWeight.w500
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (thread.unreadCount > 0)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            thread.unreadCount > 9
                                ? '9+'
                                : thread.unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon(BuildContext context, MessageStatus status) {
    switch (status) {
      case MessageStatus.pending:
        return Icon(Icons.access_time, size: 14, color: Colors.grey.shade400);
      case MessageStatus.error:
        return const Icon(Icons.error_outline,
            size: 14, color: Colors.redAccent);
      case MessageStatus.sent:
        return Icon(Icons.done, size: 16, color: Colors.grey.shade500);
      case MessageStatus.delivered:
        return Icon(Icons.done_all, size: 16, color: Colors.grey.shade500);
      case MessageStatus.read:
        return const Icon(Icons.done_all,
            size: 16, color: Colors.black); // Requested black seen marks
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return DateFormat.jm().format(dateTime);
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return DateFormat.E().format(dateTime);
    } else {
      return DateFormat.MMMd().format(dateTime);
    }
  }
}

class _UserTile extends StatelessWidget {
  final ChatUserModel user;
  const _UserTile({required this.user});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Create or get thread
        context
            .read<ChatThreadsBloc>()
            .add(CreateThreadEvent(participantId: user.id));
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Avatar with online indicator
            Stack(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor:
                      Theme.of(context).primaryColor.withValues(alpha: 0.2),
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                if (user.isOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            // User info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatUserType(user.userType),
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            // Chat icon
            BlocBuilder<ChatThreadsBloc, ChatThreadsState>(
              builder: (context, state) {
                // Only show loading if THIS specific user is being acted on
                if (state.isActionLoading && state.loadingActionId == user.id) {
                  return const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  );
                }
                return Icon(
                  user.threadId != null
                      ? Icons.chat_bubble
                      : Icons.chat_bubble_outline,
                  color: Theme.of(context).primaryColor,
                );
              },
            ),
            ],
          ),
        ),
    );
  }

  String _formatUserType(String userType) {
    switch (userType.toLowerCase()) {
      case 'doctor':
        return 'Doctor';
      case 'receptionist':
        return 'Receptionist';
      case 'admin':
        return 'Admin';
      default:
        return userType;
    }
  }
}
