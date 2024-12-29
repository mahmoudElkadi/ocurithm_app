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
    cubit.validateField('clinic', cubit.selectedClinic != null);
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

  Widget _buildClinicDropdown(MakeAppointmentCubit cubit) {
    return DropdownItem(
      radius: 30,
      color: Colorz.white,
      isShadow: true,
      iconData: Icon(Icons.arrow_drop_down_circle, color: Colorz.primaryColor),
      items: cubit.clinics?.clinics,
      isValid: cubit.validationState['doctor']!,
      validateText: "Must Select Clinic",
      selectedValue: cubit.selectedClinic?.name,
      hintText: 'Select Clinic',
      itemAsString: (item) => item.name.toString(),
      onItemSelected: (item) {
        setState(() {
          cubit.selectedClinic = item;
          cubit.selectedBranch = null;
        });
        cubit.getBranches();
      },
      isLoading: cubit.clinics == null,
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
                        _buildClinicDropdown(cubit),
                        const HeightSpacer(size: 15),
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
