import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocurithm/core/utils/colors.dart';
import 'package:ocurithm/modules/Examination/presentaion/views/widgets/review_examination.dart';

import '../../../../../Main/presentation/views/drawer.dart';
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
          drawer: const CustomDrawer(),
          body: Column(
            children: [
              ModernStepHeader(
                currentStep: cubit.currentStep,
                totalSteps: cubit.totalSteps,
                onMenuPressed: () {
                  try {
                    Scaffold.of(context).openDrawer();
                  } catch (e) {
                    debugPrint(e.toString());
                  }
                },
              ),
              Expanded(
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      padding: const EdgeInsets.only(
                        top: 16,
                        left: 16,
                        right: 16,
                        bottom: 80,
                      ),
                      child: _buildStepContent(cubit.currentStep),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: StepNavigation(
                        onPrevious: () => cubit.previousStep(),
                        onNext: () => cubit.nextStep(),
                        isLastStep: cubit.currentStep == cubit.totalSteps - 1,
                        canGoBack: cubit.currentStep > 0,
                        canContinue: cubit.currentStep < cubit.totalSteps - 1,
                      ),
                    ),
                  ],
                ),
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

// Step content widgets
class _HistoryDetails extends StatelessWidget {
  const _HistoryDetails();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ExaminationCubit>();

    return BlocBuilder<ExaminationCubit, ExaminationState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Patient History',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please provide detailed medical history',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
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
                controller: cubit.historyController,
                maxLines: 10,
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
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Include any relevant medical conditions, medications, or allergies',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ],
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
      builder: (context, state) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current Complaints',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Describe the current symptoms and concerns',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          // Main Complaint Box
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
              maxLines: 10,
              controller: cubit.complaintController,
              decoration: InputDecoration(
                hintText: 'Describe the main complaint...',
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Include main symptoms, when they started, and any treatments tried',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
        ],
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
    final size = MediaQuery.of(context).size;

