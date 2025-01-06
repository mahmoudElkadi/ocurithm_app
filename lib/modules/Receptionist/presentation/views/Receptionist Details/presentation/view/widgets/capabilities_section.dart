import 'package:flutter/material.dart';

import '../../../../../../../../../core/utils/colors.dart';
import '../../../../../../../Login/data/model/login_response.dart';

class CustomCheckbox extends StatelessWidget {
  final bool isSelected;
  final ValueChanged<bool>? onChanged;

  const CustomCheckbox({
    Key? key,
    required this.isSelected,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onChanged != null ? () => onChanged!(!isSelected) : null,
      child: Container(
        width: 25,
        height: 25,
        decoration: BoxDecoration(
          color: isSelected ? Colorz.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: isSelected ? Colorz.primaryColor : Colors.grey,
          ),
        ),
        child: isSelected
            ? const Icon(
                Icons.check,
                size: 19,
                color: Colors.white,
              )
            : null,
      ),
    );
  }
}


class CapabilitiesSection extends StatefulWidget {
  final List<Capability> capabilities;
  final List<Capability> initialSelectedCapabilities;
  final Function(List<Capability>) onSelectionChanged;
  final bool? readOnly;

  const CapabilitiesSection({
    Key? key,
    required this.capabilities,
    required this.initialSelectedCapabilities,
    required this.onSelectionChanged,
    this.readOnly = false,
  }) : super(key: key);

  @override
  State<CapabilitiesSection> createState() => _CapabilitiesSectionState();
}

class _CapabilitiesSectionState extends State<CapabilitiesSection>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;
  late Set<Capability> _selectedCapabilities;

  @override
  void initState() {
    super.initState();
    // Initialize selected capabilities with a proper Set
    _selectedCapabilities = _initializeSelectedCapabilities();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  Set<Capability> _initializeSelectedCapabilities() {
    // Create a Set of selected capabilities by matching with available capabilities
    final initialSet = <Capability>{};
    for (final initial in widget.initialSelectedCapabilities) {
      // Find matching capability from available capabilities
      final matchingCapability = widget.capabilities.firstWhere(
            (cap) => cap.name == initial.name && cap.id == initial.id,
        orElse: () => initial,
      );
      initialSet.add(matchingCapability);
    }
    return initialSet;
  }

  @override
  void didUpdateWidget(CapabilitiesSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_areListsEqual(widget.initialSelectedCapabilities, oldWidget.initialSelectedCapabilities)) {
      setState(() {
        _selectedCapabilities = _initializeSelectedCapabilities();
      });
    }
  }

  bool _areListsEqual(List<Capability> list1, List<Capability> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    return true;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _toggleSelection(Capability capability) {
    if (widget.readOnly == true) return;

    setState(() {
      if (_isSelected(capability)) {
        _selectedCapabilities.removeWhere((cap) =>
        cap.name == capability.name && cap.id == capability.id);
      } else {
        // Add the exact instance from capabilities list
        _selectedCapabilities.add(capability);
      }
      widget.onSelectionChanged(_selectedCapabilities.toList());
    });
  }

  bool _isSelected(Capability capability) {
    return _selectedCapabilities.any((selected) =>
    selected.name == capability.name && selected.id == capability.id);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_isExpanded ? 8 : 30),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          InkWell(
            onTap: _toggleExpand,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.category, color: Colors.black),
                      SizedBox(width: 16),
                      Text(
                        'Capabilities',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  AnimatedRotation(
                    duration: const Duration(milliseconds: 300),
                    turns: _isExpanded ? 0.5 : 0,
                    child: const Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Expandable Content
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Divider(height: 1),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: widget.capabilities.length,
                  itemBuilder: (context, index) {
                    final capability = widget.capabilities[index];
                    final isSelected = _isSelected(capability);

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: InkWell(
                        onTap: widget.readOnly == true
                            ? null
                            : () => _toggleSelection(capability),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: isSelected
                                ? Colors.blue.withOpacity(0.1)
                                : Colors.transparent,
                          ),
                          child: Row(
                            children: [
                              CustomCheckbox(
                                isSelected: isSelected,
                                onChanged: widget.readOnly == true
                                    ? null
                                    : (_) => _toggleSelection(capability),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  capability.name ?? "",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}  
