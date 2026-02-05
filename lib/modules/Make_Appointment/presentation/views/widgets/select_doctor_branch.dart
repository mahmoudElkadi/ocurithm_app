import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:ocurithm/core/widgets/height_spacer.dart';
import 'package:ocurithm/modules/Make_Appointment/presentation/manager/Make Appointment cubit/make_appointment_cubit.dart';
import 'package:ocurithm/core/utils/snackbar_service.dart';

import '../../../../../core/utils/colors.dart';
import '../../../../../core/widgets/DropdownPackage.dart';

class SelectDoctorBranch extends StatefulWidget {
  final MakeAppointmentCubit cubit;

  SelectDoctorBranch({
    super.key,
    required this.cubit,
  });

  @override
  State<SelectDoctorBranch> createState() => _SelectDoctorBranchState();
}

class _SelectDoctorBranchState extends State<SelectDoctorBranch> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: BlocBuilder<MakeAppointmentCubit, MakeAppointmentState>(
        bloc: widget.cubit,
        builder: (context, state) => Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha:0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Doctor And Branch',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 16),

              // Form
              Form(
                child: Column(
                  children: [
                    // Code TextField
                    DropdownItem(
                      radius: 30,
                      color: Colorz.white,
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
                          if (item != null) {
                            widget.cubit.add(SelectDoctorEvent(item));
                          }
                      },
                      isLoading: state.doctorStatus == DataStatus.loading,
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
                      items: state.branches?.branches,
                      selectedValue: state.selectedBranch?.name,
                      hintText: 'Select Branch',
                      itemAsString: (item) => item.name.toString(),
                      onItemSelected: (item) {
                          if (item != null) {
                            widget.cubit.add(SelectBranchEvent(item));
                          }
                      },
                      isLoading: state.branchStatus == DataStatus.loading,
                    ),
                    // Submit Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            if (state.selectedDoctor != null && state.selectedBranch != null) {
                              Navigator.pop(context, true);
                            } else {
                              SnackbarService.showError(
                                context,
                                message: 'Please select doctor and branch',
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                            backgroundColor: Colorz.primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Submit',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
