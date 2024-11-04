import 'dart:developer';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ocurithm/core/utils/app_style.dart';
import 'package:ocurithm/core/widgets/height_spacer.dart';
import 'package:ocurithm/core/widgets/responsiveText.dart';
import 'package:ocurithm/generated/l10n.dart';
import 'package:ocurithm/modules/Patient/data/model/patients_model.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart' as tc show StartingDayOfWeek;
import 'package:table_calendar/table_calendar.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../widgets/DropdownPackage.dart';
import '../../../colors.dart';
import '../core/booking_controller.dart';
import '../model/booking_service.dart';
import '../model/enums.dart' as bc;
import '../util/booking_util.dart';
import 'booking_dialog.dart';
import 'booking_explanation.dart';
import 'booking_slot.dart';
import 'common_button.dart';
import 'common_card.dart';

class BookingCalendarMain extends StatefulWidget {
  const BookingCalendarMain({
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
    required this.branch,
    required this.viewOnly,
    required this.patient,
  }) : super(key: key);

  final Stream<dynamic>? Function({required DateTime start, required DateTime end, required String branch}) getBookingStream;
  final Future<dynamic> Function(
      {required BookingService newBooking, required Patient patient, required String branch, required String examinationType}) uploadBooking;
  // final List<DateTimeRange> Function({required dynamic streamResult})
  //     convertStreamResultToDateTimeRanges;
  final List<Map<String, dynamic>> Function({required dynamic streamResult}) convertStreamResultToDateTimeRanges;

  ///Customizable
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

//Added optional TextStyle to available, booked and selected cards.
  final String? bookedSlotText;
  final String? selectedSlotText;
  final String? availableSlotText;
  final String? pauseSlotText;

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
  final String branch;
  final bool viewOnly;
  final Patient patient;

  final Widget? wholeDayIsBookedWidget;

  @override
  State<BookingCalendarMain> createState() => _BookingCalendarMainState();
}

class _BookingCalendarMainState extends State<BookingCalendarMain> {
  late BookingController controller;
  late String branch;
  final now = DateTime.now();

  @override
  void initState() {
    super.initState();
    controller = context.read<BookingController>();
    final firstDay = calculateFirstDay();

    startOfDay = firstDay.startOfDayService(controller.serviceOpening!);
    endOfDay = firstDay.endOfDayService(controller.serviceClosing!);
    branch = controller.branch;
    _focusedDay = firstDay;
    _selectedDay = firstDay;
    controller.selectFirstDayByHoliday(startOfDay, endOfDay);
  }

  CalendarFormat _calendarFormat = CalendarFormat.twoWeeks;

  late DateTime _selectedDay;
  late DateTime _focusedDay;
  late DateTime startOfDay;
  late DateTime endOfDay;

  void selectNewDateRange() {
    startOfDay = _selectedDay.startOfDayService(controller.serviceOpening!);
    endOfDay = _selectedDay.add(const Duration(days: 1)).endOfDayService(controller.serviceClosing!);

    controller.base = startOfDay;
    controller.resetSelectedSlot();
  }

  DateTime calculateFirstDay() {
    final now = DateTime.now();
    if (widget.disabledDays != null) {
      return widget.disabledDays!.contains(now.weekday) ? now.add(Duration(days: getFirstMissingDay(now.weekday))) : now;
    } else {
      return DateTime.now();
    }
  }

  int getFirstMissingDay(int now) {
    for (var i = 1; i <= 7; i++) {
      if (!widget.disabledDays!.contains(now + i)) {
        return i;
      }
    }
    return -1;
  }

