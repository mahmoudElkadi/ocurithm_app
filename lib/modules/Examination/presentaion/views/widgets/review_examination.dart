import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocurithm/core/widgets/height_spacer.dart';

import '../../../../../core/utils/colors.dart';
import '../../manager/examination_cubit.dart';
import '../../manager/examination_state.dart';
import 'circle_view.dart';

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
    return SingleChildScrollView(
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

          // Tab Buttons
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildCustomTabButton(
                    text: 'Left Eye',
                    isSelected: _selectedTab == 0,
                    onTap: () {
                      _pageController.animateToPage(
                        0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                ),
                Expanded(
                  child: _buildCustomTabButton(
                    text: 'Right Eye',
                    isSelected: _selectedTab == 1,
                    onTap: () {
                      _pageController.animateToPage(
                        1,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // PageView with Examination Content
          // PageView with Examination Content
          SizedBox(
            // Set a reasonable initial height
            height: MediaQuery.of(context).size.height * 0.4,
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _selectedTab = index;
                });
              },
              children: [
                // Left Eye Content
                SingleChildScrollView(
                  child: _buildEyeExaminationContent(isLeft: true),
                ),
                // Right Eye Content
                SingleChildScrollView(
                  child: _buildEyeExaminationContent(isLeft: false),
                ),
              ],
            ),
          ),
        ],
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
          initiallyExpanded: false,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          childrenPadding: const EdgeInsets.all(16),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colorz.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.grid_4x4, color: Colorz.primaryColor),
          ),
          title: Text(
            'Confrontation Fields',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colorz.primaryColor,
            ),
          ),
          children: [
            QuadrantContainer(
              containerSize: 300,
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

  Widget _buildCustomTabButton({
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colorz.primaryColor.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colorz.primaryColor : Colors.grey[600],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildEyeExaminationContent({required bool isLeft}) {
    return BlocBuilder<ExaminationCubit, ExaminationState>(
      builder: (context, state) {
        final cubit = context.read<ExaminationCubit>();

        return Column(
          mainAxisSize: MainAxisSize.min, // Add this line

          children: [
            _buildExaminationSection(
              title: 'Autoref',
              icon: Icons.remove_red_eye,
              isLeft: isLeft,
              sectionIndex: 0,
              data: {
                'Spherical': isLeft ? cubit.leftAurorefSpherical : cubit.rightAurorefSpherical,
                'Cylindrical': isLeft ? cubit.leftAurorefCylindrical : cubit.rightAurorefCylindrical,
                'Axis': isLeft ? cubit.leftAurorefAxis : cubit.rightAurorefAxis,
              },
            ),
            _buildExaminationSection(
              title: 'Visual Acuity',
              icon: Icons.visibility,
              isLeft: isLeft,
              sectionIndex: 1,
              data: {
                'UCVA': isLeft ? cubit.leftUCVA : cubit.rightUCVA,
                'BCVA': isLeft ? cubit.leftBCVA : cubit.rightBCVA,
              },
            ),
            _buildExaminationSection(
              title: 'Refined Refraction',
              icon: Icons.science,
              isLeft: isLeft,
              sectionIndex: 2,
              data: {
                'Spherical': isLeft ? cubit.leftRefinedRefractionSpherical : cubit.rightRefinedRefractionSpherical,
                'Cylindrical': isLeft ? cubit.leftRefinedRefractionCylindrical : cubit.rightRefinedRefractionCylindrical,
                'Axis': isLeft ? cubit.leftRefinedRefractionAxis : cubit.rightRefinedRefractionAxis,
              },
            ),
            _buildExaminationSection(
              title: 'IOP',
              icon: Icons.opacity,
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
              icon: Icons.lens_blur,
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
            _buildQuadrantSection(isLeft: isLeft),
            _buildExaminationSection(
              title: 'External Examination',
              icon: Icons.visibility_outlined,
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
              title: 'Slitlamp Examination',
              icon: Icons.biotech,
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
            _buildExaminationSection(
              title: 'Additional Examination',
              icon: Icons.add_circle_outline,
              isLeft: isLeft,
              sectionIndex: 7,
              data: {
                'Cornea': isLeft ? cubit.leftCornea : cubit.rightCornea,
                'Anterior Chambre': isLeft ? cubit.leftAnteriorChambre : cubit.rightAnteriorChambre,
                'Iris': isLeft ? cubit.leftIris : cubit.rightIris,
                'Lens': isLeft ? cubit.leftLens : cubit.rightLens,
                'Anterior Vitreous': isLeft ? cubit.leftAnteriorVitreous : cubit.rightAnteriorVitreous,
              },
            ),
            _buildExaminationSection(
              title: 'Fundus Examination',
              icon: Icons.center_focus_strong,
              isLeft: isLeft,
              sectionIndex: 8,
              data: {
                'Optic Disc': isLeft ? cubit.leftFundusOpticDisc : cubit.rightFundusOpticDisc,
                'Macula': isLeft ? cubit.leftFundusMacula : cubit.rightFundusMacula,
                'Vessels': isLeft ? cubit.leftFundusVessels : cubit.rightFundusVessels,
                'Periphery': isLeft ? cubit.leftFundusPeriphery : cubit.rightFundusPeriphery,
              },
            ),
            const SizedBox(height: 16), // Bottom padding
          ],
        );
      },
    );
  }

  Widget _buildExaminationSection({
    required String title,
    required IconData icon,
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
          maintainState: true, // Add this
          initiallyExpanded: false, // Add this
          tilePadding: const EdgeInsets.symmetric(horizontal: 16), // Optional for better spacing
          expandedCrossAxisAlignment: CrossAxisAlignment.start, // Add this for better alignment
          childrenPadding: const EdgeInsets.all(16), // Add this for better padding
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colorz.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colorz.primaryColor),
          ),
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

  Widget _buildPatientInfoCard() {
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
                        'Patient Name',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colorz.primaryColor,
                        ),
                      ),
                      Text(
                        'ID: #12345',
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
                  value: '45 years',
                ),
                _buildInfoItem(
                  icon: Icons.person,
                  label: 'Gender',
                  value: 'Male',
                ),
                _buildInfoItem(
                  icon: Icons.phone,
                  label: 'Contact',
                  value: '+123456789',
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

        return Column(
          spacing: 16,
          children: [
            HeightSpacer(size: 0),
            _buildExpandableCard(
              title: 'Patient History',
              icon: Icons.history,
              content: cubit.historyController.text,
              color: Colorz.primaryColor,
            ),
            _buildExpandableCard(
              title: 'Chief Complaint',
              icon: Icons.medical_information,
              content: cubit.complaintController.text,
              color: Colorz.primaryColor,
            ),
          ],
        );
      },
    );
  }

  Widget _buildExpandableCard({
    required String title,
    required IconData icon,
    required String content,
    required Color color,
  }) {
    return Card(
      elevation: 3,
      shadowColor: color.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
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
            Text(
              content.isEmpty ? 'No data available' : content,
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
