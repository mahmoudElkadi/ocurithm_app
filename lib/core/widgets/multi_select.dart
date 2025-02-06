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

  const CustomMultiSelectDropdown({
    Key? key,
    required this.items,
    required this.textRow,
    this.hintText = '',
    required this.selectedValues,
    required this.onChanged,
    this.radius,
    this.height,
  }) : super(key: key);

  @override
  State<CustomMultiSelectDropdown> createState() => _CustomMultiSelectDropdownState();
}

class _CustomMultiSelectDropdownState extends State<CustomMultiSelectDropdown> {
  final LayerLink _layerLink = LayerLink();
  bool isExpanded = false;
  late List<dynamic> localSelectedValues;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    localSelectedValues = List.from(widget.selectedValues);
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
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
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.3,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: widget.items.map((item) {
                        final itemStr = item.toString();
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
                                    style: appStyle(context, 12, Colors.black, FontWeight.w400),
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
                      }).toList(),
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
                style: appStyle(context, 14, Colors.black, FontWeight.w500),
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
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade200,
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
                            localSelectedValues.isEmpty ? Colors.grey : Colors.black,
                            FontWeight.w400,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(
                        Icons.arrow_drop_down,
                        color: Colors.grey,
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
