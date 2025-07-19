import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' hide Transition;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:intl/intl.dart' as intl;
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:ocurithm/core/Network/shared.dart';
import 'package:ocurithm/core/utils/format_helper.dart';
import 'package:ocurithm/core/widgets/width_spacer.dart';
import 'package:ocurithm/modules/Appointment/presentation/views/widgets/calendar_slider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../core/utils/app_style.dart';
import '../../../../../core/utils/colors.dart';
import '../../../../../core/widgets/confirmation_popuo.dart';
import '../../../../../core/widgets/custom_freeze_loading.dart';
import '../../../../../core/widgets/height_spacer.dart';
import '../../../../../core/widgets/search_and_filter.dart';
import '../../../../Examination/presentaion/views/examination_view.dart';
import '../../../../Patient/presentation/views/Patient Details/presentation/view/patient_details_view.dart';
import '../../../data/models/appointment_model.dart';
import '../../manager/Appointment cubit/appointment_cubit.dart';
import '../../manager/Appointment cubit/appointment_state.dart';
import 'delay_appointment.dart';
import 'filter_appointment.dart';

class AppointmentViewBody extends StatefulWidget {
  const AppointmentViewBody({super.key});

  @override
  State<AppointmentViewBody> createState() => _AppointmentViewBodyState();
}

class _AppointmentViewBodyState extends State<AppointmentViewBody> {
  var selectedDoctor;
  var selectedBranch;

  void onDateSelected(DateTime date) {
    setState(() {
      AppointmentCubit.get(context).selectedDate = date;
      AppointmentCubit.get(context).getAppointments();
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    selectedMonth = DateTime.now();
    AppointmentCubit.get(context).selectedDate = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = AppointmentCubit.get(context);

    return BlocBuilder<AppointmentCubit, AppointmentState>(
      builder: (context, state) => SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SearchAndFilter(
                controller: cubit.searchController,
                backgroundColor: Colorz.white,
                withShadow: true,
                onChanged: () {
                  cubit.getAppointments();
                },
                onTap: () => filterAppointment(context, cubit),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GestureDetector(
                    onTap: () => _showMonthYearPicker(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 7),
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                          color: Colorz.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 0),
                            ),
                          ]),
                      child: Text(
                        selectedMonth != null
                            ? "${intl.DateFormat('MMMM').format(selectedMonth!)}-${selectedMonth!.year}"
                            : 'Select Month/Year',
                        style: appStyle(
                            context, 18, Colorz.black, FontWeight.w600),
                      ),
                    ),
                  ),
                ),
                // InkWell(
                //   onTap: () => filterAppointment(context, cubit),
                //   child: Container(
                //     padding: const EdgeInsets.all(10),
                //     decoration: const BoxDecoration(
                //         color: Colors.transparent, shape: BoxShape.circle),
                //     child: Icon(
                //       Icons.filter_alt_rounded,
                //       color: Colorz.primaryColor,
                //     ),
                //   ),
                // )
              ],
            ),
            const HeightSpacer(size: 2),
            selectedMonth != null
                ? CalendarSliderWidget(
                    month: selectedMonth!.month,
                    selectedDate: AppointmentCubit.get(context).selectedDate,
                    onDateSelected: onDateSelected,
                    year: selectedMonth!.year,
                  )
                : const Center(child: Text('Please select a month')),
            const HeightSpacer(size: 10),
            const AppointmentListView()
          ],
        ),
      ),
    );
  }

  DateTime? selectedMonth;

  Future<void> _showMonthYearPicker(BuildContext context) async {
    final selected = await showMonthPicker(
      context: context,
      initialDate: selectedMonth ?? DateTime.now(),
      headerColor: Colorz.primaryColor,
      headerTextColor: Colors.black,
      selectedMonthBackgroundColor: Colorz.primaryColor.withOpacity(0.5),
      selectedMonthTextColor: Colors.white,
      unselectedMonthTextColor: Colors.black,
      currentMonthTextColor: Colors.green,
      cancelWidget: Text(
        'Cancel',
        style: appStyle(context, 16, Colorz.grey, FontWeight.w500),
      ),
      confirmWidget: Text(
        'Ok',
        style: appStyle(context, 16, Colorz.primaryColor, FontWeight.w500),
      ),
      dismissible: true,
      firstDate: DateTime(DateTime.now().year - 50),
      lastDate: DateTime(DateTime.now().year + 50),
    );

    if (selected != null) {
      setState(() {
        selectedMonth = selected;
        AppointmentCubit.get(context).afternoonAppointments.clear();
        AppointmentCubit.get(context).morningAppointments.clear();
        AppointmentCubit.get(context).eveningAppointments.clear();
      });
    }
  }
}

