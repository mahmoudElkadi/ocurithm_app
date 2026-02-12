import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' hide Transition;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart' as intl;
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:ocurithm/core/utils/capability_services.dart';
import 'package:ocurithm/core/utils/format_helper.dart';
import 'package:ocurithm/core/widgets/width_spacer.dart';
import 'package:ocurithm/modules/Appointment/presentation/views/widgets/calendar_slider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../core/utils/app_style.dart';
import '../../../../../core/utils/colors.dart';
import '../../../../../core/widgets/confirmation_popuo.dart';
import '../../../../../core/widgets/height_spacer.dart';
import '../../../../../core/widgets/manage_capabilities.dart';
import '../../../../../core/widgets/search_and_filter.dart';
import '../../../../Examination/presentation/views/examination_view.dart';
import '../../../data/models/appointment_model.dart';
import '../../manager/Appointment cubit/appointment_cubit.dart';

import 'delay_appointment.dart';
import 'filter_appointment.dart';

class AppointmentViewBody extends StatefulWidget {
  const AppointmentViewBody({super.key});

  @override
  State<AppointmentViewBody> createState() => _AppointmentViewBodyState();
}

class _AppointmentViewBodyState extends State<AppointmentViewBody> {
  DateTime? selectedMonth;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedMonth = DateTime.now();
    // Use addPostFrameCallback to trigger initial fetch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<AppointmentCubit>();
      cubit.add(GetAppointmentsEvent(date: DateTime.now()));
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void onDateSelected(DateTime date) {
    context.read<AppointmentCubit>().add(SelectDateEvent(date));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocBuilder<AppointmentCubit, AppointmentState>(
      builder: (context, state) {
        final cubit = context.read<AppointmentCubit>();
        
        return RefreshIndicator(
          onRefresh: () async {
            cubit.add(RefreshAppointmentsEvent());
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SearchAndFilter(
                    controller: _searchController,
                    backgroundColor: isDark ? theme.cardColor : Colors.white,
                    withShadow: true,
                    onChanged: () {
                      cubit.onSearchChanged(_searchController.text);
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
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isDark ? theme.cardColor : Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 0),
                              ),
                            ],
                          ),
                          child: Text(
                            selectedMonth != null
                                ? "${intl.DateFormat('MMMM').format(selectedMonth!)}-${selectedMonth!.year}"
                                : 'Select Month/Year',
                            style: appStyle(context, 18, isDark ? Colors.white : Colors.black, FontWeight.w600),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const HeightSpacer(size: 2),
                if (selectedMonth != null)
                  CalendarSliderWidget(
                    month: selectedMonth!.month,
                    selectedDate: state.selectedDate,
                    onDateSelected: onDateSelected,
                    year: selectedMonth!.year,
                  )
                else
                  const Center(child: Text('Please select a month')),
                const HeightSpacer(size: 10),
                const AppointmentListView()
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showMonthYearPicker(BuildContext context) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selected = await showMonthPicker(
      context: context,
      initialDate: selectedMonth ?? DateTime.now(),
      headerColor: Colorz.primaryColor,
      headerTextColor: isDark ? Colors.black : Colors.white,
      selectedMonthBackgroundColor: Colorz.primaryColor.withValues(alpha: 0.5),
      selectedMonthTextColor: Colors.white,
      unselectedMonthTextColor: isDark ? Colors.white70 : Colors.black,
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
      });
      // Trigger update in cubit if needed or let the UI handle month change
    }
  }
}

class ExpandableTimeSlots extends StatefulWidget {
  const ExpandableTimeSlots({
    super.key,
    this.title,
    this.image,
    required this.appointments,
  });

  final String? title;
  final String? image;
  final List<Appointment> appointments;

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

