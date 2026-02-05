import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ocurithm/core/utils/app_style.dart';
import 'package:ocurithm/modules/Make_Appointment/presentation/manager/Make Appointment cubit/make_appointment_cubit.dart';
import '../../../../Clinics/presentation/manager/get_clinics_cubit/get_clinics_cubit.dart';
import '../../../../Branch/presentation/manager/get_branches_cubit/get_branches_cubit.dart';
import '../../../../Doctor/presentation/manager/get_doctors_cubit/get_doctors_cubit.dart' hide SetClinicFilterEvent;
import '../../../../Patient/presentation/manager/get_patients_cubit/get_patients_cubit.dart' hide SetClinicFilterEvent, SetBranchFilterEvent;
import '../../../../Payment Methods/presentation/manager/get_payment_methods_cubit/get_payment_methods_cubit.dart';
import '../../../../Examination Type/presentation/manager/get_examination_types_cubit/get_examination_types_cubit.dart';


import '../../../../../core/Network/shared.dart';
import '../../../../../core/utils/colors.dart';
import '../../../../../core/widgets/DropdownPackage.dart';
import '../../../../../core/widgets/height_spacer.dart';
import '../../../../../generated/l10n.dart';
import '../../../../Patient/data/model/patients_model.dart';

class FormDataAppointment extends StatefulWidget {
  const FormDataAppointment({super.key, this.patient, this.isUpdate = false});

  final bool isUpdate;
  final Patient? patient;

  @override
  State<FormDataAppointment> createState() => _FormDataAppointmentState();
}

class _FormDataAppointmentState extends State<FormDataAppointment> {

  void validateAndProceed(BuildContext context) {
    final cubit = context.read<MakeAppointmentCubit>();
    final state = cubit.state;
    
    bool isValid = true;

    final isDoctorValid = state.selectedDoctor != null;
    cubit.add(ValidateFieldEvent('doctor', isDoctorValid));
    if (!isDoctorValid) isValid = false;

    final isPatientValid = state.selectedPatient != null;
    cubit.add(ValidateFieldEvent('patient', isPatientValid));
    if (!isPatientValid) isValid = false;

    final isClinicValid = state.selectedClinic != null;
    cubit.add(ValidateFieldEvent('clinic', isClinicValid));
    if (!isClinicValid) isValid = false;
    
    final isBranchValid = state.selectedBranch != null;
    cubit.add(ValidateFieldEvent('branch', isBranchValid));
    if (!isBranchValid) isValid = false;

    final isExamValid = state.selectedExaminationType != null;
    cubit.add(ValidateFieldEvent('examinationType', isExamValid));
    if (!isExamValid) isValid = false;

    final isPaymentValid = state.selectedPaymentMethod != null;
    cubit.add(ValidateFieldEvent('paymentMethod', isPaymentValid));
    if (!isPaymentValid) isValid = false;

    if (isValid) {
      try {
        cubit.add(ChangeStepEvent(1));
      } catch (e) {
        log(e.toString());
      }
    }
  }

  Widget _buildDoctorDropdown(BuildContext context, MakeAppointmentState state) {
    final cubit = context.read<MakeAppointmentCubit>();
    return BlocBuilder<GetDoctorsCubit, GetDoctorsState>(
      builder: (context, doctorState) {
        return DropdownItem(
          radius: 30,
          color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[800]! : Colorz.white,
          isShadow: true,
          iconData: Icon(Icons.arrow_drop_down_circle, color: Colorz.primaryColor),
          items: doctorState.doctors?.doctors,
          isValid: state.validationState['doctor'] ?? true,
          validateText: "Must Select Doctor",
          selectedValue: state.selectedDoctor?.name,
          readOnly: state.selectedBranch == null,
          hintText: 'Select Doctor',
          itemAsString: (item) => item.name.toString(),
          onItemSelected: (item) {
              cubit.add(SelectDoctorEvent(item));
              cubit.add(SelectTimeEvent(null)); 
          },
          isLoading: doctorState.state == GetDoctorsStatus.loading,
        );
      },
    );
  }

