import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:ocurithm/core/utils/services_locator.dart';
import 'package:ocurithm/core/widgets/no_internet.dart';
import 'package:ocurithm/modules/Appointment/data/models/appointment_model.dart';
import 'package:ocurithm/modules/Make_Appointment/presentation/views/widgets/appointment_form.dart';
import 'package:ocurithm/modules/Make_Appointment/presentation/views/widgets/make_appointment_view_body.dart';
import 'package:ocurithm/modules/Make_Appointment/presentation/views/widgets/preview_content_appointment.dart';
import 'package:ocurithm/modules/Patient/data/model/patients_model.dart';

import '../../../../core/utils/app_style.dart';
import '../../../../core/utils/colors.dart';
import '../../../Branch/presentation/manager/get_branches_cubit/get_branches_cubit.dart';
import '../../../Clinics/presentation/manager/get_clinics_cubit/get_clinics_cubit.dart';
import '../../../Doctor/presentation/manager/get_doctors_cubit/get_doctors_cubit.dart';
import '../../../Examination Type/presentation/manager/get_examination_types_cubit/get_examination_types_cubit.dart';
import '../../../Patient/presentation/manager/get_patients_cubit/get_patients_cubit.dart';
import '../../../Payment Methods/presentation/manager/get_payment_methods_cubit/get_payment_methods_cubit.dart';
import '../manager/Make Appointment cubit/make_appointment_cubit.dart' hide GetDoctorsEvent;

class HorizontalStepper extends StatelessWidget {
  final int currentStep;
  final List<String> steps;
  final Function(int) onStepTapped;

  const HorizontalStepper({
    Key? key,
    required this.currentStep,
    required this.steps,
    required this.onStepTapped,
  }) : super(key: key);

