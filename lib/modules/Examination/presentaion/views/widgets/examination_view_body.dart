import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:ocurithm/core/utils/colors.dart';
import 'package:ocurithm/core/widgets/custom_freeze_loading.dart';
import 'package:ocurithm/core/widgets/no_internet.dart';
import 'package:ocurithm/modules/Examination/presentaion/views/widgets/review_examination.dart';

import '../../../../../core/utils/app_style.dart';
import '../../../../../core/widgets/DropdownPackage.dart';
import '../../../../../core/widgets/height_spacer.dart';
import '../../../../../core/widgets/multi_select.dart';
import '../../../../../core/widgets/text_field.dart';
import '../../../../Appointment/data/models/appointment_model.dart';
import '../../../../Patient/presentation/views/Patient Details/presentation/view/patient_details_view.dart';
import '../../manager/examination_cubit.dart';
import '../../manager/examination_state.dart';
import 'circle_view.dart';
import 'header_view.dart';
import 'navigation_view.dart';

class MultiStepFormView extends StatelessWidget {
  const MultiStepFormView({super.key, required this.appointment});

  final Appointment appointment;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: BlocBuilder<ExaminationCubit, ExaminationState>(builder: (context, state) {
        final cubit = ExaminationCubit.get(context);
        log('state: ' + state.toString());
        if (cubit.isLoading) {
          return Center(
            child: CircularProgressIndicator(
              color: Colorz.primaryColor,
            ),
          );
        }

        if (cubit.connection == false) {
          return NoInternet(
            onPressed: () async {
              if (appointment.status == 'Saved') {
                log('here again');
                cubit.getOneExamination(id: appointment.id.toString());
              }
              cubit.readJson();
              cubit.setAppointment(appointment);
            },
          );
        }
        return Column(
          children: [
            ModernStepHeader(
              currentStep: cubit.currentStep,
              totalSteps: cubit.totalSteps,
              onPop: () => cubit.previousStep(),
              suffix: IconButton(
                  onPressed: () async {
                    if (appointment.patient != null) {
                      bool? result = await Get.to(() =>
                          PatientDetailsView(patient: appointment.patient!, id: appointment.patient!.id.toString()));
                    }
                  },
                  icon: SvgPicture.asset("assets/icons/patient.svg")),
            ),
            Expanded(
              // Wrapped with Expanded
              child: _buildStepContent(cubit.currentStep),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildStepContent(int step) {
    switch (step) {
      case 0:
        return const _StepTwoContent();
      case 1:
        return const _HistoryDetails();
      case 2:
        return const StepThreeContent();
      case 3:
        return ExaminationReviewScreen(
          appointment: appointment,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

class _HistoryDetails extends StatelessWidget {
  const _HistoryDetails();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ExaminationCubit>();

    return BlocBuilder<ExaminationCubit, ExaminationState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16).copyWith(bottom: 0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // Added this
              children: [
                Text(
                  'Present Illness',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.grey[200]!,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey[100]!,
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextFormField(
                    controller: cubit.presentIllnessController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Type patient history here...',
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 15,
                      ),
                      contentPadding: const EdgeInsets.all(20),
                      border: InputBorder.none,
                      filled: true,
                      fillColor: Colors.transparent,
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Past History',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.grey[200]!,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey[100]!,
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextFormField(
                    controller: cubit.pastHistoryController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Type patient history here...',
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 15,
                      ),
                      contentPadding: const EdgeInsets.all(20),
                      border: InputBorder.none,
                      filled: true,
                      fillColor: Colors.transparent,
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Medication History',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.grey[200]!,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey[100]!,
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextFormField(
                    controller: cubit.medicationHistoryController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Type patient history here...',
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 15,
                      ),
                      contentPadding: const EdgeInsets.all(20),
                      border: InputBorder.none,
                      filled: true,
                      fillColor: Colors.transparent,
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Family History',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.grey[200]!,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey[100]!,
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextFormField(
                    controller: cubit.familyHistoryController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Type patient history here...',
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 15,
                      ),
                      contentPadding: const EdgeInsets.all(20),
                      border: InputBorder.none,
                      filled: true,
                      fillColor: Colors.transparent,
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                ),
                StepNavigation(
                  onPrevious: () => cubit.previousStep(),
                  onNext: () => cubit.nextStep(),
                  isLastStep: cubit.currentStep == cubit.totalSteps - 1,
                  canGoBack: cubit.currentStep > 0,
                  canContinue: cubit.currentStep < cubit.totalSteps - 1,
                  onSave: () async {
                    if (cubit.appointmentData != null) {
                      customLoading(context, "");
                      bool connection = await InternetConnection().hasInternetAccess;
                      if (connection) {
                        cubit.action = "save";
                        cubit.makeExamination(context: context);
                      } else {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: const Text('No Internet Connection', style: TextStyle(color: Colors.white)),
                          backgroundColor: Colorz.redColor,
                        ));
                      }
                    }
                  },
                  onConfirm: () async {
                    if (cubit.appointmentData != null) {
                      customLoading(context, "");
                      bool connection = await InternetConnection().hasInternetAccess;
                      if (connection) {
                        cubit.action = "create";
                        cubit.makeExamination(context: context);
                      } else {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: const Text('No Internet Connection', style: TextStyle(color: Colors.white)),
                          backgroundColor: Colorz.redColor,
                        ));
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StepTwoContent extends StatelessWidget {
  const _StepTwoContent();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ExaminationCubit>();

    return BlocBuilder<ExaminationCubit, ExaminationState>(
      builder: (context, state) => Padding(
        padding: const EdgeInsets.all(16).copyWith(bottom: 0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                ' Complaint One',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.grey[200]!,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey[100]!,
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextFormField(
                  maxLines: 4,
                  controller: cubit.oneComplaintController,
                  decoration: InputDecoration(
                    hintText: 'Describe the one complaint...',
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 15,
                    ),
                    contentPadding: const EdgeInsets.all(20),
                    border: InputBorder.none,
                    filled: true,
                    fillColor: Colors.transparent,
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                ' Complaint Two',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.grey[200]!,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey[100]!,
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextFormField(
                  maxLines: 4,
                  controller: cubit.twoComplaintController,
                  decoration: InputDecoration(
                    hintText: 'Describe the one complaint...',
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 15,
                    ),
                    contentPadding: const EdgeInsets.all(20),
                    border: InputBorder.none,
                    filled: true,
                    fillColor: Colors.transparent,
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                ' Complaint Three',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.grey[200]!,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey[100]!,
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextFormField(
                  maxLines: 4,
                  controller: cubit.threeComplaintController,
                  decoration: InputDecoration(
                    hintText: 'Describe the one complaint...',
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 15,
                    ),
                    contentPadding: const EdgeInsets.all(20),
                    border: InputBorder.none,
                    filled: true,
                    fillColor: Colors.transparent,
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              StepNavigation(
                onPrevious: () => cubit.previousStep(),
                onNext: () => cubit.nextStep(),
                isLastStep: cubit.currentStep == cubit.totalSteps - 1,
                canGoBack: cubit.currentStep > 0,
                canContinue: cubit.currentStep < cubit.totalSteps - 1,
                onSave: () async {
                  if (cubit.appointmentData != null) {
                    customLoading(context, "");
                    bool connection = await InternetConnection().hasInternetAccess;
                    if (connection) {
                      cubit.action = "save";
                      cubit.makeExamination(context: context);
                    } else {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: const Text('No Internet Connection', style: TextStyle(color: Colors.white)),
                        backgroundColor: Colorz.redColor,
                      ));
                    }
                  }
                },
                onConfirm: () async {
                  if (cubit.appointmentData != null) {
                    customLoading(context, "");
                    bool connection = await InternetConnection().hasInternetAccess;
                    if (connection) {
                      cubit.action = "create";

                      cubit.makeExamination(context: context);
                    } else {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: const Text('No Internet Connection', style: TextStyle(color: Colors.white)),
                        backgroundColor: Colorz.redColor,
                      ));
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StepThreeContent extends StatefulWidget {
  const StepThreeContent({Key? key}) : super(key: key);

  @override
  State<StepThreeContent> createState() => _StepThreeContentState();
}

class _StepThreeContentState extends State<StepThreeContent> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const ClampingScrollPhysics(),
      children: [const EyeExaminationView()],
    );
  }
}

// Extract segment label to a separate widget for better performance
class SegmentLabel extends StatelessWidget {
  final String text;
  final int index;
  final Color color;

  const SegmentLabel({
    Key? key,
    required this.text,
    required this.index,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Text(
        text,
        style: appStyle(
          context,
          18,
          color,
          FontWeight.w500,
        ),
      ),
    );
  }
}

class EyeExaminationView extends StatelessWidget {
  const EyeExaminationView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cubit = BlocProvider.of<ExaminationCubit>(context);
    final List<Color> _colorList = [
      Colors.grey[400]!,
      Colors.black,
      Colors.white,
    ];

    return BlocBuilder<ExaminationCubit, ExaminationState>(
      builder: (context, state) => Padding(
        padding: const EdgeInsets.only(left: 16, right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Confrontation field",
              style: appStyle(context, 18, Colorz.black, FontWeight.bold),
            ),
            Row(
              spacing: 10,
              children: [
                Expanded(
                  child: QuadrantContainer(
                    // Left side configuration
                    containerSize: 300,
                    title: "right eye",
                    colorList: _colorList,
                    tapCounts: [
                      cubit.rightTopLeftTapCount,
                      cubit.rightTopRightTapCount,
                      cubit.rightBottomLeftTapCount,
                      cubit.rightBottomRightTapCount,
                    ],
                    tapHandlers: [
                      cubit.rightTopLeftHandleTap,
                      cubit.rightTopRightHandleTap,
                      cubit.rightBottomLeftHandleTap,
                      cubit.rightBottomRightHandleTap,
                    ],

                    side: 'right',
                  ),
                ),
                Expanded(
                  child: QuadrantContainer(
                    // Left side configuration
                    containerSize: 300,
                    title: 'left eye',
                    colorList: _colorList,
                    tapCounts: [
                      cubit.leftTopLeftTapCount,
                      cubit.leftTopRightTapCount,
                      cubit.leftBottomLeftTapCount,
                      cubit.leftBottomRightTapCount,
                    ],
                    tapHandlers: [
                      cubit.leftTopLeftHandleTap,
                      cubit.leftTopRightHandleTap,
                      cubit.leftBottomLeftHandleTap,
                      cubit.leftBottomRightHandleTap,
                    ],

                    side: 'left',
                  ),
                ),
              ],
            ),
            const HeightSpacer(size: 10),
            Text(
              "Old Glasses",
              style: appStyle(context, 18, Colorz.black, FontWeight.bold),
            ),
            const HeightSpacer(size: 4),
            const Row(
              spacing: 10,
              children: [RightOldGlasses(), LeftOldGlasses()],
            ),
            const HeightSpacer(size: 8),
            Text(
              "Auto-refraction",
              style: appStyle(context, 18, Colorz.black, FontWeight.bold),
            ),
            const HeightSpacer(size: 4),
            const Row(
              spacing: 10,
              children: [RightAutorefContent(), LeftAutorefContent()],
            ),
            const HeightSpacer(size: 8),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(
                "Refined Refraction",
                style: appStyle(context, 18, Colorz.black, FontWeight.bold),
              ),
              TextButton(
                  onPressed: () {
                    cubit.mergeRefinedWithAuto();
                  },
                  child: Text(
                    "Merge",
                    style: appStyle(context, 18, Colorz.primaryColor, FontWeight.bold),
                  )),
            ]),
            const HeightSpacer(size: 4),
            const Row(
              spacing: 10,
              children: [RightRefinedRefractionContent(), LeftRefinedRefractionContent()],
            ),
            const HeightSpacer(size: 8),
            Text(
              "Visual Acuity",
              style: appStyle(context, 18, Colorz.black, FontWeight.bold),
            ),
            const HeightSpacer(size: 4),
            const Row(
              spacing: 10,
              children: [RightVisualAcuityContent(), LeftVisualAcuityContent()],
            ),
            const HeightSpacer(size: 8),
            Text(
              "IOP (mmHg)",
              style: appStyle(context, 18, Colorz.black, FontWeight.bold),
            ),
            const HeightSpacer(size: 4),
            const Row(
              spacing: 10,
              children: [RightIOPContent(), LeftIOPContent()],
            ),
            const HeightSpacer(size: 8),
            Text(
              "Pupils",
              style: appStyle(context, 18, Colorz.black, FontWeight.bold),
            ),
            const HeightSpacer(size: 4),
            const Row(
              spacing: 10,
              children: [RightPupilsContent(), LeftPupilsContent()],
            ),
            const HeightSpacer(size: 8),
            Text(
              "EyeLid & Physical",
              style: appStyle(context, 18, Colorz.black, FontWeight.bold),
            ),
            const HeightSpacer(size: 4),
            const Row(
              spacing: 10,
              children: [RightEyeLid(), LeftEyeLid()],
            ),
            const HeightSpacer(size: 8),
            Text(
              "Eye Structure",
              style: appStyle(context, 18, Colorz.black, FontWeight.bold),
            ),
            const HeightSpacer(size: 4),
            const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 10,
              children: [RightAdditionalExaminationContent(), LeftAdditionalExaminationContent()],
            ),
            const HeightSpacer(size: 8),
            Text(
              "Fundus Examination",
              style: appStyle(context, 18, Colorz.black, FontWeight.bold),
            ),
            const HeightSpacer(size: 4),
            const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 10,
              children: [FundusExaminationContent(isLeftEye: false), FundusExaminationContent(isLeftEye: true)],
            ),
            const HeightSpacer(size: 8),
            Text(
              "External Features ",
              style: appStyle(context, 18, Colorz.black, FontWeight.bold),
            ),
            const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 10,
              children: [SlitLampExaminationContent(isLeftEye: false), SlitLampExaminationContent(isLeftEye: true)],
            ),
            StepNavigation(
              onPrevious: () => cubit.previousStep(),
              onNext: () => cubit.nextStep(),
              isLastStep: cubit.currentStep == cubit.totalSteps - 1,
              canGoBack: cubit.currentStep > 0,
              canContinue: cubit.currentStep < cubit.totalSteps - 1,
              onSave: () async {
                if (cubit.appointmentData != null) {
                  customLoading(context, "");
                  bool connection = await InternetConnection().hasInternetAccess;
                  if (connection) {
                    cubit.action = "save";
                    cubit.makeExamination(context: context);
                  } else {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: const Text('No Internet Connection', style: TextStyle(color: Colors.white)),
                      backgroundColor: Colorz.redColor,
                    ));
                  }
                }
              },
              onConfirm: () async {
                if (cubit.appointmentData != null) {
                  customLoading(context, "");
                  bool connection = await InternetConnection().hasInternetAccess;
                  if (connection) {
                    cubit.action = "create";

                    cubit.makeExamination(context: context);
                  } else {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: const Text('No Internet Connection', style: TextStyle(color: Colors.white)),
                      backgroundColor: Colorz.redColor,
                    ));
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableContainer(String title, Widget content) {
    return ModifiedExpandableContainer(
      title: title,
      content: content,
    );
  }
}

class RightAutorefContent extends StatelessWidget {
  const RightAutorefContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ExaminationCubit>();

    return BlocBuilder<ExaminationCubit, ExaminationState>(
      builder: (context, state) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colorz.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Text("Right eye", style: appStyle(context, 16, Colorz.black, FontWeight.bold)),
              const SizedBox(height: 8),
              CustomColumnDropdown(
                items: cubit.data['AurorefSpherical'] ?? [],
                textRow: "Spherical :",
                selectedValue: cubit.rightAurorefSpherical,
                onChanged: (selected) {
                  cubit.updateRightEyeField('aurorefSpherical', selected);
                },
              ),
              const SizedBox(height: 8),
              CustomColumnDropdown(
                items: cubit.data['AurorefSpherical'] ?? [],
                textRow: "Cylindrical :",
                hintText: '',
                selectedValue: cubit.rightAurorefCylindrical,
                onChanged: (selected) {
                  cubit.updateRightEyeField('aurorefCylindrical', selected);
                },
              ),
              const SizedBox(height: 8),
              CustomColumnDropdown(
                items: cubit.data['AurorefAxis'] ?? [],
                textRow: "Axis :",
                hintText: '',
                selectedValue: cubit.rightAurorefAxis,
                onChanged: (selected) {
                  cubit.updateRightEyeField('aurorefAxis', selected);
                },
              ),
              // Add other Autoref fields...
            ],
          ),
        ),
      ),
    );
  }
}

class LeftAutorefContent extends StatelessWidget {
  const LeftAutorefContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ExaminationCubit>();

    return BlocBuilder<ExaminationCubit, ExaminationState>(
      builder: (context, state) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colorz.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Text("Left eye", style: appStyle(context, 16, Colorz.black, FontWeight.bold)),
              const SizedBox(height: 8),
              CustomColumnDropdown(
                items: cubit.data['AurorefSpherical'] ?? [],
                textRow: "Spherical :",
                selectedValue: cubit.leftAurorefSpherical,
                onChanged: (selected) {
                  cubit.updateLeftEyeField('aurorefSpherical', selected);
                },
              ),
              const SizedBox(height: 8),
              CustomColumnDropdown(
                items: cubit.data['AurorefSpherical'] ?? [],
                textRow: "Cylindrical :",
                hintText: '',
                selectedValue: cubit.leftAurorefCylindrical,
                onChanged: (selected) {
                  cubit.updateLeftEyeField('aurorefCylindrical', selected);
                },
              ),
              const SizedBox(height: 8),
              CustomColumnDropdown(
                items: cubit.data['AurorefAxis'] ?? [],
                textRow: "Axis :",
                hintText: '',
                selectedValue: cubit.leftAurorefAxis,
                onChanged: (selected) {
                  cubit.updateLeftEyeField('aurorefAxis', selected);
                },
              ),
              // Add other Autoref fields...
            ],
          ),
        ),
      ),
    );
  }
}

class RightOldGlasses extends StatelessWidget {
  const RightOldGlasses({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ExaminationCubit>();

    return BlocBuilder<ExaminationCubit, ExaminationState>(
      builder: (context, state) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colorz.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Text("Right eye", style: appStyle(context, 16, Colorz.black, FontWeight.bold)),
              const SizedBox(height: 8),
              CustomColumnDropdown(
                items: cubit.data['AurorefSpherical'] ?? [],
                textRow: "Spherical :",
                selectedValue: cubit.rightOldSpherical,
                onChanged: (selected) {
                  cubit.updateRightEyeField('oldSpherical', selected);
                },
              ),
              const SizedBox(height: 8),
              CustomColumnDropdown(
                items: cubit.data['AurorefSpherical'] ?? [],
                textRow: "Cylindrical :",
                hintText: '',
                selectedValue: cubit.rightOldCylindrical,
                onChanged: (selected) {
                  cubit.updateRightEyeField('oldCylindrical', selected);
                },
              ),
              const SizedBox(height: 8),
              CustomColumnDropdown(
                items: cubit.data['AurorefAxis'] ?? [],
                textRow: "Axis :",
                hintText: '',
                selectedValue: cubit.rightOldAxis,
                onChanged: (selected) {
                  cubit.updateRightEyeField('oldAxis', selected);
                },
              ),
              // Add other Autoref fields...
            ],
          ),
        ),
      ),
    );
  }
}

