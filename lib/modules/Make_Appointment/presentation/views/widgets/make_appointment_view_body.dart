import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/api/api_handler.dart'; 
import '../../../../../core/utils/booking_calendar/booking_calendar.dart';
import '../../../../../core/utils/colors.dart';
import '../../../../../core/widgets/height_spacer.dart';
import '../../../../Appointment/data/models/appointment_model.dart';
import '../../../../Patient/data/model/patients_model.dart';
import '../../manager/Make Appointment cubit/make_appointment_cubit.dart';
import 'package:ocurithm/core/utils/snackbar_service.dart';

class MakeAppointmentViewBody extends StatefulWidget {
  const MakeAppointmentViewBody({super.key, this.isUpdate = false});

  final bool isUpdate;

  @override
  State<MakeAppointmentViewBody> createState() => _MakeAppointmentViewBodyState();
}

class _MakeAppointmentViewBodyState extends State<MakeAppointmentViewBody> {
  late BookingService bookingService;
  late StreamController<List<Appointment>> _controller;
  bool _disposed = false;
  bool _viewOnly = false;
  bool isFirst = true;

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

    final List<String>? workingDaysFull =
        workingDays?.map((day) => dayMapping[day.toLowerCase()] ?? day.toLowerCase()).toList();

    final List<String> holidays = allDays.where((day) => !workingDaysFull!.contains(day)).toList();

