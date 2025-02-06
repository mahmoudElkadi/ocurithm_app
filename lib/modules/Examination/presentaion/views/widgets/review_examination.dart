import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:ocurithm/core/widgets/height_spacer.dart';

import '../../../../../core/utils/colors.dart';
import '../../../../../core/widgets/custom_freeze_loading.dart';
import '../../manager/examination_cubit.dart';
import '../../manager/examination_state.dart';
import 'circle_view.dart';
import 'navigation_view.dart';

class ExaminationReviewScreen extends StatefulWidget {
  const ExaminationReviewScreen({Key? key}) : super(key: key);

  @override
  State<ExaminationReviewScreen> createState() => _ExaminationReviewScreenState();
}

class _ExaminationReviewScreenState extends State<ExaminationReviewScreen> with SingleTickerProviderStateMixin {
  late PageController _pageController;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageController.addListener(() {
      if (_pageController.page?.round() != _selectedTab) {
        setState(() {
          _selectedTab = _pageController.page!.round();
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ExaminationCubit>();
    return BlocBuilder<ExaminationCubit, ExaminationState>(
      builder: (BuildContext context, state) => SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0).copyWith(bottom: 0),
          child: Column(
            spacing: 16,
            children: [
              // Patient Info and History Section
              Column(
                children: [
                  _buildPatientInfoCard(),
                  _buildHistorySection(),
                ],
              ),

              Column(
                children: [
                  // Tab bar
                  // Row(
                  //   children: [
                  //     Expanded(
                  //       child: InkWell(
                  //         onTap: () => setState(() => _selectedTab = 0),
                  //         child: Container(
                  //           padding: const EdgeInsets.symmetric(vertical: 12),
                  //           decoration: BoxDecoration(
                  //             border: Border(
                  //               bottom: BorderSide(
                  //                 color: _selectedTab == 0 ? Colorz.primaryColor : Colors.grey.shade300,
                  //                 width: 2,
                  //               ),
                  //             ),
                  //           ),
                  //           child: Text(
                  //             'Left Eye',
                  //             textAlign: TextAlign.center,
                  //             style: TextStyle(
                  //               color: _selectedTab == 0 ? Colorz.primaryColor : Colors.grey,
                  //               fontWeight: _selectedTab == 0 ? FontWeight.bold : FontWeight.normal,
                  //             ),
                  //           ),
                  //         ),
                  //       ),
                  //     ),
                  //     Expanded(
                  //       child: InkWell(
                  //         onTap: () => setState(() => _selectedTab = 1),
                  //         child: Container(
                  //           padding: const EdgeInsets.symmetric(vertical: 12),
                  //           decoration: BoxDecoration(
                  //             border: Border(
                  //               bottom: BorderSide(
                  //                 color: _selectedTab == 1 ? Colorz.primaryColor : Colors.grey.shade300,
                  //                 width: 2,
                  //               ),
                  //             ),
                  //           ),
                  //           child: Text(
                  //             'Right Eye',
                  //             textAlign: TextAlign.center,
                  //             style: TextStyle(
                  //               color: _selectedTab == 1 ? Colorz.primaryColor : Colors.grey,
                  //               fontWeight: _selectedTab == 1 ? FontWeight.bold : FontWeight.normal,
                  //             ),
                  //           ),
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 10,
                    children: [
                      _buildEyeExaminationContent(isLeft: false),
                      _buildEyeExaminationContent(isLeft: true),
                    ],
                  )
                  // Content
                ],
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
      ),
    );
  }

  Widget _buildQuadrantSection({required bool isLeft}) {
    final cubit = context.read<ExaminationCubit>();

    // Define color list matching your original implementation
    final List<Color> _colorList = [
      Colors.grey[400]!,
      Colors.black,
      Colors.white,
    ];

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      shadowColor: Colorz.primaryColor.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          maintainState: true,
          initiallyExpanded: true,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          childrenPadding: const EdgeInsets.all(0),
          title: Text(
            'Confrontation Fields',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colorz.primaryColor,
            ),
          ),
          children: [
            QuadrantContainer(
              containerSize: 280,
              colorList: _colorList,
              tapCounts: isLeft
                  ? [
                      cubit.leftTopLeftTapCount,
                      cubit.leftTopRightTapCount,
                      cubit.leftBottomLeftTapCount,
                      cubit.leftBottomRightTapCount,
                    ]
                  : [
                      cubit.rightTopLeftTapCount,
                      cubit.rightTopRightTapCount,
                      cubit.rightBottomLeftTapCount,
                      cubit.rightBottomRightTapCount,
                    ],
              side: isLeft ? 'left' : 'right',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEyeExaminationContent({required bool isLeft}) {
    return BlocBuilder<ExaminationCubit, ExaminationState>(
      builder: (context, state) {
        final cubit = context.read<ExaminationCubit>();

        return Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, // Add this line

            children: [
              Text(isLeft ? 'Left Eye' : 'Right Eye',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colorz.primaryColor,
                    fontWeight: FontWeight.bold,
                  )),
              HeightSpacer(size: 10),
              _buildQuadrantSection(isLeft: isLeft),
              _buildExaminationSection(
                title: 'Auto-refraction',
                isLeft: isLeft,
                sectionIndex: 0,
                data: {
                  'Spherical': isLeft ? cubit.leftAurorefSpherical : cubit.rightAurorefSpherical,
                  'Cylindrical': isLeft ? cubit.leftAurorefCylindrical : cubit.rightAurorefCylindrical,
                  'Axis': isLeft ? cubit.leftAurorefAxis : cubit.rightAurorefAxis,
                },
              ),
              _buildExaminationSection(
                title: 'Refined Refraction',
                isLeft: isLeft,
                sectionIndex: 2,
                data: {
                  'Spherical': isLeft ? cubit.leftRefinedRefractionSpherical : cubit.rightRefinedRefractionSpherical,
                  'Cylindrical': isLeft ? cubit.leftRefinedRefractionCylindrical : cubit.rightRefinedRefractionCylindrical,
                  'Axis': isLeft ? cubit.leftRefinedRefractionAxis : cubit.rightRefinedRefractionAxis,
                  'NearVision': isLeft ? cubit.leftNearVisionAddition : cubit.rightNearVisionAddition,
                },
              ),
              _buildExaminationSection(
                title: 'Visual Acuity',
                isLeft: isLeft,
                sectionIndex: 1,
                data: {
                  'UCVA': isLeft ? cubit.leftUCVA : cubit.rightUCVA,
                  'BCVA': isLeft ? cubit.leftBCVA : cubit.rightBCVA,
                },
              ),

              _buildExaminationSection(
                title: 'IOP',
                isLeft: isLeft,
                sectionIndex: 3,
                data: {
                  'IOP Value': isLeft ? cubit.leftIOP : cubit.rightIOP,
                  'Measurement Method': isLeft ? cubit.leftMeansOfMeasurement : cubit.rightMeansOfMeasurement,
                  'Additional Measurement': isLeft ? cubit.leftAcquireAnotherIOPMeasurement : cubit.rightAcquireAnotherIOPMeasurement,
                },
              ),
              _buildExaminationSection(
                title: 'Pupils',
                isLeft: isLeft,
                sectionIndex: 4,
                data: {
                  'Shape': isLeft ? cubit.leftPupilsShape : cubit.rightPupilsShape,
                  'Light Reflex': isLeft ? cubit.leftPupilsLightReflexTest : cubit.rightPupilsLightReflexTest,
                  'Near Reflex': isLeft ? cubit.leftPupilsNearReflexTest : cubit.rightPupilsNearReflexTest,
                  'Swinging Flashlight': isLeft ? cubit.leftPupilsSwingingFlashLightTest : cubit.rightPupilsSwingingFlashLightTest,
                  'Other Disorders': isLeft ? cubit.leftPupilsOtherDisorders : cubit.rightPupilsOtherDisorders,
                },
              ),
              _buildExaminationSection(
                title: 'Eyelid & Physcal',
                isLeft: isLeft,
                sectionIndex: 5,
                data: {
                  'Eyelid Ptosis': isLeft ? cubit.leftEyelidPtosis : cubit.rightEyelidPtosis,
                  'Lagophthalmos': isLeft ? cubit.leftEyelidLagophthalmos : cubit.rightEyelidLagophthalmos,
                  'Palpable Lymph Nodes': isLeft ? cubit.leftPalpableLymphNodes : cubit.rightPalpableLymphNodes,
                  'Papable Temporal Artery': isLeft ? cubit.leftPapableTemporalArtery : cubit.rightPapableTemporalArtery,
                },
              ),

              _buildExaminationSection(
                title: 'Eye Structure',
                isLeft: isLeft,
                sectionIndex: 7,
                data: {
                  'Cornea': (isLeft ? cubit.leftCornea : cubit.rightCornea).join(', '),
                  'Anterior Chambre': (isLeft ? cubit.leftAnteriorChambre : cubit.rightAnteriorChambre).join(', '),
                  'Iris': (isLeft ? cubit.leftIris : cubit.rightIris).join(', '),
                  'Lens': (isLeft ? cubit.leftLens : cubit.rightLens).join(', '),
                  'Anterior Vitreous': (isLeft ? cubit.leftAnteriorVitreous : cubit.rightAnteriorVitreous).join(', '),
                },
              ),
              _buildExaminationSection(
                title: 'Fundus Examination',
                isLeft: isLeft,
                sectionIndex: 8,
                data: {
                  'Optic Disc': (isLeft ? cubit.leftFundusOpticDisc : cubit.rightFundusOpticDisc).join(', '),
                  'Macula': (isLeft ? cubit.leftFundusMacula : cubit.rightFundusMacula).join(', '),
                  'Vessels': (isLeft ? cubit.leftFundusVessels : cubit.rightFundusVessels).join(', '),
                  'Periphery': (isLeft ? cubit.leftFundusPeriphery : cubit.rightFundusPeriphery).join(', '),
                },
              ),
              _buildExaminationSection(
                title: 'External Features',
                isLeft: isLeft,
                sectionIndex: 6,
                data: {
                  'Lids': isLeft ? cubit.leftLidsController.text : cubit.rightLidsController.text,
                  'Lashes': isLeft ? cubit.leftLashesController.text : cubit.rightLashesController.text,
                  'Lacrimal': isLeft ? cubit.leftLacrimalController.text : cubit.rightLacrimalController.text,
                  'Conjunctiva': isLeft ? cubit.leftConjunctivaController.text : cubit.rightConjunctivaController.text,
                  'Sclera': isLeft ? cubit.leftScleraController.text : cubit.rightScleraController.text,
                },
              ),

              const SizedBox(height: 16), // Bottom padding
            ],
          ),
        );
      },
    );
  }

  Widget _buildExaminationSection({
    required String title,
    required Map<String, dynamic> data,
    required int sectionIndex,
    required bool isLeft,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      shadowColor: Colorz.primaryColor.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          maintainState: false, // Add this
          initiallyExpanded: true,
          enabled: false, // Ad d this
          tilePadding: const EdgeInsets.symmetric(horizontal: 16), // Optional for better spacing
          expandedCrossAxisAlignment: CrossAxisAlignment.start, // Add this for better alignment
          childrenPadding: const EdgeInsets.all(16), // Add this for better padding

          title: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colorz.primaryColor,
            ),
          ),
          children: [
            Column(
              spacing: 8,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: data.entries.map((entry) => _buildDataRow(entry.key, entry.value)).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataRow(String label, dynamic value) {
    final displayValue = value?.toString() ?? 'N/A';
    final isLongText = displayValue.length > 30;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colorz.primaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
          ),
          child: Text(
            displayValue,
            style: TextStyle(
              fontSize: isLongText ? 13 : 14,
              color: Colorz.black,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  String? calculateAge(DateTime? birthDate) {
    if (birthDate == null) {
      print("Error: Birth date is null.");
      return "N/A";
    }

    try {
      DateTime currentDate = DateTime.now();
      int age = currentDate.year - birthDate.year;

      // Adjust if the birthday has not occurred yet this year
      if (currentDate.month < birthDate.month || (currentDate.month == birthDate.month && currentDate.day < birthDate.day)) {
        age--;
      }

      return '$age Years';
    } catch (e) {
      print("Error calculating age: $e");
      return "N/A";
    }
  }

  Widget _buildPatientInfoCard() {
    final cubit = context.read<ExaminationCubit>();

    return Card(
      elevation: 4,
      shadowColor: Colorz.primaryColor.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: Colorz.white),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colorz.primaryColor.withOpacity(0.1),
                  child: Icon(Icons.person_outline, color: Colorz.primaryColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cubit.appointmentData?.patient?.name ?? 'Unknown',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colorz.primaryColor,
                        ),
                      ),
                      Text(
                        cubit.appointmentData?.patient?.nationalId ?? 'Unknown',
                        style: TextStyle(
                          color: Colorz.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoItem(
                  icon: Icons.calendar_today,
                  label: 'Age',
                  value: '${calculateAge(cubit.appointmentData?.patient?.birthDate)}',
                ),
                _buildInfoItem(
                  icon: Icons.person,
                  label: 'Gender',
                  value: cubit.appointmentData?.patient?.gender ?? 'N/A',
                ),
                _buildInfoItem(
                  icon: Icons.phone,
                  label: 'Contact',
                  value: cubit.appointmentData?.patient?.phone ?? 'N/A',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colorz.primaryColor, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colorz.primaryColor,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildHistorySection() {
    return BlocBuilder<ExaminationCubit, ExaminationState>(
      builder: (context, state) {
        final cubit = context.read<ExaminationCubit>();

        // Create complaints data map
        final complaintsData = {
          'Complain One': cubit.oneComplaintController.text,
          'Complain Two': cubit.twoComplaintController.text,
          'Complain Three': cubit.threeComplaintController.text,
        };

        // Create history data map
        final historyData = {
          'Family History': cubit.familyHistoryController.text,
          'Present Illness': cubit.presentIllnessController.text,
          'Past History': cubit.pastHistoryController.text,
          'Medication History': cubit.medicationHistoryController.text,
        };

        return Column(
          children: [
            HeightSpacer(size: 0),
            _buildExpandableCard(
              title: 'Medical History',
              icon: Icons.history,
              content: historyData,
              color: Colorz.primaryColor,
              isHistoryCard: true,
            ),
            _buildExpandableCard(
              title: 'Chief Complaints',
              icon: Icons.medical_information,
              content: complaintsData,
              color: Colorz.primaryColor,
              isComplaintCard: true,
            ),
          ],
        );
      },
    );
  }

  Widget _buildExpandableCard({
    required String title,
    required IconData icon,
    required dynamic content,
    required Color color,
    bool isComplaintCard = false,
    bool isHistoryCard = false,
  }) {
    return Card(
      elevation: 3,
      shadowColor: color.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          enabled: false,
          initiallyExpanded: true,
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colorz.primaryColor,
            ),
          ),
          childrenPadding: const EdgeInsets.all(16),
          children: [
            if (isHistoryCard && content is Map<String, String>)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: content.entries.map((entry) {
                  return SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.key,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colorz.primaryColor,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 8,
                            top: 4,
                            bottom: 16,
                          ),
                          child: Text(
                            entry.value.isEmpty ? 'No data available' : entry.value,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colorz.black,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              )
            else if (isComplaintCard && content is Map<String, String>)
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: content.isEmpty
                      ? [
                          Text(
                            'No complaints available',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colorz.primaryColor,
                              height: 1.5,
                            ),
                          ),
                        ]
                      : content.entries.map((entry) {
                          return SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entry.key,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colorz.primaryColor,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 8,
                                    top: 4,
                                    bottom: 16,
                                  ),
                                  child: Text(
                                    entry.value,
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colorz.black,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                ),
              )
            else
              Text(
                content?.isEmpty ?? true ? 'No data available' : content,
                style: TextStyle(
                  fontSize: 15,
                  color: Colorz.primaryColor,
                  height: 1.5,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
