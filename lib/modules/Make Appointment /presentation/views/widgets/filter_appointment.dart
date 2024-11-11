import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:ocurithm/modules/Make%20Appointment%20/presentation/manager/Make%20Appointment%20cubit/make_appointment_cubit.dart';

import '../../../../../core/utils/app_style.dart';
import '../../../../../core/utils/colors.dart';
import '../../../../../core/widgets/DropdownPackage.dart';
import '../../../../../core/widgets/height_spacer.dart';
import '../../../../../core/widgets/my_line.dart';
import '../../../../../core/widgets/width_spacer.dart';
import '../../manager/Make Appointment cubit/make_appointment_state.dart';

filterAppointment(context, MakeAppointmentCubit cubit) {
  final AnimationController animationController = AnimationController(
    duration: const Duration(milliseconds: 500), // Set the desired duration here
    vsync: Navigator.of(context),
  );
  return showModalBottomSheet(
      isScrollControlled: true,
      transitionAnimationController: animationController,
      context: context,
      backgroundColor: Colors.transparent,
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.4),
      builder: (context) {
        return filterAppointmentData(
          cubit: cubit,
        );
      });
}

class filterAppointmentData extends StatefulWidget {
  const filterAppointmentData({super.key, required this.cubit});
  final MakeAppointmentCubit cubit;

  @override
  State<filterAppointmentData> createState() => _filterAppointmentDataState();
}

class _filterAppointmentDataState extends State<filterAppointmentData> {
  TextEditingController noteController = TextEditingController();
  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  bool _filterLoading = false;
  bool _resetLoading = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
      },
      child: BlocBuilder<MakeAppointmentCubit, MakeAppointmentState>(
        bloc: widget.cubit,
        builder: (context, state) => SafeArea(
          child: Container(
            height: MediaQuery.sizeOf(context).height * 0.4,
            width: MediaQuery.sizeOf(context).width,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              color: Colorz.white,
            ),
            child: Column(
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
                            Get.back(result: true);
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
                        textAlign: TextAlign.center,
                        "Filter Appointment",
                        style: appStyle(context, 20, Colorz.primaryColor, FontWeight.w600),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Get.back(result: true);
                          },
                          child: Text(
                            "Add Patient",
                            style: appStyle(context, 18, Colors.transparent, FontWeight.w600),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const HeightSpacer(size: 10),
                MyLine(
                  height: 1,
                  color: Colorz.grey200,
                ),
                const HeightSpacer(size: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: DropdownItem(
                    radius: 30,
                    color: Colorz.white,
                    isShadow: true,
                    iconData: Icon(
                      Icons.arrow_drop_down_circle,
                      color: Colorz.primaryColor,
                    ),
                    items: widget.cubit.doctors?.doctors,
                    // isValid: widget.cubit.chooseBranch,
                    // validateText: S.of(context).mustBranch,
                    selectedValue: widget.cubit.selectedDoctor?.name,
                    hintText: 'Select Doctor',
                    itemAsString: (item) => item.name.toString(),
                    onItemSelected: (item) {
                      setState(() {
                        if (item != "Not Found") {
                          // widget.cubit.chooseBranch = true;
                          widget.cubit.selectedDoctor = item;
                          //  widget.cubit.branchId = item.id;
                          log(widget.cubit.selectedDoctor.toString());
                        }
                      });
                    },
                    isLoading: widget.cubit.doctors == null,
                  ),
                ),
                const HeightSpacer(size: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: DropdownItem(
                    radius: 30,
                    color: Colorz.white,
                    isShadow: true,
                    iconData: Icon(
                      Icons.arrow_drop_down_circle,
                      color: Colorz.primaryColor,
                    ),
                    items: widget.cubit.branches?.branches,
                    // isValid: widget.cubit.chooseBranch,
                    // validateText: S.of(context).mustBranch,
                    selectedValue: widget.cubit.selectedBranch?.name,
                    hintText: 'Select Branch',
                    itemAsString: (item) => item.name.toString(),
                    onItemSelected: (item) {
                      setState(() {
                        if (item != "Not Found") {
                          //   widget.cubit.chooseBranch = true;
                          widget.cubit.selectedBranch = item;
                          log(widget.cubit.selectedBranch!.id.toString());
                        }
                      });
                    },
                    isLoading: widget.cubit.branches == null,
                  ),
                ),
                Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                                foregroundColor: Colorz.redColor,
                                side: BorderSide(width: 1, color: Colorz.redColor),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                            onPressed: () async {
                              setState(() {
                                _resetLoading = true;
                                widget.cubit.selectedBranch = null;
                                widget.cubit.selectedDoctor = null;
                              });
                              Navigator.pop(context);
                              //  await widget.cubit.get();
                              _resetLoading = false;
                            },
                            child: _resetLoading
                                ? Container(width: 30, height: 30, child: CircularProgressIndicator(color: Colorz.redColor, strokeWidth: 2))
                                : Text("Reset", style: appStyle(context, 20, Colorz.redColor, FontWeight.w600))),
                      ),
                      const WidthSpacer(size: 20),
                      Expanded(
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colorz.primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                              onPressed: () async {
                                setState(() {
                                  _filterLoading = true;
                                });
                                //  await widget.cubit.getAppointments();
                                setState(() {
                                  _filterLoading = false;
                                });
                                Get.back(result: true);
                              },
                              child: _filterLoading
                                  ? Container(width: 30, height: 30, child: CircularProgressIndicator(color: Colorz.white, strokeWidth: 2))
                                  : Text("Filter", style: appStyle(context, 20, Colorz.white, FontWeight.w600)))),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
