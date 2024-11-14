import 'package:flutter/material.dart';
import 'package:ocurithm/modules/Patient/data/model/patients_model.dart';

import '../../../../../modules/Branch/data/model/branches_model.dart';
import '../model/booking_service.dart';

class BookingController extends ChangeNotifier {
  BookingService bookingService;
  Branch? branch;
  bool viewOnly;
  Patient patient;
  DateTime? selectedDate;

  BookingController({
    required this.bookingService,
    this.pauseSlots,
    required this.branch,
    required this.patient,
    required this.viewOnly,
  }) {
    serviceOpening = bookingService.bookingStart;
    serviceClosing = bookingService.bookingEnd;
    selectedDate = DateTime.now();

    if (serviceOpening!.isAfter(serviceClosing!)) {
      throw "Service closing must be after opening";
    }
    base = serviceOpening!;
    _generateBookingSlots();
  }

  late DateTime base;
  DateTime? serviceOpening;
  DateTime? serviceClosing;
  List<DateTime> _allBookingSlots = [];
  List<Map<String, dynamic>> bookedSlots = [];
  List<DateTimeRange>? pauseSlots = [];
  int _selectedSlot = -1;
  bool _isUploading = false;

  List<DateTime> get allBookingSlots => _allBookingSlots;
  int get selectedSlot => _selectedSlot;
  bool get isUploading => _isUploading;

  void updateSelectedDate(DateTime date) {
    selectedDate = date;
    _generateBookingSlots();
    resetSelectedSlot();
    notifyListeners();
  }

  void _generateBookingSlots() {
    _allBookingSlots.clear();

    if (serviceOpening == null || serviceClosing == null || selectedDate == null) return;

    // Create datetime for selected date with service hours
    DateTime dayStart = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      serviceOpening!.hour,
      serviceOpening!.minute,
    );

    DateTime dayEnd = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      serviceClosing!.hour,
      serviceClosing!.minute,
    );

    // Sort booked slots by start time
    bookedSlots.sort((a, b) => (a['Time'] as DateTimeRange).start.compareTo((b['Time'] as DateTimeRange).start));

    DateTime currentTime = dayStart;
    final serviceDuration = Duration(minutes: bookingService.serviceDuration);

    while (currentTime.add(serviceDuration).isBefore(dayEnd) || currentTime.add(serviceDuration).isAtSameMomentAs(dayEnd)) {
      bool isValidSlot = true;
      DateTime slotEnd = currentTime.add(serviceDuration);

      // Check against booked slots
      for (var bookedSlot in bookedSlots) {
        DateTimeRange bookedRange = bookedSlot['Time'];

        DateTime normalizedBookedStart = DateTime(
          selectedDate!.year,
          selectedDate!.month,
          selectedDate!.day,
          bookedRange.start.hour,
          bookedRange.start.minute,
        );

        DateTime normalizedBookedEnd = DateTime(
          selectedDate!.year,
          selectedDate!.month,
          selectedDate!.day,
          bookedRange.end.hour,
          bookedRange.end.minute,
        );

        if (_isOverlapping(currentTime, slotEnd, normalizedBookedStart, normalizedBookedEnd)) {
          isValidSlot = false;
          currentTime = normalizedBookedEnd;
          break;
        }
      }

      if (isValidSlot) {
        _allBookingSlots.add(currentTime);
        currentTime = currentTime.add(serviceDuration);
      }
    }

    if (_selectedSlot >= _allBookingSlots.length) {
      _selectedSlot = -1;
    }
  }

  bool _isOverlapping(DateTime start1, DateTime end1, DateTime start2, DateTime end2) {
    return start1.isBefore(end2) && end1.isAfter(start2);
  }

  bool isSlotBooked(int index) {
    if (index >= _allBookingSlots.length) return false;

    DateTime slotStart = _allBookingSlots[index];
    DateTime slotEnd = slotStart.add(Duration(minutes: bookingService.serviceDuration));

    for (var bookedSlot in bookedSlots) {
      DateTimeRange bookedRange = bookedSlot['Time'];

      DateTime normalizedBookedStart = DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
        bookedRange.start.hour,
        bookedRange.start.minute,
      );

      DateTime normalizedBookedEnd = DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
        bookedRange.end.hour,
        bookedRange.end.minute,
      );

      if (_isOverlapping(slotStart, slotEnd, normalizedBookedStart, normalizedBookedEnd)) {
        return true;
      }
    }
    return false;
  }

  void updateBookedSlots(List<Map<String, dynamic>> newData) {
    bookedSlots = newData;
    _generateBookingSlots();
    notifyListeners();
  }

  void selectSlot(int idx) {
    // If clicking the same slot again, deselect it
    if (idx == _selectedSlot) {
      _selectedSlot = -1;
      notifyListeners();
      return;
    }

    // Allow selecting a new slot if it's not booked and not in view only mode
    if (!viewOnly && idx >= 0 && idx < _allBookingSlots.length && !isSlotBooked(idx)) {
      _selectedSlot = idx;
      notifyListeners();
    }
  }

  Map<String, dynamic> getBookingSlotInformation(int index) {
    if (index >= _allBookingSlots.length) return {};

    DateTime slotStart = _allBookingSlots[index];
    DateTime slotEnd = slotStart.add(Duration(minutes: bookingService.serviceDuration));

    for (var slot in bookedSlots) {
      DateTimeRange bookedRange = slot['Time'];

      DateTime normalizedBookedStart = DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
        bookedRange.start.hour,
        bookedRange.start.minute,
      );

      DateTime normalizedBookedEnd = DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
        bookedRange.end.hour,
        bookedRange.end.minute,
      );

      if (_isOverlapping(slotStart, slotEnd, normalizedBookedStart, normalizedBookedEnd)) {
        return slot;
      }
    }
    return {};
  }

  bool isSlotInPauseTime(DateTime slot) {
    if (pauseSlots == null) return false;
    DateTime slotEnd = slot.add(Duration(minutes: bookingService.serviceDuration));

    for (var pauseSlot in pauseSlots!) {
      DateTime normalizedPauseStart = DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
        pauseSlot.start.hour,
        pauseSlot.start.minute,
      );

      DateTime normalizedPauseEnd = DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
        pauseSlot.end.hour,
        pauseSlot.end.minute,
      );

      if (_isOverlapping(slot, slotEnd, normalizedPauseStart, normalizedPauseEnd)) {
        return true;
      }
    }
    return false;
  }

  void selectFirstDayByHoliday(DateTime first, DateTime firstEnd) {
    serviceOpening = first;
    serviceClosing = firstEnd;
    base = first;
    selectedDate = first;
    _generateBookingSlots();
    notifyListeners();
  }

  void resetSelectedSlot() {
    _selectedSlot = -1;
    notifyListeners();
  }

  bool isWholeDayBooked() {
    return _allBookingSlots.isEmpty;
  }

  BookingService generateNewBookingForUploading() {
    if (_selectedSlot >= 0 && _selectedSlot < _allBookingSlots.length) {
      final bookingDate = _allBookingSlots[_selectedSlot];
      bookingService
        ..bookingStart = bookingDate
        ..bookingEnd = bookingDate.add(Duration(minutes: bookingService.serviceDuration));
    }
    return bookingService;
  }
}