class LeftOldGlasses extends StatelessWidget {
  const LeftOldGlasses({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ExaminationCubit>();

    return BlocBuilder<ExaminationCubit, ExaminationState>(
      builder: (context, state) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colorz.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Text("Left eye", style: appStyle(context, 16, Colorz.black, FontWeight.bold)),
              const SizedBox(height: 8),
              CustomColumnDropdown(
                items: cubit.data['AurorefSpherical'] ?? [],
                textRow: "Spherical :",
                selectedValue: cubit.leftOldSpherical,
                onChanged: (selected) {
                  cubit.updateLeftEyeField('oldSpherical', selected);
                },
              ),
              const SizedBox(height: 8),
              CustomColumnDropdown(
                items: cubit.data['AurorefSpherical'] ?? [],
                textRow: "Cylindrical :",
                hintText: '',
                selectedValue: cubit.leftOldCylindrical,
                onChanged: (selected) {
                  cubit.updateLeftEyeField('oldCylindrical', selected);
                },
              ),
              const SizedBox(height: 8),
              CustomColumnDropdown(
                items: cubit.data['AurorefAxis'] ?? [],
                textRow: "Axis :",
                hintText: '',
                selectedValue: cubit.leftOldAxis,
                onChanged: (selected) {
                  cubit.updateLeftEyeField('oldAxis', selected);
                },
              ),
              // Add other Autoref fields...
            ],
          ),
        ),
      ),
    );
  }
}

