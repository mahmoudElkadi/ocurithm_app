import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocurithm/modules/Patient/data/repos/patient_repo_impl.dart';

import '../../../../../../../../core/utils/colors.dart';
import '../../../../../../../../core/widgets/height_spacer.dart';
import '../../../../../../../Examination/presentaion/views/widgets/circle_view.dart';
import '../../../../../manager/patient_cubit.dart';
import '../../../../../manager/patient_state.dart';

class OneExaminationView extends StatefulWidget {
  const OneExaminationView({Key? key, required this.id}) : super(key: key);

  final String id;
  @override
  State<OneExaminationView> createState() => _OneExaminationViewState();
}

class _OneExaminationViewState extends State<OneExaminationView> with SingleTickerProviderStateMixin {
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
    return BlocProvider(
      create: (BuildContext context) => PatientCubit(PatientRepoImpl())..getOneExamination(id: widget.id),
      child: BlocBuilder<PatientCubit, PatientState>(
        builder: (BuildContext context, state) => Scaffold(
          appBar: AppBar(
            centerTitle: true,
            backgroundColor: Colorz.primaryColor,
            title: Text("Examination Details"),
          ),
          body: PatientCubit.get(context).oneExamination == null
              ? Center(
                  child: CircularProgressIndicator(
                  color: Colorz.primaryColor,
                ))
              : Padding(
                  padding: const EdgeInsets.all(8.0).copyWith(bottom: 0),
                  child: SingleChildScrollView(
                    child: Column(
                      spacing: 16,
                      children: [
                        // Patient Info and History Section
                        Column(
                          children: [
                            _buildPatientInfoCard(PatientCubit.get(context)),
                            _buildHistorySection(),
                          ],
                        ),

                        Column(
                          children: [
                            // Tab bar
                            Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () => setState(() => _selectedTab = 0),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            color: _selectedTab == 0 ? Colorz.primaryColor : Colors.grey.shade300,
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        'Left Eye',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: _selectedTab == 0 ? Colorz.primaryColor : Colors.grey,
                                          fontWeight: _selectedTab == 0 ? FontWeight.bold : FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: InkWell(
                                    onTap: () => setState(() => _selectedTab = 1),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            color: _selectedTab == 1 ? Colorz.primaryColor : Colors.grey.shade300,
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        'Right Eye',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: _selectedTab == 1 ? Colorz.primaryColor : Colors.grey,
                                          fontWeight: _selectedTab == 1 ? FontWeight.bold : FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            // Content
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: _selectedTab == 0 ? _buildEyeExaminationContent(isLeft: true) : _buildEyeExaminationContent(isLeft: false),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildQuadrantSection({required bool isLeft, required PatientCubit cubit}) {
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
                      cubit.oneExamination?.examination?.measurements[0].topLeft ?? 0,
                      cubit.oneExamination?.examination?.measurements[0].topRight ?? 0,
                      cubit.oneExamination?.examination?.measurements[0].bottomLeft ?? 0,
                      cubit.oneExamination?.examination?.measurements[0].bottomRight ?? 0,
                    ]
                  : [
                      cubit.oneExamination?.examination?.measurements[1].topLeft ?? 0,
                      cubit.oneExamination?.examination?.measurements[1].topRight ?? 0,
                      cubit.oneExamination?.examination?.measurements[1].bottomLeft ?? 0,
                      cubit.oneExamination?.examination?.measurements[1].bottomRight ?? 0,
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
    return BlocBuilder<PatientCubit, PatientState>(
      builder: (context, state) {
        final cubit = context.read<PatientCubit>();

        return Column(
          mainAxisSize: MainAxisSize.min, // Add this line

          children: [
            _buildExaminationSection(
              title: 'Autoref',
              icon: Icons.remove_red_eye,
              isLeft: isLeft,
              sectionIndex: 0,
              data: {
                'Spherical': isLeft
                    ? cubit.oneExamination?.examination?.measurements[0].autorefSpherical ?? '-'
                    : cubit.oneExamination?.examination?.measurements[1].autorefSpherical ?? '-',
                'Cylindrical': isLeft
                    ? cubit.oneExamination?.examination?.measurements[0].autorefCylindrical ?? '-'
                    : cubit.oneExamination?.examination?.measurements[1].autorefCylindrical,
                'Axis': isLeft
                    ? cubit.oneExamination?.examination?.measurements[0].autorefAxis
                    : cubit.oneExamination?.examination?.measurements[1].autorefAxis,
              },
            ),
            _buildExaminationSection(
              title: 'Visual Acuity',
              icon: Icons.visibility,
              isLeft: isLeft,
              sectionIndex: 1,
              data: {
                'UCVA': isLeft ? cubit.oneExamination?.examination?.measurements[0].ucva : cubit.oneExamination?.examination?.measurements[1].ucva,
                'BCVA': isLeft ? cubit.oneExamination?.examination?.measurements[0].bcva : cubit.oneExamination?.examination?.measurements[1].bcva,
              },
            ),
            _buildExaminationSection(
              title: 'Refined Refraction',
              icon: Icons.science,
              isLeft: isLeft,
              sectionIndex: 2,
              data: {
                'Spherical': isLeft
                    ? cubit.oneExamination?.examination?.measurements[0].refinedRefractionSpherical
                    : cubit.oneExamination?.examination?.measurements[1].refinedRefractionSpherical,
                'Cylindrical': isLeft
                    ? cubit.oneExamination?.examination?.measurements[0].refinedRefractionCylindrical
                    : cubit.oneExamination?.examination?.measurements[1].refinedRefractionCylindrical,
                'Axis': isLeft
                    ? cubit.oneExamination?.examination?.measurements[0].refinedRefractionAxis
                    : cubit.oneExamination?.examination?.measurements[1].refinedRefractionAxis,
              },
            ),
            _buildExaminationSection(
              title: 'IOP',
              icon: Icons.opacity,
              isLeft: isLeft,
              sectionIndex: 3,
              data: {
                'IOP Value': isLeft ? cubit.oneExamination?.examination?.measurements[0].iop : cubit.oneExamination?.examination?.measurements[1].iop,
                'Measurement Method': isLeft
                    ? cubit.oneExamination?.examination?.measurements[0].meansOfMeasurement
                    : cubit.oneExamination?.examination?.measurements[1].meansOfMeasurement,
                'Acquire Another IOP Measurement': isLeft
                    ? cubit.oneExamination?.examination?.measurements[0].acquireAnotherIopMeasurement
                    : cubit.oneExamination?.examination?.measurements[1].acquireAnotherIopMeasurement,
              },
            ),
            _buildExaminationSection(
              title: 'Pupils',
              icon: Icons.lens_blur,
              isLeft: isLeft,
              sectionIndex: 4,
              data: {
                'Shape': isLeft
                    ? cubit.oneExamination?.examination?.measurements[0].pupilsShape
                    : cubit.oneExamination?.examination?.measurements[1].pupilsShape,
                'Light Reflex': isLeft
                    ? cubit.oneExamination?.examination?.measurements[0].pupilsLightReflexTest
                    : cubit.oneExamination?.examination?.measurements[1].pupilsLightReflexTest,
                'Near Reflex': isLeft
                    ? cubit.oneExamination?.examination?.measurements[0].pupilsNearReflexTest
                    : cubit.oneExamination?.examination?.measurements[1].pupilsNearReflexTest,
                'Swinging Flashlight': isLeft
                    ? cubit.oneExamination?.examination?.measurements[0].pupilsSwingingFlashLightTest
                    : cubit.oneExamination?.examination?.measurements[1].pupilsSwingingFlashLightTest,
                'Other Disorders': isLeft
                    ? cubit.oneExamination?.examination?.measurements[0].pupilsOtherDisorders
                    : cubit.oneExamination?.examination?.measurements[1].pupilsOtherDisorders,
              },
            ),
            _buildQuadrantSection(isLeft: isLeft, cubit: cubit),
            _buildExaminationSection(
              title: 'External Examination',
              icon: Icons.visibility_outlined,
              isLeft: isLeft,
              sectionIndex: 5,
              data: {
                'Eyelid Ptosis': isLeft
                    ? cubit.oneExamination?.examination?.measurements[0].eyelidPtosis
                    : cubit.oneExamination?.examination?.measurements[1].eyelidPtosis,
                'Lagophthalmos': isLeft
                    ? cubit.oneExamination?.examination?.measurements[0].eyelidLagophthalmos
                    : cubit.oneExamination?.examination?.measurements[1].eyelidLagophthalmos,
                'Palpable Lymph Nodes': isLeft
                    ? cubit.oneExamination?.examination?.measurements[0].palpableLymphNodes
                    : cubit.oneExamination?.examination?.measurements[1].palpableLymphNodes,
                'Papable Temporal Artery': isLeft
                    ? cubit.oneExamination?.examination?.measurements[0].palpableTemporalArtery
                    : cubit.oneExamination?.examination?.measurements[1].palpableTemporalArtery,
              },
            ),
            _buildExaminationSection(
              title: 'Slitlamp Examination',
              icon: Icons.biotech,
              isLeft: isLeft,
              sectionIndex: 6,
              data: {
                'Lids': isLeft ? cubit.oneExamination?.examination?.measurements[0].lids : cubit.oneExamination?.examination?.measurements[1].lids,
                'Lashes':
                    isLeft ? cubit.oneExamination?.examination?.measurements[0].lashes : cubit.oneExamination?.examination?.measurements[1].lashes,
                'Lacrimal': isLeft
                    ? cubit.oneExamination?.examination?.measurements[0].lacrimalSystem
                    : cubit.oneExamination?.examination?.measurements[1].lacrimalSystem,
                'Conjunctiva': isLeft
                    ? cubit.oneExamination?.examination?.measurements[0].conjunctiva
                    : cubit.oneExamination?.examination?.measurements[1].conjunctiva,
                'Sclera':
                    isLeft ? cubit.oneExamination?.examination?.measurements[0].sclera : cubit.oneExamination?.examination?.measurements[1].sclera,
              },
            ),
            _buildExaminationSection(
              title: 'Additional Examination',
              icon: Icons.add_circle_outline,
              isLeft: isLeft,
              sectionIndex: 7,
              data: {
                'Cornea':
                    isLeft ? cubit.oneExamination?.examination?.measurements[0].cornea : cubit.oneExamination?.examination?.measurements[1].cornea,
                'Anterior Chambre': isLeft
                    ? cubit.oneExamination?.examination?.measurements[0].anteriorChamber
                    : cubit.oneExamination?.examination?.measurements[1].anteriorChamber,
                'Iris': isLeft ? cubit.oneExamination?.examination?.measurements[0].iris : cubit.oneExamination?.examination?.measurements[1].iris,
                'Lens': isLeft ? cubit.oneExamination?.examination?.measurements[0].lens : cubit.oneExamination?.examination?.measurements[1].lens,
                'Anterior Vitreous': isLeft
                    ? cubit.oneExamination?.examination?.measurements[0].anteriorVitreous
                    : cubit.oneExamination?.examination?.measurements[1].anteriorVitreous,
              },
            ),
            _buildExaminationSection(
              title: 'Fundus Examination',
              icon: Icons.center_focus_strong,
              isLeft: isLeft,
              sectionIndex: 8,
              data: {
                'Optic Disc': isLeft
                    ? cubit.oneExamination?.examination?.measurements[0].fundusOpticDisc
                    : cubit.oneExamination?.examination?.measurements[1].fundusOpticDisc,
                'Macula': isLeft
                    ? cubit.oneExamination?.examination?.measurements[0].fundusMacula
                    : cubit.oneExamination?.examination?.measurements[1].fundusMacula,
                'Vessels': isLeft
                    ? cubit.oneExamination?.examination?.measurements[0].fundusVessels
                    : cubit.oneExamination?.examination?.measurements[1].fundusVessels,
                'Periphery': isLeft
                    ? cubit.oneExamination?.examination?.measurements[0].fundusPeriphery
                    : cubit.oneExamination?.examination?.measurements[1].fundusPeriphery,
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

  Widget _buildPatientInfoCard(PatientCubit cubit) {
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
                        cubit.oneExamination?.examination?.patient?.name ?? 'Unknown',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colorz.primaryColor,
                        ),
                      ),
                      Text(
                        cubit.oneExamination?.examination?.patient?.nationalId ?? 'Unknown',
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
                  value: '${calculateAge(cubit.oneExamination?.examination?.patient?.birthDate)}',
                ),
                _buildInfoItem(
                  icon: Icons.person,
                  label: 'Gender',
                  value: cubit.oneExamination?.examination?.patient?.gender ?? 'N/A',
                ),
                _buildInfoItem(
                  icon: Icons.phone,
                  label: 'Contact',
                  value: cubit.oneExamination?.examination?.patient?.phone ?? 'N/A',
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
    return BlocBuilder<PatientCubit, PatientState>(
      builder: (context, state) {
        final cubit = context.read<PatientCubit>();

        return Column(
          spacing: 16,
          children: [
            HeightSpacer(size: 0),
            _buildExpandableCard(
              title: 'Patient History',
              icon: Icons.history,
              content: cubit.oneExamination?.examination?.history?.history ?? 'N/A',
              color: Colorz.primaryColor,
            ),
            _buildExpandableCard(
              title: 'Chief Complaint',
              icon: Icons.medical_information,
              content: cubit.oneExamination?.examination?.complain?.complain ?? 'N/A',
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
