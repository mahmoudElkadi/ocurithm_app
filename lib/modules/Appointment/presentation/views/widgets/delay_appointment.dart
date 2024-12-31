import 'dart:async';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:ocurithm/core/widgets/custom_freeze_loading.dart';

import '../../../../../core/Network/shared.dart';
import '../../../../../core/utils/booking_calendar/booking_calendar.dart';
import '../../../../../core/utils/colors.dart';
import '../../../../../core/utils/config.dart';
import '../../../../../core/widgets/height_spacer.dart';
import '../../../../Patient/data/model/patients_model.dart';
import '../../../data/models/appointment_model.dart';
import '../../manager/Appointment cubit/appointment_cubit.dart';
import '../../manager/Appointment cubit/appointment_state.dart';

class DelayAppointment extends StatefulWidget {
  const DelayAppointment({super.key, this.isUpdate = false, required this.appointment, required this.cubit});
  final bool isUpdate;
  final Appointment appointment;
  final AppointmentCubit cubit;
  @override
  State<DelayAppointment> createState() => _DelayAppointmentState();
}

class _DelayAppointmentState extends State<DelayAppointment> {
  final now = DateTime.now();
  late BookingService bookingService;
  late StreamController<dynamic> _controller;
  Timer? _pollingTimer;
  bool _disposed = false;

  bool _viewOnly = false;

  List<String> getHolidayDays({List<String>? workingDays}) {
    // Map of abbreviations to full day names
    final Map<String, String> dayMapping = {
      'mon': 'monday',
      'tue': 'tuesday',
      'wed': 'wednesday',
      'thu': 'thursday',
      'fri': 'friday',
      'sat': 'saturday',
      'sun': 'sunday',
    };

    // Define all days of the week
    final List<String> allDays = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];

    // Convert working days to full day names (if abbreviated) and lowercase
    final List<String>? workingDaysFull = workingDays?.map((day) => dayMapping[day.toLowerCase()] ?? day.toLowerCase()).toList();

    // Get days that are not in working days list
    final List<String> holidays = allDays.where((day) => !workingDaysFull!.contains(day)).toList();

    return holidays;
  }

  void initState() {
    super.initState();
    // final cubit = BlocProvider.of<AppointmentCubit>(context);
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

    //  Get doctor's available hours
    final availableFrom = getTimeOfDay(
        widget.appointment.doctor?.branches?.firstWhere((branch) => branch.branch?.id == widget.appointment.branch?.id).availableFrom ?? "8:00",
        const TimeOfDay(hour: 8, minute: 0));
    final availableTo = getTimeOfDay(
        widget.appointment.doctor?.branches?.firstWhere((branch) => branch.branch?.id == widget.appointment.branch?.id).availableTo ?? "18:00",
        const TimeOfDay(hour: 18, minute: 0));

    // Set up examination duration
    final duration = int.tryParse(widget.appointment.examinationType?.duration?.toString() ?? "10") ?? 10;

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
  Future<void> fetchInitialData({required DateTime date}) async {
    if (_disposed) return;

    log("data ${date.toString()}");

    var dio = Dio(BaseOptions(
      connectTimeout: const Duration(minutes: 2),
      receiveTimeout: const Duration(minutes: 2),
    ));
    DateTime dateTime = DateTime.parse(date.toString());

    Map<String, dynamic> query = {
      "startDate": DateTime(dateTime.year, dateTime.month, dateTime.day, 0, 0, 0),
      "endDate": DateTime(dateTime.year, dateTime.month, dateTime.day, 23, 59, 59),
      //  'doctor': BlocProvider.of<AppointmentCubit>(context).selectedDoctor?.id,
      //   'branch': BlocProvider.of<AppointmentCubit>(context).selectedBranch?.id
    };

    try {
      var response = await dio.get(
        "${Config.baseUrl}appointments",
        queryParameters: query,
        options: Options(
          headers: {"Accept": "application/json", "Content-Type": "application/json", "Cookie": "ocurithmToken=${CacheHelper.getData(key: 'token')}"},
          validateStatus: (status) {
            return status! <= 500;
          },
        ),
      );
      if (isFirst) {
        isFirst = false;
        fetchInitialData(date: date);
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
    fetchInitialData(date: start);
    // });

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
            end: DateTime.parse(item["datetime"]).add(Duration(minutes: item['examinationType']['duration'])),
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
    return BlocBuilder<AppointmentCubit, AppointmentState>(
      bloc: widget.cubit,
      builder: (context, state) => Scaffold(
        appBar: AppBar(
          title: Text('Delay Appointment', style: TextStyle(color: Colorz.primaryColor)),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: Column(
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
                branch: widget.cubit.selectedBranch,
                doctor: widget.cubit.selectedDoctor,
                viewOnly: _viewOnly,
                availableSlotTextStyle: const TextStyle(
                  fontSize: 13,
                ),
                bookedSlotTextStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
                isUpdate: widget.isUpdate,
                selectedSlotTextStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
                holidayWeekdays: getHolidayDays(
                    workingDays: widget.appointment.doctor?.branches
                        ?.firstWhere((branch) => branch.branch?.id == widget.appointment.branch?.id)
                        .availableDays),
                availableSlotColor: Colorz.primaryColor,
                patient: Patient(),
                onDateSelected: (DateTime date) {
                  setState(() {
                    widget.cubit.selectedTime = date;
                  });
                },
                actionButton: Row(
                  children: [
                    if (widget.isUpdate == false)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            side: BorderSide(
                              color: Colorz.primaryColor,
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Colorz.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (widget.cubit.selectedTime != null) {
                            customLoading(context, "");
                            bool value = await InternetConnection().hasInternetAccess;
                            if (!value) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                content: Text('No Internet Connection', style: TextStyle(color: Colors.white)),
                                backgroundColor: Colors.red,
                              ));
                              return;
                            }
                            widget.cubit.editAppointment(
                                context: context,
                                id: widget.appointment.id.toString(),
                                action: 'delay',
                                date: widget.cubit.selectedTime!,
                                doctor: widget.appointment.doctor?.id.toString());
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text('Please select a time', style: TextStyle(color: Colors.white)),
                              backgroundColor: Colors.red,
                              behavior: SnackBarBehavior.floating,
                            ));
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          backgroundColor: Colorz.primaryColor,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text(
                          'Update',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
