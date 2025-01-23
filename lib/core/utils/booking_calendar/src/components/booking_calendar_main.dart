import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocurithm/modules/Patient/data/model/patients_model.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../../modules/Appointment/data/models/appointment_model.dart';
import '../../../../../modules/Branch/data/model/branches_model.dart';
import '../../../../../modules/Doctor/data/model/doctor_model.dart';
import '../core/booking_controller.dart';
import '../model/booking_service.dart';
import '../model/enums.dart' as bc;
import '../util/booking_util.dart';
import 'booking_explanation.dart';
import 'booking_slot.dart';
import 'common_card.dart';

enum WeekDay { monday, tuesday, wednesday, thursday, friday, saturday, sunday }

// Extension to convert string to WeekDay
extension WeekDayExtension on String {
  WeekDay toWeekDay() {
    return WeekDay.values.firstWhere(
      (e) => e.toString().split('.').last.toLowerCase() == this.toLowerCase(),
      orElse: () => WeekDay.monday,
    );
  }
}

// Extension to convert WeekDay to int (1-7)
extension WeekDayToInt on WeekDay {
  int toDayNumber() {
    switch (this) {
      case WeekDay.monday:
        return DateTime.monday;
      case WeekDay.tuesday:
        return DateTime.tuesday;
      case WeekDay.wednesday:
        return DateTime.wednesday;
      case WeekDay.thursday:
        return DateTime.thursday;
      case WeekDay.friday:
        return DateTime.friday;
      case WeekDay.saturday:
        return DateTime.saturday;
      case WeekDay.sunday:
        return DateTime.sunday;
      default:
        return DateTime.monday;
    }
  }
}

class BookingCalendarMain extends StatefulWidget {
  BookingCalendarMain({
    Key? key,
    required this.getBookingStream,
    required this.convertStreamResultToDateTimeRanges,
    required this.uploadBooking,
    this.bookingExplanation,
    this.bookingGridCrossAxisCount,
    this.bookingGridChildAspectRatio,
    this.formatDateTime,
    this.bookingButtonText,
    this.bookingButtonColor,
    this.bookedSlotColor,
    this.selectedSlotColor,
    this.availableSlotColor,
    this.bookedSlotText,
    this.bookedSlotTextStyle,
    this.selectedSlotText,
    this.selectedSlotTextStyle,
    this.availableSlotText,
    this.availableSlotTextStyle,
    this.gridScrollPhysics,
    this.loadingWidget,
    this.errorWidget,
    this.uploadingWidget,
    this.wholeDayIsBookedWidget,
    this.pauseSlotColor,
    this.pauseSlotText,
    this.hideBreakTime = false,
    this.locale,
    this.startingDayOfWeek,
    this.disabledDays,
    this.disabledDates,
    this.lastDay,
    this.branch,
    this.doctor,
    this.actionButton,
    required this.viewOnly,
    required this.patient,
    this.appointment,
    this.onDateSelected,
    this.holidayWeekdays = const [],
    this.isUpdate = false,
    this.selectedDate,
  }) : super(key: key);

  final Stream<dynamic>? Function({required DateTime start, required DateTime end, required String branch}) getBookingStream;
  final Future<dynamic> Function(
      {required BookingService newBooking, required Patient patient, required String branch, required String examinationType}) uploadBooking;
  // final List<DateTimeRange> Function({required dynamic streamResult})
  //     convertStreamResultToDateTimeRanges;
  final List<Map<String, dynamic>> Function({required dynamic streamResult}) convertStreamResultToDateTimeRanges;

  ///Customizable
  final Appointment? appointment;

  final Function(DateTime)? onDateSelected;
  final Widget? bookingExplanation;
  final int? bookingGridCrossAxisCount;
  final double? bookingGridChildAspectRatio;
  final String Function(DateTime dt)? formatDateTime;
  final String? bookingButtonText;
  final Color? bookingButtonColor;
  final Color? bookedSlotColor;
  final Color? selectedSlotColor;
  final Color? availableSlotColor;
  final Color? pauseSlotColor;
  final List<String> holidayWeekdays;
  final DateTime? selectedDate;
  final Widget? actionButton;
//Added optional TextStyle to available, booked and selected cards.
  final String? bookedSlotText;
  final String? selectedSlotText;
  final String? availableSlotText;
  final String? pauseSlotText;
  final bool? isUpdate;

  final TextStyle? bookedSlotTextStyle;
  final TextStyle? availableSlotTextStyle;
  final TextStyle? selectedSlotTextStyle;

  final ScrollPhysics? gridScrollPhysics;
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final Widget? uploadingWidget;