class ModifiedExpandableContainer extends StatefulWidget {
  final String title;
  final Widget content;

  const ModifiedExpandableContainer({
    Key? key,
    required this.title,
    required this.content,
  }) : super(key: key);

  @override
  State<ModifiedExpandableContainer> createState() => _ModifiedExpandableContainerState();
}

class _ModifiedExpandableContainerState extends State<ModifiedExpandableContainer> {
  bool isExpanded = true;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              spreadRadius: 2,
              blurRadius: 4,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () => setState(() => isExpanded = !isExpanded),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                    ),
                  ],
                ),
              ),
            ),
            if (isExpanded)
              Padding(
                padding: const EdgeInsets.all(8),
                child: widget.content,
              ),
          ],
        ),
      ),
    );
  }
}

class RightVisualAcuityContent extends StatefulWidget {
  const RightVisualAcuityContent({Key? key}) : super(key: key);

  @override
  State<RightVisualAcuityContent> createState() => _RightVisualAcuityContentState();
}

class _RightVisualAcuityContentState extends State<RightVisualAcuityContent> {
  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ExaminationCubit>();

    return BlocBuilder<ExaminationCubit, ExaminationState>(
      builder: (context, state) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colorz.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Text("Right eye", style: appStyle(context, 16, Colorz.black, FontWeight.bold)),
              const SizedBox(height: 8),
              CustomColumnDropdown(
                items: cubit.data['UCVA'] ?? [],
                textRow: "UCVA :",
                radius: 15,
                height: 40,
                selectedValue: cubit.rightUCVA,
                onChanged: (selected) {
                  cubit.updateRightEyeField('ucva', selected);
                  setState(() {});
                },
              ),
              const SizedBox(height: 8),
              CustomColumnDropdown(
                items: cubit.data['BCVA'] ?? [],
                textRow: "BCVA :",
                radius: 15,
                height: 40,
                selectedValue: cubit.rightBCVA,
                onChanged: (selected) {
                  cubit.updateRightEyeField('bcva', selected);
                  setState(() {});
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LeftVisualAcuityContent extends StatefulWidget {
  const LeftVisualAcuityContent({Key? key}) : super(key: key);

  @override
  State<LeftVisualAcuityContent> createState() => _LeftVisualAcuityContentState();
}

class _LeftVisualAcuityContentState extends State<LeftVisualAcuityContent> {
  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ExaminationCubit>();

    return BlocBuilder<ExaminationCubit, ExaminationState>(
      builder: (context, state) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colorz.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Text("Left eye", style: appStyle(context, 16, Colorz.black, FontWeight.bold)),
              const SizedBox(height: 8),
              CustomColumnDropdown(
                items: cubit.data['UCVA'] ?? [],
                textRow: "UCVA :",
                radius: 15,
                height: 40,
                selectedValue: cubit.leftUCVA,
                onChanged: (selected) {
                  cubit.updateLeftEyeField('ucva', selected);
                  setState(() {});
                },
              ),
              const SizedBox(height: 8),
              CustomColumnDropdown(
                items: cubit.data['BCVA'] ?? [],
                textRow: "BCVA :",
                radius: 15,
                height: 40,
                selectedValue: cubit.leftBCVA,
                onChanged: (selected) {
                  cubit.updateLeftEyeField('bcva', selected);
                  setState(() {});
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RightPupilsContent extends StatelessWidget {
  const RightPupilsContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ExaminationCubit>();

    return BlocBuilder<ExaminationCubit, ExaminationState>(
      builder: (context, state) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colorz.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Text("Right eye", style: appStyle(context, 16, Colorz.black, FontWeight.bold)),
              const SizedBox(height: 8),
              CustomColumnDropdown(
                items: cubit.data['PupilsShape'] ?? [],
                textRow: "Shape :",
                selectedValue: cubit.rightPupilsShape,
                onChanged: (selected) {
                  cubit.updateRightEyeField('pupilsShape', selected);
                },
              ),
              if (cubit.rightPupilsShape == "others")
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: TextField2(
                    controller: cubit.rightShapeController,
                    hintText: 'Shape:',
                    required: false,
                    onTextFieldChanged: (value) {
                      cubit.updateRightEyeField('lidsShape', value);
                    },
                    borderColor: Colors.black,
                    fillColor: Colors.white,
                    radius: 30,
                  ),
                ),
              const SizedBox(height: 8),
              CustomColumnDropdown(
                items: cubit.data['PupilsLightReflexTest'] ?? [],
                textRow: "Light Reflex Test :",
                hintText: 'Light Reflex:',
                selectedValue: cubit.rightPupilsLightReflexTest,
                onChanged: (selected) {
                  cubit.updateRightEyeField('pupilsLightReflexTest', selected);
                },
              ),
              const SizedBox(height: 8),
              CustomColumnDropdown(
                items: cubit.data['PupilsNearReflexTest'] ?? [],
                textRow: "Near Reflex Test:",
                hintText: 'Near Reflex',
                selectedValue: cubit.rightPupilsNearReflexTest,
                onChanged: (selected) {
                  cubit.updateRightEyeField('pupilsNearReflexTest', selected);
                },
              ),
              const SizedBox(height: 8),
              CustomColumnDropdown(
                items: cubit.data['PupilsSwingingFlashLightTest'] ?? [],
                textRow: "Swinging Flash Test :",
                hintText: "Swinging Flash:",
                selectedValue: cubit.rightPupilsSwingingFlashLightTest,
                onChanged: (selected) {
                  cubit.updateRightEyeField('pupilsSwingingFlashLightTest', selected);
                },
              ),
              const SizedBox(height: 8),
              CustomColumnDropdown(
                items: cubit.data['PupilsOtherDisorders'] ?? [],
                textRow: "Other Disorders :",
                selectedValue: cubit.rightPupilsOtherDisorders,
                onChanged: (selected) {
                  cubit.updateRightEyeField('pupilsOtherDisorders', selected);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LeftPupilsContent extends StatelessWidget {
  const LeftPupilsContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ExaminationCubit>();

    return BlocBuilder<ExaminationCubit, ExaminationState>(
      builder: (context, state) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colorz.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Text("Left eye", style: appStyle(context, 16, Colorz.black, FontWeight.bold)),
              const SizedBox(height: 8),
              CustomColumnDropdown(
                items: cubit.data['PupilsShape'] ?? [],
                textRow: "Shape :",
                selectedValue: cubit.leftPupilsShape,
                onChanged: (selected) {
                  cubit.updateLeftEyeField('pupilsShape', selected);
                },
              ),
              if (cubit.leftPupilsShape == "others")
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: TextField2(
                    controller: cubit.leftShapeController,
                    hintText: 'Shape',
                    required: false,
                    onTextFieldChanged: (value) {
                      cubit.updateLeftEyeField('lidsShape', value);
                    },
                    borderColor: Colors.black,
                    fillColor: Colors.white,
                    radius: 30,
                  ),
                ),
              const SizedBox(height: 8),
              CustomColumnDropdown(
                items: cubit.data['PupilsLightReflexTest'] ?? [],
                textRow: "Light Reflex Test :",
                hintText: 'Light Reflex',
                selectedValue: cubit.leftPupilsLightReflexTest,
                onChanged: (selected) {
                  cubit.updateLeftEyeField('pupilsLightReflexTest', selected);
                },
              ),
              const SizedBox(height: 8),
              CustomColumnDropdown(
                items: cubit.data['PupilsNearReflexTest'] ?? [],
                textRow: "Near Reflex Test :",
                hintText: "Near Reflex:",
                selectedValue: cubit.leftPupilsNearReflexTest,
                onChanged: (selected) {
                  cubit.updateLeftEyeField('pupilsNearReflexTest', selected);
                },
              ),
              const SizedBox(height: 8),
              CustomColumnDropdown(
                items: cubit.data['PupilsSwingingFlashLightTest'] ?? [],
                textRow: "Swinging Flash Test :",
                hintText: "Swinging Flash:",
                selectedValue: cubit.leftPupilsSwingingFlashLightTest,
                onChanged: (selected) {
                  cubit.updateLeftEyeField('pupilsSwingingFlashLightTest', selected);
                },
              ),
              const SizedBox(height: 8),
              CustomColumnDropdown(
                items: cubit.data['PupilsOtherDisorders'] ?? [],
                textRow: "Other Disorders :",
                selectedValue: cubit.leftPupilsOtherDisorders,
                onChanged: (selected) {
                  cubit.updateLeftEyeField('pupilsOtherDisorders', selected);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RightRefinedRefractionContent extends StatelessWidget {
  const RightRefinedRefractionContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ExaminationCubit>();

    return BlocBuilder<ExaminationCubit, ExaminationState>(
      builder: (context, state) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colorz.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Text("Right eye", style: appStyle(context, 16, Colorz.black, FontWeight.bold)),
              const SizedBox(height: 8),
              CustomColumnDropdown(
                items: cubit.data['AurorefSpherical'] ?? [],
                textRow: "Spherical :",
                selectedValue: cubit.rightRefinedRefractionSpherical,
                onChanged: (selected) {
                  cubit.updateRightEyeField('refinedRefractionSpherical', selected);
                },
              ),
              const SizedBox(height: 8),
              CustomColumnDropdown(
                items: cubit.data['AurorefSpherical'] ?? [],
                textRow: "Cylindrical :",
                hintText: '',
                selectedValue: cubit.rightRefinedRefractionCylindrical,
                onChanged: (selected) {
                  cubit.updateRightEyeField('refinedRefractionCylindrical', selected);
                },
              ),
              const SizedBox(height: 8),
              CustomColumnDropdown(
                items: cubit.data['AurorefAxis'] ?? [],
                textRow: "Axis :",
                selectedValue: cubit.rightRefinedRefractionAxis,
                onChanged: (selected) {
                  cubit.updateRightEyeField('refinedRefractionAxis', selected);
                },
              ),
              const SizedBox(height: 8),
              CustomColumnDropdown(
                items: cubit.data['NearVisionAddition'] ?? [],
                hintText: "",
                textRow: "Near vision addition :",
                selectedValue: cubit.rightNearVisionAddition,
                onChanged: (selected) {
                  cubit.updateRightEyeField('nearVisionAddition', selected);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LeftRefinedRefractionContent extends StatelessWidget {
  const LeftRefinedRefractionContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ExaminationCubit>();

    return BlocBuilder<ExaminationCubit, ExaminationState>(
      builder: (context, state) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colorz.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Text("Left eye", style: appStyle(context, 16, Colorz.black, FontWeight.bold)),
              const SizedBox(height: 8),
              CustomColumnDropdown(
                items: cubit.data['AurorefSpherical'] ?? [],
                textRow: "Spherical :",
                selectedValue: cubit.leftRefinedRefractionSpherical,
                onChanged: (selected) {
                  cubit.updateLeftEyeField('refinedRefractionSpherical', selected);
                },
              ),
              const SizedBox(height: 8),
              CustomColumnDropdown(
                items: cubit.data['AurorefSpherical'] ?? [],
                textRow: "Cylindrical :",
                hintText: '',
                selectedValue: cubit.leftRefinedRefractionCylindrical,
                onChanged: (selected) {
                  cubit.updateLeftEyeField('refinedRefractionCylindrical', selected);
                },
              ),
              const SizedBox(height: 8),
              CustomColumnDropdown(
                items: cubit.data['AurorefAxis'] ?? [],
                textRow: "Axis :",
                selectedValue: cubit.leftRefinedRefractionAxis,
                onChanged: (selected) {
                  cubit.updateLeftEyeField('refinedRefractionAxis', selected);
                },
              ),
              CustomColumnDropdown(
                items: cubit.data['NearVisionAddition'] ?? [],
                textRow: "Near vision addition :",
                hintText: "",
                selectedValue: cubit.leftNearVisionAddition,
                onChanged: (selected) {
                  cubit.updateLeftEyeField('nearVisionAddition', selected);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RightIOPContent extends StatelessWidget {
  const RightIOPContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ExaminationCubit>();

    return BlocBuilder<ExaminationCubit, ExaminationState>(
      builder: (context, state) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colorz.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Text("Right eye", style: appStyle(context, 16, Colorz.black, FontWeight.bold)),
              const SizedBox(height: 8),
              CustomColumnDropdown(
                items: cubit.data['IOP'] ?? [],
                textRow: "IOP :",
                radius: 15,
                height: 40,
                selectedValue: cubit.rightIOP,
                onChanged: (selected) {
                  cubit.updateRightEyeField('iop', selected);
                },
              ),
              const SizedBox(height: 8),
              CustomColumnDropdown(
                items: cubit.data['MeansOfMeasurement'] ?? [],
                textRow: "Means of Measurement:",
                hintText: "Measurement",
                selectedValue: cubit.rightMeansOfMeasurement,
                onChanged: (selected) {
                  cubit.updateRightEyeField('meansOfMeasurement', selected);
                },
              ),
              const SizedBox(height: 8),
              CustomColumnDropdown(
                items: cubit.data['AcquireAnotherIOPMeasurement'] ?? [],
                textRow: "Another IOP:",
                selectedValue: cubit.rightAcquireAnotherIOPMeasurement,
                onChanged: (selected) {
                  cubit.updateRightEyeField('acquireAnotherIOPMeasurement', selected);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LeftIOPContent extends StatelessWidget {
  const LeftIOPContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ExaminationCubit>();

    return BlocBuilder<ExaminationCubit, ExaminationState>(
      builder: (context, state) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colorz.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Text("Left eye", style: appStyle(context, 16, Colorz.black, FontWeight.bold)),
              const SizedBox(height: 8),
              CustomColumnDropdown(
                items: cubit.data['IOP'] ?? [],
                textRow: "IOP :",
                radius: 15,
                height: 40,
                selectedValue: cubit.leftIOP,
                onChanged: (selected) {
                  cubit.updateLeftEyeField('iop', selected);
                },
              ),
              const SizedBox(height: 8),
              CustomColumnDropdown(
                items: cubit.data['MeansOfMeasurement'] ?? [],
                textRow: "Means of Measurement:",
                hintText: "Measurement",
                selectedValue: cubit.leftMeansOfMeasurement,
                onChanged: (selected) {
                  cubit.updateLeftEyeField('meansOfMeasurement', selected);
                },
              ),
              const SizedBox(height: 8),
              CustomColumnDropdown(
                items: cubit.data['AcquireAnotherIOPMeasurement'] ?? [],
                textRow: "Another IOP:",
                selectedValue: cubit.leftAcquireAnotherIOPMeasurement,
                onChanged: (selected) {
                  cubit.updateLeftEyeField('acquireAnotherIOPMeasurement', selected);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SlitLampExaminationContent extends StatelessWidget {
  final bool isLeftEye;

  const SlitLampExaminationContent({Key? key, required this.isLeftEye}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ExaminationCubit>();

    return BlocBuilder<ExaminationCubit, ExaminationState>(
      builder: (context, state) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colorz.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("${isLeftEye ? 'Left' : 'Right'} eye", style: appStyle(context, 16, Colorz.black, FontWeight.bold)),
              const SizedBox(height: 8),
              TextField2(
                controller: isLeftEye ? cubit.leftLidsController : cubit.rightLidsController,
                hintText: 'Lids',
                required: false,
                onTextFieldChanged: (value) {
                  // cubit.updateStepState();
                },
                borderColor: Colors.black,
                fillColor: Colors.white,
                radius: 10,
              ),
              const SizedBox(height: 20),
              TextField2(
                controller: isLeftEye ? cubit.leftLashesController : cubit.rightLashesController,
                hintText: 'Lashes',
                required: false,
                onTextFieldChanged: (value) {
                  // cubit.updateStepState();
                },
                borderColor: Colors.black,
                fillColor: Colors.white,
                radius: 10,
              ),
              const SizedBox(height: 20),
              TextField2(
                controller: isLeftEye ? cubit.leftLacrimalController : cubit.rightLacrimalController,
                hintText: 'Lacrimal System',
                required: false,
                onTextFieldChanged: (value) {
                  // cubit.updateStepState();
                },
                borderColor: Colors.black,
                fillColor: Colors.white,
                radius: 10,
              ),
              const SizedBox(height: 20),
              TextField2(
                controller: isLeftEye ? cubit.leftConjunctivaController : cubit.rightConjunctivaController,
                hintText: 'Conjunctiva',
                required: false,
                onTextFieldChanged: (value) {
                  //  cubit.updateStepState();
                },
                borderColor: Colors.black,
                fillColor: Colors.white,
                radius: 10,
              ),
              const SizedBox(height: 20),
              TextField2(
                controller: isLeftEye ? cubit.leftScleraController : cubit.rightScleraController,
                hintText: 'Sclera',
                required: false,
                onTextFieldChanged: (value) {
                  // cubit.updateStepState();
                },
                borderColor: Colors.black,
                fillColor: Colors.white,
                radius: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RightAdditionalExaminationContent extends StatelessWidget {
  const RightAdditionalExaminationContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ExaminationCubit>();

    return BlocBuilder<ExaminationCubit, ExaminationState>(
      builder: (context, state) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colorz.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Text("Right eye", style: appStyle(context, 16, Colorz.black, FontWeight.bold)),
              const SizedBox(height: 8),
              CustomMultiSelectDropdown(
                items: cubit.data['Cornea'] ?? [],
                textRow: "Cornea :",
                hintText: "Cornea :",
                selectedValues: cubit.rightCornea,
                onChanged: (selected) {
                  cubit.rightCornea = selected;
                },
              ),
              const SizedBox(height: 15),
              CustomMultiSelectDropdown(
                items: cubit.data['AnteriorChambre'] ?? [],
                textRow: "Anterior Chambre :",
                hintText: "Anterior...",
                selectedValues: cubit.rightAnteriorChambre,
                onChanged: (selected) {
                  cubit.rightAnteriorChambre = selected;
                },
              ),
              const SizedBox(height: 15),
              CustomMultiSelectDropdown(
                items: cubit.data['Iris'] ?? [],
                textRow: "Iris :",
                selectedValues: cubit.rightIris,
                onChanged: (selected) {
                  cubit.rightIris = selected;
                },
              ),
              const SizedBox(height: 15),
              CustomMultiSelectDropdown(
                items: cubit.data['Lens'] ?? [],
                textRow: "Lens :",
                selectedValues: cubit.rightLens,
                onChanged: (selected) {
                  cubit.rightLens = selected;
                },
              ),
              const SizedBox(height: 15),
              CustomMultiSelectDropdown(
                items: cubit.data['AnteriorVitreous'] ?? [],
                textRow: "Anterior Vitreous :",
                hintText: "Anterior...",
                selectedValues: cubit.rightAnteriorVitreous,
                onChanged: (selected) {
                  cubit.rightAnteriorVitreous = selected;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LeftAdditionalExaminationContent extends StatelessWidget {
  const LeftAdditionalExaminationContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ExaminationCubit>();

    return BlocBuilder<ExaminationCubit, ExaminationState>(
      builder: (context, state) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colorz.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Text("Left eye", style: appStyle(context, 16, Colorz.black, FontWeight.bold)),
              const SizedBox(height: 8),
              CustomMultiSelectDropdown(
                items: cubit.data['Cornea'] ?? [],
                textRow: "Cornea :",
                hintText: "Cornea :",
                selectedValues: cubit.leftCornea,
                onChanged: (selected) {
                  cubit.leftCornea = selected;
                },
              ),
              const SizedBox(height: 15),
              CustomMultiSelectDropdown(
                items: cubit.data['AnteriorChambre'] ?? [],
                textRow: "Anterior Chambre :",
                hintText: "Anterior...",
                selectedValues: cubit.leftAnteriorChambre,
                onChanged: (selected) {
                  cubit.leftAnteriorChambre = selected;
                },
              ),
              const SizedBox(height: 15),
              CustomMultiSelectDropdown(
                items: cubit.data['Iris'] ?? [],
                textRow: "Iris :",
                selectedValues: cubit.leftIris,
                onChanged: (selected) {
                  cubit.leftIris = selected;
                },
              ),
              const SizedBox(height: 15),
              CustomMultiSelectDropdown(
                items: cubit.data['Lens'] ?? [],
                textRow: "Lens :",
                selectedValues: cubit.leftLens,
                onChanged: (selected) {
                  cubit.leftLens = selected;
                },
              ),
              const SizedBox(height: 15),
              CustomMultiSelectDropdown(
                items: cubit.data['AnteriorVitreous'] ?? [],
                textRow: "Anterior Vitreous :",
                hintText: "Anterior...",
                selectedValues: cubit.leftAnteriorVitreous,
                onChanged: (selected) {
                  cubit.leftAnteriorVitreous = selected;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FundusExaminationContent extends StatelessWidget {
  final bool isLeftEye;

  const FundusExaminationContent({Key? key, required this.isLeftEye}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ExaminationCubit>();

    return BlocBuilder<ExaminationCubit, ExaminationState>(
      builder: (context, state) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colorz.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Text("${isLeftEye ? 'Left' : 'Right'} eye", style: appStyle(context, 16, Colorz.black, FontWeight.bold)),
              const SizedBox(height: 8),
              CustomMultiSelectDropdown(
                items: cubit.data['FundusOpticDisc'] ?? [],
                textRow: "Optic Disc :",
                hintText: "Optic Disc :",
                selectedValues: isLeftEye ? cubit.leftFundusOpticDisc : cubit.rightFundusOpticDisc,
                onChanged: (selected) {
                  if (isLeftEye) {
                    cubit.leftFundusOpticDisc = selected;
                  } else {
                    cubit.rightFundusOpticDisc = selected;
                  }
                },
              ),
              const SizedBox(height: 15),
              CustomMultiSelectDropdown(
                items: cubit.data['FundusMacula'] ?? [],
                textRow: "Macula :",
                hintText: "Macula :",
                selectedValues: isLeftEye ? cubit.leftFundusMacula : cubit.rightFundusMacula,
                onChanged: (selected) {
                  if (isLeftEye) {
                    cubit.leftFundusMacula = selected;
                  } else {
                    cubit.rightFundusMacula = selected;
                  }
                },
              ),
              const SizedBox(height: 15),
              CustomMultiSelectDropdown(
                items: cubit.data['FundusVessels'] ?? [],
                textRow: "Vessels :",
                hintText: "Vessels :",
                selectedValues: isLeftEye ? cubit.leftFundusVessels : cubit.rightFundusVessels,
                onChanged: (selected) {
                  if (isLeftEye) {
                    cubit.leftFundusVessels = selected;
                  } else {
                    cubit.rightFundusVessels = selected;
                  }
                },
              ),
              const SizedBox(height: 15),
              CustomMultiSelectDropdown(
                items: cubit.data['FundusPeriphery'] ?? [],
                textRow: "Fundus Periphery :",
                hintText: "Fundus Periphery :",
                selectedValues: isLeftEye ? cubit.leftFundusPeriphery : cubit.rightFundusPeriphery,
                onChanged: (selected) {
                  if (isLeftEye) {
                    cubit.leftFundusPeriphery = selected;
                  } else {
                    cubit.rightFundusPeriphery = selected;
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RightEyeLid extends StatelessWidget {
  const RightEyeLid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ExaminationCubit>();

    return BlocBuilder<ExaminationCubit, ExaminationState>(
      builder: (context, state) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colorz.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Right eye", style: appStyle(context, 16, Colorz.black, FontWeight.bold)),
              const HeightSpacer(size: 10),
              CustomColumnDropdown(
                items: cubit.data['EyelidPtosis'] ?? [],
                textRow: "Ptosis :",
                hintText: "-",
                selectedValue: cubit.rightEyelidPtosis,
                onChanged: (selected) {
                  cubit.updateRightEyeField('eyelidPtosis', selected);
                },
              ),
              const HeightSpacer(size: 15),
              CustomColumnDropdown(
                items: cubit.data['EyelidLagophthalmos'] ?? [],
                textRow: "Lagophthalmos :",
                hintText: "-",
                selectedValue: cubit.rightEyelidLagophthalmos,
                onChanged: (selected) {
                  cubit.updateRightEyeField('eyelidLagophthalmos', selected);
                },
              ),
              const HeightSpacer(size: 15),
              CustomColumnDropdown(
                items: cubit.data['PalpableLymphNodes'] ?? [],
                textRow: "Palpable Lymph Nodes :",
                hintText: "-",
                selectedValue: cubit.rightPalpableLymphNodes,
                onChanged: (selected) {
                  cubit.updateRightEyeField('palpableLymphNodes', selected);
                },
              ),
              const HeightSpacer(size: 15),
              CustomColumnDropdown(
                items: cubit.data['PapableTemporalArtery'] ?? [],
                textRow: "PapableTemporalArtery:",
                hintText: "-",
                selectedValue: cubit.rightPapableTemporalArtery,
                onChanged: (selected) {
                  cubit.updateRightEyeField('papableTemporalArtery', selected);
                },
              ),
              const HeightSpacer(size: 15),
              CustomColumnDropdown(
                items: cubit.data['Exophthalmometry'] ?? [],
                textRow: "Exophthalmometry:",
                hintText: "-",
                selectedValue: cubit.rightExophthalmometry,
                onChanged: (selected) {
                  cubit.updateRightEyeField('exophthalmometry', selected);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LeftEyeLid extends StatelessWidget {
  const LeftEyeLid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ExaminationCubit>();

    return BlocBuilder<ExaminationCubit, ExaminationState>(
      builder: (context, state) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colorz.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Left eye", style: appStyle(context, 16, Colorz.black, FontWeight.bold)),
              const HeightSpacer(size: 10),
              CustomColumnDropdown(
                items: cubit.data['EyelidPtosis'] ?? [],
                textRow: "Ptosis :",
                hintText: "-",
                selectedValue: cubit.leftEyelidPtosis,
                onChanged: (selected) {
                  cubit.updateLeftEyeField('eyelidPtosis', selected);
                },
              ),
              const HeightSpacer(size: 15),
              CustomColumnDropdown(
                items: cubit.data['EyelidLagophthalmos'] ?? [],
                textRow: "Lagophthalmos :",
                hintText: "-",
                selectedValue: cubit.leftEyelidLagophthalmos,
                onChanged: (selected) {
                  cubit.updateLeftEyeField('eyelidLagophthalmos', selected);
                },
              ),
              const HeightSpacer(size: 15),
              CustomColumnDropdown(
                items: cubit.data['PalpableLymphNodes'] ?? [],
                textRow: "Palpable Lymph Nodes :",
                hintText: "-",
                selectedValue: cubit.leftPalpableLymphNodes,
                onChanged: (selected) {
                  cubit.updateLeftEyeField('palpableLymphNodes', selected);
                },
              ),
              const HeightSpacer(size: 15),
              CustomColumnDropdown(
                items: cubit.data['PapableTemporalArtery'] ?? [],
                textRow: "PapableTemporalArtery:",
                hintText: "-",
                selectedValue: cubit.leftPapableTemporalArtery,
                onChanged: (selected) {
                  cubit.updateLeftEyeField('papableTemporalArtery', selected);
                },
              ),
              const HeightSpacer(size: 15),
              CustomColumnDropdown(
                items: cubit.data['Exophthalmometry'] ?? [],
                textRow: "Exophthalmometry:",
                hintText: "-",
                selectedValue: cubit.leftExophthalmometry,
                onChanged: (selected) {
                  cubit.updateLeftEyeField('exophthalmometry', selected);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
