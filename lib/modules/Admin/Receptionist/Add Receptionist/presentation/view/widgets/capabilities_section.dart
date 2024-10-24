import 'package:flutter/material.dart';

import '../../../../../../../core/utils/colors.dart';

class CustomCheckbox extends StatelessWidget {
  final bool isSelected;
  final ValueChanged<bool> onChanged;

  const CustomCheckbox({
    Key? key,
    required this.isSelected,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!isSelected),
      child: Container(
        width: 25,
        height: 25,
        decoration: BoxDecoration(
          color: isSelected ? Colors.green.shade600 : Colors.transparent,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: isSelected ? Colors.green.shade600 : Colors.grey,
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

class Capability {
  final String id;
  final String name;
  bool isSelected;

  Capability({
    required this.id,
    required this.name,
    this.isSelected = false,
  });
}

class CapabilitiesSection extends StatefulWidget {
  final List<Capability> capabilities;
  final Function(List<Capability>) onSelectionChanged;

  const CapabilitiesSection({
    Key? key,
    required this.capabilities,
    required this.onSelectionChanged,
  }) : super(key: key);

  @override
  State<CapabilitiesSection> createState() => _CapabilitiesSectionState();
}

class _CapabilitiesSectionState extends State<CapabilitiesSection> with SingleTickerProviderStateMixin {
  late List<Capability> _capabilities;
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _capabilities = widget.capabilities;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
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

  void _toggleSelection(int index) {
    setState(() {
      _capabilities[index].isSelected = !_capabilities[index].isSelected;
      widget.onSelectionChanged(_capabilities);
    });
  }

  void _selectAll(bool value) {
    setState(() {
      for (var capability in _capabilities) {
        capability.isSelected = value;
      }
      widget.onSelectionChanged(_capabilities);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_isExpanded ? 8 : 30),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: _toggleExpand,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.category, color: Colors.grey),
                      const SizedBox(width: 16),
                      Text(
                        'Capabilities',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  AnimatedRotation(
                      duration: const Duration(milliseconds: 300),
                      turns: _isExpanded ? 0.5 : 0,
                      child: Icon(
                        Icons.arrow_drop_down_circle,
                        color: Colorz.blue,
                      )),
                ],
              ),
            ),
          ),

          // Expandable Content
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: Column(
              children: [
                const Divider(height: 1),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: _capabilities.length,
                  itemBuilder: (context, index) {
                    final capability = _capabilities[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: InkWell(
                        onTap: () => _toggleSelection(index),
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              CustomCheckbox(
                                isSelected: capability.isSelected,
                                onChanged: (_) => _toggleSelection(index),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  capability.name,
                                  style: const TextStyle(fontSize: 16),
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

// Example Usage
class ExampleScreen extends StatelessWidget {
  ExampleScreen({Key? key}) : super(key: key);

  final List<Capability> capabilities = [
    Capability(id: '1', name: 'Programming'),
    Capability(id: '2', name: 'Design'),
    Capability(id: '3', name: 'Project Management'),
    Capability(id: '4', name: 'Communication'),
    Capability(id: '5', name: 'Problem Solving'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Capabilities Example'),
      ),
      body: CapabilitiesSection(
        capabilities: capabilities,
        onSelectionChanged: (updatedCapabilities) {
          // Handle the updated selections
          print('Selected capabilities: ${updatedCapabilities.where((c) => c.isSelected).map((c) => c.name).toList()}');
        },
      ),
    );
  }
}
