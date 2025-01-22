import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:ocurithm/core/utils/colors.dart';
import 'package:ocurithm/core/widgets/custom_freeze_loading.dart';
import 'package:ocurithm/modules/Examination/presentaion/views/widgets/review_examination.dart';

import '../../../../../core/utils/app_style.dart';
import '../../../../../core/widgets/DropdownPackage.dart';
import '../../../../../core/widgets/height_spacer.dart';
import '../../../../../core/widgets/text_field.dart';
import '../../manager/examination_cubit.dart';
import '../../manager/examination_state.dart';
import 'circle_view.dart';
import 'header_view.dart';
import 'navigation_view.dart';

class MultiStepFormView extends StatelessWidget {
  const MultiStepFormView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExaminationCubit, ExaminationState>(
      builder: (context, state) {
        final cubit = context.read<ExaminationCubit>();

        return Scaffold(
          resizeToAvoidBottomInset: true,
          body: Column(
            children: [
              ModernStepHeader(
                currentStep: cubit.currentStep,
                totalSteps: cubit.totalSteps,
                onPop: () => cubit.previousStep(),
              ),
              Expanded(
                // Wrapped with Expanded
                child: _buildStepContent(cubit.currentStep),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStepContent(int step) {
    switch (step) {
      case 0:
        return const _HistoryDetails();
      case 1:
        return const _StepTwoContent();
      case 2:
        return const StepThreeContent();
      case 3:
        return const ExaminationReviewScreen();
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
                  onConfirm: () async {
                    if (cubit.appointmentData != null) {
                      customLoading(context, "");
                      bool connection = await InternetConnection().hasInternetAccess;
                      if (connection) {
                        cubit.makeExamination(context: context);
                      } else {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('No Internet Connection', style: TextStyle(color: Colors.white)),
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
                onConfirm: () async {
                  if (cubit.appointmentData != null) {
                    customLoading(context, "");
                    bool connection = await InternetConnection().hasInternetAccess;
                    if (connection) {
                      cubit.makeExamination(context: context);
                    } else {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('No Internet Connection', style: TextStyle(color: Colors.white)),
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
  int index = 0;
  // Cache eye examination views
  late final leftEyeView = RepaintBoundary(child: EyeExaminationView(isLeftEye: true));
  late final rightEyeView = RepaintBoundary(child: EyeExaminationView(isLeftEye: false));

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const ClampingScrollPhysics(),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: CupertinoSlidingSegmentedControl<int>(
              groupValue: index,
              thumbColor: Colorz.primaryColor,
              backgroundColor: Colorz.white,
              padding: EdgeInsets.zero,
              children: {
                0: SegmentLabel(
                  text: "Left Eye",
                  index: 0,
                  color: index == 0 ? Colorz.white : Colorz.black,
                ),
                1: SegmentLabel(
                  text: "Right Eye",
                  index: 1,
                  color: index == 1 ? Colorz.white : Colorz.black,
                ),
              },
              onValueChanged: (value) {
                if (value != null && value != index) {
                  setState(() => index = value);
                }
              },
            ),
          ),
        ),
        // Use cached views
        index == 0 ? leftEyeView : rightEyeView,
      ],
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
  final bool isLeftEye;

  const EyeExaminationView({Key? key, required this.isLeftEye}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cubit = BlocProvider.of<ExaminationCubit>(context);
    final List<Color> _colorList = [
      Colors.grey[400]!,
      Colors.black,
      Colors.white,
    ];
    // // Create a list of all content widgets
    // final List<Widget> contentWidgets = [
    //   _buildExpandableContainer('Autoref', AutorefContent(isLeftEye: isLeftEye)),
    //   _buildExpandableContainer('Visual Acuity', VisualAcuityContent(isLeftEye: isLeftEye)),
    //   _buildExpandableContainer('Refined Refraction', RefinedRefractionContent(isLeftEye: isLeftEye)),
    //   _buildExpandableContainer('IOP', IOPContent(isLeftEye: isLeftEye)),
    //   isLeftEye
    //       ? QuadrantContainer(
    //           // Left side configuration
    //           containerSize: 300,
    //           colorList: _colorList,
    //           tapCounts: [
    //             cubit.leftTopLeftTapCount,
    //             cubit.leftTopRightTapCount,
    //             cubit.leftBottomLeftTapCount,
    //             cubit.leftBottomRightTapCount,
    //           ],
    //           tapHandlers: [
    //             cubit.leftTopLeftHandleTap,
    //             cubit.leftTopRightHandleTap,
    //             cubit.leftBottomLeftHandleTap,
    //             cubit.leftBottomRightHandleTap,
    //           ],
    //
    //           side: 'left',
    //         )
    //       : QuadrantContainer(
    //           // Left side configuration
    //           containerSize: 300,
    //           colorList: _colorList,
    //           tapCounts: [
    //             cubit.rightTopLeftTapCount,
    //             cubit.rightTopRightTapCount,
    //             cubit.rightBottomLeftTapCount,
    //             cubit.rightBottomRightTapCount,
    //           ],
    //           tapHandlers: [
    //             cubit.rightTopLeftHandleTap,
    //             cubit.rightTopRightHandleTap,
    //             cubit.rightBottomLeftHandleTap,
    //             cubit.rightBottomRightHandleTap,
    //           ],
    //
    //           side: 'right',
    //         ),
    //   _buildExpandableContainer('Pupils', PupilsContent(isLeftEye: isLeftEye)),
    //   _buildExpandableContainer('External Examination', ExternalExaminationContent(isLeftEye: isLeftEye)),
    //   _buildExpandableContainer('Slitlamp Examination', SlitLampExaminationContent(isLeftEye: isLeftEye)),
    //   _buildExpandableContainer('Additional Examination', AdditionalExaminationContent(isLeftEye: isLeftEye)),
    //   _buildExpandableContainer('Fundus Examination', FundusExaminationContent(isLeftEye: isLeftEye)),
    // ];

    return BlocBuilder<ExaminationCubit, ExaminationState>(
      builder: (context, state) => Padding(
        padding: const EdgeInsets.only(left: 16, right: 16),
        child: Column(
          spacing: 20,
          children: [
            _buildExpandableContainer('Autoref', AutorefContent(isLeftEye: isLeftEye)),
            _buildExpandableContainer('Visual Acuity', VisualAcuityContent(isLeftEye: isLeftEye)),
            _buildExpandableContainer('Refined Refraction', RefinedRefractionContent(isLeftEye: isLeftEye)),
            _buildExpandableContainer('IOP (mmHg)', IOPContent(isLeftEye: isLeftEye)),
            isLeftEye
                ? QuadrantContainer(
                    // Left side configuration
                    containerSize: 300,
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
                  )
                : QuadrantContainer(
                    // Left side configuration
                    containerSize: 300,
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
            _buildExpandableContainer('Pupils', PupilsContent(isLeftEye: isLeftEye)),
            _buildExpandableContainer('External Examination', ExternalExaminationContent(isLeftEye: isLeftEye)),
            _buildExpandableContainer('Slitlamp Examination', SlitLampExaminationContent(isLeftEye: isLeftEye)),
            _buildExpandableContainer('Additional Examination', AdditionalExaminationContent(isLeftEye: isLeftEye)),
            _buildExpandableContainer('Fundus Examination', FundusExaminationContent(isLeftEye: isLeftEye)),
            StepNavigation(
              onPrevious: () => cubit.previousStep(),
              onNext: () => cubit.nextStep(),
              isLastStep: cubit.currentStep == cubit.totalSteps - 1,
              canGoBack: cubit.currentStep > 0,
              canContinue: cubit.currentStep < cubit.totalSteps - 1,
              onConfirm: () async {
                if (cubit.appointmentData != null) {
                  customLoading(context, "");
                  bool connection = await InternetConnection().hasInternetAccess;
                  if (connection) {
                    cubit.makeExamination(context: context);
                  } else {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('No Internet Connection', style: TextStyle(color: Colors.white)),
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

class AutorefContent extends StatelessWidget {
  final bool isLeftEye;
  const AutorefContent({Key? key, required this.isLeftEye}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ExaminationCubit>();

    return BlocBuilder<ExaminationCubit, ExaminationState>(
      builder: (context, state) => Column(
        children: [
          CustomColumnDropdown(
            items: cubit.data['AurorefSpherical'] ?? [],
            hintText: "",
            textRow: "Spherical :",
            selectedValue: isLeftEye ? cubit.leftAurorefSpherical : cubit.rightAurorefSpherical,
            onChanged: (selected) {
              if (isLeftEye) {
                log("ssssssss" + selected.toString());
                cubit.updateLeftEyeField('aurorefSpherical', selected);
              } else {
                cubit.updateRightEyeField('aurorefSpherical', selected);
              }
            },
          ),
          const SizedBox(height: 8),
          CustomColumnDropdown(
            items: cubit.data['AurorefCylindrical'] ?? [],
            textRow: "Cylindrical :",
            hintText: '',
            selectedValue: isLeftEye ? cubit.leftAurorefCylindrical : cubit.rightAurorefCylindrical,
            onChanged: (selected) {
              if (isLeftEye) {
                cubit.updateLeftEyeField('aurorefCylindrical', selected);
              } else {
                cubit.updateRightEyeField('aurorefCylindrical', selected);
              }
            },
          ),
          const SizedBox(height: 8),
          CustomColumnDropdown(
            items: cubit.data['AurorefAxis'] ?? [],
            textRow: "Axis :",
            hintText: '',
            selectedValue: isLeftEye ? cubit.leftAurorefAxis : cubit.rightAurorefAxis,
            onChanged: (selected) {
              if (isLeftEye) {
                cubit.updateLeftEyeField('aurorefAxis', selected);
              } else {
                cubit.updateRightEyeField('aurorefAxis', selected);
              }
            },
          ),
          // Add other Autoref fields...
        ],
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
  bool isExpanded = false;

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

class VisualAcuityContent extends StatefulWidget {
  final bool isLeftEye;
  const VisualAcuityContent({Key? key, required this.isLeftEye}) : super(key: key);

  @override
  State<VisualAcuityContent> createState() => _VisualAcuityContentState();
}

class _VisualAcuityContentState extends State<VisualAcuityContent> {
  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ExaminationCubit>();

    return BlocBuilder<ExaminationCubit, ExaminationState>(
      builder: (context, state) => Column(
        children: [
          CustomColumnDropdown(
            items: cubit.data['UCVA'] ?? [],
            hintText: "",
            textRow: "UCVA :",
            radius: 15,
            height: 40,
            selectedValue: widget.isLeftEye ? cubit.leftUCVA : cubit.rightUCVA,
            onChanged: (selected) {
              log(selected.toString());
              if (widget.isLeftEye) {
                cubit.updateLeftEyeField('ucva', selected);
              } else {
                cubit.updateRightEyeField('ucva', selected);
              }
              setState(() {});
            },
          ),
          const SizedBox(height: 8),
          CustomColumnDropdown(
            items: cubit.data['BCVA'] ?? [],
            hintText: "",
            textRow: "BCVA :",
            radius: 15,
            height: 40,
            selectedValue: widget.isLeftEye ? cubit.leftBCVA : cubit.rightBCVA,
            onChanged: (selected) {
              if (widget.isLeftEye) {
                cubit.updateLeftEyeField('bcva', selected);
              } else {
                cubit.updateRightEyeField('bcva', selected);
              }
              setState(() {});
            },
          ),
        ],
      ),
    );
  }
}

class PupilsContent extends StatelessWidget {
  final bool isLeftEye;
  const PupilsContent({Key? key, required this.isLeftEye}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ExaminationCubit>();

    return BlocBuilder<ExaminationCubit, ExaminationState>(
      builder: (context, state) => Column(
        children: [
          CustomColumnDropdown(
            items: cubit.data['PupilsShape'] ?? [],
            hintText: "",
            textRow: "Shape :",
            selectedValue: isLeftEye ? cubit.leftPupilsShape : cubit.rightPupilsShape,
            onChanged: (selected) {
              if (isLeftEye) {
                cubit.updateLeftEyeField('pupilsShape', selected);
                log(cubit.leftPupilsShape.toString());
              } else {
                cubit.updateRightEyeField('pupilsShape', selected);
              }
            },
          ),
          if (cubit.leftPupilsShape == "others" && isLeftEye)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: TextField2(
                controller: isLeftEye ? cubit.leftShapeController : cubit.rightPupilsShape,
                hintText: 'Shape',
                required: false,
                onTextFieldChanged: (value) {
                  if (isLeftEye) {
                    cubit.updateLeftEyeField('lidsShape', value);
                  } else {
                    cubit.updateRightEyeField('lidsShape', value);
                  }
                },
                borderColor: Colors.black,
                fillColor: Colors.white,
                radius: 30,
              ),
            ),
          if (cubit.rightPupilsShape == "others" && !isLeftEye)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: TextField2(
                controller: isLeftEye ? cubit.leftShapeController : cubit.rightShapeController,
                hintText: 'Shape',
                required: false,
                onTextFieldChanged: (value) {
                  if (isLeftEye) {
                    cubit.updateLeftEyeField('lidsShape', value);
                  } else {
                    cubit.updateRightEyeField('lidsShape', value);
                  }
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
            hintText: '',
            selectedValue: isLeftEye ? cubit.leftPupilsLightReflexTest : cubit.rightPupilsLightReflexTest,
            onChanged: (selected) {
              if (isLeftEye) {
                cubit.updateLeftEyeField('pupilsLightReflexTest', selected);
              } else {
                cubit.updateRightEyeField('pupilsLightReflexTest', selected);
              }
            },
          ),
          const SizedBox(height: 8),
          CustomColumnDropdown(
            items: cubit.data['PupilsNearReflexTest'] ?? [],
            hintText: "",
            textRow: "Near Reflex Test :",
            selectedValue: isLeftEye ? cubit.leftPupilsNearReflexTest : cubit.rightPupilsNearReflexTest,
            onChanged: (selected) {
              if (isLeftEye) {
                cubit.updateLeftEyeField('pupilsNearReflexTest', selected);
              } else {
                cubit.updateRightEyeField('pupilsNearReflexTest', selected);
              }
            },
          ),
          const SizedBox(height: 8),
          CustomColumnDropdown(
            items: cubit.data['PupilsSwingingFlashLightTest'] ?? [],
            hintText: "",
            textRow: "Swinging Flash Test :",
            selectedValue: isLeftEye ? cubit.leftPupilsSwingingFlashLightTest : cubit.rightPupilsSwingingFlashLightTest,
            onChanged: (selected) {
              if (isLeftEye) {
                cubit.updateLeftEyeField('pupilsSwingingFlashLightTest', selected);
              } else {
                cubit.updateRightEyeField('pupilsSwingingFlashLightTest', selected);
              }
            },
          ),
          const SizedBox(height: 8),
          CustomColumnDropdown(
            items: cubit.data['PupilsOtherDisorders'] ?? [],
            hintText: "",
            textRow: "Other Disorders :",
            selectedValue: isLeftEye ? cubit.leftPupilsOtherDisorders : cubit.rightPupilsOtherDisorders,
            onChanged: (selected) {
              if (isLeftEye) {
                cubit.updateLeftEyeField('pupilsOtherDisorders', selected);
              } else {
                cubit.updateRightEyeField('pupilsOtherDisorders', selected);
              }
            },
          ),
        ],
      ),
    );
  }
}

class RefinedRefractionContent extends StatelessWidget {
  final bool isLeftEye;
  const RefinedRefractionContent({Key? key, required this.isLeftEye}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ExaminationCubit>();

    return BlocBuilder<ExaminationCubit, ExaminationState>(
      builder: (context, state) => Column(
        children: [
          CustomColumnDropdown(
            items: cubit.data['RefinedRefractionSpherical'] ?? [],
            hintText: "",
            textRow: "Spherical :",
            selectedValue: isLeftEye ? cubit.leftRefinedRefractionSpherical : cubit.rightRefinedRefractionSpherical,
            onChanged: (selected) {
              if (isLeftEye) {
                cubit.updateLeftEyeField('refinedRefractionSpherical', selected);
              } else {
                cubit.updateRightEyeField('refinedRefractionSpherical', selected);
              }
            },
          ),
          const SizedBox(height: 8),
          CustomColumnDropdown(
            items: cubit.data['RefinedRefractionCylindrical'] ?? [],
            textRow: "Cylindrical :",
            hintText: '',
            selectedValue: isLeftEye ? cubit.leftRefinedRefractionCylindrical : cubit.rightRefinedRefractionCylindrical,
            onChanged: (selected) {
              if (isLeftEye) {
                cubit.updateLeftEyeField('refinedRefractionCylindrical', selected);
              } else {
                cubit.updateRightEyeField('refinedRefractionCylindrical', selected);
              }
            },
          ),
          const SizedBox(height: 8),
          CustomColumnDropdown(
            items: cubit.data['RefinedRefractionAxis'] ?? [],
            hintText: "",
            textRow: "Axis :",
            selectedValue: isLeftEye ? cubit.leftRefinedRefractionAxis : cubit.rightRefinedRefractionAxis,
            onChanged: (selected) {
              if (isLeftEye) {
                cubit.updateLeftEyeField('refinedRefractionAxis', selected);
              } else {
                cubit.updateRightEyeField('refinedRefractionAxis', selected);
              }
            },
          ),
        ],
      ),
    );
  }
}

class IOPContent extends StatelessWidget {
  final bool isLeftEye;
  const IOPContent({Key? key, required this.isLeftEye}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ExaminationCubit>();

    return BlocBuilder<ExaminationCubit, ExaminationState>(
      builder: (context, state) => Column(
        children: [
          CustomColumnDropdown(
            items: cubit.data['IOP'] ?? [],
            hintText: "",
            textRow: "IOP :",
            radius: 15,
            height: 40,
            selectedValue: isLeftEye ? cubit.leftIOP : cubit.rightIOP,
            onChanged: (selected) {
              if (isLeftEye) {
                cubit.updateLeftEyeField('iop', selected);
              } else {
                cubit.updateRightEyeField('iop', selected);
              }
            },
          ),
          const SizedBox(height: 8),
          CustomColumnDropdown(
            items: cubit.data['MeansOfMeasurement'] ?? [],
            hintText: "",
            textRow: "Means of Measurement:",
            selectedValue: isLeftEye ? cubit.leftMeansOfMeasurement : cubit.rightMeansOfMeasurement,
            onChanged: (selected) {
              if (isLeftEye) {
                cubit.updateLeftEyeField('meansOfMeasurement', selected);
              } else {
                cubit.updateRightEyeField('meansOfMeasurement', selected);
              }
            },
          ),
          const SizedBox(height: 8),
          CustomColumnDropdown(
            items: cubit.data['AcquireAnotherIOPMeasurement'] ?? [],
            hintText: "",
            textRow: "Another IOP:",
            selectedValue: isLeftEye ? cubit.leftAcquireAnotherIOPMeasurement : cubit.rightAcquireAnotherIOPMeasurement,
            onChanged: (selected) {
              if (isLeftEye) {
                cubit.updateLeftEyeField('acquireAnotherIOPMeasurement', selected);
              } else {
                cubit.updateRightEyeField('acquireAnotherIOPMeasurement', selected);
              }
            },
          ),
        ],
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
      builder: (context, state) => Column(
        children: [
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
    );
  }
}

class AdditionalExaminationContent extends StatelessWidget {
  final bool isLeftEye;
  const AdditionalExaminationContent({Key? key, required this.isLeftEye}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ExaminationCubit>();

    return BlocBuilder<ExaminationCubit, ExaminationState>(
      builder: (context, state) => Column(
        children: [
          CustomColumnDropdown(
            items: cubit.data['Cornea'] ?? [],
            hintText: "",
            textRow: "Cornea :",
            selectedValue: isLeftEye ? cubit.leftCornea : cubit.rightCornea,
            onChanged: (selected) {
              if (isLeftEye) {
                cubit.updateLeftEyeField('cornea', selected);
              } else {
                cubit.updateRightEyeField('cornea', selected);
              }
            },
          ),
          const SizedBox(height: 15),
          CustomColumnDropdown(
            items: cubit.data['AnteriorChambre'] ?? [],
            hintText: "",
            textRow: "Anterior Chambre :",
            selectedValue: isLeftEye ? cubit.leftAnteriorChambre : cubit.rightAnteriorChambre,
            onChanged: (selected) {
              if (isLeftEye) {
                cubit.updateLeftEyeField('anteriorChambre', selected);
              } else {
                cubit.updateRightEyeField('anteriorChambre', selected);
              }
            },
          ),
          const SizedBox(height: 15),
          CustomColumnDropdown(
            items: cubit.data['Iris'] ?? [],
            hintText: "",
            textRow: "Iris :",
            selectedValue: isLeftEye ? cubit.leftIris : cubit.rightIris,
            onChanged: (selected) {
              if (isLeftEye) {
                cubit.updateLeftEyeField('iris', selected);
              } else {
                cubit.updateRightEyeField('iris', selected);
              }
            },
          ),
          const SizedBox(height: 15),
          CustomColumnDropdown(
            items: cubit.data['Lens'] ?? [],
            hintText: "",
            textRow: "Lens :",
            selectedValue: isLeftEye ? cubit.leftLens : cubit.rightLens,
            onChanged: (selected) {
              if (isLeftEye) {
                cubit.updateLeftEyeField('lens', selected);
              } else {
                cubit.updateRightEyeField('lens', selected);
              }
            },
          ),
          const SizedBox(height: 15),
          CustomColumnDropdown(
            items: cubit.data['AnteriorVitreous'] ?? [],
            hintText: "",
            textRow: "Anterior Vitreous :",
            selectedValue: isLeftEye ? cubit.leftAnteriorVitreous : cubit.rightAnteriorVitreous,
            onChanged: (selected) {
              if (isLeftEye) {
                cubit.updateLeftEyeField('anteriorVitreous', selected);
              } else {
                cubit.updateRightEyeField('anteriorVitreous', selected);
              }
            },
          ),
        ],
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
      builder: (context, state) => Column(
        children: [
          CustomColumnDropdown(
            items: cubit.data['FundusOpticDisc'] ?? [],
            hintText: "",
            textRow: "Optic Disc :",
            selectedValue: isLeftEye ? cubit.leftFundusOpticDisc : cubit.rightFundusOpticDisc,
            onChanged: (selected) {
              if (isLeftEye) {
                cubit.updateLeftEyeField('fundusOpticDisc', selected);
              } else {
                cubit.updateRightEyeField('fundusOpticDisc', selected);
              }
            },
          ),
          const SizedBox(height: 15),
          CustomColumnDropdown(
            items: cubit.data['FundusMacula'] ?? [],
            hintText: "",
            textRow: "Macula :",
            selectedValue: isLeftEye ? cubit.leftFundusMacula : cubit.rightFundusMacula,
            onChanged: (selected) {
              if (isLeftEye) {
                cubit.updateLeftEyeField('fundusMacula', selected);
              } else {
                cubit.updateRightEyeField('fundusMacula', selected);
              }
            },
          ),
          const SizedBox(height: 15),
          CustomColumnDropdown(
            items: cubit.data['FundusVessels'] ?? [],
            hintText: "",
            textRow: "Vessels :",
            selectedValue: isLeftEye ? cubit.leftFundusVessels : cubit.rightFundusVessels,
            onChanged: (selected) {
              if (isLeftEye) {
                cubit.updateLeftEyeField('fundusVessels', selected);
              } else {
                cubit.updateRightEyeField('fundusVessels', selected);
              }
            },
          ),
          const SizedBox(height: 15),
          CustomColumnDropdown(
            items: cubit.data['FundusPeriphery'] ?? [],
            hintText: "",
            textRow: "Fundus Periphery :",
            selectedValue: isLeftEye ? cubit.leftFundusPeriphery : cubit.rightFundusPeriphery,
            onChanged: (selected) {
              if (isLeftEye) {
                cubit.updateLeftEyeField('fundusPeriphery', selected);
              } else {
                cubit.updateRightEyeField('fundusPeriphery', selected);
              }
            },
          ),
        ],
      ),
    );
  }
}

class ExternalExaminationContent extends StatelessWidget {
  final bool isLeftEye;
  const ExternalExaminationContent({Key? key, required this.isLeftEye}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ExaminationCubit>();

    return BlocBuilder<ExaminationCubit, ExaminationState>(
      builder: (context, state) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const HeightSpacer(size: 10),
          Center(
            child: Text("Eyelid", style: appStyle(context, 20, Colors.black, FontWeight.w600)),
          ),
          const HeightSpacer(size: 10),
          CustomColumnDropdown(
            items: cubit.data['EyelidPtosis'] ?? [],
            hintText: "",
            textRow: "Ptosis :",
            selectedValue: isLeftEye ? cubit.leftEyelidPtosis : cubit.rightEyelidPtosis,
            onChanged: (selected) {
              if (isLeftEye) {
                cubit.updateLeftEyeField('eyelidPtosis', selected);
              } else {
                cubit.updateRightEyeField('eyelidPtosis', selected);
              }
            },
          ),
          const HeightSpacer(size: 15),
          CustomColumnDropdown(
            items: cubit.data['EyelidLagophthalmos'] ?? [],
            textRow: "Lagophthalmos :",
            hintText: '',
            selectedValue: isLeftEye ? cubit.leftEyelidLagophthalmos : cubit.rightEyelidLagophthalmos,
            onChanged: (selected) {
              if (isLeftEye) {
                cubit.updateLeftEyeField('eyelidLagophthalmos', selected);
              } else {
                cubit.updateRightEyeField('eyelidLagophthalmos', selected);
              }
            },
          ),
          const HeightSpacer(size: 15),
          CustomColumnDropdown(
            items: cubit.data['PalpableLymphNodes'] ?? [],
            hintText: "",
            textRow: "Palpable Lymph Nodes :",
            selectedValue: isLeftEye ? cubit.leftPalpableLymphNodes : cubit.rightPalpableLymphNodes,
            onChanged: (selected) {
              if (isLeftEye) {
                cubit.updateLeftEyeField('palpableLymphNodes', selected);
              } else {
                cubit.updateRightEyeField('palpableLymphNodes', selected);
              }
            },
          ),
          const HeightSpacer(size: 15),
          CustomColumnDropdown(
            items: cubit.data['PapableTemporalArtery'] ?? [],
            hintText: "",
            textRow: "PapableTemporalArtery:",
            selectedValue: isLeftEye ? cubit.leftPapableTemporalArtery : cubit.rightPapableTemporalArtery,
            onChanged: (selected) {
              if (isLeftEye) {
                cubit.updateLeftEyeField('papableTemporalArtery', selected);
              } else {
                cubit.updateRightEyeField('papableTemporalArtery', selected);
              }
            },
          ),
          const HeightSpacer(size: 15),
          CustomColumnDropdown(
            items: cubit.data['Exophthalmometry'] ?? [],
            hintText: "",
            textRow: "Exophthalmometry:",
            selectedValue: isLeftEye ? cubit.leftExophthalmometry : cubit.rightExophthalmometry,
            onChanged: (selected) {
              if (isLeftEye) {
                cubit.updateLeftEyeField('exophthalmometry', selected);
              } else {
                cubit.updateRightEyeField('exophthalmometry', selected);
              }
            },
          ),
        ],
      ),
    );
  }
}
