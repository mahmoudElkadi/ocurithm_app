import 'dart:developer';
import 'dart:math' as math;

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ocurithm/core/utils/keyboard_helper.dart';
import 'package:ocurithm/core/widgets/width_spacer.dart';

import '../../generated/l10n.dart';
import '../utils/app_style.dart';
import 'height_spacer.dart';

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
  final TextEditingController? searchController;
  final TextStyle? dropdownTextStyle;
  final IconData? suffixIcon;
  final double? dropdownHeight;
  final double? height;
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
  final bool? readOnly;
  final FlutterDropdownSearchController? controller;
  final void Function(String)? onChanged;

  const FlutterDropdownSearch({
    super.key,
    this.hintText,
    required this.items,
    this.disabledItems = const [],
    this.hintStyle,
    this.style,
    this.onChanged,
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
    this.height,
    this.searchController,
    this.readOnly = false,
  });

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

  @override
  void didUpdateWidget(FlutterDropdownSearch<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update items when they change
    setState(() {
      _selectedValue = widget.selectedValue;
    });
    if (widget.items != oldWidget.items) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_isDropdownOpen) {
          log("in");
          _overlayEntry?.markNeedsBuild();
        }
        _overlayEntry?.markNeedsBuild();
      });
    }
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
  //
  // @override
  // void didUpdateWidget(covariant FlutterDropdownSearch<T> oldWidget) {
  //   super.didUpdateWidget(oldWidget);
  //   if (widget.selectedValue == null) {
  //     setState(() {
  //       _selectedValue = null;
  //     });
  //   }
  //   if (oldWidget.isLoading != widget.isLoading || oldWidget.items != widget.items) {
  //     WidgetsBinding.instance.addPostFrameCallback(() {
  //       _updateOverlay();
  //     });
  //   }
  // }

  void _toggleDropdown() {
    if (_isDropdownOpen) {
      _removeOverlay();
    } else {
      _createOverlay();
    }
    setState(() {
      _isDropdownOpen = !_isDropdownOpen;
      // WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
    });
  }

  void _createOverlay() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _updateOverlay() {
    _removeOverlay();
    if (_isDropdownOpen) {
      _createOverlay();
    }
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;
    var offset = renderBox.localToGlobal(Offset.zero);

    // Get screen metrics
    final screenHeight = MediaQuery.of(context).size.height;
    var keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
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
          keyboardHeight = height;
          // Force rebuild overlay when keyboard height changes
          // WidgetsBinding.instance.addPostFrameCallback(() {
          //   _overlayEntry?.markNeedsBuild();
          // });
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
        controller: widget.searchController ?? _searchController,
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
          if (widget.onChanged != null) {
            widget.onChanged!(value);
          } else {
            setState(() {
              _searchTerm = value;
            });
          }
          if (_overlayEntry != null) {
            log("overlay entry not null");
            _overlayEntry!.markNeedsBuild();
          }
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
      return -dropdownHeight + 50;
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
            maxHeight: (filteredList.length > 1 ? double.parse((filteredList.length * 80.0).toString()) : double.parse("130")).clamp(15.0, 200.0),
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
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Container(
                    width: 30,
                    height: 30,
                    child: CircularProgressIndicator(
                      color: Colors.grey,
                      strokeWidth: 2,
                    ),
                  ),
                ),
              )
            : filteredList.isEmpty
                ? Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "No Data",
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: Colors.grey.shade800,
                        fontSize: 16.0,
                      ).copyWith(),
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
    if (widget.onChanged != null) {
      // If external search is being used, return all items as filtering
      // is handled by the parent
      return widget.items;
    }
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
            onTap: widget.readOnly == true ? null : _toggleDropdown,
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
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: widget.height ?? 12),
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
                                ? FittedBox(
                                    alignment: Alignment.centerLeft,
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      _selectedValue!,
                                      style: widget.style ??
                                          const TextStyle(
                                            fontSize: 16,
                                            color: Colors.black,
                                            fontWeight: FontWeight.w400,
                                          ),
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
                    if (widget.readOnly != true)
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
      this.hintStyle,
      this.border,
      this.prefixIcon,
      this.validateText,
      this.height,
      this.textStyle,
      this.onChanged,
      this.readOnly});
  // Add this new property

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
  final TextStyle? hintStyle;
  final TextStyle? textStyle;
  final String Function(T) itemAsString; // Function to convert item to string
  final void Function(T) onItemSelected; // Callback for item selection
  final bool isLoading; // Indicates whether the data is being loaded
  final bool? readOnly;
  final double? radius;
  final double? height;
  final void Function(String)? onChanged;

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
          onChanged: onChanged,
          color: color,
          isValid: isValid,
          readOnly: readOnly,
          radius: radius,
          selectedValue: selectedValue,
          isShadow: isShadow,
          controller: controller,
          height: height,
          hintStyle: hintStyle,
          style: textStyle,
          validateText: validateText,
          //textController: searchController,
          hintText: hintText,
          textFieldBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.blueAccent, width: 3),
            borderRadius: BorderRadius.circular(10),
          ),
          itemAsString: itemAsString,
          onItemSelected: onItemSelected,
          isLoading: isLoading, searchController: searchController,
        ),
      ],
    );
  }
}

