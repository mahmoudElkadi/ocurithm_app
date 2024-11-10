import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ocurithm/core/widgets/custom_freeze_loading.dart';
import 'package:ocurithm/modules/Branch/data/model/branches_model.dart' as branch;
import 'package:ocurithm/modules/Make%20Appointment%20/data/repos/make_appointment_repo_impl.dart';
import 'package:ocurithm/modules/Make%20Appointment%20/presentation/manager/Make%20Appointment%20cubit/make_appointment_cubit.dart';
import 'package:ocurithm/modules/Patient/data/model/patients_model.dart';

import '../../../../../core/utils/app_style.dart';
import '../../../../../core/utils/booking_calendar/src/components/common_button.dart';
import '../../../../../core/utils/colors.dart';
import '../../../../../core/widgets/DropdownPackage.dart';
import '../../../../../core/widgets/height_spacer.dart';
import '../../../../../core/widgets/my_line.dart';
import '../../../../../core/widgets/text_field.dart';
import '../../../../Doctor/data/model/doctor_model.dart';
import '../../../../Examination Type/data/model/examination_type_model.dart';
import '../../../../Payment Methods/data/model/payment_method_model.dart';
import '../../../data/models/make_appointment_model.dart';
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
        return AppointmentForm(
          date: date,
        );
      });
}

class AppointmentForm extends StatefulWidget {
  const AppointmentForm({super.key, this.date});
  final DateTime? date;

  @override
  State<AppointmentForm> createState() => _AppointmentFormState();
}

class _AppointmentFormState extends State<AppointmentForm> {
  TextEditingController noteController = TextEditingController();
  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
  }

  Doctor? selectedDoctor;
  Patient? selectedPatient;
  branch.Branch? selectedBranch;
  PaymentMethod? selectedPaymentMethod;
  ExaminationType? selectedExaminationType;

  @override
  void initState() {
    super.initState();
    selectedDoctor = Doctor(
      name: 'Dr. John Doe',
      image: 'https://picsum.photos/200',
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
      },
      child: BlocProvider(
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
                          selectedValue: selectedDoctor?.name,
                          hintText: 'Select Doctor',
                          itemAsString: (item) => item.name.toString(),
                          onItemSelected: (item) {
                            setState(() {
                              if (item != "Not Found") {
                                // widget.cubit.chooseBranch = true;
                                selectedDoctor = item;
                                //  widget.cubit.branchId = item.id;
                                log(selectedDoctor.toString());
                              }
                            });
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
                          selectedValue: selectedPatient?.name,
                          hintText: 'Select Patient',
                          onChanged: (item) {
                            MakeAppointmentCubit.get(context).searchPatients();
                          },
                          searchController: MakeAppointmentCubit.get(context).patientController,
                          itemAsString: (item) => item.name.toString(),
                          onItemSelected: (item) {
                            setState(() {
                              if (item != "Not Found") {
                                // widget.cubit.chooseBranch = true;
                                selectedPatient = item;
                                log(selectedPatient!.id.toString());
                              }
                            });
                          },
                          isLoading: MakeAppointmentCubit.get(context).loadPatients,
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
                          selectedValue: selectedBranch?.name,
                          hintText: 'Select Branch',
                          itemAsString: (item) => item.name.toString(),
                          onItemSelected: (item) {
                            setState(() {
                              if (item != "Not Found") {
                                //   widget.cubit.chooseBranch = true;
                                selectedBranch = item;
                                log(selectedBranch!.id.toString());
                              }
                            });
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
                          selectedValue: selectedExaminationType?.name,
                          hintText: 'Select Examination Type',
                          itemAsString: (item) => item.name.toString(),
                          onItemSelected: (item) {
                            setState(() {
                              if (item != "Not Found") {
                                // widget.cubit.chooseBranch = true;
                                selectedExaminationType = item;
                                log(selectedExaminationType!.id.toString());
                              }
                            });
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
                          selectedValue: selectedPaymentMethod?.title,
                          hintText: 'Select Payment Method',
                          itemAsString: (item) => item.title.toString(),
                          onItemSelected: (item) {
                            setState(() {
                              if (item != "Not Found") {
                                //widget.cubit.chooseBranch = true;
                                selectedPaymentMethod = item;
                                log(selectedPaymentMethod!.id.toString());
                              }
                            });
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
                          controller: noteController,
                        ),
                        const Spacer(),
                        CommonButton(
                          text: 'Make Appointment',
                          onTap: () async {
                            if (selectedPatient != null &&
                                selectedBranch != null &&
                                selectedExaminationType != null &&
                                selectedPaymentMethod != null) {
                              customLoading(context, "");
                              await MakeAppointmentCubit.get(context).makeAppointment(
                                  context: context,
                                  model: MakeAppointmentModel(
                                      patient: selectedPatient!.id,
                                      branch: selectedBranch!.id,
                                      examinationType: selectedExaminationType!.id,
                                      paymentMethod: selectedPaymentMethod!.id,
                                      note: noteController.text,
                                      datetime: widget.date,
                                      doctor: selectedDoctor!.id,
                                      status: "Scheduled",
                                      clinic: "672b6748c642f2ffd02807ad"));
                            }
                          },
                        )
                      ])),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
