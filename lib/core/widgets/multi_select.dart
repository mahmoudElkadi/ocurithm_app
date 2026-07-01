import 'package:flutter/material.dart';

import '../utils/app_style.dart';
import 'height_spacer.dart';

class CustomMultiSelectDropdown extends StatefulWidget {
  final List<dynamic> items;
  final String textRow;
  final String hintText;
  final List<dynamic> selectedValues;
  final Function(List<dynamic>) onChanged;
  final double? radius;
  final double? height;

  /// When true, an "Other" free-text box is shown in the overlay so the doctor can
  /// add a custom value not in [items]. Any already-selected value not in [items]
  /// (legacy/custom data) is also rendered as a removable row.
  final bool allowCustomInput;

  const CustomMultiSelectDropdown({
    Key? key,
    required this.items,
    required this.textRow,
    this.hintText = '',
    required this.selectedValues,
    required this.onChanged,
    this.radius,
    this.height,
    this.allowCustomInput = false,
  }) : super(key: key);

  @override
  State<CustomMultiSelectDropdown> createState() => _CustomMultiSelectDropdownState();
}

class _CustomMultiSelectDropdownState extends State<CustomMultiSelectDropdown> {
  final LayerLink _layerLink = LayerLink();
  bool isExpanded = false;
  late List<dynamic> localSelectedValues;
  OverlayEntry? _overlayEntry;
  final TextEditingController _customController = TextEditingController();

  @override
  void initState() {
    super.initState();
    localSelectedValues = List.from(widget.selectedValues);
  }

  @override
  void didUpdateWidget(covariant CustomMultiSelectDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reflect external changes (e.g. loading an existing examination) while the
    // overlay is closed, without clobbering an in-progress selection.
    if (!isExpanded && widget.selectedValues != oldWidget.selectedValues) {
      localSelectedValues = List.from(widget.selectedValues);
    }
  }

  @override
  void dispose() {
    _customController.dispose();
    _overlayEntry?.remove();
    super.dispose();
  }

  /// Catalog options plus any already-selected value not in them, so legacy /
  /// custom entries render as checked, removable rows.
  List<String> _combinedOptions() {
    final out = <String>[for (final e in widget.items) e.toString()];
    for (final v in localSelectedValues) {
      final s = v.toString();
      if (!out.contains(s)) out.add(s);
    }
    return out;
  }

  void _addCustomValue() {
    final value = _customController.text.trim();
    if (value.isEmpty) return;
    if (!localSelectedValues.contains(value)) {
      localSelectedValues.add(value);
      widget.onChanged(List.from(localSelectedValues));
    }
    _customController.clear();
    _overlayEntry?.remove();
    _showOverlay();
  }

  void _showOverlay() {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Size size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // This GestureDetector covers the entire screen to detect outside clicks
          Positioned.fill(
            child: GestureDetector(
              onTap: _hideOverlay,
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
          Positioned(
            width: size.width,
            child: CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(0, size.height + 5),
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.3,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                      if (widget.allowCustomInput)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _customController,
                                  style: appStyle(
                                      context,
                                      12,
                                      Theme.of(context).textTheme.bodyLarge?.color ??
                                          Colors.black,
                                      FontWeight.w400),
                                  decoration: InputDecoration(
                                    isDense: true,
                                    hintText: 'Other (type to add)…',
                                    hintStyle: appStyle(context, 12,
                                        Theme.of(context).hintColor, FontWeight.w400),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 8),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onSubmitted: (_) => _addCustomValue(),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_circle,
                                    color: Colors.green),
                                onPressed: _addCustomValue,
                              ),
                            ],
                          ),
                        ),
                      ..._combinedOptions().map((itemStr) {
                        final isSelected = localSelectedValues.contains(itemStr);
                        return InkWell(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                localSelectedValues.remove(itemStr);
                              } else {
                                localSelectedValues.add(itemStr);
                              }
                              widget.onChanged(List.from(localSelectedValues));

                              // Remove the current overlay
                              _overlayEntry?.remove();

                              // Create and insert a new overlay to reflect the changes
                              _showOverlay();
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 16,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    itemStr,
                                    style: appStyle(context, 12, Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black, FontWeight.w400),
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(
                                    Icons.check,
                                    color: Colors.green,
                                    size: 20,
                                  ),
                              ],
                            ),
                          ),
                        );
                      }),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    setState(() {
      isExpanded = true;
    });
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    isExpanded = false;
  }

  void _toggleOverlay() {
    setState(() {
      if (isExpanded) {
        _hideOverlay();
      } else {
        _showOverlay();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.textRow,
                style: appStyle(context, 14, Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black, FontWeight.w500),
              ),
              const HeightSpacer(size: 2),
              GestureDetector(
                onTap: () {
                  _toggleOverlay();
                },
                child: Container(
                  height: widget.height ?? 35,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).shadowColor.withValues(alpha:0.1),
                        spreadRadius: 2,
                        blurRadius: 4,
                      ),
                    ],
                    borderRadius: BorderRadius.circular(widget.radius ?? 30),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          localSelectedValues.isEmpty ? widget.hintText : localSelectedValues.join(', '),
                          style: appStyle(
                            context,
                            12,
                            localSelectedValues.isEmpty ? Theme.of(context).hintColor : (Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black),
                            FontWeight.w400,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(
                        Icons.arrow_drop_down,
                        color: Theme.of(context).iconTheme.color ?? Colors.grey,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