class ExpandableTimeSlots extends StatefulWidget {
  const ExpandableTimeSlots({
    super.key,
    this.title,
    this.image,
    required this.appointments, // Add appointments list parameter
  });

  final String? title;
  final String? image;
  final List<Appointment>
      appointments; // List of appointments for this time slot

  @override
  State<ExpandableTimeSlots> createState() => _ExpandableTimeSlotsState();
}

class _ExpandableTimeSlotsState extends State<ExpandableTimeSlots> {
  int? expandedIndex;
  bool isExpanded = false;

  void toggleExpansion() {
    setState(() {
      isExpanded = !isExpanded;
    });
  }

  List<Color> getThemeColors(String theme) {
    switch (theme.toLowerCase()) {
      case 'afternoon':
        return [
          HexColor("#C2FDF2"),
          HexColor("#CAF0F5"),
          HexColor("#DAD6FC"),
          HexColor("#DED0FE"),
        ];
      case 'morning':
        return [
          HexColor("#FDF598"),
          HexColor("#FCE7A9"),
          HexColor("#FBD5BF"),
          HexColor("#FAC0D8"),
          Colors.pink.shade300
        ];
      case 'evening':
        return [
          HexColor("#F8F8F8"),
          HexColor("#F0F0F0"),
          HexColor("#E8E8E8"),
        ];
      default:
        return [
          HexColor("#C2FDF2"),
          HexColor("#CAF0F5"),
          HexColor("#DAD6FC"),
          HexColor("#DED0FE"),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    // Only show if there are appointments
    return BlocBuilder<AppointmentCubit, AppointmentState>(
      builder: (context, state) => Visibility(
        visible: widget.appointments.isNotEmpty,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GestureDetector(
            onTap: toggleExpansion,
            child: Stack(
              children: [
                // Main Container
                Container(
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.only(top: 17),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: Colorz.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colorz.grey, width: 0.3),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 30),
                    child: AnimatedSize(
                      duration: const Duration(milliseconds: 200),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: isExpanded
                            ? _buildTimeSlots(AppointmentCubit.get(context))
                            : [],
                      ),
                    ),
                  ),
                ),

                // Time Slot Label
                AnimatedPositioned(
                  left: Directionality.of(context) == ui.TextDirection.ltr
                      ? 20
                      : null,
                  right: Directionality.of(context) == ui.TextDirection.rtl
                      ? 20
                      : null,
                  top: isExpanded ? 0 : 29,
                  duration: const Duration(milliseconds: 200),
                  child: AnimatedContainer(
                    padding: EdgeInsets.fromLTRB(
                        isExpanded ? 10 : 0, 5, isExpanded ? 20 : 0, 5),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        gradient: LinearGradient(
                          begin: Alignment.centerRight,
                          end: Alignment.centerLeft,
                          colors: isExpanded
                              ? getThemeColors(widget.title ?? "Afternoon")
                              : [Colorz.white, Colorz.white],
                        ),
                        borderRadius: BorderRadius.circular(20)),
                    duration: const Duration(milliseconds: 200),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          widget.image ?? "assets/icons/afternoon.svg",
                          width: 25,
                          height: 25,
                        ),
                        const WidthSpacer(size: 5),
                        Text(
                          widget.title ?? "Afternoon",
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),

                // Appointment Count Circle
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 200),
                  left: Directionality.of(context) == ui.TextDirection.rtl
                      ? 20
                      : null,
                  right: Directionality.of(context) == ui.TextDirection.ltr
                      ? 20
                      : null,
                  top: isExpanded ? 0 : 28,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                            color:
                                isExpanded ? Colors.transparent : Colors.black,
                            width: 0.3),
                        gradient: isExpanded
                            ? LinearGradient(
                                begin: Alignment.bottomRight,
                                end: Alignment.topLeft,
                                colors:
                                    getThemeColors(widget.title ?? "Afternoon"),
                              )
                            : null,
                        shape: BoxShape.circle),
                    child: Text(
                      widget.appointments.length.toString(),
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildTimeSlots(AppointmentCubit cubit) {
    List<Widget> slots = [];
    final appointments = widget.appointments;
    int i = 0;

    while (i < appointments.length) {
      if (i == expandedIndex ||
          (i + 1 == expandedIndex && i + 1 < appointments.length)) {
        // Add expanded item
        slots.add(
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: _buildExpandedItem(
                expandedIndex!, appointments[expandedIndex!], cubit),
          ),
        );

        if (i == expandedIndex) {
          if (i + 1 < appointments.length) {
            slots.add(
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                        child: _buildRegularItem(i + 1, appointments[i + 1])),
                    const SizedBox(width: 8),
                    if (i + 2 < appointments.length)
                      Expanded(
                          child: _buildRegularItem(i + 2, appointments[i + 2]))
                    else
                      const Expanded(child: SizedBox()),
                  ],
                ),
              ),
            );
            i += 3;
          } else {
            i++;
          }
        } else if (i + 1 == expandedIndex) {
          if (i + 2 < appointments.length) {
            slots.add(
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(child: _buildRegularItem(i, appointments[i])),
                    const SizedBox(width: 8),
                    Expanded(
                        child: _buildRegularItem(i + 2, appointments[i + 2])),
                  ],
                ),
              ),
            );
            i += 3;
          } else {
            slots.add(
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(child: _buildRegularItem(i, appointments[i])),
                    const SizedBox(width: 8),
                    const Expanded(child: SizedBox()),
                  ],
                ),
              ),
            );
            i += 2;
          }
        }
      } else {
        // Add regular pairs
        if (i + 1 < appointments.length) {
          slots.add(
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(child: _buildRegularItem(i, appointments[i])),
                  const SizedBox(width: 8),
                  Expanded(
                      child: _buildRegularItem(i + 1, appointments[i + 1])),
                ],
              ),
            ),
          );
          i += 2;
        } else {
          slots.add(
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(child: _buildRegularItem(i, appointments[i])),
                  const SizedBox(width: 8),
                  const Expanded(child: SizedBox()),
                ],
              ),
            ),
          );
          i++;
        }
      }
    }
    return slots;
  }

  Widget _buildExpandedItem(
      int index, Appointment appointment, AppointmentCubit cubit) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colorz.grey, width: 0.3),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          SvgPicture.asset("assets/icons/doctor.svg",
                              width: 18, height: 18),
                          const WidthSpacer(size: 8),
                          Text(
                            appointment.doctor?.name ?? 'Unknown',
                            style: appStyle(
                                context, 16, Colorz.black, FontWeight.w600),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.watch_later_outlined,
                            size: 18,
                          ),
                          const WidthSpacer(size: 8),
                          Text(
                            FormatHelper.formatTimes(
                                context, appointment.datetime.toString()),
                            style: appStyle(
                                context, 18, Colorz.redColor, FontWeight.w500),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        expandedIndex = null;
                      });
                    },
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                children: [
                  SvgPicture.asset("assets/icons/branch.svg",
                      width: 18, height: 18),
                  const SizedBox(width: 8),
                  Text(
                    appointment.branch?.name ?? 'No Branch',
                    style: appStyle(context, 16, Colorz.black, FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () async {
                  if (appointment.patient != null) {
                    bool? result = await Get.to(() => PatientDetailsView(
                        patient: appointment.patient!,
                        id: appointment.patient!.id.toString()));
                    if (result == true) {
                      setState(() {});
                    }
                  }
                },
                child: Ink(
                  child: Container(
                    color: Colors.transparent,
                    child: Row(
                      children: [
                        SvgPicture.asset("assets/icons/patient.svg",
                            width: 18, height: 18),
                        const SizedBox(width: 8),
                        Text(
                          appointment.patient?.name ?? 'No Name',
                          style: appStyle(
                              context, 16, Colorz.black, FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () async {
                  if (appointment.patient?.phone != null) {
                    String url = "tel:${appointment.patient!.phone}";
                    if (!kIsWeb && await canLaunchUrl(Uri.parse(url))) {
                      await launchUrl(Uri.parse(url),
                          mode: LaunchMode.externalApplication);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Could not call ${appointment.patient?.phone}'),
                        ),
                      );
                    }
                  }
                },
                child: Row(
                  children: [
                    const Icon(Icons.phone, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      appointment.patient?.phone ?? 'No phone',
                      style:
                          appStyle(context, 16, Colorz.black, FontWeight.w500),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  SvgPicture.asset(
                    "assets/icons/status.svg",
                    width: 18,
                    height: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Status: ${appointment.status ?? 'N/A'}",
                    style: appStyle(context, 16, Colorz.black, FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.medical_services, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FittedBox(
                      alignment: Alignment.centerLeft,
                      fit: BoxFit.scaleDown,
                      child: Text(
                        appointment.examinationType?.name ?? 'Unknown',
                        style: appStyle(
                            context, 16, Colorz.black, FontWeight.w500),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (appointment.status != 'Completed' &&
                  appointment.status != 'Cancelled')
                appointment.status != 'Examining' &&
                        CacheHelper.getStringList(key: "capabilities")
                            .contains("editAppointmentsReciptionist")
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(8.r),
                                    bottomLeft: Radius.circular(8.r)),
                              ),
                              //   backgroundColor: Colors.green,
                              side: const BorderSide(
                                  color: Colors.green,
                                  strokeAlign: BorderSide.strokeAlignOutside),
                            ),
                            onPressed: () async {
                              showConfirmationDialog(
                                context: context,
                                title: "Proceed Appointment",
                                message:
                                    "Do you want to Proceed this Appointment?",
                                onConfirm: () async {
                                  customLoading(context, "");
                                  bool value = await InternetConnection()
                                      .hasInternetAccess;
                                  if (!value) {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(const SnackBar(
                                      content: Text('No Internet Connection',
                                          style:
                                              TextStyle(color: Colors.white)),
                                      backgroundColor: Colors.red,
                                    ));
                                    return;
                                  }
                                  cubit.editAppointment(
                                      context: context,
                                      id: appointment.id.toString(),
                                      action: 'proceed');
                                },
                                onCancel: () {
                                  Navigator.pop(context);
                                },
                              );
                            },
                            child: const Icon(
                              Icons.done,
                              color: Colors.green,
                              size: 25,
                            ),
                          ),
                          const WidthSpacer(size: 1),
                          OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(0.r),
                                ),
                                side: BorderSide(
                                    color: Colorz.secondaryColor,
                                    strokeAlign: BorderSide.strokeAlignOutside),
                                //  backgroundColor: Colorz.primaryColor
                              ),
                              onPressed: () async {
                                showConfirmationDialog(
                                  context: context,
                                  title: "Delay Appointment",
                                  message:
                                      "Do you want to Delay this Appointment?",
                                  onConfirm: () async {
                                    bool? isResult = false;

                                    isResult =
                                        await Get.off(() => DelayAppointment(
                                              appointment: appointment,
                                              cubit: cubit,
                                            ));
                                    if (isResult == true) {
                                      cubit.getAppointments();
                                    }
                                  },
                                  onCancel: () {
                                    Navigator.pop(context);
                                  },
                                );
                              },
                              child: SvgPicture.asset(
                                "assets/icons/sand_watch.svg",
                                colorFilter: ColorFilter.mode(
                                    Colorz.secondaryColor, BlendMode.srcIn),
                                width: 20,
                                height: 20,
                              )),
                          const WidthSpacer(size: 1),
                          OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(0.r),
                                ),
                                //   backgroundColor: Colors.yellow.shade800,
                                side: BorderSide(
                                    color: Colors.yellow.shade800,
                                    strokeAlign: BorderSide.strokeAlignOutside),
                              ),
                              onPressed: () async {
                                showConfirmationDialog(
                                  context: context,
                                  title: "Late Appointment",
                                  message:
                                      "Do you want to Late this Appointment?",
                                  onConfirm: () async {
                                    customLoading(context, "");
                                    bool value = await InternetConnection()
                                        .hasInternetAccess;
                                    if (!value) {
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                        content: Text('No Internet Connection',
                                            style:
                                                TextStyle(color: Colors.white)),
                                        backgroundColor: Colors.red,
                                      ));
                                      return;
                                    }
                                    cubit.editAppointment(
                                        context: context,
                                        id: appointment.id.toString(),
                                        action: 'late');
                                  },
                                  onCancel: () {
                                    Navigator.pop(context);
                                  },
                                );
                              },
                              child: SvgPicture.asset(
                                "assets/icons/circle_half.svg",
                                colorFilter: ColorFilter.mode(
                                    Colors.yellow.shade800, BlendMode.srcIn),
                                width: 20,
                                height: 20,
                              )),
                          const WidthSpacer(size: 1),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(8.r),
                                    bottomRight: Radius.circular(8.r)),
                              ),
                              // backgroundColor: Colors.red,
                              side: const BorderSide(
                                  color: Colors.red,
                                  strokeAlign: BorderSide.strokeAlignOutside),
                            ),
                            onPressed: () async {
                              showConfirmationDialog(
                                context: context,
                                title: "Cancel Appointment",
                                message:
                                    "Do you want to Cancel this Appointment?",
                                onConfirm: () async {
                                  customLoading(context, "");
                                  bool value = await InternetConnection()
                                      .hasInternetAccess;
                                  if (!value) {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(const SnackBar(
                                      content: Text('No Internet Connection',
                                          style:
                                              TextStyle(color: Colors.white)),
                                      backgroundColor: Colors.red,
                                    ));
                                    return;
                                  }
                                  cubit.editAppointment(
                                      context: context,
                                      id: appointment.id.toString(),
                                      action: 'cancel');
                                },
                                onCancel: () {
                                  Navigator.pop(context);
                                },
                              );
                            },
                            child: const Icon(Icons.close,
                                color: Colors.red, size: 25),
                          ),
                        ],
                      )
                    : appointment.status == 'Examining' &&
                            CacheHelper.getStringList(key: "capabilities")
                                .contains("editAppointmentsDoctor")
                        ? Row(spacing: 10, children: [
                            Expanded(
                              child: ElevatedButton(
                                  style: ButtonStyle(
                                      backgroundColor:
                                          WidgetStateProperty.all<Color>(
                                              Colorz.primaryColor),
                                      shape: WidgetStateProperty.all<
                                          RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      )),
                                  onPressed: () async {
                                    if (CacheHelper.getStringList(
                                            key: "capabilities")
                                        .contains("manageExaminations")) {
                                      bool? isChanged = await Get.to(
                                          () => MultiStepFormPage(
                                                appointment: appointment,
                                              ),
                                          transition: Transition.rightToLeft,
                                          duration: const Duration(
                                              milliseconds: 500));
                                      if (isChanged == true) {
                                        appointment.status = 'Completed';
                                        setState(() {});
                                      }
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                        content: Text('Permission Denied',
                                            style:
                                                TextStyle(color: Colors.white)),
                                        backgroundColor: Colors.red,
                                      ));
                                    }
                                  },
                                  child: const Text(
                                    "Examine",
                                    style: TextStyle(color: Colors.white),
                                  )),
                            ),
                            Expanded(
                              child: ElevatedButton(
                                  style: ButtonStyle(
                                      backgroundColor:
                                          WidgetStateProperty.all<Color>(
                                              Colors.orange),
                                      shape: WidgetStateProperty.all<
                                          RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      )),
                                  onPressed: () {
                                    showConfirmationDialog(
                                      context: context,
                                      title: "Wait Appointment",
                                      message:
                                          "Do you want to Wait this Appointment?",
                                      onConfirm: () async {
                                        customLoading(context, "");
                                        bool value = await InternetConnection()
                                            .hasInternetAccess;
                                        if (!value) {
                                          Navigator.pop(context);
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(const SnackBar(
                                            content: Text(
                                                'No Internet Connection',
                                                style: TextStyle(
                                                    color: Colors.white)),
                                            backgroundColor: Colors.red,
                                          ));
                                          return;
                                        }
                                        cubit.editAppointment(
                                            context: context,
                                            id: appointment.id.toString(),
                                            action: 'wait');
                                      },
                                      onCancel: () {
                                        Navigator.pop(context);
                                      },
                                    );
                                  },
                                  child: const Text(
                                    "Wait",
                                    style: TextStyle(color: Colors.white),
                                  )),
                            ),
                          ])
                        : const SizedBox.shrink()
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRegularItem(int index, Appointment appointment) {
    return GestureDetector(
      onTap: () {
        setState(() {
          expandedIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colorz.grey200.withOpacity(0.7),
              spreadRadius: 2,
              blurRadius: 5,
            )
          ],
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                FormatHelper.formatTimes(
                    context, appointment.datetime.toString()),
                style: appStyle(context, 18, Colorz.redColor, FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    "Dr. ${appointment.doctor?.name ?? 'Unknown'}",
                    style: appStyle(context, 16, Colorz.black, FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppointmentListView extends StatefulWidget {
  const AppointmentListView({Key? key}) : super(key: key);

  @override
  State<AppointmentListView> createState() => _AppointmentListViewState();
}

class _AppointmentListViewState extends State<AppointmentListView> {
  Widget _buildShimmer(Widget child) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppointmentCubit, AppointmentState>(
      builder: (context, state) {
        final cubit = context.read<AppointmentCubit>();
        bool isLoading = AppointmentCubit.get(context).appointments == null;
        bool isEmpty =
            AppointmentCubit.get(context).appointments?.appointments.isEmpty ??
                true;

        if (isLoading) {
          return _buildLoadingList(isLoading);
        } else if (isEmpty) {
          return _buildEmptyState();
        } else {
          return _buildAppointmentList(cubit);
        }
      },
    );
  }

  Widget _buildLoadingList(bool isLoading) {
    return Column(
      children: [
        isLoading
            ? _buildShimmer(Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  width: MediaQuery.sizeOf(context).width,
                  height: 40,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    color: Colors.white,
                  ),
                ),
              ))
            : const ExpandableTimeSlots(
                title: "Morning",
                image: "assets/icons/morning.svg",
                appointments: [],
              ),
        const HeightSpacer(size: 10),
        isLoading
            ? _buildShimmer(Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  width: MediaQuery.sizeOf(context).width,
                  height: 40,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    color: Colors.white,
                  ),
                ),
              ))
            : const ExpandableTimeSlots(
                title: "Afternoon",
                image: "assets/icons/afternoon.svg",
                appointments: [],
              ),
        const HeightSpacer(size: 10),
        isLoading
            ? _buildShimmer(Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  width: MediaQuery.sizeOf(context).width,
                  height: 40,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    color: Colors.white,
                  ),
                ),
              ))
            : const ExpandableTimeSlots(
                title: "Evening",
                image: "assets/icons/evening.svg",
                appointments: [],
              ),
      ],
    );
  }

  Widget _buildAppointmentList(AppointmentCubit cubit) {
    return Column(
      children: [
        if (cubit.morningAppointments.isNotEmpty) ...[
          ExpandableTimeSlots(
            title: "Morning",
            image: "assets/icons/morning.svg",
            appointments: cubit.morningAppointments,
          ),
          const HeightSpacer(size: 10),
        ],
        if (cubit.afternoonAppointments.isNotEmpty) ...[
          ExpandableTimeSlots(
            title: "Afternoon",
            image: "assets/icons/afternoon.svg",
            appointments: cubit.afternoonAppointments,
          ),
          const HeightSpacer(size: 10),
        ],
        if (cubit.eveningAppointments.isNotEmpty) ...[
          ExpandableTimeSlots(
            title: "Evening",
            image: "assets/icons/evening.svg",
            appointments: cubit.eveningAppointments,
          ),
        ],
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const HeightSpacer(size: 30),
          Icon(Icons.event_busy, size: 70, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No Appointments Found',
            style: TextStyle(
                fontSize: 22,
                color: Colors.grey[600],
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Appointments will appear here',
            style: TextStyle(
                fontSize: 18,
                color: Colors.grey[400],
                fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
