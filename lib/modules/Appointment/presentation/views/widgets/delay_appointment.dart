import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:ocurithm/core/widgets/custom_freeze_loading.dart';
import 'package:ocurithm/core/utils/snackbar_service.dart';

import '../../../../../core/Network/shared.dart';
import '../../../../../core/utils/booking_calendar/booking_calendar.dart';
import '../../../../../core/utils/colors.dart';
import '../../../../../core/widgets/height_spacer.dart';
import '../../../../Patient/data/model/patients_model.dart';
import '../../../data/models/appointment_model.dart';
import '../../manager/Appointment cubit/appointment_cubit.dart';

class DelayAppointment extends StatefulWidget {
  const DelayAppointment({super.key, this.isUpdate = false, required this.appointment, required this.cubit});
  final bool isUpdate;
  final Appointment appointment;
  final AppointmentCubit cubit;
  @override
  State<DelayAppointment> createState() => _DelayAppointmentState();
}

class _DelayAppointmentState extends State<DelayAppointment> {
  late BookingService bookingService;
  late StreamController<dynamic> _controller;
  bool _disposed = false;
  bool _viewOnly = false;

  List<String> getHolidayDays({List<String>? workingDays}) {
    final Map<String, String> dayMapping = {
      'mon': 'monday',
      'tue': 'tuesday',
      'wed': 'wednesday',
      'thu': 'thursday',
      'fri': 'friday',
      'sat': 'saturday',
      'sun': 'sunday',
    };

    final List<String> allDays = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
    final List<String>? workingDaysFull = workingDays?.map((day) => dayMapping[day.toLowerCase()] ?? day.toLowerCase()).toList();
    final List<String> holidays = allDays.where((day) => !workingDaysFull!.contains(day)).toList();

    return holidays;
  }

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();

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

    final availableFrom = getTimeOfDay(
        widget.appointment.doctor?.branches?.firstWhere((branch) => branch.branch?.id == widget.appointment.branch?.id).availableFrom ?? "8:00",
        const TimeOfDay(hour: 8, minute: 0));
    final availableTo = getTimeOfDay(
        widget.appointment.doctor?.branches?.firstWhere((branch) => branch.branch?.id == widget.appointment.branch?.id).availableTo ?? "18:00",
        const TimeOfDay(hour: 18, minute: 0));

    final duration = int.tryParse(widget.appointment.examinationType?.duration?.toString() ?? "10") ?? 10;

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

    _controller = StreamController<dynamic>.broadcast();
  }

  List<dynamic> appointmentsList = [];
  bool isFirst = true;

  Future<void> fetchAppointmentsData({required DateTime date}) async {
    if (_disposed) return;
    
    // We can use the cubit or a dedicated repo call here, 
    // but the user wanted to keep the logic.
    // However, I'll refactor it to use AppointmentRepo via the cubit if possible
    // to avoid direct Dio calls and use ApiHandler.
    
    try {
      final results = await widget.cubit.appointmentRepo.getAllAppointment(
        date: date,
        doctor: widget.appointment.doctor?.id,
        branch: widget.appointment.branch?.id,
      );
      
      if (_disposed) return;
      
      // The current BookingCalendar expects a specific format (Map list from JSON)
      // because convertStreamResultToDateTimeRanges manually parses it.
      // We'll mimic the JSON structure from the model for compatibility.
      
      final appointmentsJson = results.appointments.map((a) => {
        "datetime": a.datetime?.toIso8601String(),
        "examinationType": {
          "duration": a.examinationType?.duration ?? 10,
          "name": a.examinationType?.name ?? ""
        },
        "patient": {
          "phone": a.patient?.phone ?? "",
          "name": a.patient?.name ?? ""
        },
        "id": a.id,
        "branch": {
          "name": a.branch?.name ?? ""
        },
        "status": a.status
      }).toList();

      _controller.add(appointmentsJson);
    } catch (e) {
      if (!_disposed) {
        _controller.addError(e);
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _controller.close();
    super.dispose();
  }

  Stream<dynamic>? getBookingStream({
    required String branch,
    required DateTime start,
    required DateTime end,
  }) {
    fetchAppointmentsData(date: start);
    return _controller.stream;
  }

  Future<dynamic> uploadBooking({
    required String branch,
    required String examinationType,
    required BookingService newBooking,
    required Patient patient,
  }) async {
    // This is not used in DelayAppointment but required by BookingCalendar
    return null;
  }

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
    }
    return dateTimeRanges;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocListener<AppointmentCubit, AppointmentState>(
      bloc: widget.cubit,
      listener: (context, state) {
        if (state.status == AppointmentStatus.editSuccess) {
          Navigator.pop(context, true);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Delay Appointment', style: TextStyle(color: Colorz.primaryColor)),
          centerTitle: true,
          backgroundColor: isDark ? theme.appBarTheme.backgroundColor : Colors.white,
          elevation: 0,
          leading: BackButton(color: isDark ? Colors.white : Colors.black),
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
                loadingWidget: const Center(child: Text('Fetching data...')),
                uploadingWidget: const Center(child: CircularProgressIndicator()),
                locale: 'en',
                startingDayOfWeek: StartingDayOfWeek.saturday,
                wholeDayIsBookedWidget: const Center(child: Text('Sorry, for this day everything is booked')),
                branch: widget.appointment.branch,
                doctor: widget.appointment.doctor,
                viewOnly: _viewOnly,
                availableSlotTextStyle: TextStyle(fontSize: 13, color: isDark ? Colors.white : Colors.black),
                bookedSlotTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                isUpdate: widget.isUpdate,
                selectedSlotTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                holidayWeekdays: getHolidayDays(
                    workingDays: widget.appointment.doctor?.branches
                        ?.firstWhere((branch) => branch.branch?.id == widget.appointment.branch?.id)
                        .availableDays),
                availableSlotColor: Colorz.primaryColor,
                bookedSlotColor: Colors.redAccent,
                selectedSlotColor: Colors.orange,
                patient: Patient(),
                onDateSelected: (DateTime date) {
                   widget.cubit.selectedTime = date;
                },
                actionButton: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      if (widget.isUpdate == false)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 16.h),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                              side: BorderSide(color: Colorz.primaryColor),
                            ),
                            child: Text(
                              'Cancel',
                              style: TextStyle(fontSize: 16.sp, color: Colorz.primaryColor, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            if (widget.cubit.selectedTime != null) {
                              bool value = await InternetConnection().hasInternetAccess;
                              if (!value) {
                                SnackbarService.showWarning(context, message: 'No Internet Connection');
                                return;
                              }
                              widget.cubit.add(EditAppointmentEvent(
                                context: context,
                                id: widget.appointment.id.toString(),
                                action: 'delay',
                                date: widget.cubit.selectedTime!.toUtc(),
                              ));
                            } else {
                              SnackbarService.showError(context, message: 'Please select a time');
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            backgroundColor: Colorz.primaryColor,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                          ),
                          child: Text(
                            'Update',
                            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