  @override
  Widget build(BuildContext context) {
    controller = context.watch<BookingController>();
    final size = MediaQuery.of(context).size;
    return Consumer<BookingController>(
      builder: (_, controller, __) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
        child: (controller.isUploading)
            ? widget.uploadingWidget ?? const BookingDialog()
            : Column(
                children: [
                  CommonCard(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    child: TableCalendar(
                      startingDayOfWeek: widget.startingDayOfWeek?.toTC() ?? tc.StartingDayOfWeek.monday,
                      holidayPredicate: (day) {
                        if (widget.disabledDates == null) return false;

                        bool isHoliday = false;
                        for (var holiday in widget.disabledDates!) {
                          if (isSameDay(day, holiday)) {
                            isHoliday = true;
                          }
                        }
                        return isHoliday;
                      },
                      enabledDayPredicate: (day) {
                        if (widget.disabledDays == null && widget.disabledDates == null) return true;

                        bool isEnabled = true;
                        if (widget.disabledDates != null) {
                          for (var holiday in widget.disabledDates!) {
                            if (isSameDay(day, holiday)) {
                              isEnabled = false;
                            }
                          }
                          if (!isEnabled) return false;
                        }
                        if (widget.disabledDays != null) {
                          isEnabled = !widget.disabledDays!.contains(day.weekday);
                        }

                        return isEnabled;
                      },
                      locale: widget.locale,
                      firstDay: calculateFirstDay(),
                      lastDay: widget.lastDay ?? DateTime.now().add(const Duration(days: 1000)),
                      focusedDay: _focusedDay,
                      calendarFormat: _calendarFormat,
                      calendarStyle: const CalendarStyle(isTodayHighlighted: true),
                      selectedDayPredicate: (day) {
                        return isSameDay(_selectedDay, day);
                      },
                      onDaySelected: (selectedDay, focusedDay) {
                        if (!isSameDay(_selectedDay, selectedDay)) {
                          setState(() {
                            _selectedDay = selectedDay;
                            _focusedDay = focusedDay;
                          });
                          selectNewDateRange();
                        }
                      },
                      onFormatChanged: (format) {
                        if (_calendarFormat != format) {
                          setState(() {
                            _calendarFormat = format;
                          });
                        }
                      },
                      onPageChanged: (focusedDay) {
                        _focusedDay = focusedDay;
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
                          BookingExplanation(
                              color: widget.availableSlotColor ?? Colors.greenAccent, text: widget.availableSlotText ?? S.of(context).available),
                          BookingExplanation(
                              color: widget.selectedSlotColor ?? Colors.orangeAccent, text: widget.selectedSlotText ?? S.of(context).selected),
                          BookingExplanation(color: widget.bookedSlotColor ?? Colors.redAccent, text: widget.bookedSlotText ?? S.of(context).booked),
                          if (widget.hideBreakTime != null && widget.hideBreakTime == false)
                            BookingExplanation(color: widget.pauseSlotColor ?? Colors.grey, text: widget.pauseSlotText ?? S.of(context).breakTime),
                        ],
                      ),
                  const SizedBox(height: 8),
                  StreamBuilder<dynamic>(
                    stream: widget.getBookingStream(start: startOfDay, end: endOfDay, branch: branch!),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return widget.errorWidget ??
                            Center(
                              child: Text(snapshot.error.toString()),
                            );
                      }

                      if (!snapshot.hasData) {
                        return widget.loadingWidget ?? const Center(child: CircularProgressIndicator());
                      }

                      ///this snapshot should be converted to List<DateTimeRange>
                      final data = snapshot.requireData;
                      controller.generateBookedSlots(widget.convertStreamResultToDateTimeRanges(streamResult: data));

                      return Expanded(
                        child: (widget.wholeDayIsBookedWidget != null && controller.isWholeDayBooked())
                            ? widget.wholeDayIsBookedWidget!
                            : GridView.builder(
                                physics: widget.gridScrollPhysics ?? const BouncingScrollPhysics(),
                                itemCount: controller.allBookingSlots.length,
                                itemBuilder: (context, index) {
                                  TextStyle? getTextStyle() {
                                    if (controller.isSlotBooked(index)) {
                                      return widget.bookedSlotTextStyle;
                                    } else if (index == controller.selectedSlot) {
                                      return widget.selectedSlotTextStyle;
                                    } else {
                                      return widget.availableSlotTextStyle;
                                    }
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
                                      if (!controller.isSlotBooked(index) && controller.viewOnly == true) {
                                      } else if (!controller.isSlotBooked(index) && controller.viewOnly == false) {
                                        controller.selectSlot(index);
                                      } else if (controller.isSlotBooked(index) && controller.viewOnly == false) {
                                      } else if (controller.isSlotBooked(index) && controller.viewOnly == true) {
                                        showAppointmentDetails(controller.getBookingSlotInformation(index));
                                        log(controller.getBookingSlotInformation(index).toString());
                                      }
                                    },
                                    child: Center(
                                      child: Text(
                                        widget.formatDateTime?.call(slot) ?? BookingUtil.formatDateTime(slot),
                                        style: getTextStyle(),
                                      ),
                                    ),
                                  );
                                },
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  childAspectRatio: 2.1,
                                  crossAxisSpacing: 20,
                                  mainAxisSpacing: 10,
                                ),
                              ),
                      );
                    },
                  ),
                  widget.viewOnly != true
                      ? const SizedBox(
                          height: 10,
                        )
                      : SizedBox.shrink(),
                  widget.viewOnly != true
                      ? CommonButton(
                          text: widget.bookingButtonText ?? S.of(context).makeAppointment,
                          onTap: () async {
                            // log(widget.startingDayOfWeek.toString());
                            // log(widget.endingDayOfWeek.toString());
                            // String? choosenType;
                            // String? returnedType = await showGeneralDialog(
                            //     barrierColor: Colors.black.withOpacity(0.5),
                            //     transitionBuilder: (context, a1, a2, widget) {
                            //       return Transform.scale(
                            //         scale: a1.value,
                            //         child: Opacity(
                            //           opacity: a1.value,
                            //           child: AlertDialog(
                            //             shape: OutlineInputBorder(borderRadius: BorderRadius.circular(16.0)),
                            //             title: Text(
                            //               "Choose Examination Type",
                            //               style: TextStyle(fontWeight: FontWeight.bold),
                            //             ),
                            //             content: Padding(
                            //               padding: EdgeInsets.only(left: size.width * 0.01, top: size.height * 0.02),
                            //               child: SizedBox(
                            //                 child: Column(
                            //                   children: [
                            //                     Container(
                            //                       width: size.width * 0.8,
                            //                       padding: EdgeInsets.only(left: 10, right: 5),
                            //                       decoration: BoxDecoration(
                            //                           border: Border.all(color: Colors.grey, width: 1), borderRadius: BorderRadius.circular(15)),
                            //                       child: DropdownSearch<String>(
                            //                         items: [
                            //                           "Examination",
                            //                           "1st Examination follow up",
                            //                           "2nd Examination follow up",
                            //                           "Surgery preparation",
                            //                           "Surgery Day",
                            //                           "1st Post-operative follow up",
                            //                           "2nd Post-operative follow up",
                            //                           "Investigation",
                            //                           "Investigation Discussion"
                            //                         ],
                            //                         clearButtonProps: ClearButtonProps(
                            //                           isVisible: true,
                            //                         ),
                            //                         popupProps: PopupProps.modalBottomSheet(
                            //                           showSearchBox: true,
                            //                           showSelectedItems: true,
                            //                         ),
                            //                         dropdownDecoratorProps: DropDownDecoratorProps(
                            //                           dropdownSearchDecoration: InputDecoration(
                            //                             border: InputBorder.none,
                            //                             hintText: "Choose Examination Type",
                            //                             hintStyle: TextStyle(
                            //                               color: Colors.black,
                            //                               fontSize: 17,
                            //                             ),
                            //                           ),
                            //                         ),
                            //                         onChanged: (newValue) {
                            //                           setState(() {
                            //                             choosenType = newValue;
                            //                           });
                            //                         },
                            //                       ),
                            //                     ),
                            //                     Container(
                            //                       width: size.width * 0.8,
                            //                       padding: EdgeInsets.only(left: 10, right: 5),
                            //                       decoration: BoxDecoration(
                            //                           border: Border.all(color: Colors.grey, width: 1), borderRadius: BorderRadius.circular(15)),
                            //                       child: DropdownSearch<String>(
                            //                         items: [
                            //                           "Examination",
                            //                           "1st Examination follow up",
                            //                           "2nd Examination follow up",
                            //                           "Surgery preparation",
                            //                           "Surgery Day",
                            //                           "1st Post-operative follow up",
                            //                           "2nd Post-operative follow up",
                            //                           "Investigation",
                            //                           "Investigation Discussion"
                            //                         ],
                            //                         clearButtonProps: ClearButtonProps(
                            //                           isVisible: true,
                            //                         ),
                            //                         popupProps: PopupProps.modalBottomSheet(
                            //                           showSearchBox: true,
                            //                           showSelectedItems: true,
                            //                         ),
                            //                         dropdownDecoratorProps: DropDownDecoratorProps(
                            //                           dropdownSearchDecoration: InputDecoration(
                            //                             border: InputBorder.none,
                            //                             hintText: "Choose Examination Type",
                            //                             hintStyle: TextStyle(
                            //                               color: Colors.black,
                            //                               fontSize: 17,
                            //                             ),
                            //                           ),
                            //                         ),
                            //                         onChanged: (newValue) {
                            //                           setState(() {
                            //                             choosenType = newValue;
                            //                           });
                            //                         },
                            //                       ),
                            //                     ),
                            //                     Container(
                            //                       width: size.width * 0.8,
                            //                       padding: EdgeInsets.only(left: 10, right: 5),
                            //                       decoration: BoxDecoration(
                            //                           border: Border.all(color: Colors.grey, width: 1), borderRadius: BorderRadius.circular(15)),
                            //                       child: DropdownSearch<String>(
                            //                         items: [
                            //                           "Examination",
                            //                           "1st Examination follow up",
                            //                           "2nd Examination follow up",
                            //                           "Surgery preparation",
                            //                           "Surgery Day",
                            //                           "1st Post-operative follow up",
                            //                           "2nd Post-operative follow up",
                            //                           "Investigation",
                            //                           "Investigation Discussion"
                            //                         ],
                            //                         clearButtonProps: ClearButtonProps(
                            //                           isVisible: true,
                            //                         ),
                            //                         popupProps: PopupProps.modalBottomSheet(
                            //                           showSearchBox: true,
                            //                           showSelectedItems: true,
                            //                         ),
                            //                         dropdownDecoratorProps: DropDownDecoratorProps(
                            //                           dropdownSearchDecoration: InputDecoration(
                            //                             border: InputBorder.none,
                            //                             hintText: "Choose Examination Type",
                            //                             hintStyle: TextStyle(
                            //                               color: Colors.black,
                            //                               fontSize: 17,
                            //                             ),
                            //                           ),
                            //                         ),
                            //                         onChanged: (newValue) {
                            //                           setState(() {
                            //                             choosenType = newValue;
                            //                           });
                            //                         },
                            //                       ),
                            //                     ),
                            //                     Container(
                            //                       width: size.width * 0.8,
                            //                       padding: EdgeInsets.only(left: 10, right: 5),
                            //                       decoration: BoxDecoration(
                            //                           border: Border.all(color: Colors.grey, width: 1), borderRadius: BorderRadius.circular(15)),
                            //                       child: DropdownSearch<String>(
                            //                         items: [
                            //                           "Examination",
                            //                           "1st Examination follow up",
                            //                           "2nd Examination follow up",
                            //                           "Surgery preparation",
                            //                           "Surgery Day",
                            //                           "1st Post-operative follow up",
                            //                           "2nd Post-operative follow up",
                            //                           "Investigation",
                            //                           "Investigation Discussion"
                            //                         ],
                            //                         clearButtonProps: ClearButtonProps(
                            //                           isVisible: true,
                            //                         ),
                            //                         popupProps: PopupProps.modalBottomSheet(
                            //                           showSearchBox: true,
                            //                           showSelectedItems: true,
                            //                         ),
                            //                         dropdownDecoratorProps: DropDownDecoratorProps(
                            //                           dropdownSearchDecoration: InputDecoration(
                            //                             border: InputBorder.none,
                            //                             hintText: "Choose Examination Type",
                            //                             hintStyle: TextStyle(
                            //                               color: Colors.black,
                            //                               fontSize: 17,
                            //                             ),
                            //                           ),
                            //                         ),
                            //                         onChanged: (newValue) {
                            //                           setState(() {
                            //                             choosenType = newValue;
                            //                           });
                            //                         },
                            //                       ),
                            //                     ),
                            //                   ],
                            //                 ),
                            //               ),
                            //             ),
                            //             actions: [
                            //               Padding(
                            //                 padding: EdgeInsets.only(right: size.width * 0.05),
                            //                 child: ElevatedButton(
                            //                   child: Text("Continue", style: appStyle(context, 18, Colors.white, FontWeight.w600)),
                            //                   style: ElevatedButton.styleFrom(
                            //                     backgroundColor: Colors.blue,
                            //                   ),
                            //                   onPressed: () async {
                            //                     if (choosenType != null) {
                            //                       log(" chooosenType " + choosenType.toString());
                            //                       Navigator.of(context).pop(choosenType);
                            //                     }
                            //                   },
                            //                 ),
                            //               )
                            //             ],
                            //           ),
                            //         ),
                            //       );
                            //     },
                            //     transitionDuration: Duration(milliseconds: 300),
                            //     barrierDismissible: true,
                            //     barrierLabel: '',
                            //     context: context,
                            //     pageBuilder: (context, animation1, animation2) {
                            //       return Container();
                            //     });
                            // if (choosenType != null && returnedType != null) {
                            //   controller.toggleUploading();
                            //   var data = await widget.uploadBooking(
                            //     newBooking: controller.generateNewBookingForUploading(),
                            //     patient: controller.patient,
                            //     branch: controller.branch,
                            //     examinationType: returnedType.toString(),
                            //   );
                            //
                            //   controller.toggleUploading();
                            //   controller.resetSelectedSlot();
                            //   if (data == "Booking uploaded successfully") {
                            //     Navigator.of(context).popUntil((route) => route.isFirst);
                            //   } else if (data == "Error uploading booking") {
                            //     showDialog(
                            //       context: context,
                            //       builder: (BuildContext context) {
                            //         return AlertDialog(
                            //           title: Text(S.of(context).error),
                            //           content: Text(S.of(context).conflict),
                            //           actions: [
                            //             TextButton(
                            //               onPressed: () {
                            //                 Navigator.of(context).pop(); // Closes the dialog
                            //               },
                            //               child: Text('OK', style: appStyle(context, 16, Colors.black, FontWeight.w600)),
                            //             ),
                            //           ],
                            //         );
                            //       },
                            //     );
                            //   } else {
                            //     showDialog(
                            //       context: context,
                            //       builder: (BuildContext context) {
                            //         return AlertDialog(
                            //           title: Text(S.of(context).error),
                            //           content: Text(S.of(context).serverError),
                            //           actions: [
                            //             TextButton(
                            //               onPressed: () {
                            //                 Navigator.of(context).pop(); // Closes the dialog
                            //               },
                            //               child: Text('OK', style: appStyle(context, 16, Colors.black, FontWeight.w600)),
                            //             ),
                            //           ],
                            //         );
                            //       },
                            //     );
                            //   }
                            // }
                            customerInfoDialog(context);
                          },
                          isDisabled: controller.selectedSlot == -1,
                          buttonActiveColor: widget.bookingButtonColor,
                        )
                      : Container(
                          height: 0,
                        ),
                  widget.viewOnly != true
                      ? const SizedBox(
                          height: 10,
                        )
                      : SizedBox.shrink()
                ],
              ),
      ),
    );
  }

  Future<String?> showAppointmentDetails(Map<String, dynamic> patientData) {
    return showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            alignment: Alignment.center,
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            child: Container(
              height: getResponsiveHeight(context, heightFactor: MediaQuery.sizeOf(context).height * 0.62),
              padding: const EdgeInsets.all(16.0),
              width: MediaQuery.sizeOf(context).width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      "Appointment Details",
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const HeightSpacer(size: 30),
                  Text(
                    "  Name",
                    style: appStyle(context, 18, Colors.black, FontWeight.w600),
                  ),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 10),
                        width: MediaQuery.sizeOf(context).width,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 5,
                            ),
                          ],
                        ),
                        child: Text(
                          "${patientData['name'].toString()}",
                          textAlign: TextAlign.start,
                          style: appStyle(context, 16, Colors.grey, FontWeight.w600),
                        ),
                      ),
                      Positioned(
                        right: Directionality.of(context) == TextDirection.ltr ? 15 : null,
                        left: Directionality.of(context) == TextDirection.ltr ? null : 15,
                        top: -15,
                        child: SvgPicture.asset(
                          'packages/booking_calendar/assets/name_icon.svg',
                        ),
                      )
                    ],
                  ),
                  const HeightSpacer(size: 10),
                  Text(
                    " Phone Number",
                    style: appStyle(context, 18, Colors.black, FontWeight.w600),
                  ),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 10),
                        width: MediaQuery.sizeOf(context).width,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 5,
                            ),
                          ],
                        ),
                        child: GestureDetector(
                          onTap: () async {
                            String url = "tel:" + patientData['phoneNumber'];
                            if (!kIsWeb && await canLaunchUrl(Uri.parse(url))) {
                              await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Could not call ${patientData["phoneNumber"]}'),
                                ),
                              );
                            }
                          },
                          child: Text(
                            patientData['phoneNumber'].toString(),
                            style: appStyle(context, 18, Colors.grey, FontWeight.w600),
                            textAlign: TextAlign.start,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      Positioned(
                        top: -15,
                        right: Directionality.of(context) == TextDirection.ltr ? 15 : null,
                        left: Directionality.of(context) == TextDirection.ltr ? null : 15,
                        child: SvgPicture.asset(
                          'packages/booking_calendar/assets/phone.svg',
                        ),
                      )
                    ],
                  ),
                  const HeightSpacer(size: 10),
                  Text(
                    "  Branch",
                    style: appStyle(context, 18, Colors.black, FontWeight.w600),
                  ),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 10),
                        width: MediaQuery.sizeOf(context).width,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 5,
                            ),
                          ],
                        ),
                        child: Text(
                          "${patientData['branch'].toString()} ",
                          textAlign: TextAlign.start,
                          style: appStyle(context, 16, Colors.grey, FontWeight.w600),
                        ),
                      ),
                      Positioned(
                        top: -15,
                        right: Directionality.of(context) == TextDirection.ltr ? 15 : null,
                        left: Directionality.of(context) == TextDirection.ltr ? null : 15,
                        child: SvgPicture.asset(
                          'packages/booking_calendar/assets/branch.svg',
                        ),
                      )
                    ],
                  ),
                  const HeightSpacer(size: 10),
                  Text(
                    "  ID",
                    style: appStyle(context, 18, Colors.black, FontWeight.w600),
                  ),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 10),
                        width: MediaQuery.sizeOf(context).width,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 5,
                            ),
                          ],
                        ),
                        child: Text(
                          "${patientData['manualId'].toString()} ",
                          textAlign: TextAlign.start,
                          style: appStyle(context, 16, Colors.grey, FontWeight.w600),
                        ),
                      ),
                      Positioned(
                        top: -15,
                        right: Directionality.of(context) == TextDirection.ltr ? 15 : null,
                        left: Directionality.of(context) == TextDirection.ltr ? null : 15,
                        child: SvgPicture.asset(
                          'packages/booking_calendar/assets/id.svg',
                        ),
                      )
                    ],
                  ),
                  const HeightSpacer(size: 10),
                  Text(
                    "  Type",
                    style: appStyle(context, 18, Colors.black, FontWeight.w600),
                  ),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 10),
                        width: MediaQuery.sizeOf(context).width,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 5,
                            ),
                          ],
                        ),
                        child: Text(
                          "${patientData['examination_type'].toString()} ",
                          textAlign: TextAlign.start,
                          style: appStyle(context, 16, Colors.grey, FontWeight.w600),
                        ),
                      ),
                      Positioned(
                        top: -15,
                        right: Directionality.of(context) == TextDirection.ltr ? 15 : null,
                        left: Directionality.of(context) == TextDirection.ltr ? null : 15,
                        child: SvgPicture.asset(
                          'packages/booking_calendar/assets/examination.svg',
                        ),
                      )
                    ],
                  ),
                  const HeightSpacer(size: 15),
                  Center(
                    child: SizedBox(
                      width: double.infinity, // This makes the button take full width
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            )),
                        onPressed: () async {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          "Close",
                          style: appStyle(context, 18, Colors.white, FontWeight.w600),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

Future customerInfoDialog(BuildContext context) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => PopScope(
      canPop: false,
      onPopInvoked: (value) {
        if (value) return;
        Get.back(result: true);
      },
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        alignment: Alignment.center,
        backgroundColor: Colorz.white,
        insetPadding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 20.h),
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              width: MediaQuery.sizeOf(context).width,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Appointment Info', style: appStyle(context, 18, Colorz.black, FontWeight.w600)),
                  HeightSpacer(size: 10.h),
                  DropdownItem(
                    radius: 30,
                    color: Colorz.white,
                    isShadow: true,
                    iconData: Icon(
                      Icons.arrow_drop_down_circle,
                      color: Colorz.blue,
                    ),
                    items: ["mahmoud", "ahmed"],
                    selectedValue: "widget.cubit.selectedBranch",
                    hintText: 'Select Branch',
                    itemAsString: (item) => item.toString(),
                    onItemSelected: (item) {},
                    isLoading: false,
                    insideDialog: true,
                  ),
                  // ... other widgets
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
