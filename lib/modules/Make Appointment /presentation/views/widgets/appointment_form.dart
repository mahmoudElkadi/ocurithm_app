import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ocurithm/core/utils/app_style.dart';
import 'package:ocurithm/modules/Make%20Appointment%20/presentation/manager/Make%20Appointment%20cubit/make_appointment_cubit.dart';

import '../../../../../core/utils/colors.dart';
import '../../../../../core/widgets/DropdownPackage.dart';
import '../../../../../core/widgets/height_spacer.dart';
import '../../../../../generated/l10n.dart';
import '../../manager/Make Appointment cubit/make_appointment_state.dart';

// showAppointmentBottomSheet(context, {DateTime? date, Appointment? appointment, Doctor? doctor, Branch? branch}) {
//   log(date.toString());
//   TextEditingController qualificationController = TextEditingController();
//   final AnimationController animationController = AnimationController(
//     duration: const Duration(milliseconds: 1000), // Set the desired duration here
//     vsync: Navigator.of(context),
//   );
//   log("doctorssssss" + doctor.toString());
//
//   return showModalBottomSheet(
//       isScrollControlled: true,
//       transitionAnimationController: animationController,
//       context: context,
//       backgroundColor: Colors.transparent,
//       constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.8),
//       builder: (context) {
//         return AppointmentForm(
//           date: date,
//           appointment: appointment,
//           doctor: doctor,
//           branch: branch,
//         );
//       });
// }
// class AppointmentForm extends StatefulWidget {
//   const AppointmentForm({super.key, this.date, this.appointment, this.doctor, this.branch});
//   final DateTime? date;
//   final Appointment? appointment;
//   final Doctor? doctor;
//   final Branch? branch;
//
//   @override
//   State<AppointmentForm> createState() => _AppointmentFormState();
// }
//
// class _AppointmentFormState extends State<AppointmentForm> {
//   TextEditingController noteController = TextEditingController();
//   @override
//   void dispose() {
//     noteController.dispose();
//     super.dispose();
//   }
//
//   Doctor? cubit.selectedDoctor;
//   Patient? cubit.selectedPatient;
//   branch.Branch? cubit.selectedBranch;
//   PaymentMethod? cubit.selectedPaymentMethod;
//   ExaminationType? cubit.selectedExaminationType;
//
//   @override
//   void initState() {
//     super.initState();
//
//     if (widget.appointment != null) {
//       cubit.selectedDoctor = widget.appointment?.doctor;
//       cubit.selectedPatient = widget.appointment?.patient;
//       cubit.selectedBranch = widget.appointment?.branch;
//       cubit.selectedPaymentMethod = widget.appointment?.paymentMethod;
//       cubit.selectedExaminationType = widget.appointment?.examinationType;
//       noteController.text = widget.appointment?.note ?? "";
//     }
//
//     if (widget.appointment == null && (widget.doctor != null || widget.branch != null)) {
//       cubit.selectedDoctor = widget.doctor;
//       cubit.selectedBranch = widget.branch;
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
//       },
//       child: BlocProvider(
//         create: (context) => MakeAppointmentCubit(MakeAppointmentRepoImpl())..getAllData(),
//         child: BlocBuilder<MakeAppointmentCubit, MakeAppointmentState>(
//           builder: (context, state) => SafeArea(
//             child: Container(
//               width: MediaQuery.sizeOf(context).width,
//               decoration: BoxDecoration(
//                 borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
//                 color: Colorz.white,
//               ),
//               child: Column(
//                 children: [
//                   const HeightSpacer(size: 10),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Expanded(
//                         flex: 2,
//                         child: Align(
//                           alignment: Alignment.centerLeft,
//                           child: TextButton(
//                             onPressed: () {
//                               log("dismissed");
//                               log(widget.doctor!.toJson().toString());
//                               log(widget.branch!.toJson().toString());
//                             },
//                             child: Text(
//                               "Dismiss",
//                               style: appStyle(context, 18, Colorz.redColor, FontWeight.w600),
//                             ),
//                           ),
//                         ),
//                       ),
//                       Expanded(
//                         flex: 3,
//                         child: Text(
//                           textAlign: TextAlign.center,
//                           "Add Appointment",
//                           style: appStyle(context, 20, Colorz.primaryColor, FontWeight.w600),
//                         ),
//                       ),
//                       Expanded(
//                         flex: 2,
//                         child: Align(
//                           alignment: Alignment.centerRight,
//                           child: TextButton(
//                             onPressed: () {
//                               Get.back(result: true);
//                             },
//                             child: Text(
//                               "Add Patient",
//                               style: appStyle(context, 18, Colorz.grey, FontWeight.w600),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const HeightSpacer(size: 10),
//                   MyLine(
//                     height: 1,
//                     color: Colorz.grey200,
//                   ),
//                   const HeightSpacer(size: 15),
//                   Container(
//                       constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.68),
//                       padding: EdgeInsets.symmetric(horizontal: 10.w),
//                       decoration: BoxDecoration(
//                         borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
//                         color: Colorz.white,
//                       ),
//                       child: Column(children: [
//                         DropdownItem(
//                           radius: 30,
//                           color: Colorz.white,
//                           isShadow: true,
//                           iconData: Icon(
//                             Icons.arrow_drop_down_circle,
//                             color: Colorz.primaryColor,
//                           ),
//                           items: MakeAppointmentCubit.get(context).doctors?.doctors,
//                           // isValid: widget.cubit.chooseBranch,
//                           // validateText: S.of(context).mustBranch,
//                           selectedValue: cubit.selectedDoctor?.name,
//                           hintText: 'Select Doctor',
//                           itemAsString: (item) => item.name.toString(),
//                           onItemSelected: (item) {
//                             setState(() {
//                               if (item != "Not Found") {
//                                 // widget.cubit.chooseBranch = true;
//                                 cubit.selectedDoctor = item;
//                                 //  widget.cubit.branchId = item.id;
//                                 log(cubit.selectedDoctor.toString());
//                               }
//                             });
//                           },
//                           isLoading: MakeAppointmentCubit.get(context).doctors == null,
//                         ),
//                         const HeightSpacer(size: 15),
//                         DropdownItem(
//                           radius: 30,
//                           color: Colorz.white,
//                           isShadow: true,
//                           iconData: Icon(
//                             Icons.arrow_drop_down_circle,
//                             color: Colorz.primaryColor,
//                           ),
//                           items: MakeAppointmentCubit.get(context).patients?.patients,
//                           // isValid: widget.cubit.chooseBranch,
//                           // validateText: S.of(context).mustBranch,
//                           selectedValue: cubit.selectedPatient?.name,
//                           hintText: 'Select Patient',
//                           onChanged: (item) {
//                             MakeAppointmentCubit.get(context).searchPatients();
//                           },
//                           searchController: MakeAppointmentCubit.get(context).patientController,
//                           itemAsString: (item) => item.name.toString(),
//                           onItemSelected: (item) {
//                             setState(() {
//                               if (item != "Not Found") {
//                                 // widget.cubit.chooseBranch = true;
//                                 cubit.selectedPatient = item;
//                                 log(cubit.selectedPatient!.id.toString());
//                               }
//                             });
//                           },
//                           isLoading: MakeAppointmentCubit.get(context).loadPatients,
//                         ),
//                         const HeightSpacer(size: 15),
//                         DropdownItem(
//                           radius: 30,
//                           color: Colorz.white,
//                           isShadow: true,
//                           iconData: Icon(
//                             Icons.arrow_drop_down_circle,
//                             color: Colorz.primaryColor,
//                           ),
//                           items: MakeAppointmentCubit.get(context).branches?.branches,
//                           // isValid: widget.cubit.chooseBranch,
//                           // validateText: S.of(context).mustBranch,
//                           selectedValue: cubit.selectedBranch?.name,
//                           hintText: 'Select Branch',
//                           itemAsString: (item) => item.name.toString(),
//                           onItemSelected: (item) {
//                             setState(() {
//                               if (item != "Not Found") {
//                                 //   widget.cubit.chooseBranch = true;
//                                 cubit.selectedBranch = item;
//                                 log(cubit.selectedBranch!.id.toString());
//                               }
//                             });
//                           },
//                           isLoading: MakeAppointmentCubit.get(context).branches == null,
//                         ),
//                         const HeightSpacer(size: 15),
//                         DropdownItem(
//                           radius: 30,
//                           color: Colorz.white,
//                           isShadow: true,
//                           iconData: Icon(
//                             Icons.arrow_drop_down_circle,
//                             color: Colorz.primaryColor,
//                           ),
//                           items: MakeAppointmentCubit.get(context).examinationTypes?.examinationTypes,
//                           // isValid: widget.cubit.chooseBranch,
//                           // validateText: S.of(context).mustBranch,
//                           selectedValue: cubit.selectedExaminationType?.name,
//                           hintText: 'Select Examination Type',
//                           itemAsString: (item) => item.name.toString(),
//                           onItemSelected: (item) {
//                             setState(() {
//                               if (item != "Not Found") {
//                                 // widget.cubit.chooseBranch = true;
//                                 cubit.selectedExaminationType = item;
//                                 log(cubit.selectedExaminationType!.id.toString());
//                               }
//                             });
//                           },
//                           isLoading: MakeAppointmentCubit.get(context).examinationTypes == null,
//                         ),
//                         const HeightSpacer(size: 15),
//                         DropdownItem(
//                           radius: 30,
//                           color: Colorz.white,
//                           isShadow: true,
//                           iconData: Icon(
//                             Icons.arrow_drop_down_circle,
//                             color: Colorz.primaryColor,
//                           ),
//                           items: MakeAppointmentCubit.get(context).paymentMethods?.paymentMethods,
//                           // isValid: widget.cubit.chooseBranch,
//                           // validateText: S.of(context).mustBranch,
//                           selectedValue: cubit.selectedPaymentMethod?.title,
//                           hintText: 'Select Payment Method',
//                           itemAsString: (item) => item.title.toString(),
//                           onItemSelected: (item) {
//                             setState(() {
//                               if (item != "Not Found") {
//                                 //widget.cubit.chooseBranch = true;
//                                 cubit.selectedPaymentMethod = item;
//                                 log(cubit.selectedPaymentMethod!.id.toString());
//                               }
//                             });
//                           },
//                           isLoading: MakeAppointmentCubit.get(context).paymentMethods == null,
//                         ),
//                         const HeightSpacer(size: 15),
//                         MultilineTextInput(
//                           hint: 'Enter Note Here',
//                           maxHeight: 200,
//                           onSubmitted: (text) {},
//                           textStyle: const TextStyle(
//                             fontSize: 16,
//                             color: Colors.black87,
//                           ),
//                           hintStyle: TextStyle(
//                             color: Colors.grey.shade500,
//                             fontSize: 16.sp,
//                             fontWeight: FontWeight.w600,
//                           ),
//                           color: Colorz.white,
//                           controller: noteController,
//                         ),
//                         const Spacer(),
//                         CommonButton(
//                           text: 'Make Appointment',
//                           onTap: () async {
//                             if (cubit.selectedPatient != null &&
//                                 cubit.selectedBranch != null &&
//                                 cubit.selectedExaminationType != null &&
//                                 cubit.selectedPaymentMethod != null) {
//                               if (widget.appointment != null) {
//                                 customLoading(context, "");
//
//                                 await MakeAppointmentCubit.get(context).editAppointment(
//                                   context: context,
//                                   model: MakeAppointmentModel(
//                                     patient: cubit.selectedPatient!.id,
//                                     branch: cubit.selectedBranch!.id,
//                                     examinationType: cubit.selectedExaminationType!.id,
//                                     paymentMethod: cubit.selectedPaymentMethod!.id,
//                                     note: noteController.text,
//                                     datetime: widget.date,
//                                     doctor: cubit.selectedDoctor!.id,
//                                     status: "Scheduled",
//                                     clinic: "672b6748c642f2ffd02807ad",
//                                     id: widget.appointment!.id.toString(),
//                                   ),
//                                 );
//                               } else {
//                                 customLoading(context, "");
//                                 await MakeAppointmentCubit.get(context).makeAppointment(
//                                     context: context,
//                                     model: MakeAppointmentModel(
//                                         patient: cubit.selectedPatient!.id,
//                                         branch: cubit.selectedBranch!.id,
//                                         examinationType: cubit.selectedExaminationType!.id,
//                                         paymentMethod: cubit.selectedPaymentMethod!.id,
//                                         note: noteController.text,
//                                         datetime: widget.date,
//                                         doctor: cubit.selectedDoctor!.id,
//                                         status: "Scheduled",
//                                         clinic: "672b6748c642f2ffd02807ad"));
//                               }
//                             }
//                           },
//                         )
//                       ])),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