class PopupDropdownSearchController {
  _PopupDropdownSearchState? _state;

  void _setState(_PopupDropdownSearchState state) {
    _state = state;
  }

  void clear() {
    _state?._clearSelection();
  }
}

class PopupDropdownSearch<T> extends StatefulWidget {
  final String? hintText;
  final String? validateText;
  final String? selectedValue;
  final List<T> items;
  final List<T> disabledItems;
  final TextStyle? hintStyle;
  final TextStyle? style;
  final TextStyle? dropdownTextStyle;
  final double? dropdownHeight;
  final double? height;
  final Color? dropdownBgColor;
  final Color? color;
  final Color? border;
  final EdgeInsetsGeometry? contentPadding;
  final String Function(T) itemAsString;
  final void Function(T)? onItemSelected;
  final bool isLoading;
  final bool? isShadow;
  final Widget? icon;
  final Widget? prefixIcon;
  final double? radius;
  final bool? isValid;
  final PopupDropdownSearchController? controller;
  final bool insidePopup;

  const PopupDropdownSearch({
    Key? key,
    this.hintText,
    required this.items,
    this.disabledItems = const [],
    this.hintStyle,
    this.style,
    this.dropdownTextStyle,
    this.dropdownHeight,
    this.dropdownBgColor,
    this.contentPadding,
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
    this.height,
    this.insidePopup = true,
  }) : super(key: key);

  @override
  State<PopupDropdownSearch<T>> createState() => _PopupDropdownSearchState<T>();
}

class _PopupDropdownSearchState<T> extends State<PopupDropdownSearch<T>> {
  bool _isDropdownOpen = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchTerm = '';
  String? _selectedValue;
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.selectedValue;
    widget.controller?._setState(this);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _clearSelection() {
    setState(() {
      _selectedValue = null;
      _searchTerm = '';
      _searchController.clear();
    });
  }

  void _toggleDropdown() {
    if (_isDropdownOpen) {
      _removeOverlay();
    } else {
      _showDropdown();
    }
    setState(() {
      _isDropdownOpen = !_isDropdownOpen;
    });
  }

