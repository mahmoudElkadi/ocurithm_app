import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../views/chat_list_view.dart';
import '../../data/mock_data.dart';

class FloatingChatWrapper extends StatefulWidget {
  final Widget child;
  const FloatingChatWrapper({super.key, required this.child});

  @override
  State<FloatingChatWrapper> createState() => _FloatingChatWrapperState();
}

class _FloatingChatWrapperState extends State<FloatingChatWrapper> {
  Offset position = Offset.zero;
  bool isDragging = false;
  bool isInitialized = false;
  bool isChatOpen = false;

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
    }
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount =
        ChatMockData.chats.fold<int>(0, (sum, item) => sum + item.unreadCount);

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          widget.child,
          AnimatedPositioned(
            duration:
                isDragging ? Duration.zero : const Duration(milliseconds: 300),
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
                    child: _ChatBubble(
                      isDragging: isDragging,
                      unreadCount: unreadCount,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
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
                  Theme.of(context).primaryColor.withOpacity(0.8),
                  Theme.of(context).primaryColor.withBlue(255).withRed(100),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).primaryColor.withOpacity(0.4),
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
        ],
      ),
    );
  }
}
