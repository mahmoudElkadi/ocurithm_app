import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:ocurithm/core/widgets/no_internet.dart';
import 'package:ocurithm/modules/Make_Appointment/presentation/views/widgets/appointment_form.dart';
import 'package:ocurithm/modules/Make_Appointment/presentation/views/widgets/make_appointment_view_body.dart';
import 'package:ocurithm/modules/Make_Appointment/presentation/views/widgets/preview_content_appointment.dart';
import 'package:ocurithm/modules/Patient/data/model/patients_model.dart';

import '../../../../core/utils/app_style.dart';
import '../../../../core/utils/colors.dart';
import '../../data/repos/make_appointment_repo_impl.dart';
import '../manager/Make Appointment cubit/make_appointment_cubit.dart';
import '../manager/Make Appointment cubit/make_appointment_state.dart';

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
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
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
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(1.5),
                      ),
                    ),
                    // Progress line with animation
                    AnimatedContainer(
                      duration: Duration(milliseconds: 400),
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
                              : Colors.white,
                          border: Border.all(
                            color: isCompleted || isCurrent
                                ? Colorz.primaryColor
                                : Colors.grey.shade300,
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
                                          : Colors.grey.shade600,
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
                  SizedBox(height: 8),
                  // Step text
                  AnimatedDefaultTextStyle(
                    duration: Duration(milliseconds: 200),
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
  const MakeAppointmentView({super.key, this.patient});

  final Patient? patient;

  @override
  State<MakeAppointmentView> createState() => _MakeAppointmentViewState();
}

class _MakeAppointmentViewState extends State<MakeAppointmentView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
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
            begin: Offset(1.0, 0.0),
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
        return FormDataAppointment(
          key: ValueKey('details'),
        );
      case 1:
        return MakeAppointmentViewBody(
          key: ValueKey('time'),
        );
      case 2:
        return AppointmentPreviewContent(
          key: ValueKey('preview'),
        );

      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MakeAppointmentCubit(MakeAppointmentRepoImpl())
        ..setPatient(widget.patient)
        ..getAllData(),
      child: BlocBuilder<MakeAppointmentCubit, MakeAppointmentState>(
        builder: (context, state) {
          final cubit = MakeAppointmentCubit.get(context);

          return Scaffold(
            backgroundColor: Colorz.white,
            appBar: AppBar(
              backgroundColor: Colorz.white,
              elevation: 0,
              title: Text("Appointments",
                  style: appStyle(context, 20, Colorz.black, FontWeight.w600)),
              centerTitle: true,
              leading: IconButton(
                onPressed: () {
                  if (cubit.currentStep > 0) {
                    cubit.previousStep();
                  } else {
                    Get.back();
                  }
                },
                icon: Icon(Icons.arrow_back, color: Colorz.black),
              ),
            ),
            body: cubit.connection != false
                ? Column(
                    children: [
                      HorizontalStepper(
                        currentStep: cubit.currentStep,
                        steps: cubit.steps,
                        onStepTapped: (index) => (),
                      ),
                      Expanded(
                        child: _buildStepContent(cubit.currentStep, context),
                      ),
                    ],
                  )
                : NoInternet(
                    onPressed: () {
                      if (cubit.doctors == null) {
                        cubit.getDoctors();
                        cubit.getBranches();
                      }
                    },
                  ),
          );
        },
      ),
    );
  }
}
