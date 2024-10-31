import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:ocurithm/core/utils/keyboard_helper.dart';

class FlutterDropdownSearchController {
  _FlutterDropdownSearchState? _state;

  void _setState(_FlutterDropdownSearchState state) {
    _state = state;
  }

  void openDropdown() {
    _state?._toggleDropdown();
  }
}

class FlutterDropdownSearch<T> extends StatefulWidget {
  final String? hintText;
  final String? validateText;
  final String? selectedValue;
  final List<T> items;
  final List<T> disabledItems;
  final TextStyle? hintStyle;
  final TextStyle? style;
  final TextStyle? dropdownTextStyle;
  final IconData? suffixIcon;
  final double? dropdownHeight;
  final Color? dropdownBgColor;
  final Color? color;
  final Color? border;
  final InputBorder? textFieldBorder;
  final EdgeInsetsGeometry? contentPadding;
  final String? labelText;
  final String Function(T) itemAsString;
  final void Function(T)? onItemSelected;
  final bool isLoading;
  final bool? isShadow;
  final Widget? icon;
  final Widget? prefixIcon;
  final double? radius;
  final bool? isValid;
  final FlutterDropdownSearchController? controller;

  const FlutterDropdownSearch({
    Key? key,
    this.hintText,
    required this.items,
    this.disabledItems = const [],
    this.hintStyle,
    this.style,
    this.dropdownTextStyle,
    this.suffixIcon,
    this.dropdownHeight,
    this.dropdownBgColor,
    this.textFieldBorder,
    this.contentPadding,
    this.labelText,
    required this.itemAsString,
    this.onItemSelected,
    required this.isLoading,
    this.icon,
    this.color,
    this.prefixIcon,
    this.isShadow,
    this.radius,
    this.selectedValue,
    this.isValid,
    this.controller,
    this.border,
    this.validateText,
  }) : super(key: key);

  @override
  State<FlutterDropdownSearch> createState() => _FlutterDropdownSearchState<T>();
}

class _FlutterDropdownSearchState<T> extends State<FlutterDropdownSearch<T>> with WidgetsBindingObserver {
  bool _isDropdownOpen = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchTerm = '';
  String? _selectedValue;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  final double _dropdownMaxHeight = 200.0;

  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.selectedValue;
    widget.controller?._setState(this);

