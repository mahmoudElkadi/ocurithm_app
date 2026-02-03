import 'package:flutter/material.dart';

import '../utils/snackbar_service.dart';
import 'height_spacer.dart';

class BusinessHoursSelector extends StatefulWidget {
  final TimeOfDay? initialOpenTime;
  final TimeOfDay? initialCloseTime;
  final Function(TimeOfDay, TimeOfDay) onTimeRangeSelected;
  final double? radius;
  final bool? isShadow;
  final Color? border;
  final bool use24HourFormat;
  final bool readOnly;
  final TimeOfDay? startEnabledTime; // New parameter for start of enabled range
  final TimeOfDay? endEnabledTime;
  final Widget? icon;
  final bool? isValid;

  const BusinessHoursSelector({
    super.key,
    this.initialOpenTime,
    this.initialCloseTime,
    required this.onTimeRangeSelected,
    this.radius,
    this.isShadow,
    this.border,
    this.use24HourFormat = true,
    this.readOnly = false,
    this.startEnabledTime,
    this.endEnabledTime,
    this.icon,
    this.isValid = true,
  });

  @override
  State<BusinessHoursSelector> createState() => _BusinessHoursSelectorState();
}

class _BusinessHoursSelectorState extends State<BusinessHoursSelector> {
  bool _isExpanded = false;
  late TimeOfDay _openTime;
  late TimeOfDay _closeTime;

  @override
  void initState() {
    super.initState();
    _openTime = widget.initialOpenTime ?? const TimeOfDay(hour: 8, minute: 0);
    _closeTime =
        widget.initialCloseTime ?? const TimeOfDay(hour: 18, minute: 0);
  }

  bool _isTimeInRange(TimeOfDay time) {
    if (widget.startEnabledTime == null || widget.endEnabledTime == null)
      return true;

    int timeInMinutes = time.hour * 60 + time.minute;
    int startInMinutes =
        widget.startEnabledTime!.hour * 60 + widget.startEnabledTime!.minute;
    int endInMinutes =
        widget.endEnabledTime!.hour * 60 + widget.endEnabledTime!.minute;

    return timeInMinutes >= startInMinutes && timeInMinutes <= endInMinutes;
  }

  Future<void> _selectTime(BuildContext context, bool isOpenTime) async {
    final currentTime = isOpenTime ? _openTime : _closeTime;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: currentTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Theme.of(context).cardColor,
              hourMinuteShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side:
                    BorderSide(color: Theme.of(context).primaryColor, width: 1),
              ),
              hourMinuteColor: Theme.of(context).primaryColor.withValues(alpha:0.1),
              hourMinuteTextStyle: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 58,
                fontWeight: FontWeight.w800,
              ),
              timeSelectorSeparatorColor: WidgetStateProperty.all(
                isDark ? Colors.white : Colors.black,
              ),
              hourMinuteTextColor: Theme.of(context).primaryColor,
              dayPeriodColor: Theme.of(context).primaryColor.withValues(alpha:0.1),
              dialHandColor: Theme.of(context).primaryColor,
              dayPeriodTextColor: Theme.of(context).primaryColor,
              cancelButtonStyle: TextButton.styleFrom(
                foregroundColor: Theme.of(context).primaryColor,
              ),
              confirmButtonStyle: TextButton.styleFrom(
                foregroundColor: Theme.of(context).primaryColor,
              ),
              dayPeriodShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side:
                    BorderSide(color: Theme.of(context).primaryColor, width: 1),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      if (!_isTimeInRange(picked)) {
        SnackbarService.showError(
          context,
          message: 'Please select a time between ${_formatTime(widget.startEnabledTime!)} and ${_formatTime(widget.endEnabledTime!)}',
        );
        return;
      }

      // For opening time, ensure it's not after closing time
      if (isOpenTime) {
        int pickedMinutes = picked.hour * 60 + picked.minute;
        int closeMinutes = _closeTime.hour * 60 + _closeTime.minute;
        if (pickedMinutes >= closeMinutes) {
          SnackbarService.showError(
            context,
            message: 'Opening time must be before closing time',
          );
          return;
        }
      }
      // For closing time, ensure it's not before opening time
      else {
        int pickedMinutes = picked.hour * 60 + picked.minute;
        int openMinutes = _openTime.hour * 60 + _openTime.minute;
        if (pickedMinutes <= openMinutes) {
          SnackbarService.showError(
            context,
            message: 'Closing time must be after opening time',
          );
          return;
        }
      }

      setState(() {
        if (isOpenTime) {
          _openTime = picked;
        } else {
          _closeTime = picked;
        }
        widget.onTimeRangeSelected(_openTime, _closeTime);
        WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
      });
    }
  }

  String _formatTimeRange() {
    return '${_formatTime(_openTime)} - ${_formatTime(_closeTime)}';
  }

  String _formatTime(TimeOfDay time) {
    if (widget.use24HourFormat) {
      final hour = time.hour.toString().padLeft(2, '0');
      final minute = time.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    } else {
      final hour = time.hour == 0
          ? 12
          : time.hour > 12
              ? time.hour - 12
              : time.hour;
      final minute = time.minute.toString().padLeft(2, '0');
      final period = time.period == DayPeriod.am ? 'AM' : 'PM';
      return '$hour:$minute $period';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(widget.radius ?? 8),
            border: Border.all(
              color: widget.isValid == false
                  ? Colors.red
                  : widget.border ??
                      (isDark ? Colors.grey.shade700 : Colors.grey),
            ),
            boxShadow: widget.isShadow == true
                ? [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withValues(alpha:0.3)
                          : Colors.black.withValues(alpha:0.1),
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
                onTap: widget.readOnly == false
                    ? () => setState(() => _isExpanded = !_isExpanded)
                    : null,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        color: isDark ? Colors.grey.shade400 : Colors.grey,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Business Hours',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color,
                              ),
                            ),
                            if (!_isExpanded)
                              Text(
                                _formatTimeRange(),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? Colors.grey.shade400
                                      : Colors.grey.shade600,
                                ),
                              ),
                            if (widget.startEnabledTime != null &&
                                widget.endEnabledTime != null)
                              Text(
                                'Allowed: ${_formatTime(widget.startEnabledTime!)} - ${_formatTime(widget.endEnabledTime!)}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isDark
                                      ? Colors.grey.shade500
                                      : Colors.grey.shade500,
                                  fontStyle: FontStyle.italic,
                                ),
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
                              color: isDark
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade600,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              AnimatedCrossFade(
                firstChild: const SizedBox(height: 0),
                secondChild: Column(
                  children: [
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          _buildTimeSelector(
                            title: 'Opening Time',
                            time: _openTime,
                            onTap: widget.readOnly
                                ? null
                                : () => _selectTime(context, true),
                            icon: Icons.wb_sunny_outlined,
                          ),
                          const SizedBox(height: 12),
                          _buildTimeSelector(
                            title: 'Closing Time',
                            time: _closeTime,
                            onTap: widget.readOnly
                                ? null
                                : () => _selectTime(context, false),
                            icon: Icons.nightlight_outlined,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                crossFadeState: _isExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
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
                  "Must Select Time Range",
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildTimeSelector({
    required String title,
    required TimeOfDay time,
    required VoidCallback? onTap,
    required IconData icon,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color:
                          isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatTime(time),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.access_time_rounded,
              size: 16,
              color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}