    return SizedBox(
      height: size.height - 200,
      child: ListView(
        physics: const ClampingScrollPhysics(),
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
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
      ),
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
      builder: (context, state) => Column(
        spacing: 20,
        children: [
          _buildExpandableContainer('Autoref', AutorefContent(isLeftEye: isLeftEye)),
          _buildExpandableContainer('Visual Acuity', VisualAcuityContent(isLeftEye: isLeftEye)),
          _buildExpandableContainer('Refined Refraction', RefinedRefractionContent(isLeftEye: isLeftEye)),
          _buildExpandableContainer('IOP', IOPContent(isLeftEye: isLeftEye)),
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
        ],
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
          DropValidateRow(
            items: cubit.data['AurorefSpherical']
                    ?.map<DropdownMenuItem<dynamic>>((item) => DropdownMenuItem(value: item, child: Text(item.toString())))
                    .toList() ??
                [],
            hintText: "",
            textRow: "Spherical :",
            selectedValue: isLeftEye ? cubit.leftAurorefSpherical : cubit.rightAurorefSpherical,
            onChanged: (selected) {
              if (isLeftEye) {
                cubit.updateLeftEyeField('aurorefSpherical', selected);
              } else {
                cubit.updateRightEyeField('aurorefSpherical', selected);
              }
            },
          ),
          const SizedBox(height: 16),
          DropValidateRow(
            items: cubit.data['AurorefCylindrical']
                    ?.map<DropdownMenuItem<dynamic>>((item) => DropdownMenuItem(value: item, child: Text(item.toString())))
                    .toList() ??
                [],
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
          DropValidateRow(
            items:
                cubit.data['UCVA']?.map<DropdownMenuItem<dynamic>>((item) => DropdownMenuItem(value: item, child: Text(item.toString()))).toList() ??
                    [],
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
          const SizedBox(height: 16),
          DropValidateRow(
            items:
                cubit.data['BCVA']?.map<DropdownMenuItem<dynamic>>((item) => DropdownMenuItem(value: item, child: Text(item.toString()))).toList() ??
                    [],
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
          DropValidateRow(
            items: cubit.data['PupilsShape']
                    ?.map<DropdownMenuItem<dynamic>>((item) => DropdownMenuItem(value: item, child: Text(item.toString())))
                    .toList() ??
                [],
            hintText: "",
            textRow: "Shape :",
            selectedValue: isLeftEye ? cubit.leftPupilsShape : cubit.rightPupilsShape,
            onChanged: (selected) {
              if (isLeftEye) {
                cubit.updateLeftEyeField('pupilsShape', selected);
              } else {
                cubit.updateRightEyeField('pupilsShape', selected);
              }
            },
          ),
          const SizedBox(height: 16),
          DropValidateRow(
            items: cubit.data['PupilsLightReflexTest']
                    ?.map<DropdownMenuItem<dynamic>>((item) => DropdownMenuItem(value: item, child: Text(item.toString())))
                    .toList() ??
                [],
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
          const SizedBox(height: 16),
          DropValidateRow(
            items: cubit.data['PupilsNearReflexTest']
                    ?.map<DropdownMenuItem<dynamic>>((item) => DropdownMenuItem(value: item, child: Text(item.toString())))
                    .toList() ??
                [],
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
          const SizedBox(height: 16),
          DropValidateRow(
            items: cubit.data['PupilsSwingingFlashLightTest']
                    ?.map<DropdownMenuItem<dynamic>>((item) => DropdownMenuItem(value: item, child: Text(item.toString())))
                    .toList() ??
                [],
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
          const SizedBox(height: 16),
          DropValidateRow(
            items: cubit.data['PupilsOtherDisorders']
                    ?.map<DropdownMenuItem<dynamic>>((item) => DropdownMenuItem(value: item, child: Text(item.toString())))
                    .toList() ??
                [],
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
          DropValidateRow(
            items: cubit.data['RefinedRefractionSpherical']
                    ?.map<DropdownMenuItem<dynamic>>((item) => DropdownMenuItem(value: item, child: Text(item.toString())))
                    .toList() ??
                [],
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
          const SizedBox(height: 16),
          DropValidateRow(
            items: cubit.data['RefinedRefractionCylindrical']
                    ?.map<DropdownMenuItem<dynamic>>((item) => DropdownMenuItem(value: item, child: Text(item.toString())))
                    .toList() ??
                [],
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
          const SizedBox(height: 16),
          DropValidateRow(
            items: cubit.data['RefinedRefractionAxis']
                    ?.map<DropdownMenuItem<dynamic>>((item) => DropdownMenuItem(value: item, child: Text(item.toString())))
                    .toList() ??
                [],
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
          DropValidateRow(
            items:
                cubit.data['IOP']?.map<DropdownMenuItem<dynamic>>((item) => DropdownMenuItem(value: item, child: Text(item.toString()))).toList() ??
                    [],
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
          const SizedBox(height: 16),
          DropValidateRow(
            items: cubit.data['MeansOfMeasurement']
                    ?.map<DropdownMenuItem<dynamic>>((item) => DropdownMenuItem(value: item, child: Text(item.toString())))
                    .toList() ??
                [],
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
          const SizedBox(height: 16),
          DropValidateRow(
            items: cubit.data['AcquireAnotherIOPMeasurement']
                    ?.map<DropdownMenuItem<dynamic>>((item) => DropdownMenuItem(value: item, child: Text(item.toString())))
                    .toList() ??
                [],
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
          DropValidateRow(
            items: cubit.data['Cornea']
                    ?.map<DropdownMenuItem<dynamic>>((item) => DropdownMenuItem(value: item, child: Text(item.toString())))
                    .toList() ??
                [],
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
          DropValidateRow(
            items: cubit.data['AnteriorChambre']
                    ?.map<DropdownMenuItem<dynamic>>((item) => DropdownMenuItem(value: item, child: Text(item.toString())))
                    .toList() ??
                [],
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
          DropValidateRow(
            items:
                cubit.data['Iris']?.map<DropdownMenuItem<dynamic>>((item) => DropdownMenuItem(value: item, child: Text(item.toString()))).toList() ??
                    [],
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
          DropValidateRow(
            items:
                cubit.data['Lens']?.map<DropdownMenuItem<dynamic>>((item) => DropdownMenuItem(value: item, child: Text(item.toString()))).toList() ??
                    [],
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
          DropValidateRow(
            items: cubit.data['AnteriorVitreous']
                    ?.map<DropdownMenuItem<dynamic>>((item) => DropdownMenuItem(value: item, child: Text(item.toString())))
                    .toList() ??
                [],
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
          DropValidateRow(
            items: cubit.data['FundusOpticDisc']
                    ?.map<DropdownMenuItem<dynamic>>((item) => DropdownMenuItem(value: item, child: Text(item.toString())))
                    .toList() ??
                [],
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
          DropValidateRow(
            items: cubit.data['FundusMacula']
                    ?.map<DropdownMenuItem<dynamic>>((item) => DropdownMenuItem(value: item, child: Text(item.toString())))
                    .toList() ??
                [],
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
          DropValidateRow(
            items: cubit.data['FundusVessels']
                    ?.map<DropdownMenuItem<dynamic>>((item) => DropdownMenuItem(value: item, child: Text(item.toString())))
                    .toList() ??
                [],
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
          DropValidateRow(
            items: cubit.data['FundusPeriphery']
                    ?.map<DropdownMenuItem<dynamic>>((item) => DropdownMenuItem(value: item, child: Text(item.toString())))
                    .toList() ??
                [],
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
          DropValidateRow(
            items:
                cubit.data['EyelidPtosis']?.map<DropdownMenuItem<dynamic>>((item) => DropdownMenuItem(value: item, child: Text(item))).toList() ?? [],
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
          DropValidateRow(
            items: cubit.data['EyelidLagophthalmos']
                    ?.map<DropdownMenuItem<dynamic>>((item) => DropdownMenuItem(value: item, child: Text(item)))
                    .toList() ??
                [],
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
          DropValidateRow(
            items: cubit.data['PalpableLymphNodes']
                    ?.map<DropdownMenuItem<dynamic>>((item) => DropdownMenuItem(value: item, child: Text(item)))
                    .toList() ??
                [],
            hintText: "",
            textRow: "Palpable Temporal Artery :",
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
          DropValidateRow(
            items:
                cubit.data['Exophthalmometry']?.map<DropdownMenuItem<dynamic>>((item) => DropdownMenuItem(value: item, child: Text(item))).toList() ??
                    [],
            hintText: "",
            textRow: "Exophthamometry:",
            selectedValue: isLeftEye ? cubit.leftPapableTemporalArtery : cubit.rightPapableTemporalArtery,
            onChanged: (selected) {
              if (isLeftEye) {
                cubit.updateLeftEyeField('papableTemporalArtery', selected);
              } else {
                cubit.updateRightEyeField('papableTemporalArtery', selected);
              }
            },
          ),
        ],
      ),
    );
  }
}
