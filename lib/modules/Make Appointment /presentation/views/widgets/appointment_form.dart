import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ocurithm/core/widgets/height_spacer.dart';
import 'package:ocurithm/core/widgets/my_line.dart';
import 'package:ocurithm/modules/Make%20Appointment%20/data/repos/make_appointment_repo_impl.dart';
import 'package:ocurithm/modules/Make%20Appointment%20/presentation/manager/Make%20Appointment%20cubit/make_appointment_cubit.dart';

import '../../../../../core/utils/app_style.dart';
import '../../../../../core/utils/booking_calendar/src/components/common_button.dart';
import '../../../../../core/utils/colors.dart';
import '../../../../../core/widgets/DropdownPackage.dart';
import '../../../../../core/widgets/text_field.dart';
import '../../manager/Make Appointment cubit/make_appointment_state.dart';

showAppointmentBottomSheet(context, {DateTime? date}) {
  log(date.toString());
  TextEditingController qualificationController = TextEditingController();
  final AnimationController animationController = AnimationController(
    duration: const Duration(milliseconds: 1000), // Set the desired duration here
    vsync: Navigator.of(context),
  );
  return showModalBottomSheet(
      isScrollControlled: true,
      transitionAnimationController: animationController,
      context: context,
      backgroundColor: Colors.transparent,
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.8),
      builder: (context) {
        return BlocProvider(
          create: (context) => MakeAppointmentCubit(MakeAppointmentRepoImpl())..getAllData(),
          child: BlocBuilder<MakeAppointmentCubit, MakeAppointmentState>(
            builder: (context, state) => SafeArea(
              child: Container(
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
                            "Add Appointment",
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
                                style: appStyle(context, 18, Colorz.grey, FontWeight.w600),
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
                    Container(
                        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.68),
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                          color: Colorz.white,
                        ),
                        child: Column(children: [
                          DropdownItem(
                            radius: 30,
                            color: Colorz.white,
                            isShadow: true,
                            iconData: Icon(
                              Icons.arrow_drop_down_circle,
                              color: Colorz.primaryColor,
                            ),
                            items: MakeAppointmentCubit.get(context).doctors?.doctors,
                            // isValid: widget.cubit.chooseBranch,
                            // validateText: S.of(context).mustBranch,
                            selectedValue: "",
                            hintText: 'Select Doctor',
                            itemAsString: (item) => item.name.toString(),
                            onItemSelected: (item) {
                              // setState(() {
                              //   if (item != "Not Found") {
                              //     widget.cubit.chooseBranch = true;
                              //     widget.cubit.selectedBranch = item.name;
                              //     widget.cubit.branchId = item.id;
                              //     log(widget.cubit.selectedBranch.toString());
                              //   }
                              // });
                            },
                            isLoading: MakeAppointmentCubit.get(context).doctors == null,
                          ),
                          const HeightSpacer(size: 15),
                          DropdownItem(
                            radius: 30,
                            color: Colorz.white,
                            isShadow: true,
                            iconData: Icon(
                              Icons.arrow_drop_down_circle,
                              color: Colorz.primaryColor,
                            ),
                            items: MakeAppointmentCubit.get(context).patients?.patients,
                            // isValid: widget.cubit.chooseBranch,
                            // validateText: S.of(context).mustBranch,
                            selectedValue: "",
                            hintText: 'Select Patient',
                            itemAsString: (item) => item.name.toString(),
                            onItemSelected: (item) {
                              // setState(() {
                              //   if (item != "Not Found") {
                              //     widget.cubit.chooseBranch = true;
                              //     widget.cubit.selectedBranch = item.name;
                              //     widget.cubit.branchId = item.id;
                              //     log(widget.cubit.selectedBranch.toString());
                              //   }
                              // });
                            },
                            isLoading: MakeAppointmentCubit.get(context).patients == null,
                          ),
                          const HeightSpacer(size: 15),
                          DropdownItem(
                            radius: 30,
                            color: Colorz.white,
                            isShadow: true,
                            iconData: Icon(
                              Icons.arrow_drop_down_circle,
                              color: Colorz.primaryColor,
                            ),
                            items: MakeAppointmentCubit.get(context).branches?.branches,
                            // isValid: widget.cubit.chooseBranch,
                            // validateText: S.of(context).mustBranch,
                            selectedValue: "",
                            hintText: 'Select Branch',
                            itemAsString: (item) => item.name.toString(),
                            onItemSelected: (item) {
                              // setState(() {
                              //   if (item != "Not Found") {
                              //     widget.cubit.chooseBranch = true;
                              //     widget.cubit.selectedBranch = item.name;
                              //     widget.cubit.branchId = item.id;
                              //     log(widget.cubit.selectedBranch.toString());
                              //   }
                              // });
                            },
                            isLoading: MakeAppointmentCubit.get(context).branches == null,
                          ),
                          const HeightSpacer(size: 15),
                          DropdownItem(
                            radius: 30,
                            color: Colorz.white,
                            isShadow: true,
                            iconData: Icon(
                              Icons.arrow_drop_down_circle,
                              color: Colorz.primaryColor,
                            ),
                            items: MakeAppointmentCubit.get(context).examinationTypes?.examinationTypes,
                            // isValid: widget.cubit.chooseBranch,
                            // validateText: S.of(context).mustBranch,
                            selectedValue: "",
                            hintText: 'Select Examination Type',
                            itemAsString: (item) => item.name.toString(),
                            onItemSelected: (item) {
                              // setState(() {
                              //   if (item != "Not Found") {
                              //     widget.cubit.chooseBranch = true;
                              //     widget.cubit.selectedBranch = item.name;
                              //     widget.cubit.branchId = item.id;
                              //     log(widget.cubit.selectedBranch.toString());
                              //   }
                              // });
                            },
                            isLoading: MakeAppointmentCubit.get(context).examinationTypes == null,
                          ),
                          const HeightSpacer(size: 15),
                          DropdownItem(
                            radius: 30,
                            color: Colorz.white,
                            isShadow: true,
                            iconData: Icon(
                              Icons.arrow_drop_down_circle,
                              color: Colorz.primaryColor,
                            ),
                            items: MakeAppointmentCubit.get(context).paymentMethods?.paymentMethods,
                            // isValid: widget.cubit.chooseBranch,
                            // validateText: S.of(context).mustBranch,
                            selectedValue: "",
                            hintText: 'Select Payment Method',
                            itemAsString: (item) => item.title.toString(),
                            onItemSelected: (item) {
                              // setState(() {
                              //   if (item != "Not Found") {
                              //     widget.cubit.chooseBranch = true;
                              //     widget.cubit.selectedBranch = item.name;
                              //     widget.cubit.branchId = item.id;
                              //     log(widget.cubit.selectedBranch.toString());
                              //   }
                              // });
                            },
                            isLoading: MakeAppointmentCubit.get(context).paymentMethods == null,
                          ),
                          const HeightSpacer(size: 15),
                          MultilineTextInput(
                            hint: 'Enter Note Here',
                            maxHeight: 200,
                            onSubmitted: (text) {},
                            textStyle: const TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                            hintStyle: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                            color: Colorz.white,
                            controller: qualificationController,
                          ),
                          const Spacer(),
                          CommonButton(
                            text: 'Make Appointment',
                            onTap: () async {},
                          )
                        ])),
                  ],
                ),
              ),
            ),
          ),
        );
      });
}
