import 'package:flutter/material.dart';
import '../utils/app_style.dart';

class ArrowTextField extends StatefulWidget {
  final List<dynamic> items;
  final String textRow;
  final String? selectedValue;
  final Function(String) onChanged;

  const ArrowTextField({
    Key? key,
    required this.items,
    required this.textRow,
    required this.selectedValue,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<ArrowTextField> createState() => _ArrowTextFieldState();
}

class _ArrowTextFieldState extends State<ArrowTextField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.selectedValue);
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      _validateAndSet();
    }
  }

  @override
  void didUpdateWidget(covariant ArrowTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedValue != oldWidget.selectedValue) {
      if (_controller.text != widget.selectedValue) {
        // Only update text if the user hasn't typed something that caused an error mismatch, 
        // or effectively we want to sync with parent only if no error?
        // Actually, if parent forces a value, we should probably accept it and clear error.
        _controller.text = widget.selectedValue ?? '';
        if (_errorText != null) {
          setState(() {
            _errorText = null;
          });
        }
      }
    }
  }

  void _validateAndSet() {
    String value = _controller.text;
    final stringItems = widget.items.map((e) => e.toString()).toList();
    
    // 1. Direct match
    if (stringItems.contains(value)) {
      setState(() {
        _errorText = null;
      });
      widget.onChanged(value);
      return;
    } 
    
    // 2. Numeric match (e.g. "1" matches "1.00")
    double? valueNum = double.tryParse(value);
    if (valueNum != null) {
      String? matchedItem;
      for (var item in stringItems) {
        double? itemNum = double.tryParse(item);
        if (itemNum != null && itemNum == valueNum) {
          matchedItem = item;
          break;
        }
      }
      
      if (matchedItem != null) {
        // Automatically correct input to match list format
        _controller.text = matchedItem;
        setState(() {
          _errorText = null;
        });
        widget.onChanged(matchedItem);
        return;
      }
    }

    // 3. Empty string handler
    if (value.isEmpty) {
      setState(() {
          _errorText = null;
      });
      widget.onChanged("");
    } else {
      setState(() {
        _errorText = "Invalid Number";
      });
    }
  }

  void _onArrowPressed(int change) {
    if (widget.items.isEmpty) return;
    final stringItems = widget.items.map((e) => e.toString()).toList();

    // If we have an error or manual input not in list, try to find closest match or default?
    // Current logic: find index of CURRENT value.
    // If current value (text) is invalid (not in list), index is -1.
    int currentIndex = stringItems.indexOf(_controller.text);

    // If text match failed, maybe widget.selectedValue matches?
    if (currentIndex == -1) {
       currentIndex = stringItems.indexOf(widget.selectedValue ?? "");
    }

    if (currentIndex == -1) {
      if (stringItems.contains("0")) {
          currentIndex = stringItems.indexOf("0");
      } else if (stringItems.contains("0.0")) {
          currentIndex = stringItems.indexOf("0.0");
      } else if (stringItems.contains("0.00")) {
          currentIndex = stringItems.indexOf("0.00");
      } else {
         currentIndex = 0;
      }
    } else {
      currentIndex += change;
    }

    if (currentIndex < 0) currentIndex = 0;
    if (currentIndex >= stringItems.length) currentIndex = stringItems.length - 1;

    String newValue = stringItems[currentIndex];
    
    // update controller text first so user sees change immediately
    _controller.text = newValue;
    if (_errorText != null) {
        setState(() {
            _errorText = null;
        });
    }
    // Notify parent
    widget.onChanged(newValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.textRow.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0, left: 12),
            child: Text(
              widget.textRow,
              style: appStyle(context, 14,
                  Theme.of(context).textTheme.bodyLarge?.color ?? Colors.grey,
                  FontWeight.w600),
            ),
          ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Theme.of(context).dividerColor),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor.withValues(alpha:0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.chevron_left,
                    color: Theme.of(context).iconTheme.color),
                onPressed: () => _onArrowPressed(-1),
              ),
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  onSubmitted: (value) {
                    _validateAndSet();
                  },
                ),
              ),
              IconButton(
                icon: Icon(Icons.chevron_right,
                    color: Theme.of(context).iconTheme.color),
                onPressed: () => _onArrowPressed(1),
              ),
            ],
          ),
        ),
        if (_errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 5, left: 12),
            child: Text(
              _errorText!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          )
      ],
    );
  }
}