  // Helper method to determine divider color
  Color getDividerColor(
      BuildContext context, int dividerIndex, int currentStep) {
    // Calculate which steps this divider is between (dividerIndex is always odd)
    final leftStepIndex = (dividerIndex - 1) ~/ 2; // Step before divider
    final rightStepIndex = (dividerIndex + 1) ~/ 2; // Step after divider

    // If left step is completed (meaning current step is beyond it)
    if (leftStepIndex < currentStep) {
      return Colorz.primaryColor;
    }
    return Colors.grey.shade100;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Row(
        children: List.generate(steps.length * 2 - 1, (index) {
          if (index.isOdd) {
            // Connection line
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20, left: 10, right: 10),
                child: Stack(
                  children: [
                    // Background line
                    Container(
                      height: 3,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[800] : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(1.5),
                      ),
                    ),
                    // Progress line with animation
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      height: 3,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(1.5),
                        color: getDividerColor(context, index, currentStep),
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            // Step circles with text
            final stepIndex = index ~/ 2;
            final isCompleted = stepIndex < currentStep;
            final isCurrent = stepIndex == currentStep;

            return GestureDetector(
              onTap: () => onStepTapped(stepIndex),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    children: [
                      // Optional glow effect for current step
                      if (isCurrent)
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colorz.primaryColor.withOpacity(0.1),
                          ),
                        ),
                      Container(
                        width: 35,
                        height: 35,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isCompleted || isCurrent
                              ? Colorz.primaryColor
                              : isDark ? Theme.of(context).scaffoldBackgroundColor : Colors.white,
                          border: Border.all(
                            color: isCompleted || isCurrent
                                ? Colorz.primaryColor
                                : isDark ? Colors.grey[600]! : Colors.grey.shade300,
                            width: 2,
                          ),
                          boxShadow: isCurrent
                              ? [
                                  BoxShadow(
                                    color: Colorz.primaryColor.withOpacity(0.3),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ]
                              : [],
                        ),
                        child: Center(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder:
                                (Widget child, Animation<double> animation) {
                              return ScaleTransition(
                                  scale: animation, child: child);
                            },
                            child: isCompleted
                                ? Icon(
                                    Icons.check_rounded,
                                    color: Colors.white,
                                    size: 20,
                                    key: ValueKey('check-$stepIndex'),
                                  )
                                : Text(
                                    '${stepIndex + 1}',
                                    style: TextStyle(
                                      color: isCurrent
                                          ? Colors.white
                                          : isDark ? Colors.grey[400] : Colors.grey.shade600,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                    key: ValueKey('number-$stepIndex'),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Step text
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                      color: isCurrent
                          ? Colorz.primaryColor
                          : isCompleted
                              ? Colors.grey.shade700
                              : Colors.grey.shade500,
                      fontSize: 12,
                      fontWeight:
                          isCurrent ? FontWeight.w600 : FontWeight.normal,
                    ),
                    child: Text(
                      steps[stepIndex],
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }
        }),
      ),
    );
  }
}

class MakeAppointmentView extends StatefulWidget {
  const MakeAppointmentView(
      {super.key, this.patient, this.appointment, this.isUpdated = false});

  final bool isUpdated;
  final Appointment? appointment;
  final Patient? patient;

  @override
  State<MakeAppointmentView> createState() => _MakeAppointmentViewState();
}

class _MakeAppointmentViewState extends State<MakeAppointmentView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  // ignore: unused_field
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildStepContent(int step, BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(animation),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      child: _getStepWidget(step, context),
    );
  }

  Widget _getStepWidget(int step, BuildContext context) {
    switch (step) {
      case 0:
        return const FormDataAppointment(
          key: ValueKey('details'),
        );
      case 1:
        return const MakeAppointmentViewBody(
          key: ValueKey('time'),
        );
      case 2:
        return AppointmentPreviewContent(
          key: const ValueKey('preview'),
          isUpdated: widget.isUpdated,
          appointment: widget.appointment,
        );

      default:
        return const SizedBox.shrink();
    }
  }

  final List<String> steps = ['Details', 'Time', 'Preview'];

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) {
            final cubit = sl<MakeAppointmentCubit>();
            if (widget.patient != null) cubit.add(SetPatientEvent(widget.patient));
            cubit.add(InitialDataEvent());
            if (widget.appointment != null) cubit.add(SetDataEvent(widget.appointment!));
            return cubit;
          },
        ),
        BlocProvider(create: (context) => sl<GetClinicsCubit>()..add(GetAllClinicsEvent(noPagination: true))),
        BlocProvider(create: (context) => sl<GetBranchesCubit>()),
        BlocProvider(create: (context) => sl<GetDoctorsCubit>()),
        BlocProvider(create: (context) => sl<GetPatientsCubit>()),
        BlocProvider(create: (context) => sl<GetPaymentMethodsCubit>()),
        BlocProvider(create: (context) => sl<GetExaminationTypesCubit>()),
      ],
      child: BlocBuilder<MakeAppointmentCubit, MakeAppointmentState>(
        builder: (context, state) {
          final cubit = MakeAppointmentCubit.get(context);
          final isDark = Theme.of(context).brightness == Brightness.dark;

          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: AppBar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              elevation: 0,
              title: Text("Appointments",
                  style: appStyle(context, 20, isDark ? Colors.white : Colorz.black, FontWeight.w600)),
              centerTitle: true,
              leading: IconButton(
                onPressed: () {
                  if (state.currentStep > 0) {
                    cubit.add(PreviousStepEvent());
                  } else {
                    Get.back();
                  }
                },
                icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colorz.black),
              ),
            ),
            body: state.status != MakeAppointmentStatus.noConnection // Using status enum
                ? Column(
                    children: [
                      HorizontalStepper(
                        currentStep: state.currentStep,
                        steps: steps, // User defined list
                        onStepTapped: (index) {
                           // Optional: Allow jumping steps if possible
                           // cubit.add(ChangeStepEvent(index));
                        },
                      ),
                      Expanded(
                        child: _buildStepContent(state.currentStep, context),
                      ),
                    ],
                  )
                : NoInternet(
                    onPressed: () {
                      if (state.doctors == null) {
                        // cubit.add(GetDoctorsEvent());
                        // cubit.add(GetBranchesEvent());
                      }
                      cubit.add(InitialDataEvent());
                    },
                  ),
          );
        },
      ),
    );
  }
}