class FormDataAppointment extends StatefulWidget {
  const FormDataAppointment({super.key});

  @override
  State<FormDataAppointment> createState() => _FormDataAppointmentState();
}

class _FormDataAppointmentState extends State<FormDataAppointment> {
  // Map to track field validation states

  Future<void> validateAndProceed(MakeAppointmentCubit cubit) async {
    // Validate all fields
    cubit.validateField('doctor', cubit.selectedDoctor != null);
    cubit.validateField('patient', cubit.selectedPatient != null);
    cubit.validateField('branch', cubit.selectedBranch != null);
    cubit.validateField('examinationType', cubit.selectedExaminationType != null);
    cubit.validateField('paymentMethod', cubit.selectedPaymentMethod != null);

    log(cubit.validationState.toString());

    if (cubit.isFormValid) {
      try {
        cubit.changeStep(1);
      } catch (e) {
        log(e.toString());
      }
    } else {
      log('Form is not valid');
    }
  }

  Widget _buildDoctorDropdown(MakeAppointmentCubit cubit) {
    return DropdownItem(
      radius: 30,
      color: Colorz.white,
      isShadow: true,
      iconData: Icon(Icons.arrow_drop_down_circle, color: Colorz.primaryColor),
      items: cubit.doctors?.doctors,
      isValid: cubit.validationState['doctor']!,
      validateText: "Must Select Doctor",
      selectedValue: cubit.selectedDoctor?.name,
      readOnly: cubit.selectedBranch == null,
      hintText: 'Select Doctor',
      itemAsString: (item) => item.name.toString(),
      onItemSelected: (item) {
        setState(() {
          cubit.selectedDoctor = item;
        });
      },
      isLoading: cubit.doctors == null,
    );
  }