  final bool? hideBreakTime;
  final DateTime? lastDay;
  final String? locale;
  final bc.StartingDayOfWeek? startingDayOfWeek;
  final List<int>? disabledDays;
  final List<DateTime>? disabledDates;
  final Branch? branch;
  final Doctor? doctor;
  final bool viewOnly;
  final Patient patient;

  final Widget? wholeDayIsBookedWidget;

  @override
  State<BookingCalendarMain> createState() => _BookingCalendarMainState();
}

class _BookingCalendarMainState extends State<BookingCalendarMain> {
  final now = DateTime.now();
  late BookingService bookingService;
  late StreamController<dynamic> _controller;
  Timer? _pollingTimer;
  bool _disposed = false;
  late List<int> _holidayWeekdayNumbers;
  late DateTime _selectedDay;
  late DateTime _focusedDay;
  late DateTime startOfDay;
  late DateTime endOfDay;
  late String? branch;
  CalendarFormat _calendarFormat = CalendarFormat.twoWeeks;
  List<dynamic> appointments = [];
  bool isFirst = true;
  late BookingController controller;
  bool _dataFetched = false;
  @override
  void initState() {
    super.initState();
    controller = context.read<BookingController>();

    // Initialize holidays
    _initializeHolidayWeeks();

    // Get initial date
    DateTime initialDate = DateTime.now();
    if (_isWeeklyOff(initialDate)) {
      initialDate = findNearestNonHolidayDate(initialDate);
    }

    _selectedDay = initialDate;
    _focusedDay = initialDate;

    startOfDay = _selectedDay.startOfDayService(controller.serviceOpening!);
    endOfDay = _selectedDay.endOfDayService(controller.serviceClosing!);
    branch = widget.branch?.id;

    // Initialize BookingService

    // Initialize stream controller
    _controller = StreamController<dynamic>.broadcast();
    if (!_dataFetched) {
      selectNewDateRange();
      _dataFetched = true;
    }
  }

  void _initializeHolidayWeeks() {
    _holidayWeekdayNumbers = widget.holidayWeekdays.map((day) => day.toWeekDay().toDayNumber()).toList();
  }