  void _showDropdown() {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    // Get navigator overlay instead of root overlay
    final NavigatorState navigator = Navigator.of(context);
    final OverlayState overlay = navigator.overlay!;

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: _removeOverlay,
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
          Positioned(
            left: offset.dx,
            top: offset.dy + size.height,
            width: size.width,
            child: CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(0, size.height + 5),
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(8),
                child: _buildDropdownContent(),
              ),
            ),
          ),
        ],
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() {
      _isDropdownOpen = false;
    });
  }

  Widget _buildDropdownContent() {
    final filteredItems = widget.items.where((item) => widget.itemAsString(item).toLowerCase().contains(_searchTerm.toLowerCase())).toList();

    return Container(
      constraints: BoxConstraints(
        maxHeight: widget.dropdownHeight ?? 300,
      ),
      decoration: BoxDecoration(
        color: widget.dropdownBgColor ?? Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSearchField(),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                final item = filteredItems[index];
                final isDisabled = widget.disabledItems.contains(item);
                return _buildDropdownItem(item, isDisabled);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchTerm = value;
          });
          _overlayEntry?.markNeedsBuild();
        },
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          hintText: 'Search...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownItem(T item, bool isDisabled) {
    return InkWell(
      onTap: isDisabled ? null : () => _selectItem(item),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Text(
          widget.itemAsString(item),
          style: widget.dropdownTextStyle?.copyWith(
                color: isDisabled ? Colors.grey : null,
              ) ??
              TextStyle(
                color: isDisabled ? Colors.grey : Colors.black,
                fontSize: 16,
              ),
        ),
      ),
    );
  }

  void _selectItem(T item) {
    setState(() {
      _selectedValue = widget.itemAsString(item);
      _isDropdownOpen = false;
    });
    _removeOverlay();
    widget.onItemSelected?.call(item);
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
              height: widget.height,
              decoration: BoxDecoration(
                color: widget.color ?? Colors.white,
                borderRadius: BorderRadius.circular(widget.radius ?? 8),
                border: Border.all(
                  color: widget.isValid == false ? Colors.red : widget.border ?? Colors.transparent,
                ),
                boxShadow: widget.isShadow == true
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              padding: widget.contentPadding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  if (widget.prefixIcon != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: widget.prefixIcon,
                    ),
                  Expanded(
                    child: Text(
                      _selectedValue ?? widget.hintText ?? 'Select an option',
                      style: _selectedValue != null ? widget.style : widget.hintStyle ?? const TextStyle(color: Colors.grey),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  widget.icon ?? const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
          if (widget.isValid == false)
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 12),
              child: Text(
                widget.validateText ?? 'This field is required',
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class DropdownItem2<T> extends StatelessWidget {
  const DropdownItem2({
    super.key,
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
    this.hintStyle,
    this.dropdownTextStyle,
    this.border,
    this.prefixIcon,
    this.validateText,
    this.height,
    this.textStyle,
    this.dropdownHeight,
    this.dropdownBgColor,
  });

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
  final PopupDropdownSearchController? controller;
  final TextStyle? hintStyle;
  final TextStyle? textStyle;
  final TextStyle? dropdownTextStyle;
  final String Function(T) itemAsString;
  final void Function(T) onItemSelected;
  final bool isLoading;
  final double? radius;
  final double? height;
  final double? dropdownHeight;
  final Color? dropdownBgColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Row(
            children: [
              icon ?? const SizedBox.shrink(),
              if (icon != null) const SizedBox(width: 10),
              Text(
                label!,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isValid == false ? Colors.red : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
        PopupDropdownSearch<T>(
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
          height: height,
          hintStyle: hintStyle,
          style: textStyle,
          dropdownTextStyle: dropdownTextStyle,
          dropdownHeight: dropdownHeight,
          dropdownBgColor: dropdownBgColor,
          validateText: validateText,
          hintText: hintText,
          itemAsString: itemAsString,
          onItemSelected: onItemSelected,
          isLoading: isLoading,
        ),
      ],
    );
  }
}

class DropValidateRow extends StatefulWidget {
  const DropValidateRow({
    super.key,
    required this.items,
    this.onChanged,
    this.selectedValue,
    this.text,
    required this.hintText,
    this.border,
    this.height,
    this.hintColor,
    this.validate,
    this.icon,
    this.radius,
    this.prefixIcon,
    this.textRow,
  });
  final List<DropdownMenuItem<dynamic>>? items;
  final Function(dynamic str)? onChanged;
  final dynamic selectedValue;
  final String? text;
  final String? textRow;
  final Widget? icon;
  final Widget? prefixIcon;
  final String hintText;
  final double? border;
  final double? height;
  final double? radius;
  final Color? hintColor;
  final bool? validate;

  @override
  State<DropValidateRow> createState() => _DropValidateRowState();
}

class _DropValidateRowState extends State<DropValidateRow> {
  TextEditingController textEditingController = TextEditingController();

  bool customSearchMatch(String itemValue, String searchValue) {
    int itemIndex = 0;
    int searchIndex = 0;

    while (itemIndex < itemValue.length && searchIndex < searchValue.length) {
      if (itemValue[itemIndex].toLowerCase() == searchValue[searchIndex].toLowerCase()) {
        searchIndex++;
      }
      itemIndex++;
    }
    return searchIndex == searchValue.length;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widget.text != null
            ? Row(
                children: [
                  widget.icon ??
                      const SizedBox(
                        height: 0,
                        width: 0,
                      ),
                  const WidthSpacer(size: 10),
                  Text(
                    widget.text!,
                    style: appStyle(context, 18, Colors.grey, FontWeight.bold),
                  ),
                ],
              )
            : const SizedBox(
                height: 0,
                width: 0,
              ),
        const HeightSpacer(size: 10),
        Center(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 15.w).copyWith(right: 0),
            width: MediaQuery.sizeOf(context).width,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(widget.radius ?? 30),
              border: Border.all(color: widget.validate == true ? Colors.red.shade900 : Colors.transparent),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  spreadRadius: 2,
                  blurRadius: 4,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.textRow ?? "",
                  style: appStyle(context, 15, Colors.grey, FontWeight.bold),
                ),
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton2<dynamic>(
                      isExpanded: true,
                      iconStyleData: IconStyleData(
                          icon: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade300,
                              spreadRadius: 2,
                              blurRadius: 4,
                              offset: const Offset(0, 0),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.expand_more,
                          color: Colors.black,
                        ),
                      )),
                      hint: Row(
                        children: [
                          widget.prefixIcon ?? Container(),
                          Text(
                            widget.hintText,
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      items: widget.items,
                      value: widget.selectedValue,
                      style: appStyle(context, 15, Colors.black, FontWeight.w600).copyWith(
                        overflow: TextOverflow.ellipsis,
                      ),
                      onChanged: widget.onChanged,
                      buttonStyleData: ButtonStyleData(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        height: widget.height ?? 25,
                        width: MediaQuery.sizeOf(context).width * 0.57,
                      ),
                      dropdownStyleData: const DropdownStyleData(
                        maxHeight: 200,
                      ),
                      menuItemStyleData: const MenuItemStyleData(
                        height: 40,
                      ),
                      dropdownSearchData: DropdownSearchData(
                        searchController: textEditingController,
                        searchInnerWidgetHeight: 50,
                        searchInnerWidget: Container(
                          height: 50,
                          padding: const EdgeInsets.only(
                            top: 8,
                            bottom: 4,
                            right: 8,
                            left: 8,
                          ),
                          child: TextFormField(
                            expands: true,
                            maxLines: null,
                            controller: textEditingController,
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              hintText: "Search for an item...",
                              hintStyle: const TextStyle(fontSize: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        searchMatchFn: (item, searchValue) {
                          return customSearchMatch(item.value.toString(), searchValue);
                        },
                      ),
                      //This to clear the search value when you close the menu
                      onMenuStateChange: (isOpen) {
                        if (!isOpen) {
                          textEditingController.clear();
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (widget.validate == true)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const HeightSpacer(
                size: 10,
              ),
              Text(
                S.of(context).mustNotEmpty,
                style: appStyle(context, 14, Colors.red.shade900, FontWeight.w400),
              ),
            ],
          ),
      ],
    );
  }
}

class CustomColumnDropdown<T> extends StatefulWidget {
  const CustomColumnDropdown({
    super.key,
    required this.items,
    this.onChanged,
    this.selectedValue,
    this.text,
    required this.hintText,
    this.border,
    this.height,
    this.hintColor,
    this.validate,
    this.icon,
    this.radius,
    this.prefixIcon,
    this.textRow,
  });
  final List<T> items;
  final void Function(T)? onChanged;
  final dynamic selectedValue;
  final String? text;
  final String? textRow;
  final Widget? icon;
  final Widget? prefixIcon;
  final String hintText;
  final double? border;
  final double? height;
  final double? radius;
  final Color? hintColor;
  final bool? validate;

  @override
  State<CustomColumnDropdown> createState() => _CustomColumnDropdownState();
}

class _CustomColumnDropdownState extends State<CustomColumnDropdown> {
  TextEditingController textEditingController = TextEditingController();

  bool customSearchMatch(String itemValue, String searchValue) {
    int itemIndex = 0;
    int searchIndex = 0;

    while (itemIndex < itemValue.length && searchIndex < searchValue.length) {
      if (itemValue[itemIndex].toLowerCase() == searchValue[searchIndex].toLowerCase()) {
        searchIndex++;
      }
      itemIndex++;
    }
    return searchIndex == searchValue.length;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widget.text != null
            ? Column(
                children: [
                  widget.icon ??
                      const SizedBox(
                        height: 0,
                        width: 0,
                      ),
                  const WidthSpacer(size: 10),
                  Text(
                    widget.text!,
                    style: appStyle(context, 18, Colors.grey, FontWeight.bold),
                  ),
                ],
              )
            : const SizedBox(
                height: 0,
                width: 0,
              ),
        const HeightSpacer(size: 10),
        Column(
          spacing: 10,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "   ${widget.textRow ?? " "}",
              style: appStyle(context, 18, Colors.grey, FontWeight.w600),
            ),
            DropdownItem(
                items: widget.items,
                hintText: widget.textRow ?? "",
                hintStyle: appStyle(context, 16, Colors.grey, FontWeight.w500),
                radius: 30,
                iconData: Container(
                  padding: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade300,
                        spreadRadius: 2,
                        blurRadius: 4,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.expand_more,
                    color: Colors.black,
                  ),
                ),
                selectedValue: widget.selectedValue,
                itemAsString: (item) => item.toString(),
                onItemSelected: widget.onChanged ?? (_) {},
                isLoading: false),
          ],
        ),
        if (widget.validate == true)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const HeightSpacer(
                size: 10,
              ),
              Text(
                S.of(context).mustNotEmpty,
                style: appStyle(context, 14, Colors.red.shade900, FontWeight.w400),
              ),
            ],
          ),
      ],
    );
  }
}