  Widget _buildPatientDropdown(MakeAppointmentCubit cubit) {
    return DropdownItem(
      radius: 30,
      color: Colorz.white,
      isShadow: true,
      iconData: Icon(Icons.arrow_drop_down_circle, color: Colorz.primaryColor),
      items: cubit.patients?.patients,
      isValid: cubit.validationState['patient']!,
      validateText: "Must Select Patient",
      selectedValue: cubit.selectedPatient?.name,
      hintText: 'Select Patient',
      onChanged: (value) {
        cubit.patientController.text = value;
        cubit.searchPatients();
      },
      searchController: cubit.patientController,
      itemAsString: (item) => item.name.toString(),
      onItemSelected: (item) {
        setState(() {
          cubit.selectedPatient = item;
          //   validateField('patient', true);
        });
      },
      isLoading: cubit.loadPatients,
    );
  }

  Widget _buildBranchDropdown(MakeAppointmentCubit cubit) {
    return DropdownItem(
      radius: 30,
      color: Colorz.white,
      isShadow: true,
      iconData: Icon(Icons.arrow_drop_down_circle, color: Colorz.primaryColor),
      items: cubit.branches?.branches,
      isValid: cubit.validationState['branch']!,
      validateText: S.of(context).mustBranch,
      selectedValue: cubit.selectedBranch?.name,
      hintText: 'Select Branch',
      itemAsString: (item) => item.name.toString(),
      onItemSelected: (item) {
        setState(() {
          cubit.selectedBranch = item;
          cubit.selectedDoctor?.name = "";
          cubit.selectedDoctor = null;
        });
        cubit.getDoctors(branch: cubit.selectedBranch!.id!);
      },
      isLoading: cubit.branches == null,
    );
  }