  void selectNewDateRange() {
    startOfDay = _selectedDay.startOfDayService(controller.serviceOpening!);
    endOfDay = _selectedDay.endOfDayService(controller.serviceClosing!);

    // Update selected date in controller

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.updateSelectedDate(_selectedDay);

      controller.updateBookedSlots([]);

      fetchAppointmentsAndUpdateSlots();
    });
  }

  // Update calendar day selection handler
  void onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      if (_isWeeklyOff(selectedDay)) {
        final nearestNonHolidayDate = findNearestNonHolidayDate(selectedDay);
        setState(() {
          _selectedDay = nearestNonHolidayDate;
          _focusedDay = nearestNonHolidayDate;
        });
      } else {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
      }
      selectNewDateRange();
    }
  }

  void fetchAppointmentsAndUpdateSlots() async {
    try {
      final stream = widget.getBookingStream(start: startOfDay, end: endOfDay, branch: branch ?? "");

      if (stream == null) return;

      // Listen to the stream once
      await for (final data in stream) {
        if (!mounted) break;

        final convertedData = widget.convertStreamResultToDateTimeRanges(streamResult: data);

        // Update controller with new data

        if (mounted && controller.bookedSlots != convertedData) {
          controller.updateBookedSlots(convertedData);
          // Break after first update since we don't need continuous updates
          break;
        }
      }
    } catch (e) {
      print('Error updating slots: $e');
    }
  }

  DateTime findNearestNonHolidayDate(DateTime date) {
    DateTime checkDate = date;
    for (int i = 0; i < 30; i++) {
      if (!_isWeeklyOff(checkDate)) {
        return checkDate;
      }
      checkDate = checkDate.add(const Duration(days: 1));
    }
    return date;
  }

  bool _isWeeklyOff(DateTime date) {
    return _holidayWeekdayNumbers.contains(date.weekday) || (widget.disabledDates?.any((d) => isSameDay(d, date)) ?? false);
  }

  bool _isDateSelectable(DateTime date) {
    if (date.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
      return false;
    }
    return !_isWeeklyOff(date);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          CommonCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            child: TableCalendar(
              startingDayOfWeek: StartingDayOfWeek.monday,
              firstDay: DateTime.now(),
              lastDay: widget.lastDay ?? DateTime.now().add(const Duration(days: 365)),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              enabledDayPredicate: _isDateSelectable,
              calendarStyle: CalendarStyle(
                disabledTextStyle: const TextStyle(color: Colors.red),
                selectedDecoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                ),
              ),
              onFormatChanged: (format) {
                if (_calendarFormat != format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                }
              },
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
              onDaySelected: (selectedDay, focusedDay) {
                if (!isSameDay(_selectedDay, selectedDay)) {
                  if (_isWeeklyOff(selectedDay)) {
                    final nearestNonHolidayDate = findNearestNonHolidayDate(selectedDay);
                    setState(() {
                      _selectedDay = nearestNonHolidayDate;
                      _focusedDay = nearestNonHolidayDate;
                    });
                  } else {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  }
                  selectNewDateRange();
                }
              },
            ),
          ),
          const SizedBox(height: 15),
          widget.bookingExplanation ??
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                spacing: 12,
                runSpacing: 12,
                direction: Axis.horizontal,
                children: [
                  BookingExplanation(color: widget.availableSlotColor ?? Colors.greenAccent, text: widget.availableSlotText ?? 'Available'),
                  BookingExplanation(color: widget.selectedSlotColor ?? Colors.orangeAccent, text: widget.selectedSlotText ?? 'Selected'),
                  BookingExplanation(color: widget.bookedSlotColor ?? Colors.redAccent, text: widget.bookedSlotText ?? 'Booked'),
                ],
              ),
          const SizedBox(height: 8),
          StreamBuilder<dynamic>(
            stream: widget.getBookingStream(start: startOfDay, end: endOfDay, branch: branch ?? ""),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return widget.errorWidget ?? Center(child: Text(snapshot.error.toString()));
              }

              if (!snapshot.hasData) {
                return widget.loadingWidget ?? const Center(child: CircularProgressIndicator());
              }

              final data = snapshot.requireData;
              final convertedData = widget.convertStreamResultToDateTimeRanges(streamResult: data);

              Future.microtask(() {
                if (mounted && controller.bookedSlots != convertedData) {
                  controller.updateBookedSlots(convertedData);
                }
              });

              return Expanded(
                child: (widget.wholeDayIsBookedWidget != null && controller.isWholeDayBooked())
                    ? widget.wholeDayIsBookedWidget!
                    : GridView.builder(
                        physics: widget.gridScrollPhysics ?? const BouncingScrollPhysics(),
                        itemCount: controller.allBookingSlots.length,
                        itemBuilder: (context, index) {
                          return _buildBookingSlot(controller, index);
                        },
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: widget.bookingGridCrossAxisCount ?? 3,
                          childAspectRatio: widget.bookingGridChildAspectRatio ?? 2.1,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 10,
                        ),
                      ),
              );
            },
          ),
          if (!widget.viewOnly) ...[
            const SizedBox(height: 10),
            widget.actionButton ?? SizedBox.shrink(),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }

  Widget _buildBookingSlot(BookingController controller, int index) {
    TextStyle? getTextStyle() {
      if (controller.isSlotBooked(index)) {
        return widget.bookedSlotTextStyle;
      } else if (index == controller.selectedSlot) {
        return widget.selectedSlotTextStyle;
      }
      return widget.availableSlotTextStyle;
    }

    final slot = controller.allBookingSlots.elementAt(index);
    return BookingSlot(
      hideBreakSlot: widget.hideBreakTime,
      pauseSlotColor: widget.pauseSlotColor,
      availableSlotColor: widget.availableSlotColor,
      bookedSlotColor: widget.bookedSlotColor,
      selectedSlotColor: widget.selectedSlotColor,
      isPauseTime: controller.isSlotInPauseTime(slot),
      isBooked: controller.isSlotBooked(index),
      isSelected: index == controller.selectedSlot,
      onTap: () {
        log("Slot: $slot");
        log("Slot: $index");
        _handleSlotTap(controller, index, slot);
      },
      child: Center(
        child: Text(
          widget.formatDateTime?.call(slot) ?? BookingUtil.formatDateTime(slot),
          style: getTextStyle(),
        ),
      ),
    );
  }

  void _handleSlotTap(BookingController controller, int index, DateTime slot) {
    // If in view only mode, only show details for booked slots
    if (widget.viewOnly) {
      if (controller.isSlotBooked(index)) {
        //     widget.showAppointmentDetails?.call(controller.getBookingSlotInformation(index));
      }
      return;
    }

    // For non-view mode
    if (controller.isSlotBooked(index)) {
      // Show details for booked slots
      //    widget.showAppointmentDetails?.call(controller.getBookingSlotInformation(index));
    } else {
      // Allow selecting and changing selection for available slots
      controller.selectSlot(index);
      if (widget.onDateSelected != null) {
        if (controller.selectedSlot != -1) {
          widget.onDateSelected!(controller.allBookingSlots[controller.selectedSlot]);
        }
      }
      setState(() {});
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _controller.close();
    _pollingTimer?.cancel();
    super.dispose();
  }
}
