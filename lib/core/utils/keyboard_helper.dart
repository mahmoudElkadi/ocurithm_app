import 'dart:async';

import 'package:flutter/material.dart';

class KeyboardHelper extends WidgetsBindingObserver {
  /// Stream controller for keyboard height updates
  final _keyboardHeightController = StreamController<double>.broadcast();

  /// Stream controller for keyboard visibility updates
  final _keyboardVisibilityController = StreamController<bool>.broadcast();

  /// Current keyboard height
  double _keyboardHeight = 0.0;

  /// Current keyboard visibility state
  bool _isKeyboardVisible = false;

  /// Debounce timer for keyboard updates
  Timer? _debounceTimer;

  /// Whether the helper has been disposed
  bool _isDisposed = false;

  /// Stream of keyboard height updates
  Stream<double> get keyboardHeight => _keyboardHeightController.stream;

  /// Stream of keyboard visibility updates
  Stream<bool> get isKeyboardVisible => _keyboardVisibilityController.stream;

  /// Current keyboard height value
  double get currentKeyboardHeight => _keyboardHeight;

  /// Current keyboard visibility value
  bool get currentVisibility => _isKeyboardVisible;

  KeyboardHelper() {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeMetrics() {
    if (_isDisposed) return;

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 100), () {
      if (_isDisposed) return;

      final window = WidgetsBinding.instance.window;
      final bottomInset = window.viewInsets.bottom / window.devicePixelRatio;

      _keyboardHeight = bottomInset;
      _isKeyboardVisible = bottomInset > 0;

      _keyboardHeightController.add(_keyboardHeight);
      _keyboardVisibilityController.add(_isKeyboardVisible);
    });
  }

  /// Safely dispose of the helper
  void dispose() {
    if (_isDisposed) return;

    _isDisposed = true;
    _debounceTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _keyboardHeightController.close();
    _keyboardVisibilityController.close();
  }
}

/// Widget that safely manages keyboard height information
class KeyboardHeightProvider extends StatefulWidget {
  final Widget child;
  final void Function(double height)? onKeyboardHeightChanged;
  final void Function(bool visible)? onKeyboardVisibilityChanged;

  const KeyboardHeightProvider({
    Key? key,
    required this.child,
    this.onKeyboardHeightChanged,
    this.onKeyboardVisibilityChanged,
  }) : super(key: key);

  @override
  State<KeyboardHeightProvider> createState() => _KeyboardHeightProviderState();
}

class _KeyboardHeightProviderState extends State<KeyboardHeightProvider> {
  late final KeyboardHelper _keyboardHelper;
  StreamSubscription? _heightSubscription;
  StreamSubscription? _visibilitySubscription;

  @override
  void initState() {
    super.initState();
    _keyboardHelper = KeyboardHelper();
    _setupSubscriptions();
  }

  void _setupSubscriptions() {
    if (widget.onKeyboardHeightChanged != null) {
      _heightSubscription = _keyboardHelper.keyboardHeight.listen(
        widget.onKeyboardHeightChanged!,
      );
    }

    if (widget.onKeyboardVisibilityChanged != null) {
      _visibilitySubscription = _keyboardHelper.isKeyboardVisible.listen(
        widget.onKeyboardVisibilityChanged!,
      );
    }
  }

  @override
  void dispose() {
    _heightSubscription?.cancel();
    _visibilitySubscription?.cancel();
    _keyboardHelper.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Example usage with a responsive bottom widget
class KeyboardAwareWidget extends StatefulWidget {
  const KeyboardAwareWidget({Key? key}) : super(key: key);

  @override
  State<KeyboardAwareWidget> createState() => _KeyboardAwareWidgetState();
}

class _KeyboardAwareWidgetState extends State<KeyboardAwareWidget> {
  double _keyboardHeight = 0.0;
  bool _isKeyboardVisible = false;

  @override
  Widget build(BuildContext context) {
    return KeyboardHeightProvider(
      onKeyboardHeightChanged: (height) {
        setState(() => _keyboardHeight = height);
      },
      onKeyboardVisibilityChanged: (visible) {
        setState(() => _isKeyboardVisible = visible);
      },
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Input Field',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Keyboard Height: $_keyboardHeight'),
                  Text('Keyboard Visible: $_isKeyboardVisible'),
                ],
              ),
            ),
            // Bottom widget that smoothly adjusts with keyboard
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: _keyboardHeight,
              color: Colors.grey[200],
              child: Center(
                child: Text('Bottom Widget'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Example usage:
class ExampleUsage extends StatelessWidget {
  const ExampleUsage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return KeyboardHeightProvider(
      onKeyboardHeightChanged: (double height) {
        print('Keyboard height: $height');
      },
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Input field',
                    ),
                  ),
                ],
              ),
            ),
            // Bottom widget that adjusts with keyboard
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: MediaQuery.of(context).viewInsets.bottom > 0 ? MediaQuery.of(context).viewInsets.bottom : 0,
            ),
          ],
        ),
      ),
    );
  }
}