    // Listen to keyboard visibility changes
    WidgetsBinding.instance.addObserver(this);
  }

  // void _setupKeyboardListener() {
  //   _isKeyboardVisible.value = WidgetsBinding.instance.window.viewInsets.bottom > 0;
  //
  //   // Update overlay when keyboard visibility changes
  //   _isKeyboardVisible.addListener(() {
  //     if (WidgetsBinding.instance.window.viewInsets.bottom > 0.0) {
  //       log(WidgetsBinding.instance.window.viewInsets.bottom.toString());
  //       _isVisible = true;
  //       log("is Visible");
  //     } else {
  //       _isVisible = false;
  //       log("Not Visible");
  //     }
  //     if (_isDropdownOpen) {
  //       _updateOverlay();
  //     }
  //   });
  // }

  @override
  void dispose() {
    _searchController.dispose();
    _removeOverlay();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    final bottomInset = WidgetsBinding.instance.window.viewInsets.bottom;
    final newKeyboardVisible = bottomInset > 0;

    // Update only if the visibility has changed
    if (newKeyboardVisible != _isVisible) {
      log(WidgetsBinding.instance.window.viewInsets.bottom.toString());
      setState(() {
        _isVisible = newKeyboardVisible;
        log("is Visible $_isVisible");
        setState(() {});
      });
    }
  }

  @override
  void didUpdateWidget(covariant FlutterDropdownSearch<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedValue == null) {
      setState(() {
        _selectedValue = null;
      });
    }
    if (oldWidget.isLoading != widget.isLoading || oldWidget.items != widget.items) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateOverlay();
      });
    }
  }

  void _toggleDropdown() {
    if (_isDropdownOpen) {
      _removeOverlay();
    } else {
      _createOverlay();
    }
    setState(() {
      _isDropdownOpen = !_isDropdownOpen;
      WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
    });
  }

  void _createOverlay() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
  }

  void _updateOverlay() {
    _removeOverlay();
    if (_isDropdownOpen) {
      _createOverlay();
    }
    WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;
    var offset = renderBox.localToGlobal(Offset.zero);

    // Get screen metrics
    final screenHeight = MediaQuery.of(context).size.height;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final validationHeight = widget.isValid == false ? 32.0 : 0.0;

    // Calculate available spaces and screen sections
    final spaceBelow = screenHeight - offset.dy - size.height - keyboardHeight;
    final spaceAbove = offset.dy;
    final upperThirdThreshold = screenHeight / 3;

    // Determine if dropdown is in upper third of screen
    bool isInUpperThird = offset.dy < upperThirdThreshold;

    // Calculate preferred direction
    bool openUpward = keyboardHeight > 0 || (spaceBelow < _dropdownMaxHeight && spaceAbove > spaceBelow) || isInUpperThird;

    // Calculate actual dropdown height
    double dropdownHeight = widget.dropdownHeight ?? _dropdownMaxHeight;
    if (openUpward) {
      dropdownHeight = math.min(dropdownHeight, spaceAbove - 10);
    } else {
      dropdownHeight = math.min(dropdownHeight, spaceBelow - 10);
    }

    double _keyboardHeight = keyboardHeight;

    return OverlayEntry(
      builder: (context) => KeyboardHeightProvider(
        onKeyboardHeightChanged: (height) {
          _keyboardHeight = height;
          // Force rebuild overlay when keyboard height changes
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _overlayEntry?.markNeedsBuild();
          });
        },
        child: StatefulBuilder(builder: (context, setState) {
          return Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  onTap: _closeDropdown,
                  behavior: HitTestBehavior.opaque,
                  child: Container(color: Colors.grey.withOpacity(0.4)),
                ),
              ),
              Positioned(
                left: offset.dx,
                width: size.width,
                top: openUpward ? offset.dy - dropdownHeight : offset.dy + size.height,
                child: CompositedTransformFollower(
                  link: _layerLink,
                  showWhenUnlinked: false,
                  offset: Offset(
                      0,
                      _calculateVerticalOffset(
                          isInUpperThird: isInUpperThird,
                          isKeyboardVisible: _isVisible || _keyboardHeight > 0,
                          openUpward: openUpward,
                          dropdownHeight: dropdownHeight,
                          size: size,
                          validationHeight: validationHeight,
                          keyboardHeight: _keyboardHeight)),
                  child: Material(
                    elevation: 8,
                    borderRadius: BorderRadius.circular(8),
                    child: _buildDropdownContent(dropdownHeight),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

// Updated keyboard detection in search field
  Widget _buildSearchField(StateSetter setState) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: TextField(
        controller: _searchController,
        onTap: () {
          // Immediate visibility update
          setState(() {
            _isVisible = true;
          });
          // Force rebuild after a short delay to ensure keyboard is visible
          Future.delayed(const Duration(milliseconds: 50), () {
            if (_overlayEntry != null) {
              _overlayEntry!.markNeedsBuild();
            }
          });
        },
        onChanged: (value) {
          setState(() {
            _searchTerm = value;
          });
          _overlayEntry?.markNeedsBuild();
        },
        onSubmitted: (value) {
          setState(() {
            _isVisible = false;
          });
          _overlayEntry?.markNeedsBuild();
        },
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          hintText: 'Search...',
          hintStyle: TextStyle(color: Colors.grey.shade600),
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
        ),
      ),
    );
  }

  double _calculateVerticalOffset({
    required bool isInUpperThird,
    required bool isKeyboardVisible,
    required bool openUpward,
    required double dropdownHeight,
    required Size size,
    required double validationHeight,
    required double keyboardHeight,
  }) {
    if (isInUpperThird) {
      return size.height - validationHeight; // Show dropdown below when in upper third
    }

    if (isKeyboardVisible) {
      if (openUpward) {
        return -dropdownHeight - keyboardHeight + 50;
      }
      return -dropdownHeight;
    }

    if (openUpward) {
      return -dropdownHeight + 50;
    }

    return size.height - validationHeight;
  }

  Widget _buildDropdownContent(double dropdownHeight) {
    return StatefulBuilder(
      builder: (context, setState) {
        final filteredList = _getFilteredList();
        return Container(
          constraints: BoxConstraints(
            maxHeight: (filteredList.length > 1 ? double.parse((filteredList.length * 80.0).toString()) : double.parse("120")).clamp(15.0, 200.0),
          ),
          decoration: BoxDecoration(
            color: widget.dropdownBgColor ?? Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade300,
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSearchField(setState),
              Divider(height: 1, color: Colors.grey.shade200),
              _buildListView(filteredList),
            ],
          ),
        );
      },
    );
  }

  Widget _buildListView(List<T> filteredList) {
    return Flexible(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: (filteredList.length > 1 ? double.parse((filteredList.length * 80.0).toString()) : double.parse("120")).clamp(15.0, 200.0),
        ),
        child: widget.isLoading
            ? Center(
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(
                    color: Colors.grey,
                  ),
                ),
              )
            : ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: filteredList.length,
                itemBuilder: (context, index) {
                  final item = filteredList[index];
                  final isDisabled = widget.disabledItems.contains(item);
                  return InkWell(
                    onTap: isDisabled ? null : () => _selectItem(item),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      child: Text(
                        widget.itemAsString(item),
                        style: (widget.dropdownTextStyle ??
                                TextStyle(
                                  color: Colors.grey.shade800,
                                  fontSize: 16.0,
                                ))
                            .copyWith(
                          color: isDisabled ? Colors.grey.shade400 : null,
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  void _closeDropdown() {
    setState(() {
      _isDropdownOpen = false;
    });
    _removeOverlay();
  }

  List<T> _getFilteredList() {
    return widget.items.where((item) => widget.itemAsString(item).toLowerCase().contains(_searchTerm.toLowerCase())).toList();
  }

  void _selectItem(T item) {
    setState(() {
      _selectedValue = widget.itemAsString(item);
      _isDropdownOpen = false;
    });
    _removeOverlay();
    if (widget.onItemSelected != null) {
      widget.onItemSelected!(item);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: _toggleDropdown,
            child: Container(
              decoration: BoxDecoration(
                color: widget.color ?? Colors.white,
                borderRadius: BorderRadius.circular(widget.radius ?? 10),
                boxShadow: widget.isShadow != false
                    ? [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 5,
                        ),
                      ]
                    : null,
                border: Border.all(
                  color: widget.isValid == false ? Colors.red : widget.border ?? Colors.transparent,
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          if (widget.prefixIcon != null)
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: widget.prefixIcon,
                            ),
                          Expanded(
                            child: _selectedValue != null && _selectedValue!.isNotEmpty
                                ? Text(
                                    _selectedValue!,
                                    style: widget.style ??
                                        const TextStyle(
                                          fontSize: 18,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500,
                                        ),
                                  )
                                : Text(
                                    widget.hintText ?? 'Select an item',
                                    style: widget.hintStyle ??
                                        const TextStyle(
                                          fontSize: 18,
                                          color: Colors.grey,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                    widget.icon ??
                        Icon(
                          Icons.arrow_drop_down_circle,
                          color: Colors.green.shade800,
                        ),
                  ],
                ),
              ),
            ),
          ),
          if (widget.isValid == false)
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
              child: Text(
                widget.validateText ?? "This field must not be empty",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class DropdownItem<T> extends StatelessWidget {
  const DropdownItem(
      {super.key,
      this.searchController,
      required this.items,
      required this.hintText,
      this.label,
      required this.itemAsString,
      required this.onItemSelected,
      required this.isLoading,
      this.icon,
      this.iconData,
      this.color,
      this.isShadow,
      this.radius,
      this.selectedValue,
      this.isValid,
      this.controller,
      this.disabledItems,
      this.border,
      this.prefixIcon,
      this.validateText});

  final TextEditingController? searchController;
  final List<T>? items;
  final List<T>? disabledItems;
  final String hintText;
  final String? selectedValue;
  final Widget? icon;
  final Widget? iconData;
  final Color? color;
  final Color? border;
  final bool? isShadow;
  final Widget? prefixIcon;
  final String? validateText;
  final String? label;
  final bool? isValid;
  final FlutterDropdownSearchController? controller;

  final String Function(T) itemAsString; // Function to convert item to string
  final void Function(T) onItemSelected; // Callback for item selection
  final bool isLoading; // Indicates whether the data is being loaded
  final double? radius;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        label != null
            ? Row(
                children: [
                  icon ?? const SizedBox(height: 0, width: 0),
                  const SizedBox(width: 10),
                  Text(
                    label!,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              )
            : const SizedBox.shrink(),
        label != null ? const SizedBox(height: 10) : const SizedBox.shrink(),
        FlutterDropdownSearch<T>(
          items: items ?? [],
          disabledItems: disabledItems ?? [],
          border: border,
          icon: iconData,
          prefixIcon: prefixIcon,
          color: color,
          isValid: isValid,
          radius: radius,
          selectedValue: selectedValue,
          isShadow: isShadow,
          controller: controller,
          //textController: searchController,
          hintText: hintText,
          textFieldBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.blueAccent, width: 3),
            borderRadius: BorderRadius.circular(10),
          ),
          itemAsString: itemAsString,
          onItemSelected: onItemSelected,
          isLoading: isLoading,
        ),
      ],
    );
  }
}
