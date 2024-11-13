import 'package:flutter/material.dart';

import '../utils/colors.dart';
import 'height_spacer.dart';

class WorkDaysSelector extends StatefulWidget {
  final Function(List<String>) onDaysSelected;
  final List? initialSelectedDays;
  final double? radius;
  final bool? isShadow;
  final bool? readOnly;
  final bool? isValid;
  final Color? border;
  final Widget? icon;

  final List? enabledDays; // New parameter for enabled days

  const WorkDaysSelector(
      {Key? key,
      required this.onDaysSelected,
      this.initialSelectedDays,
      this.enabledDays,
      this.radius,
      this.isShadow,
      this.border,
      this.readOnly = false,
      this.icon,
      this.isValid = true})
      : super(key: key);

  @override
  State<WorkDaysSelector> createState() => _WorkDaysSelectorState();
}

class _WorkDaysSelectorState extends State<WorkDaysSelector> {
  bool _isExpanded = false;
  final List<String> _daysOfWeek = ['sunday', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday'];
  List _selectedDays = [];

  @override
  void initState() {
    super.initState();
    _initializeSelectedDays();
  }

  void _initializeSelectedDays() {
    try {
      if (widget.initialSelectedDays != null) {
        // Filter initial selected days to only include enabled days if specified
        if (widget.enabledDays != null) {
          _selectedDays = widget.initialSelectedDays!.where((day) => widget.enabledDays!.contains(day.toLowerCase())).toList();
        } else {
          _selectedDays = List<String>.from(widget.initialSelectedDays!);
        }
      }
    } catch (e) {
      print("Error initializing days: $e");
      _selectedDays = [];
    }
  }

  bool _isDayEnabled(String day) {
    return widget.enabledDays?.contains(day.toLowerCase()) ?? true;
  }

  void _toggleDay(String day) {
    if (!_isDayEnabled(day)) return; // Prevent toggling disabled days

    try {
      setState(() {
        if (_selectedDays.contains(day)) {
          _selectedDays.removeWhere((selectedDay) => selectedDay == day);
        } else {
          _selectedDays.add(day);
        }
        widget.onDaysSelected(List<String>.from(_selectedDays));
      });
    } catch (e) {
      print("Error toggling day: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(widget.radius ?? 8),
            border: Border.all(color: widget.isValid == false ? Colors.red : widget.border ?? Colors.grey),
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: widget.readOnly == false ? () => setState(() => _isExpanded = !_isExpanded) : null,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        color: Colors.grey,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Work Days',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (!_isExpanded)
                              Text(
                                _getSelectedDaysPreview(),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                      AnimatedRotation(
                        turns: _isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 300),
                        child: widget.icon ??
                            Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.grey.shade600,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              AnimatedCrossFade(
                firstChild: const SizedBox(height: 0),
                secondChild: _buildDaysGrid(),
                crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 300),
              ),
            ],
          ),
        ),
        if (widget.isValid == false)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const HeightSpacer(
                  size: 10,
                ),
                Text(
                  "Must Select Work Days",
                  style: TextStyle(fontSize: 12, color: Colors.red.shade700, fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildDaysGrid() {
    return Column(
      children: [
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: _daysOfWeek.map((day) => _buildDayItem(day)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildDayItem(String day) {
    bool isSelected = _selectedDays.contains(day);
    bool isEnabled = _isDayEnabled(day);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isEnabled ? () => _toggleDay(day) : null,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          width: 140,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? Colorz.primaryColor.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isEnabled ? (isSelected ? Colorz.primaryColor : Colors.grey.shade300) : Colors.grey.shade200,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: isSelected,
                  onChanged: isEnabled ? (bool? value) => _toggleDay(day) : null,
                  activeColor: Colorz.primaryColor,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                day.substring(0, 3).toUpperCase(),
                style: TextStyle(
                  fontSize: 14,
                  color: isEnabled ? (isSelected ? Colorz.primaryColor : Colors.black87) : Colors.grey.shade400,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getSelectedDaysPreview() {
    if (_selectedDays.isEmpty) {
      return 'No days selected';
    } else if (_selectedDays.length == _daysOfWeek.length) {
      return 'All days';
    } else {
      return _selectedDays.map((day) => day.substring(0, 3).toUpperCase()).join(', ');
    }
  }
}