  Widget _buildExaminationTypeDropdown(MakeAppointmentCubit cubit) {
    return DropdownItem(
      radius: 30,
      color: Colorz.white,
      isShadow: true,
      iconData: Icon(Icons.arrow_drop_down_circle, color: Colorz.primaryColor),
      items: cubit.examinationTypes?.examinationTypes,
      isValid: cubit.validationState['examinationType']!,
      validateText: "Must Select Examination Type",
      selectedValue: cubit.selectedExaminationType?.name,
      hintText: 'Select Examination Type',
      itemAsString: (item) => item.name.toString(),
      onItemSelected: (item) {
        setState(() {
          cubit.selectedExaminationType = item;
        });
      },
      isLoading: cubit.examinationTypes == null,
    );
  }

  Widget _buildPaymentMethodDropdown(MakeAppointmentCubit cubit) {
    return DropdownItem(
      radius: 30,
      color: Colorz.white,
      isShadow: true,
      iconData: Icon(Icons.arrow_drop_down_circle, color: Colorz.primaryColor),
      items: cubit.paymentMethods?.paymentMethods,
      isValid: cubit.validationState['paymentMethod']!,
      validateText: "Must Select Payment Method",
      selectedValue: cubit.selectedPaymentMethod?.title,
      hintText: 'Select Payment Method',
      itemAsString: (item) => item.title.toString(),
      onItemSelected: (item) {
        setState(() {
          cubit.selectedPaymentMethod = item;
        });
      },
      isLoading: cubit.paymentMethods == null,
    );
  }

  Widget _buildNextButton(MakeAppointmentCubit cubit) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: Size(double.infinity, 50.h),
          backgroundColor: Colorz.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: () => validateAndProceed(cubit),
        child: Text(
          "Next",
          style: appStyle(context, 20, Colorz.white, FontWeight.bold),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = MakeAppointmentCubit.get(context);

    return BlocBuilder<MakeAppointmentCubit, MakeAppointmentState>(
      builder: (context, state) => SafeArea(
        child: Container(
          width: MediaQuery.sizeOf(context).width,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            color: Colorz.white,
          ),
          child: Column(
            children: [
              const HeightSpacer(size: 15),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildBranchDropdown(cubit),
                        const HeightSpacer(size: 15),
                        _buildPatientDropdown(cubit),
                        const HeightSpacer(size: 15),
                        _buildDoctorDropdown(cubit),
                        const HeightSpacer(size: 15),
                        _buildExaminationTypeDropdown(cubit),
                        const HeightSpacer(size: 15),
                        _buildPaymentMethodDropdown(cubit),
                        const HeightSpacer(size: 30),
                      ],
                    ),
                  ),
                ),
              ),
              _buildNextButton(cubit),
              const HeightSpacer(size: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Clean up any controllers or listeners if needed
    super.dispose();
  }
}
