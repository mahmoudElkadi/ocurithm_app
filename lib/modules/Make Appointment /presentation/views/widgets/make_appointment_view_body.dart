import 'dart:async';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ocurithm/modules/Make%20Appointment%20/presentation/views/widgets/select_doctor_branch.dart';

import '../../../../../core/Network/shared.dart';
import '../../../../../core/utils/booking_calendar/booking_calendar.dart';
import '../../../../../core/utils/colors.dart';
import '../../../../../core/utils/config.dart';
import '../../../../../core/widgets/height_spacer.dart';
import '../../../../Appointment/data/models/appointment_model.dart';
import '../../../../Patient/data/model/patients_model.dart';
import '../../manager/Make Appointment cubit/make_appointment_cubit.dart';
import '../../manager/Make Appointment cubit/make_appointment_state.dart';

class MakeAppointmentViewBody extends StatefulWidget {
  const MakeAppointmentViewBody({super.key, this.patient, required this.branch, this.appointment});
  final Patient? patient;
  final String branch;
  final Appointment? appointment;

  @override
  State<MakeAppointmentViewBody> createState() => _MakeAppointmentViewBodyState();
}

class _MakeAppointmentViewBodyState extends State<MakeAppointmentViewBody> {
  final now = DateTime.now();
  late BookingService bookingService;
  late StreamController<dynamic> _controller;
  Timer? _pollingTimer;
  bool _disposed = false;

  bool _viewOnly = false;

  List<String> getHolidayDays({List<String>? workingDays}) {
    // Define all days of the week
    final List<String> allDays = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];

    // Convert working days to lowercase for case-insensitive comparison
    final List<String>? workingDaysLower = workingDays?.map((day) => day.toLowerCase()).toList();

    // Get days that are not in working days list
    final List<String> holidays = allDays.where((day) => !workingDaysLower!.contains(day)).toList();

    return holidays;
  }

  void initState() {
    super.initState();
    final cubit = BlocProvider.of<MakeAppointmentCubit>(context);
    final now = DateTime.now();

    // Parse working hours safely
    TimeOfDay getTimeOfDay(String? time, TimeOfDay defaultTime) {
      if (time == null) return defaultTime;
      try {
        final parts = time.split(":");
        return TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      } catch (e) {
        return defaultTime;
      }
    }

    // Get doctor's available hours
    final availableFrom = getTimeOfDay(cubit.selectedDoctor?.availableFrom, const TimeOfDay(hour: 8, minute: 0));
    final availableTo = getTimeOfDay(cubit.selectedDoctor?.availableTo, const TimeOfDay(hour: 18, minute: 0));

    // Set up examination duration
    final duration = int.tryParse(cubit.selectedExaminationType?.duration?.toString() ?? "10") ?? 10;

    // Create booking service with correct start and end times
    bookingService = BookingService(
      serviceName: 'Appointment Reservation',
      serviceDuration: duration,
      bookingStart: DateTime(
        now.year,
        now.month,
        now.day,
        availableFrom.hour,
        availableFrom.minute,
      ),
      bookingEnd: DateTime(
        now.year,
        now.month,
        now.day,
        availableTo.hour,
        availableTo.minute,
      ),
    );

    // Initialize stream controller
    _controller = StreamController<dynamic>.broadcast();
  }

  List<dynamic> appointments = [];
  bool isFirst = true;
  Future<void> fetchInitialData({required DateTime date, required String branch}) async {
    if (_disposed) return;
    log("fetchInitialData $date $branch");

    log("data ${date.toString()}");

    var dio = Dio(BaseOptions(
      connectTimeout: const Duration(minutes: 2),
      receiveTimeout: const Duration(minutes: 2),
    ));
    DateTime dateTime = DateTime.parse(date.toString());

    Map<String, dynamic> quary = {
      "startDate": DateTime(dateTime.year, dateTime.month, dateTime.day, 0, 0, 0),
      "endDate": DateTime(dateTime.year, dateTime.month, dateTime.day, 23, 59, 59)
    };
    log("quary ${quary.toString()}");

    try {
      var response = await dio.get(
        "${Config.baseUrl}appointments",
        // data: data,
        queryParameters: quary,
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
    // _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
    //   log("tabibooking polling");
    fetchInitialData(branch: widget.branch, date: start);
    // });

    return _controller.stream;
  }

  Future<bool?> _selectDoctorAndBranch() async {
    if (!mounted) return false;

    // Get the cubit before showing dialog
    final appointmentCubit = context.read<MakeAppointmentCubit>();

    final result = await showDialog<bool>(
      // Add return type and await the result
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return BlocProvider.value(
          value: appointmentCubit,
          child: WillPopScope(
            onWillPop: () async => false,
            child: SelectDoctorBranch(
              cubit: appointmentCubit,
            ),
          ),
        );
      },
    );

    // Check if a selection was made and fetch data
    if (result == true) {
      log("result.toString()" + result.toString());
      await fetchInitialData(
        branch: widget.branch,
        date: DateTime.now(),
      );
    }

    return result; // Return the result for use in selectData()
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
        // fetchInitialData(date: DateTime.now().toString(), branch: widget.branch);
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
            start: DateTime.parse(item["datetime"]),
            end: DateTime.parse(item["datetime"]).add(const Duration(minutes: 10)),
          ),
          "phoneNumber": item["patient"]["phone"],
          "name": item["patient"]["name"],
          "manualId": item["id"],
          "examination_type": item["examinationType"]["name"],
          "branch": item["branch"]["name"],
          "status": item["status"],
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
    final cubit = context.read<MakeAppointmentCubit>();
    return BlocBuilder<MakeAppointmentCubit, MakeAppointmentState>(
      builder: (context, state) => Column(
        children: [
          HeightSpacer(size: 10.h),
          Expanded(
            child: BookingCalendar(
              bookingService: bookingService,
              convertStreamResultToDateTimeRanges: convertStreamResultToDateTimeRanges,
              getBookingStream: getBookingStream,
              uploadBooking: uploadBooking,
              hideBreakTime: false,
              appointment: widget.appointment,
              loadingWidget: const Text('Fetching data...'),
              uploadingWidget: const CircularProgressIndicator(),
              locale: 'en',
              startingDayOfWeek: StartingDayOfWeek.saturday,
              wholeDayIsBookedWidget: const Text('Sorry, for this day everything is booked'),
              branch: cubit.selectedBranch,
              doctor: cubit.selectedDoctor,
              viewOnly: _viewOnly,
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
              holidayWeekdays: getHolidayDays(workingDays: cubit.selectedDoctor?.availableDays),
              availableSlotColor: Colorz.blue,
              patient: Patient(),
            ),
          ),
        ],
      ),
    );
  }
}