  Widget _buildClinicDropdown(BuildContext context, MakeAppointmentState state) {
    final cubit = context.read<MakeAppointmentCubit>();
    return BlocBuilder<GetClinicsCubit, GetClinicsState>(
      builder: (context, clinicState) {
        return DropdownItem(
          radius: 30,
          color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[800]! : Colorz.white,
          isShadow: true,
          iconData: Icon(Icons.arrow_drop_down_circle, color: Colorz.primaryColor),
          items: clinicState.clinics?.clinics,
          isValid: state.validationState['clinic'] ?? true,
          validateText: "Must Select Clinic",
          selectedValue: state.selectedClinic?.name,
          hintText: 'Select Clinic',
          itemAsString: (item) => item.name.toString(),
          onItemSelected: (item) {
              cubit.add(SelectClinicEvent(item));
              cubit.add(SelectBranchEvent(null));
              cubit.add(SelectExaminationTypeEvent(null));
              cubit.add(SelectPaymentMethodEvent(null));
              cubit.add(SelectTimeEvent(null));
              
              if (item != null) {
                  context.read<GetBranchesCubit>().add(SetClinicFilterEvent(item.id));
                  context.read<GetBranchesCubit>().add(GetAllBranchesEvent(noPagination: true));
                  context.read<GetPatientsCubit>().add(GetAllPatientsEvent(noPagination: true));
                  context.read<GetPaymentMethodsCubit>().add(GetAllPaymentMethodsEvent(noPagination: true));
                  context.read<GetExaminationTypesCubit>().add(GetAllExaminationTypesEvent(noPagination: true));
              }
          },
          isLoading: clinicState.state == GetClinicsStatus.loading,
        );
      },
    );
  }

  Widget _buildPatientDropdown(BuildContext context, MakeAppointmentState state) {
    final cubit = context.read<MakeAppointmentCubit>();
    return BlocBuilder<GetPatientsCubit, GetPatientsState>(
      builder: (context, patientState) {
        return DropdownItem(
          radius: 30,
          color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[800]! : Colorz.white,
          isShadow: true,
          iconData: Icon(Icons.arrow_drop_down_circle, color: Colorz.primaryColor),
          items: patientState.patients?.patients,
          isValid: state.validationState['patient'] ?? true,
          validateText: "Must Select Patient",
          selectedValue: state.selectedPatient?.name,
          hintText: 'Select Patient',
          readOnly: state.selectedClinic == null,
          onChanged: (value) {
            cubit.patientController.text = value;
            context.read<GetPatientsCubit>().onSearchChanged(value);
          },
          searchController: cubit.patientController,
          itemAsString: (item) => item.name.toString(),
          onItemSelected: (item) {
              cubit.add(SetPatientEvent(item));
              cubit.add(SelectTimeEvent(null));
          },
          isLoading: patientState.state == GetPatientsStatus.loading,
        );
      },
    );
  }

  Widget _buildBranchDropdown(BuildContext context, MakeAppointmentState state) {
    final cubit = context.read<MakeAppointmentCubit>();
    return BlocBuilder<GetBranchesCubit, GetBranchesState>(
      builder: (context, branchState) {
        return DropdownItem(
          radius: 30,
          color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[800]! : Colorz.white,
          isShadow: true,
          iconData: Icon(Icons.arrow_drop_down_circle, color: Colorz.primaryColor),
          items: branchState.branches?.branches,
          isValid: state.validationState['branch'] ?? true,
          validateText: S.of(context).mustBranch,
          selectedValue: state.selectedBranch?.name,
          readOnly: state.selectedClinic == null,
          hintText: 'Select Branch',
          itemAsString: (item) => item.name.toString(),
          onItemSelected: (item) {
              cubit.add(SelectBranchEvent(item));
              cubit.add(SelectDoctorEvent(null));
              cubit.add(SelectTimeEvent(null));
              
              if (item != null) {
                  context.read<GetDoctorsCubit>().add(SetBranchFilterEvent(item.id));
                  context.read<GetDoctorsCubit>().add(GetAllDoctorsEvent(noPagination: true));
              }
          },
          isLoading: branchState.state == GetBranchesStatus.loading,
        );
      },
    );
  }