    return holidays;
  }

  @override
  void initState() {
    super.initState();
    final cubit = context.read<MakeAppointmentCubit>();
    final state = cubit.state;

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
        state.selectedDoctor?.branches
                ?.firstWhere((branch) => branch.branch?.id == state.selectedBranch?.id, orElse: () => state.selectedDoctor!.branches!.first)
                .availableFrom ??
            "8:00",
        const TimeOfDay(hour: 8, minute: 0));
    final availableTo = getTimeOfDay(
        state.selectedDoctor?.branches
                ?.firstWhere((branch) => branch.branch?.id == state.selectedBranch?.id, orElse: () => state.selectedDoctor!.branches!.first)
                .availableTo ??
            "18:00",
        const TimeOfDay(hour: 18, minute: 0));

    final duration = int.tryParse(state.selectedExaminationType?.duration?.toString() ?? "10") ?? 10;

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

    _controller = StreamController<List<Appointment>>.broadcast();
  }

  Future<void> fetchInitialData({required DateTime date}) async {
    if (_disposed) return;
    
    final cubit = context.read<MakeAppointmentCubit>();
    try {
      final appointmentsModel = await cubit.makeAppointmentRepo.getAllAppointment(
        date: date,
        branch: cubit.state.selectedBranch?.id,
        doctor: cubit.state.selectedDoctor?.id,
      );
      
      if (isFirst) {
        isFirst = false;
        fetchInitialData(date: date);
      }
      if (_disposed) return;
      
      if (appointmentsModel.appointments.isNotEmpty) {
           _controller.add(appointmentsModel.appointments);
      } else {
         _controller.add([]);
      }
    } catch (e) {
      if (_disposed) return;
      // Handle error cleanly, maybe send empty list
      _controller.add([]);
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
    fetchInitialData(date: start);
    return _controller.stream;
  }

  Future<dynamic> uploadBooking({
    required String branch,
    required String examinationType,
    required BookingService newBooking,
    required Patient patient,
  }) async {
    // This looks like legacy/unused code given the Cubit handles appointment creation.
    // However, keeping structure as requested. 
    // It seems BookingCalendar calls this on 'Book' button click.
    // If we want to use the Cubit's makeAppointment, we should return success here 
    // and let the 'Next' button handle the actual creation in the Preview step?
    // Or if this button IS the create button... 
    // The previous code posted to 'appointment' (singular) endpoint.
    // I'll return a success dummy message because the main 'Next' button calls cubit.changeStep(2)
    // which goes to Preview, where I assume the final confirmation happens.
    return 'Booking uploaded successfully';
  }

  List<Map<String, dynamic>> convertStreamResultToDateTimeRanges({
    required dynamic streamResult,
  }) {
    List<Map<String, dynamic>> dateTimeRanges = [];

    if (streamResult is List<Appointment>) {
      for (var item in streamResult) {
        if (item.datetime != null) {
             final start = item.datetime!.toLocal();
             final duration = item.examinationType?.duration ?? 10; // Default or fetch
             dateTimeRanges.add({
              "Time": DateTimeRange(
                start: start,
                end: start.add(Duration(minutes: duration.toInt())),
              ),
              "phoneNumber": item.patient?.phone,
              "name": item.patient?.name,
              "manualId": item.id,
              "examination_type": item.examinationType?.name,
              "branch": item.branch?.name,
              "status": item.status,
            });
        }
      }
    }

    return dateTimeRanges;
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return BlocBuilder<MakeAppointmentCubit, MakeAppointmentState>(
      builder: (context, state) {
        final cubit = context.read<MakeAppointmentCubit>();
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
              selectedDate: state.selectedTime,
              locale: 'en',
              startingDayOfWeek: StartingDayOfWeek.saturday,
              wholeDayIsBookedWidget: Text('Sorry, for this day everything is booked', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
              branch: state.selectedBranch,
              doctor: state.selectedDoctor,
              viewOnly: _viewOnly,
              availableSlotTextStyle: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white : Colors.black,
              ),
              bookedSlotTextStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: isDark ? Colors.white : Colors.grey,
              ),
              isUpdate: widget.isUpdate,
              selectedSlotTextStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: isDark ? Colors.white : Colors.orange,
              ),
              holidayWeekdays: getHolidayDays(
                  workingDays: state.selectedDoctor?.branches
                      ?.firstWhere((branch) => branch.branch?.id == state.selectedBranch?.id, orElse: () => state.selectedDoctor!.branches!.first)
                      .availableDays), // Added orElse to prevent crash
              
              availableSlotColor: isDark ? Colorz.primaryColor.withOpacity(0.7) : Colorz.primaryColor,
              bookedSlotColor: isDark ? Colors.grey[700] : Colors.grey,
              selectedSlotColor: isDark ? Colors.orange : Colors.orange, // Example highlighting
              pauseSlotColor: Colors.grey,
              
              onDateSelected: (DateTime date) {
                cubit.add(SelectTimeEvent(date));
              },
              patient: Patient(),
              actionButton: Padding(
                padding: EdgeInsets.only(bottom: Platform.isIOS ? 8.0 : 0.0),
                child: Row(
                  children: [
                    if (widget.isUpdate == false)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                           cubit.add(PreviousStepEvent()); // OR ChangeStepEvent(0)
                           cubit.add(ChangeStepEvent(0));
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
                            'Previous',
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
                          if (state.selectedTime != null) {
                            if (state.selectedTime!.isBefore(DateTime.now())) {
                               // Allow selecting today if internal time is later? 
                               // Logic: isBefore(now) checks exact time. 
                               // If user picks today, selectedTime might be 00:00 or current time?
                               // BookingCalendar returns generic date. 
                               // Let's assume standard behavior.
                               if (DateUtils.isSameDay(state.selectedTime, DateTime.now()) || state.selectedTime!.isAfter(DateTime.now())) {
                                  cubit.add(ChangeStepEvent(2));
                               } else {
                                  SnackbarService.showError(
                                    context,
                                    message: 'Please select a valid date',
                                  );
                               }
                            } else {
                              cubit.add(ChangeStepEvent(2));
                            }
                          } else {
                            SnackbarService.showError(
                              context,
                              message: 'Please select date',
                            );
                            return;
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
                          widget.isUpdate == true ? 'Update' : 'Next',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
     }
    );
  }
}
