import 'package:flutter/material.dart';
import 'package:ocurithm/modules/Patient/data/model/patients_model.dart';

import '../../../../../modules/Branch/data/model/branches_model.dart';
import '../model/booking_service.dart';
import '../util/booking_util.dart';

class BookingController extends ChangeNotifier {
  BookingService bookingService;
  Branch? branch;
  bool viewOnly;
  Patient patient;

  BookingController({required this.bookingService, this.pauseSlots, required this.branch, required this.patient, required this.viewOnly}) {
    serviceOpening = bookingService.bookingStart;
    serviceClosing = bookingService.bookingEnd;
    branch = branch;
    patient = patient;
    viewOnly = viewOnly;
    pauseSlots = pauseSlots;
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
  List<DateTime> get allBookingSlots => _allBookingSlots;

  // List<DateTimeRange> bookedSlots = [];
  List<Map<String, dynamic>> bookedSlots = [];
  List<DateTimeRange>? pauseSlots = [];

  int _selectedSlot = (-1);
  bool _isUploading = false;

  int get selectedSlot => _selectedSlot;
  bool get isUploading => _isUploading;

  bool _successfullUploaded = false;
  bool get isSuccessfullUploaded => _successfullUploaded;

  void initBack() {
    _isUploading = false;
    _successfullUploaded = false;
  }

  void selectFirstDayByHoliday(DateTime first, DateTime firstEnd) {
    serviceOpening = first;
    serviceClosing = firstEnd;
    base = first;
    _generateBookingSlots();
  }

  void _generateBookingSlots() {
    allBookingSlots.clear();
    _allBookingSlots = List.generate(_maxServiceFitInADay(), (index) => base.add(Duration(minutes: bookingService.serviceDuration) * index));
  }

  bool isWholeDayBooked() {
    bool isBooked = true;
    for (var i = 0; i < allBookingSlots.length; i++) {
      if (!isSlotBooked(i)) {
        isBooked = false;
        break;
      }
    }
    return isBooked;
  }

  int _maxServiceFitInADay() {
    ///if no serviceOpening and closing was provided we will calculate with 00:00-24:00
    int openingHours = 24;
    if (serviceOpening != null && serviceClosing != null) {
      openingHours = DateTimeRange(start: serviceOpening!, end: serviceClosing!).duration.inHours;
    }

    ///round down if not the whole service would fit in the last hours
    return ((openingHours * 60) / bookingService.serviceDuration).floor();
  }

  bool isSlotBooked(int index) {
    DateTime checkSlot = allBookingSlots.elementAt(index);
    bool result = false;
    for (var slot in bookedSlots) {
      if (BookingUtil.isOverLapping(
          slot["Time"].start, slot["Time"].end, checkSlot, checkSlot.add(Duration(minutes: bookingService.serviceDuration)))) {
        result = true;
        break;
      }
    }
    return result;
  }

  Map<String, dynamic> getBookingSlotInformation(int index) {
    DateTime checkSlot = allBookingSlots.elementAt(index);
    Map<String, dynamic> result = {};
    for (var slot in bookedSlots) {
      if (BookingUtil.isOverLapping(
          slot["Time"].start, slot["Time"].end, checkSlot, checkSlot.add(Duration(minutes: bookingService.serviceDuration)))) {
        result = slot;
        break;
      }
    }
    return result;
  }

  void selectSlot(int idx) {
    _selectedSlot = idx;
    notifyListeners();
  }

  void resetSelectedSlot() {
    _selectedSlot = -1;
    notifyListeners();
  }

  void toggleUploading() {
    _isUploading = !_isUploading;
    notifyListeners();
  }

  Future<void> generateBookedSlots(List<Map<String, dynamic>> data) async {
    bookedSlots.clear();
    _generateBookingSlots();

    for (var i = 0; i < data.length; i++) {
      final item = data[i];
      bookedSlots.add(item);
    }
  }

  BookingService generateNewBookingForUploading() {
    final bookingDate = allBookingSlots.elementAt(selectedSlot);
    bookingService
      ..bookingStart = (bookingDate)
      ..bookingEnd = (bookingDate.add(Duration(minutes: bookingService.serviceDuration)));
    return bookingService;
  }

  bool isSlotInPauseTime(DateTime slot) {
    bool result = false;
    if (pauseSlots == null) {
      return result;
    }
    for (var pauseSlot in pauseSlots!) {
      if (BookingUtil.isOverLapping(pauseSlot.start, pauseSlot.end, slot, slot.add(Duration(minutes: bookingService.serviceDuration)))) {
        result = true;
        break;
      }
    }
    return result;
  }
}