  Widget _buildExaminationTypeDropdown(BuildContext context, MakeAppointmentState state) {
    final cubit = context.read<MakeAppointmentCubit>();
    return BlocBuilder<GetExaminationTypesCubit, GetExaminationTypesState>(
      builder: (context, examState) {
        return DropdownItem(
          radius: 30,
          color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[800]! : Colorz.white,
          isShadow: true,
          iconData: Icon(Icons.arrow_drop_down_circle, color: Colorz.primaryColor),
          items: examState.examinationTypes?.examinationTypes,
          isValid: state.validationState['examinationType'] ?? true,
          validateText: "Must Select Examination Type",
          selectedValue: state.selectedExaminationType?.name,
          hintText: 'Select Examination Type',
          readOnly: state.selectedClinic == null,
          itemAsString: (item) => item.name.toString(),
          onItemSelected: (item) {
            cubit.add(SelectExaminationTypeEvent(item));
          },
          isLoading: examState.status == GetExaminationTypesStatus.loading,
        );
      },
    );
  }

  Widget _buildPaymentMethodDropdown(BuildContext context, MakeAppointmentState state) {
    final cubit = context.read<MakeAppointmentCubit>();
    return BlocBuilder<GetPaymentMethodsCubit, GetPaymentMethodsState>(
      builder: (context, paymentState) {
        return DropdownItem(
          radius: 30,
          color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[800]! : Colorz.white,
          isShadow: true,
          iconData: Icon(Icons.arrow_drop_down_circle, color: Colorz.primaryColor),
          items: paymentState.paymentMethods?.paymentMethods,
          isValid: state.validationState['paymentMethod'] ?? true,
          validateText: "Must Select Payment Method",
          selectedValue: state.selectedPaymentMethod?.title,
          hintText: 'Select Payment Method',
          readOnly: state.selectedClinic == null,
          itemAsString: (item) => item.title.toString(),
          onItemSelected: (item) {
            cubit.add(SelectPaymentMethodEvent(item));
          },
          isLoading: paymentState.isLoading,
        );
      },
    );
  }

  Widget _buildNextButton(BuildContext context) {
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
        onPressed: () => validateAndProceed(context),
        child: Text(
          "Next",
          style: appStyle(context, 20, Colorz.white, FontWeight.bold),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Access cubit for non-state usage if any, or rely on context.read inside methods
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return BlocBuilder<MakeAppointmentCubit, MakeAppointmentState>(
      builder: (context, state) => SafeArea(
        child: Container(
          width: MediaQuery.sizeOf(context).width,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            color: isDark ? Theme.of(context).scaffoldBackgroundColor : Colorz.white,
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
                        if (CacheHelper.getStringList(key: "capabilities").contains("manageCapability"))
                          _buildClinicDropdown(context, state),
                        const HeightSpacer(size: 15),
                        _buildBranchDropdown(context, state),
                        const HeightSpacer(size: 15),
                        _buildPatientDropdown(context, state),
                        const HeightSpacer(size: 15),
                        _buildDoctorDropdown(context, state),
                        const HeightSpacer(size: 15),
                        _buildExaminationTypeDropdown(context, state),
                        const HeightSpacer(size: 15),
                        _buildPaymentMethodDropdown(context, state),
                        const HeightSpacer(size: 30),
                      ],
                    ),
                  ),
                ),
              ),
              _buildNextButton(context),
              const HeightSpacer(size: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
