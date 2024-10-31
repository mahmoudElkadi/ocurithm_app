import 'dart:async';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ocurithm/core/Network/shared.dart';

import '../../../../../core/utils/booking_calendar/booking_calendar.dart';
import '../../../../../core/utils/colors.dart';
import '../../../../../core/utils/config.dart';
import '../../../../../core/widgets/height_spacer.dart';
import '../../../../Patient/data/model/patients_model.dart';

class AppointmentViewBody extends StatefulWidget {
  const AppointmentViewBody({super.key, this.patient, required this.branch});
  final Patient? patient;
  final String branch;

  @override
  State<AppointmentViewBody> createState() => _AppointmentViewBodyState();
}

class _AppointmentViewBodyState extends State<AppointmentViewBody> {
  final now = DateTime.now();
  late BookingService bookingService;
  late StreamController<dynamic> _controller;
  Timer? _pollingTimer;
  bool _disposed = false;

  bool _viewOnly = false;

  @override
  void initState() {
    super.initState();
    bookingService = BookingService(
      serviceName: 'Appointment Reservation',
      serviceDuration: 10,
      bookingEnd: DateTime(now.year, now.month, now.day, 18, 0),
      bookingStart: DateTime(now.year, now.month, now.day, 8, 0),
    );

    _controller = StreamController<dynamic>.broadcast();

    // Call fetchInitialData when the screen is opened
    fetchInitialData(branch: widget.branch, date: DateTime.now().toString());
  }

  List<dynamic> appointments = [];
  bool isFirst = true;
  Future<void> fetchInitialData({required String date, required String branch}) async {
    if (_disposed) return;

    Map<String, dynamic> data = {
      "date": date,
      "branch": widget.branch,
      "patient": widget.patient?.id,
    };
    log("data ${data.toString()}");

    var dio = Dio(BaseOptions(
      connectTimeout: const Duration(minutes: 2),
      receiveTimeout: const Duration(minutes: 2),
    ));

    try {
      var response = await dio.get(
        "${Config.baseUrl}appointments",
        data: data,
        options: Options(
          headers: {"Accept": "application/json", "Content-Type": "application/json", "Cookie": "ocurithmToken=${CacheHelper.getData(key: 'token')}"},
          validateStatus: (status) {
            return status! <= 500;
          },
        ),
      );
      log(response.realUri.toString());
      if (isFirst) {
        isFirst = false;
        fetchInitialData(date: date, branch: widget.branch);
      }
      if (_disposed) return;
      log(response.data.toString());

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = response.data;

        // Remove appointments that are no longer present

        // Add new appointments
        appointments = response.data['appointments'];

        _controller.add(appointments);
      } else {
        throw Exception('Failed to load appointments');
      }
    } catch (e) {
      if (_disposed) return;

      log('Error fetching data: $e');
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _controller.close();
    _pollingTimer?.cancel();
    super.dispose();
  }

  Stream<dynamic>? getBookingStream({
    required String branch,
    required DateTime start,
    required DateTime end,
  }) {
    // Start polling
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      fetchInitialData(branch: widget.branch, date: start.toIso8601String());
    });

    return _controller.stream;
  }

  Future<dynamic> uploadBooking({
    required String branch,
    required String examinationType,
    required BookingService newBooking,
    required Patient patient,
  }) async {
    var dio = Dio();

    try {
      Map<String, dynamic> data = {
        "branch_id": widget.branch,
        "examination_type": examinationType,
        "start": newBooking.bookingStart.toIso8601String(),
        "end": newBooking.bookingEnd.toIso8601String(),
        "patient_id": patient.id,
        "branch_name": patient.branch?.name,
        "full_name": patient.name,
        "phone": patient.phone,
      };
      log('Uploading booking data: $data');

      var response = await dio.post(
        "${Config.baseUrl}appointment",
        data: data,
        options: Options(
          validateStatus: (status) {
            return status! < 500;
          },
        ),
      );
      log('Response: ${response.data.toString()}');

      if (response.statusCode == 200) {
        return 'Booking uploaded successfully';
      } else if (response.data.toString().contains("Conflicting appointments found")) {
        isFirst = true;
        fetchInitialData(date: DateTime.now().toString(), branch: widget.branch);
        return 'Error uploading booking';
      } else {
        return 'Server Error';
      }
    } catch (e) {
      log('Error uploading booking: $e');
    }
  }

  List<Map<String, dynamic>> dateTimeRanges = [];

  List<Map<String, dynamic>> convertStreamResultToDateTimeRanges({
    required dynamic streamResult,
  }) {
    List<Map<String, dynamic>> dateTimeRanges = [];

    if (streamResult is List<dynamic>) {
      for (var item in streamResult) {
        dateTimeRanges.add({
          "Time": DateTimeRange(
            start: DateTime.parse(item["start"]),
            end: DateTime.parse(item["end"]),
          ),
          "phoneNumber": item["phone"],
          "name": item["full_name"],
          "manualId": item["manual_id"],
          "examination_type": item["examination_type"],
          "branch": item["branch_name"],
        });
      }
    } else {
      // Handle the case where streamResult is not a List
      log('Invalid streamResult format');
    }

    return dateTimeRanges;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        HeightSpacer(size: 10.h),
        Expanded(
          child: BookingCalendar(
            bookingService: bookingService,
            convertStreamResultToDateTimeRanges: convertStreamResultToDateTimeRanges,
            getBookingStream: getBookingStream,
            uploadBooking: uploadBooking,
            hideBreakTime: false,
            loadingWidget: const Text('Fetching data...'),
            uploadingWidget: const CircularProgressIndicator(),
            locale: 'en',
            startingDayOfWeek: StartingDayOfWeek.saturday,
            wholeDayIsBookedWidget: const Text('Sorry, for this day everything is booked'),
            branch: "1",
            viewOnly: _viewOnly,
            patient: Patient(),
            availableSlotTextStyle: const TextStyle(
              fontSize: 13,
            ),
            bookedSlotTextStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
            selectedSlotTextStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
            availableSlotColor: Colorz.blue,
          ),
        ),
      ],
    );
  }
}
