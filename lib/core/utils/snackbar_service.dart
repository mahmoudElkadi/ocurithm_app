import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'colors.dart';

/// A service class to show consistent snackbars throughout the app
class SnackbarService {
  /// Shows a success snackbar
  static void showSuccess(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    _showSnackbar(
      context: context,
      title: "Success",
      message: message,
      contentType: ContentType.success,
      color: Colorz.primaryColor,
      duration: duration,
      action: action,
    );
  }

  /// Shows an error snackbar
  static void showError(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
  }) {
    _showSnackbar(
      context: context,
      title: "Error",
      message: message,
      contentType: ContentType.failure,
      duration: duration,
      action: action,
    );
  }

  /// Shows an info snackbar
  static void showInfo(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    _showSnackbar(
      context: context,
      title: "Info",
      message: message,
      contentType: ContentType.help,
      duration: duration,
      action: action,
    );
  }

  /// Shows a warning snackbar
  static void showWarning(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    _showSnackbar(
      context: context,
      title: "Warning",
      message: message,
      contentType: ContentType.warning,
      duration: duration,
      action: action,
    );
  }

  /// Shows a custom snackbar (defaults to Help type)
  static void showCustom(
    BuildContext context, {
    String title = "Notification",
    required String message,
    required Color backgroundColor, // Ignored by AwesomeSnackbarContent usually
    IconData? icon, // Ignored as ContentType dictates icon
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    _showSnackbar(
      context: context,
      title: title,
      message: message,
      contentType: ContentType.help,
      duration: duration,
      action: action,
    );
  }

  /// Internal method to show the snackbar using custom OverlayEntry for Top position
  static void _showSnackbar({
    required BuildContext context,
    required String title,
    required String message,
    required ContentType contentType,
    Color? color,
    required Duration duration,
    SnackBarAction? action,
  }) {
    // Find the Overlay
    final overlay = Overlay.of(context);
    if (overlay == null) {
      // Fallback if no overlay found (unlikely in standard app structure)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("$title: $message"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _TopSnackBar(
        title: title,
        message: message,
        contentType: contentType,
        color: color,
        duration: duration,
        onDismiss: () {
          overlayEntry.remove();
        },
      ),
    );

    overlay.insert(overlayEntry);
  }
}

class _TopSnackBar extends StatefulWidget {
  final String title;
  final String message;
  final ContentType contentType;
  final Color? color;
  final Duration duration;
  final VoidCallback onDismiss;

  const _TopSnackBar({
    Key? key,
    required this.title,
    required this.message,
    required this.contentType,
    this.color,
    required this.duration,
    required this.onDismiss,
  }) : super(key: key);

  @override
  State<_TopSnackBar> createState() => _TopSnackBarState();
}

class _TopSnackBarState extends State<_TopSnackBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 700),
      reverseDuration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, -1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _controller.forward();

    Future.delayed(widget.duration, () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  void _dismiss() {
    if (mounted && _controller.status != AnimationStatus.reverse) {
      _controller.reverse().then((_) => widget.onDismiss());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SlideTransition(
        position: _offsetAnimation,
        child: SafeArea(
          child: Dismissible(
            key: UniqueKey(),
            direction: DismissDirection.up,
            onDismissed: (_) {
              widget.onDismiss();
            },
            child: Material(
              color: Colors.transparent,
              child: Container(
                margin: const EdgeInsets.all(16),
                child: Stack(
                  children: [
                    AwesomeSnackbarContent(
                      title: widget.title,
                      message: widget.message,
                      contentType: widget.contentType,
                      color: widget.color,
                    ),
                    // Detection area for the "X" icon of AwesomeSnackbarContent
                    Positioned(
                      top: 10,
                      right: 15,
                      child: GestureDetector(
                        onTap: _dismiss,
                        behavior: HitTestBehavior.opaque,
                        child: const SizedBox(
                          width: 40,
                          height: 40,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
