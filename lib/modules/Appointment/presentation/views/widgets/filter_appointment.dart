import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocurithm/core/widgets/manage_capabilities.dart';

import '../../../../../core/utils/app_style.dart';
import '../../../../../core/utils/colors.dart';
import '../../../../../core/widgets/DropdownPackage.dart';
import '../../../../../core/widgets/height_spacer.dart';
import '../../../../../core/widgets/my_line.dart';
import '../../../../../core/widgets/width_spacer.dart';
import '../../manager/Appointment cubit/appointment_cubit.dart';

filterAppointment(BuildContext context, AppointmentCubit cubit) {
  return showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return filterAppointmentData(
          cubit: cubit,
        );
      });
}

class filterAppointmentData extends StatefulWidget {
  const filterAppointmentData({super.key, required this.cubit});
  final AppointmentCubit cubit;

  @override
  State<filterAppointmentData> createState() => _filterAppointmentDataState();
}

class _filterAppointmentDataState extends State<filterAppointmentData> {
  @override
  void initState() {
    super.initState();
    widget.cubit.add(GetBranchesEvent());
    widget.cubit.add(GetDoctorsEvent());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
      },
      child: BlocBuilder<AppointmentCubit, AppointmentState>(
        bloc: widget.cubit,
        builder: (context, state) => Container(
          // height: MediaQuery.sizeOf(context).height * 0.4,
          // width: MediaQuery.sizeOf(context).width,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            color: isDark ? theme.cardColor : Colorz.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const HeightSpacer(size: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 2,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          "Dismiss",
                          style: appStyle(context, 18, Colorz.redColor, FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      "Filter Appointment",
                      textAlign: TextAlign.center,
                      style: appStyle(context, 20, Colorz.primaryColor, FontWeight.w600),
                    ),
                  ),
                  const Expanded(
                    flex: 2,
                    child: SizedBox(),
                  ),
                ],
              ),
              const HeightSpacer(size: 10),
              MyLine(
                height: 1,
                color: isDark ? theme.dividerColor : Colorz.grey200,
              ),
              const HeightSpacer(size: 15),
              manageCapability(
                capability: 'showDoctors',
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: DropdownItem(
                    radius: 30,
                    color: isDark ? theme.canvasColor : Colorz.white,
                    isShadow: true,
                    iconData: Icon(
                      Icons.arrow_drop_down_circle,
                      color: Colorz.primaryColor,
                    ),
                    items: state.doctors?.doctors,
                    selectedValue: state.selectedDoctor?.name,
                    hintText: 'Select Doctor',
                    itemAsString: (item) => item.name.toString(),
                    onItemSelected: (item) {
                      if (item != "Not Found") {
                        widget.cubit.add(SelectDoctorEvent(item));
                      }
                    },
                    isLoading: state.status == AppointmentStatus.loadingDoctors,
                  ),
                ),
              ),
              const HeightSpacer(size: 15),
              manageCapability(
                capability: 'showBranches',
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: DropdownItem(
                    radius: 30,
                    color: isDark ? theme.canvasColor : Colorz.white,
                    isShadow: true,
                    iconData: Icon(
                      Icons.arrow_drop_down_circle,
                      color: Colorz.primaryColor,
                    ),
                    items: state.branches?.branches,
                    selectedValue: state.selectedBranch?.name,
                    hintText: 'Select Branch',
                    itemAsString: (item) => item.name.toString(),
                    onItemSelected: (item) {
                      if (item != "Not Found") {
                        widget.cubit.add(SelectBranchEvent(item));
                      }
                    },
                    isLoading: state.status == AppointmentStatus.loadingBranches,
                  ),
                ),
              ),
              const HeightSpacer(size: 15),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colorz.redColor,
                          side:  BorderSide(width: 1, color: Colorz.redColor),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {
                          widget.cubit.add(SelectDoctorEvent(null));
                          widget.cubit.add(SelectBranchEvent(null));
                          widget.cubit.add(GetAppointmentsEvent());
                          Navigator.pop(context);
                        },
                        child: Text("Reset", style: appStyle(context, 18, Colorz.redColor, FontWeight.w600)),
                      ),
                    ),
                    const WidthSpacer(size: 20),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colorz.primaryColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {
                          widget.cubit.add(GetAppointmentsEvent());
                          Navigator.pop(context);
                        },
                        child: Text("Filter", style: appStyle(context, 18, Colors.white, FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ),
              const HeightSpacer(size: 22),

            ],
          ),
        ),
      ),
    );
  }
}
