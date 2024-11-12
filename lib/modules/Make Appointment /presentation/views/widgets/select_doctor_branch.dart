import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:ocurithm/core/widgets/height_spacer.dart';
import 'package:ocurithm/modules/Make%20Appointment%20/presentation/manager/Make%20Appointment%20cubit/make_appointment_cubit.dart';
import 'package:ocurithm/modules/Make%20Appointment%20/presentation/manager/Make%20Appointment%20cubit/make_appointment_state.dart';

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
                color: Colors.black.withOpacity(0.1),
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
                    const HeightSpacer(size: 15),
                    DropdownItem(
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
                    // Submit Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            if (widget.cubit.selectedDoctor != null && widget.cubit.selectedBranch != null) {
                              Navigator.pop(context, true);
                            } else {
                              Get.snackbar(
                                'Error',
                                'Please select doctor and branch',
                                backgroundColor: Colors.red,
                                colorText: Colors.white,
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