  List<Color> getThemeColors(String theme, bool isDark) {
    if (isDark) {
       switch (theme.toLowerCase()) {
      case 'afternoon':
        return [
          HexColor("#1A535C").withValues(alpha: 0.8),
          HexColor("#4ECDC4").withValues(alpha: 0.6),
        ];
      case 'morning':
        return [
          HexColor("#FF6B6B").withValues(alpha: 0.8),
          HexColor("#FFE66D").withValues(alpha: 0.6),
        ];
      case 'evening':
        return [
          HexColor("#292F36").withValues(alpha: 0.8),
          HexColor("#454B52").withValues(alpha: 0.6),
        ];
      default:
        return [
          Colors.grey[800]!,
          Colors.grey[700]!,
        ];
    }
    }
    
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Visibility(
      visible: widget.appointments.isNotEmpty,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: GestureDetector(
          onTap: toggleExpansion,
          child: Stack(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.only(top: 17),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: isDark ? theme.cardColor : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isDark ? theme.dividerColor : Colorz.grey, width: 0.3),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
                  child: AnimatedSize(
                    duration: const Duration(milliseconds: 200),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: isExpanded ? _buildTimeSlots(context.read<AppointmentCubit>()) : [],
                    ),
                  ),
                ),
              ),
              AnimatedPositioned(
                left: Directionality.of(context) == ui.TextDirection.ltr ? 20 : null,
                right: Directionality.of(context) == ui.TextDirection.rtl ? 20 : null,
                top: isExpanded ? 0 : 29,
                duration: const Duration(milliseconds: 200),
                child: AnimatedContainer(
                  padding: EdgeInsets.fromLTRB(isExpanded ? 10 : 0, 5, isExpanded ? 20 : 0, 5),
                  decoration: BoxDecoration(
                    color: isDark ? theme.cardColor : Colors.white,
                    gradient: LinearGradient(
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                      colors: isExpanded 
                          ? getThemeColors(widget.title ?? "Afternoon", isDark) 
                          : [isDark ? theme.cardColor : Colors.white, isDark ? theme.cardColor : Colors.white],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  duration: const Duration(milliseconds: 200),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        widget.image ?? "assets/icons/afternoon.svg",
                        width: 25,
                        height: 25,
                        colorFilter: isDark ? const ColorFilter.mode(Colors.white, BlendMode.srcIn) : null,
                      ),
                      const WidthSpacer(size: 5),
                      Text(
                        widget.title ?? "Afternoon",
                        style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 200),
                left: Directionality.of(context) == ui.TextDirection.rtl ? 20 : null,
                right: Directionality.of(context) == ui.TextDirection.ltr ? 20 : null,
                top: isExpanded ? 0 : 28,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: BoxDecoration(
                    color: isDark ? theme.cardColor : Colors.white,
                    border: Border.all(color: isExpanded ? Colors.transparent : (isDark ? theme.dividerColor : Colors.black), width: 0.3),
                    gradient: isExpanded
                        ? LinearGradient(
                            begin: Alignment.bottomRight,
                            end: Alignment.topLeft,
                            colors: getThemeColors(widget.title ?? "Afternoon", isDark),
                          )
                        : null,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    widget.appointments.length.toString(),
                    style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ],
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
      if (indexMatch(i, expandedIndex) || indexMatch(i + 1, expandedIndex)) {
        int currentExpIndex = expandedIndex!;
        slots.add(
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: _buildExpandedItem(currentExpIndex, appointments[currentExpIndex], cubit),
          ),
        );

        if (i == currentExpIndex) {
          if (i + 1 < appointments.length) {
             slots.add(
               Padding(
                 padding: const EdgeInsets.symmetric(vertical: 4),
                 child: Row(
                   children: [
                     Expanded(child: _buildRegularItem(i + 1, appointments[i + 1])),
                     const SizedBox(width: 8),
                     if (i + 2 < appointments.length)
                       Expanded(child: _buildRegularItem(i + 2, appointments[i + 2]))
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
        } else {
           if (i + 2 < appointments.length) {
             slots.add(
               Padding(
                 padding: const EdgeInsets.symmetric(vertical: 4),
                 child: Row(
                   children: [
                     Expanded(child: _buildRegularItem(i, appointments[i])),
                     const SizedBox(width: 8),
                     Expanded(child: _buildRegularItem(i + 2, appointments[i + 2])),
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
        if (i + 1 < appointments.length) {
          slots.add(
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(child: _buildRegularItem(i, appointments[i])),
                  const SizedBox(width: 8),
                  Expanded(child: _buildRegularItem(i + 1, appointments[i + 1])),
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

  bool indexMatch(int i, int? expIndex) {
    return expIndex != null && i == expIndex;
  }

  Widget _buildExpandedItem(int index, Appointment appointment, AppointmentCubit cubit) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: isDark ? theme.cardColor : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? theme.dividerColor : Colorz.grey, width: 0.3),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
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
                        SvgPicture.asset("assets/icons/doctor.svg", width: 18, height: 18, colorFilter: isDark ? const ColorFilter.mode(Colors.white, BlendMode.srcIn) : null),
                        const WidthSpacer(size: 8),
                        Text(
                          appointment.doctor?.name ?? 'Unknown',
                          style: appStyle(context, 16, isDark ? Colors.white : Colorz.black, FontWeight.w600),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.watch_later_outlined, size: 18, color: isDark ? Colors.white70 : Colors.black54),
                        const WidthSpacer(size: 8),
                        Text(
                          FormatHelper.formatTimes(context, appointment.datetime.toString()),
                          style: appStyle(context, 18, Colorz.redColor, FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.close, color: isDark ? Colors.white70 : Colors.black54),
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
            _buildInfoRow("assets/icons/branch.svg", appointment.branch?.name ?? 'No Branch', isDark),
            const SizedBox(height: 8),
            _buildInfoRow("assets/icons/patient.svg", appointment.patient?.name ?? 'No Name', isDark),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today_outlined, size: 16, color: isDark ? Colors.white70 : Colors.black54),
                const SizedBox(width: 8),
                Text(
                  "Age: ${FormatHelper.calculateAge(appointment.patient?.birthDate)}",
                  style: appStyle(context, 16, isDark ? Colors.white : Colorz.black, FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () async {
                if (appointment.patient?.phone != null) {
                  String url = "tel:${appointment.patient!.phone}";
                  if (!kIsWeb && await canLaunchUrl(Uri.parse(url))) {
                    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                  }
                }
              },
              child: Row(
                children: [
                  Icon(Icons.phone, size: 16, color: isDark ? Colors.white70 : Colors.black54),
                  const SizedBox(width: 8),
                  Text(
                    appointment.patient?.phone ?? 'No phone',
                    style: appStyle(context, 16, isDark ? Colors.white : Colorz.black, FontWeight.w500),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _buildInfoRow("assets/icons/status.svg", "Status: ${appointment.status ?? 'N/A'}", isDark),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.medical_services, size: 16, color: isDark ? Colors.white70 : Colors.black54),
                const SizedBox(width: 8),
                Expanded(
                  child: FittedBox(
                    alignment: Alignment.centerLeft,
                    fit: BoxFit.scaleDown,
                    child: Text(
                      appointment.examinationType?.name ?? 'Unknown',
                      style: appStyle(context, 16, isDark ? Colors.white : Colorz.black, FontWeight.w500),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (appointment.status != 'Completed' && appointment.status != 'Cancelled')
              _buildActionButtons(appointment, cubit),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String iconPath, String text, bool isDark) {
    return Row(
      children: [
        SvgPicture.asset(iconPath, width: 18, height: 18, colorFilter: isDark ? const ColorFilter.mode(Colors.white, BlendMode.srcIn) : null),
        const SizedBox(width: 8),
        Text(
          text,
          style: appStyle(context, 16, isDark ? Colors.white : Colorz.black, FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildActionButtons(Appointment appointment, AppointmentCubit cubit) {
    if (appointment.status == 'Examining' || appointment.status == 'Saved') {
      return manageCapability(
        capability: "editAppointmentsDoctor",
        child: Row(
          spacing: 10,
          children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colorz.primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () async {
                  if (CapabilityServices.hasCapability("manageExaminations")) {
                    bool? isChanged = await Get.to(
                      () => MultiStepFormPage(
                        appointment: appointment,
                        isSaved: appointment.status == 'Saved',
                      ),
                      transition: Transition.rightToLeft,
                      duration: const Duration(milliseconds: 500),
                    );
                    if (isChanged == true) {
                      cubit.add(GetAppointmentsEvent());
                    }
                  }
                },
                child: const Text("Examine", style: TextStyle(color: Colors.white)),
              ),
            ),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  _showActionDialog(context, cubit, appointment, 'wait', 'Wait');
                },
                child: const Text("Wait", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      );
    }

    return manageCapability(
      capability: "editAppointmentsReceptionist",
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildActionButton(Icons.done, Colors.green, () {
            _showActionDialog(context, cubit, appointment, 'proceed', 'Proceed');
          }, isFirst: true),
          const WidthSpacer(size: 1),
          _buildActionButtonSvg("assets/icons/sand_watch.svg", Colorz.secondaryColor, () {
             showConfirmationDialog(
              context: context,
              title: "Delay Appointment",
              message: "Do you want to delay the appointment for ${appointment.patient?.name ?? 'this patient'}?",
              icon: Icons.history,
              confirmColor: Colorz.secondaryColor,
              onConfirm: () async {
                bool? isResult = await Get.to(() => DelayAppointment(
                      appointment: appointment,
                      cubit: cubit,
                    ));
                if (isResult == true) {
                  cubit.add(GetAppointmentsEvent());
                }
              },
              onCancel: () {},
            );
          }),
          const WidthSpacer(size: 1),
          _buildActionButtonSvg("assets/icons/circle_half.svg", Colors.yellow.shade800, () {
            _showActionDialog(context, cubit, appointment, 'late', 'Late');
          }),
          const WidthSpacer(size: 1),
          _buildActionButton(Icons.close, Colors.red, () {
            _showActionDialog(context, cubit, appointment, 'cancel', 'Cancel');
          }, isLast: true),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, Color color, VoidCallback onPressed, {bool isFirst = false, bool isLast = false}) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: isFirst ? const Radius.circular(8) : Radius.zero,
            bottomLeft: isFirst ? const Radius.circular(8) : Radius.zero,
            topRight: isLast ? const Radius.circular(8) : Radius.zero,
            bottomRight: isLast ? const Radius.circular(8) : Radius.zero,
          ),
        ),
        side: BorderSide(color: color),
      ),
      onPressed: onPressed,
      child: Icon(icon, color: color, size: 25),
    );
  }

  Widget _buildActionButtonSvg(String asset, Color color, VoidCallback onPressed) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        side: BorderSide(color: color),
      ),
      onPressed: onPressed,
      child: SvgPicture.asset(asset, colorFilter: ColorFilter.mode(color, BlendMode.srcIn), width: 20, height: 20),
    );
  }

  void _showActionDialog(BuildContext context, AppointmentCubit cubit, Appointment appointment, String action, String title) {
    IconData icon;
    Color color;

    switch (action) {
      case 'proceed':
        icon = Icons.check_circle_outline;
        color = Colors.green;
        break;
      case 'late':
        icon = Icons.access_time;
        color = Colors.orange;
        break;
      case 'wait':
        icon = Icons.hourglass_empty;
        color = Colors.orange;
        break;
      case 'cancel':
        icon = Icons.cancel_outlined;
        color = Colors.red;
        break;
      default:
        icon = Icons.info_outline;
        color = Colorz.primaryColor;
    }

    showConfirmationDialog(
      context: context,
      title: "$title Appointment",
      message: "Are you sure you want to $action this appointment for ${appointment.patient?.name ?? 'this patient'}?",
      confirmColor: color,
      icon: icon,
      onConfirm: () async {
        cubit.add(EditAppointmentEvent(
          context: context,
          id: appointment.id.toString(),
          action: action,
        ));
      },
      onCancel: () {},
    );
  }

  Widget _buildRegularItem(int index, Appointment appointment) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          expandedIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? theme.cardColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withValues(alpha: 0.3) : Colorz.grey200.withValues(alpha: 0.7),
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
                FormatHelper.formatTimes(context, appointment.datetime.toString()),
                style: appStyle(context, 18, Colorz.redColor, FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    "Dr. ${appointment.doctor?.name ?? 'Unknown'}",
                    style: appStyle(context, 16, isDark ? Colors.white : Colorz.black, FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    appointment.patient?.name ?? 'No Patient',
                    style: appStyle(context, 14, isDark ? Colors.white70 : Colors.black87, FontWeight.w500),
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

class AppointmentListView extends StatelessWidget {
  const AppointmentListView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppointmentCubit, AppointmentState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const _LoadingList();
        } else if (state.appointments == null || state.appointments!.appointments.isEmpty) {
          return const _EmptyState();
        } else {
          return Column(
            children: [
              if (state.morningAppointments.isNotEmpty) ...[
                ExpandableTimeSlots(title: "Morning", image: "assets/icons/morning.svg", appointments: state.morningAppointments),
                const HeightSpacer(size: 10),
              ],
              if (state.afternoonAppointments.isNotEmpty) ...[
                ExpandableTimeSlots(title: "Afternoon", image: "assets/icons/afternoon.svg", appointments: state.afternoonAppointments),
                const HeightSpacer(size: 10),
              ],
              if (state.eveningAppointments.isNotEmpty) ...[
                ExpandableTimeSlots(title: "Evening", image: "assets/icons/evening.svg", appointments: state.eveningAppointments),
              ],
            ],
          );
        }
      },
    );
  }
}

class _LoadingList extends StatelessWidget {
  const _LoadingList();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: Column(
        children: List.generate(3, (index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          child: Container(
            width: double.infinity,
            height: 60,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: Colors.white),
          ),
        )),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const HeightSpacer(size: 30),
          Icon(Icons.event_busy, size: 70, color: isDark ? Colors.grey[700] : Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No Appointments Found',
            style: TextStyle(fontSize: 22, color: isDark ? Colors.grey[500] : Colors.grey[600], fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Appointments will appear here',
            style: TextStyle(fontSize: 18, color: isDark ? Colors.grey[600] : Colors.grey[400], fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
