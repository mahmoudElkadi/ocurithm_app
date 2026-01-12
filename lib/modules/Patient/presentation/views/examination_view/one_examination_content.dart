import 'package:flutter/material.dart' hide Action;
import 'package:ocurithm/core/utils/format_helper.dart';
import 'package:ocurithm/core/utils/colors.dart';
import 'package:ocurithm/core/widgets/height_spacer.dart';
import 'package:ocurithm/modules/Examination/presentation/views/widgets/circle_view.dart';
import 'package:ocurithm/modules/Examination/presentation/views/widgets/prescription_pdf.dart';
import 'package:ocurithm/modules/Patient/data/model/one_exam.dart';

class OneExaminationContent extends StatelessWidget {
  final ExaminationModel examination;

  const OneExaminationContent({Key? key, required this.examination})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Patient Info and History Section
          Column(
            spacing: 10,
            children: [
              _buildPatientInfoCard(context, examination),
              _buildFinalizationSection(context, examination),
              _buildHistorySection(context, examination),
            ],
          ),

          Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildEyeExaminationContent(context,
                      isLeft: false, examination: examination),
                  const SizedBox(width: 10),
                  _buildEyeExaminationContent(context,
                      isLeft: true, examination: examination),
                ],
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildMedicationContent(BuildContext context, Action action,
      List<Medicine>? medicines, ExaminationModel examinationModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              FormatHelper.capitalizeFirstLetter(action.action ?? ""),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colorz.primaryColor,
              ),
            ),
            IconButton(
                onPressed: () {
                  generateAndPrintPrescription(
                    examination: examinationModel,
                    showPrescriptionTable: false,
                    action: action,
                    prescriptionList:
                        examinationModel.finalization?.medicine ?? [],
                    diagnosis: examinationModel.finalization?.diagnosis,
                  );
                },
                icon: Icon(Icons.print_outlined, color: Colorz.primaryColor)),
          ],
        ),
        const SizedBox(height: 12),

        // Check if medications exist in the action
        if (medicines != null && medicines.isNotEmpty) ...[
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colorz.primaryColor.withOpacity(0.1),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Name',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colorz.primaryColor,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Dosage',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colorz.primaryColor,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Duration',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colorz.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Medications List
                ...medicines.asMap().entries.map((entry) {
                  final index = entry.key;
                  final medication = entry.value;
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: index == medicines.length - 1
                              ? Colors.transparent
                              : Colors.grey[200]!,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            FormatHelper.capitalizeFirstLetter(
                                medication.name?.toString() ?? ''),
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            FormatHelper.capitalizeFirstLetter(
                                medication.dosage?.toString() ?? ''),
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            FormatHelper.capitalizeFirstLetter(
                                medication.duration?.toString() ?? ''),
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),

          // Print Button for Medications
        ] else ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: const Text(
              'No medications prescribed',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildGlassesContent(
      BuildContext context, Action action, ExaminationModel examinationModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailItem(
          context,
          title: FormatHelper.capitalizeFirstLetter(action.action ?? ""),
          content: "IPD: ${action.data ?? 'N/A'}",
          onTap: () {
            generateAndPrintPrescription(
              examination: examinationModel,
              showPrescriptionTable: true,
              action: action,
              diagnosis: examinationModel.finalization?.diagnosis,
            );
          },
        ),
      ],
    );
  }

  Widget _buildInvestigationsContent(
      BuildContext context, Action action, ExaminationModel examinationModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              FormatHelper.capitalizeFirstLetter(action.action ?? ""),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colorz.primaryColor,
              ),
            ),
            IconButton(
                onPressed: () {
                  generateAndPrintPrescription(
                    examination: examinationModel,
                    showPrescriptionTable: false,
                    action: action,
                    diagnosis: examinationModel.finalization?.diagnosis,
                  );
                },
                icon: Icon(Icons.print_outlined, color: Colorz.primaryColor)),
          ],
        ),
        const SizedBox(height: 8),
        ...action.metaData.map((investigation) {
          if (investigation == 'corneal') {
            final cornealSubOptions = action.metaData
                .where((item) => ['topography', 'pentacam']
                    .contains(item.toString().toLowerCase()))
                .toList();

            return _buildNestedInvestigation(
              mainTitle: FormatHelper.capitalizeFirstLetter(investigation),
              subOptions: cornealSubOptions,
            );
          } else if (investigation == 'cataract') {
            final hasBiometry = action.metaData.contains('biometry');
            final biometryTypes = action.metaData
                .where((item) => ['ultrasound', 'optical']
                    .contains(item.toString().toLowerCase()))
                .toList();

            return _buildNestedInvestigation(
              mainTitle: FormatHelper.capitalizeFirstLetter(investigation),
              subOptions: hasBiometry ? ['Biometry', ...biometryTypes] : [],
            );
          } else if (![
            'topography',
            'pentacam',
            'biometry',
            'ultrasound',
            'optical'
          ].contains(investigation.toString().toLowerCase())) {
            return _buildInvestigationItem(investigation);
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }

  Widget _buildLaserContent(
      BuildContext context, Action action, ExaminationModel examinationModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailItem(
          context,
          title: FormatHelper.capitalizeFirstLetter(action.action ?? ""),
          content: FormatHelper.capitalizeFirstLetter(action.data ?? ''),
          onTap: () {
            generateAndPrintPrescription(
              examination: examinationModel,
              showPrescriptionTable: false,
              action: action,
              diagnosis: examinationModel.finalization?.diagnosis,
            );
          },
        ),
      ],
    );
  }

  Widget _buildKeratoconusContent(
      BuildContext context, Action action, ExaminationModel examinationModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailItem(context,
            title: FormatHelper.capitalizeFirstLetter(action.action ?? ""),
            content: FormatHelper.capitalizeFirstLetter(action.data ?? ''),
            onTap: () {
          generateAndPrintPrescription(
            examination: examinationModel,
            showPrescriptionTable: false,
            action: action,
            diagnosis: examinationModel.finalization?.diagnosis,
          );
        }),
      ],
    );
  }

  Widget _buildORContent(
      BuildContext context, Action action, ExaminationModel examinationModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailItem(context,
            title: 'Surgery Type',
            content: FormatHelper.capitalizeFirstLetter(action.data ?? ''),
            onTap: () {
          generateAndPrintPrescription(
            examination: examinationModel,
            showPrescriptionTable: false,
            action: action,
            diagnosis: examinationModel.finalization?.diagnosis,
          );
        }),
        if (action.metaData.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            'Additional Details',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colorz.primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          if (action.data?.toLowerCase() == 'cataract surgery') ...[
            ...action.metaData.map((detail) => _buildORDetailItem(detail)),
          ] else if (action.data?.toLowerCase() ==
              'intravitreal injection') ...[
            ...action.metaData
                .where((detail) => [
                      'eylea',
                      'lucentis',
                      'avastin',
                      'ziv-aflibercept',
                      'vabysmo',
                      'vsiqqoo',
                      'ozurdex'
                    ].contains(detail.toString().toLowerCase()))
                .map((detail) => _buildORDetailItem(detail)),
          ] else ...[
            ...action.metaData.map((detail) => _buildORDetailItem(detail)),
          ],
        ],
      ],
    );
  }

  Widget _buildAppointmentContent(
      BuildContext context, Action action, ExaminationModel examinationModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailItem(context,
            title: FormatHelper.capitalizeFirstLetter(action.action ?? ""),
            content: FormatHelper.capitalizeFirstLetter(action.data ?? ''),
            onTap: () {
          generateAndPrintPrescription(
            examination: examinationModel,
            showPrescriptionTable: false,
            action: action,
            diagnosis: examinationModel.finalization?.diagnosis,
          );
        }),
      ],
    );
  }

  Widget _buildDetailItem(BuildContext context,
      {required String title, required String content, Function()? onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colorz.primaryColor,
                  ),
                ),
                IconButton(
                    onPressed: onTap,
                    icon:
                        Icon(Icons.print_outlined, color: Colorz.primaryColor)),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              content,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNestedInvestigation({
    required String mainTitle,
    required List<dynamic> subOptions,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInvestigationItem(mainTitle),
        if (subOptions.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: subOptions
                  .map((option) => _buildInvestigationItem(option))
                  .toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildInvestigationItem(dynamic investigation) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 4),
      child: Row(
        children: [
          Icon(Icons.circle, size: 8, color: Colorz.primaryColor),
          const SizedBox(width: 8),
          Text(
            FormatHelper.capitalizeFirstLetter(investigation),
            style: const TextStyle(fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _buildORDetailItem(dynamic detail) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 4),
      child: Row(
        children: [
          Icon(Icons.circle, size: 8, color: Colorz.primaryColor),
          const SizedBox(width: 8),
          Text(
            FormatHelper.capitalizeFirstLetter(detail),
            style: const TextStyle(fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _buildQuadrantSection(BuildContext context,
      {required bool isLeft, required ExaminationModel examinationModel}) {
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
          enabled: true,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          childrenPadding: const EdgeInsets.all(16),
          title: Text(
            'Confrontation Fields',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colorz.primaryColor,
            ),
          ),
          children: [
            if (examinationModel.examination?.measurements.isNotEmpty ?? false)
              QuadrantContainer(
                containerSize: 280,
                colorList: _colorList,
                tapCounts: isLeft
                    ? [
                        examinationModel.examination?.measurements[0].topLeft ??
                            0,
                        examinationModel
                                .examination?.measurements[0].topRight ??
                            0,
                        examinationModel
                                .examination?.measurements[0].bottomLeft ??
                            0,
                        examinationModel
                                .examination?.measurements[0].bottomRight ??
                            0,
                      ]
                    : [
                        examinationModel.examination?.measurements[1].topLeft ??
                            0,
                        examinationModel
                                .examination?.measurements[1].topRight ??
                            0,
                        examinationModel
                                .examination?.measurements[1].bottomLeft ??
                            0,
                        examinationModel
                                .examination?.measurements[1].bottomRight ??
                            0,
                      ],
                side: isLeft ? 'left' : 'right',
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEyeExaminationContent(BuildContext context,
      {required bool isLeft, required ExaminationModel examination}) {
    if (examination.examination?.measurements.isEmpty ?? true) {
      return const SizedBox.shrink();
    }

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isLeft ? 'Left Eye' : 'Right Eye',
            style: TextStyle(
                color: Colorz.primaryColor,
                fontWeight: FontWeight.w500,
                fontSize: 16),
          ),
          const HeightSpacer(size: 12),
          _buildQuadrantSection(context,
              isLeft: isLeft, examinationModel: examination),
          _buildExaminationSection(
            context,
            title: 'Old Glasses',
            icon: Icons.remove_red_eye,
            isLeft: isLeft,
            sectionIndex: 0,
            data: {
              'Spherical': isLeft
                  ? FormatHelper.formatPositiveValue(examination
                          .examination?.measurements[0].oldSpherical) ??
                      '-'
                  : FormatHelper.formatPositiveValue(examination
                          .examination?.measurements[1].oldSpherical) ??
                      '-',
              'Cylindrical': isLeft
                  ? FormatHelper.formatPositiveValue(examination
                          .examination?.measurements[0].oldCylindrical) ??
                      '-'
                  : FormatHelper.formatPositiveValue(
                      examination.examination?.measurements[1].oldCylindrical),
              'Axis': isLeft
                  ? examination.examination?.measurements[0].oldAxis
                  : examination.examination?.measurements[1].oldAxis,
            },
          ),
          _buildExaminationSection(
            context,
            title: 'Autorefraction',
            icon: Icons.remove_red_eye,
            isLeft: isLeft,
            sectionIndex: 0,
            data: {
              'Spherical': isLeft
                  ? FormatHelper.formatPositiveValue(examination
                          .examination?.measurements[0].autorefSpherical) ??
                      '-'
                  : FormatHelper.formatPositiveValue(examination
                          .examination?.measurements[1].autorefSpherical) ??
                      '-',
              'Cylindrical': isLeft
                  ? FormatHelper.formatPositiveValue(examination
                          .examination?.measurements[0].autorefCylindrical) ??
                      '-'
                  : FormatHelper.formatPositiveValue(examination
                      .examination?.measurements[1].autorefCylindrical),
              'Axis': isLeft
                  ? examination.examination?.measurements[0].autorefAxis
                  : examination.examination?.measurements[1].autorefAxis,
            },
          ),
          _buildExaminationSection(
            context,
            title: 'Refined Refraction',
            icon: Icons.science,
            isLeft: isLeft,
            sectionIndex: 2,
            data: {
              'Spherical': isLeft
                  ? FormatHelper.formatPositiveValue(examination
                      .examination?.measurements[0].refinedRefractionSpherical)
                  : FormatHelper.formatPositiveValue(examination
                      .examination?.measurements[1].refinedRefractionSpherical),
              'Cylindrical': isLeft
                  ? FormatHelper.formatPositiveValue(examination.examination
                      ?.measurements[0].refinedRefractionCylindrical)
                  : FormatHelper.formatPositiveValue(examination.examination
                      ?.measurements[1].refinedRefractionCylindrical),
              'Axis': isLeft
                  ? examination
                      .examination?.measurements[0].refinedRefractionAxis
                  : examination
                      .examination?.measurements[1].refinedRefractionAxis,
              'Near Vision': isLeft
                  ? FormatHelper.formatPositiveValue(examination
                      .examination?.measurements[0].nearVisionAddition)
                  : FormatHelper.formatPositiveValue(examination
                      .examination?.measurements[1].nearVisionAddition),
            },
          ),
          _buildExaminationSection(
            context,
            title: 'Visual Acuity',
            icon: Icons.visibility,
            isLeft: isLeft,
            sectionIndex: 1,
            data: {
              'UCVA': isLeft
                  ? examination.examination?.measurements[0].ucva
                  : examination.examination?.measurements[1].ucva,
              'BCVA': isLeft
                  ? examination.examination?.measurements[0].bcva
                  : examination.examination?.measurements[1].bcva,
            },
          ),
          _buildExaminationSection(
            context,
            title: 'IOP',
            icon: Icons.opacity,
            isLeft: isLeft,
            sectionIndex: 3,
            data: {
              'IOP Value': isLeft
                  ? examination.examination?.measurements[0].iop
                  : examination.examination?.measurements[1].iop,
              'Measurement Method': isLeft
                  ? examination.examination?.measurements[0].meansOfMeasurement
                  : examination.examination?.measurements[1].meansOfMeasurement,
              'Acquire Another IOP Measurement': isLeft
                  ? examination
                      .examination?.measurements[0].acquireAnotherIopMeasurement
                  : examination.examination?.measurements[1]
                      .acquireAnotherIopMeasurement,
            },
          ),
          _buildExaminationSection(
            context,
            title: 'Pupils',
            icon: Icons.lens_blur,
            isLeft: isLeft,
            sectionIndex: 4,
            data: {
              'Shape': isLeft
                  ? examination.examination?.measurements[0].pupilsShape
                  : examination.examination?.measurements[1].pupilsShape,
              'Light Reflex': isLeft
                  ? examination
                      .examination?.measurements[0].pupilsLightReflexTest
                  : examination
                      .examination?.measurements[1].pupilsLightReflexTest,
              'Near Reflex': isLeft
                  ? examination
                      .examination?.measurements[0].pupilsNearReflexTest
                  : examination
                      .examination?.measurements[1].pupilsNearReflexTest,
              'Swinging Flashlight': isLeft
                  ? examination
                      .examination?.measurements[0].pupilsSwingingFlashLightTest
                  : examination.examination?.measurements[1]
                      .pupilsSwingingFlashLightTest,
              'Other Disorders': isLeft
                  ? examination
                      .examination?.measurements[0].pupilsOtherDisorders
                  : examination
                      .examination?.measurements[1].pupilsOtherDisorders,
            },
          ),
          _buildExaminationSection(
            context,
            title: 'Eyelid & Physical',
            icon: Icons.visibility_outlined,
            isLeft: isLeft,
            sectionIndex: 5,
            data: {
              'Eyelid Ptosis': isLeft
                  ? examination.examination?.measurements[0].eyelidPtosis
                  : examination.examination?.measurements[1].eyelidPtosis,
              'Lagophthalmos': isLeft
                  ? examination.examination?.measurements[0].eyelidLagophthalmos
                  : examination
                      .examination?.measurements[1].eyelidLagophthalmos,
              'Palpable Lymph Nodes': isLeft
                  ? examination.examination?.measurements[0].palpableLymphNodes
                  : examination.examination?.measurements[1].palpableLymphNodes,
              'Papable Temporal Artery': isLeft
                  ? examination
                      .examination?.measurements[0].palpableTemporalArtery
                  : examination
                      .examination?.measurements[1].palpableTemporalArtery,
            },
          ),
          _buildExaminationSection(
            context,
            title: 'Eye Structure',
            icon: Icons.add_circle_outline,
            isLeft: isLeft,
            sectionIndex: 7,
            data: {
              'Cornea': (isLeft
                      ? examination.examination?.measurements[0].cornea
                      : examination.examination?.measurements[1].cornea)
                  .join(', '),
              'Anterior Chambre': (isLeft
                      ? examination.examination?.measurements[0].anteriorChamber
                      : examination
                          .examination?.measurements[1].anteriorChamber)
                  .join(', '),
              'Iris': (isLeft
                      ? examination.examination?.measurements[0].iris
                      : examination.examination?.measurements[1].iris)
                  .join(', '),
              'Lens': (isLeft
                      ? examination.examination?.measurements[0].lens
                      : examination.examination?.measurements[1].lens)
                  .join(', '),
              'Anterior Vitreous': (isLeft
                      ? examination
                          .examination?.measurements[0].anteriorVitreous
                      : examination
                          .examination?.measurements[1].anteriorVitreous)
                  .join(', '),
            },
          ),
          _buildExaminationSection(
            context,
            title: 'Fundus Examination',
            icon: Icons.center_focus_strong,
            isLeft: isLeft,
            sectionIndex: 8,
            data: {
              'Optic Disc': (isLeft
                      ? examination.examination?.measurements[0].fundusOpticDisc
                      : examination
                          .examination?.measurements[1].fundusOpticDisc)
                  .join(', '),
              'Macula': (isLeft
                      ? examination.examination?.measurements[0].fundusMacula
                      : examination.examination?.measurements[1].fundusMacula)
                  .join(', '),
              'Vessels': (isLeft
                      ? examination.examination?.measurements[0].fundusVessels
                      : examination.examination?.measurements[1].fundusVessels)
                  .join(', '),
              'Periphery': (isLeft
                      ? examination.examination?.measurements[0].fundusPeriphery
                      : examination
                          .examination?.measurements[1].fundusPeriphery)
                  .join(', '),
            },
          ),
          _buildExaminationSection(
            context,
            title: 'External Features',
            icon: Icons.biotech,
            isLeft: isLeft,
            sectionIndex: 6,
            data: {
              'Lids': isLeft
                  ? examination.examination?.measurements[0].lids
                  : examination.examination?.measurements[1].lids,
              'Lashes': isLeft
                  ? examination.examination?.measurements[0].lashes
                  : examination.examination?.measurements[1].lashes,
              'Lacrimal': isLeft
                  ? examination.examination?.measurements[0].lacrimalSystem
                  : examination.examination?.measurements[1].lacrimalSystem,
              'Conjunctiva': isLeft
                  ? examination.examination?.measurements[0].conjunctiva
                  : examination.examination?.measurements[1].conjunctiva,
              'Sclera': isLeft
                  ? examination.examination?.measurements[0].sclera
                  : examination.examination?.measurements[1].sclera,
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildExaminationSection(
    BuildContext context, {
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
          maintainState: true,
          initiallyExpanded: true,
          enabled: false,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          childrenPadding: const EdgeInsets.all(16),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colorz.primaryColor,
            ),
          ),
          children: [
            Column(
              children: data.entries
                  .map((entry) => _buildDataRow(entry.key, entry.value))
                  .toList(),
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
    if (birthDate == null) return "N/A";
    try {
      DateTime currentDate = DateTime.now();
      int age = currentDate.year - birthDate.year;
      if (currentDate.month < birthDate.month ||
          (currentDate.month == birthDate.month &&
              currentDate.day < birthDate.day)) {
        age--;
      }
      return '$age Years';
    } catch (e) {
      return "N/A";
    }
  }

  Widget _buildPatientInfoCard(
      BuildContext context, ExaminationModel examination) {
    return Card(
      elevation: 4,
      shadowColor: Colorz.primaryColor.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16), color: Colorz.white),
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
                        examination.examination?.patient?.name ?? 'Unknown',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colorz.primaryColor,
                        ),
                      ),
                      Text(
                        examination.examination?.patient?.nationalId ??
                            'Unknown',
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
                  value:
                      '${calculateAge(examination.examination?.patient?.birthDate)}',
                ),
                _buildInfoItem(
                  icon: Icons.person,
                  label: 'Gender',
                  value: examination.examination?.patient?.gender ?? 'N/A',
                ),
                _buildInfoItem(
                  icon: Icons.phone,
                  label: 'Contact',
                  value: examination.examination?.patient?.phone ?? 'N/A',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinalizationSection(
      BuildContext context, ExaminationModel examination) {
    final finalization = examination.finalization;
    if (finalization == null) return const SizedBox.shrink();
    return _buildExpandableFinalizationCard(context,
        finalization: finalization, examination: examination);
  }

  Widget _buildExpandableFinalizationCard(BuildContext context,
      {required Finalization finalization,
      required ExaminationModel examination}) {
    return Card(
      elevation: 3,
      shadowColor: Colorz.primaryColor.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colorz.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.medical_services, color: Colorz.primaryColor),
          ),
          title: Text(
            "Finalization",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colorz.primaryColor,
            ),
          ),
          childrenPadding: const EdgeInsets.all(16),
          children: [
            if (finalization.diagnosis != null &&
                finalization.diagnosis!.isNotEmpty)
              SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Diagnosis",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colorz.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      finalization.diagnosis ?? 'N/A',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const HeightSpacer(size: 10),
                  ],
                ),
              ),
            ...finalization.actions.map((action) => Column(
                  children: [
                    _buildActionContent(
                        context, action, finalization.medicine, examination),
                    const HeightSpacer(size: 10),
                    Divider(
                      color: Colors.black,
                    ),
                    const HeightSpacer(size: 10),
                  ],
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildActionContent(BuildContext context, Action action,
      List<Medicine>? medicines, ExaminationModel examination) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildActionSpecificContent(context, action, medicines, examination),
        if (action.eye != null) ...[
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(left: 2),
            child: Text(
              "Eye: ${action.eye?.toUpperCase()}",
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  Widget _buildActionSpecificContent(BuildContext context, Action action,
      List<Medicine>? medicines, ExaminationModel examination) {
    switch (action.action?.toLowerCase()) {
      case 'prescribe glasses':
        return _buildGlassesContent(context, action, examination);
      case 'prescribe medications':
        return _buildMedicationContent(context, action, medicines, examination);
      case 'refer to investigations':
        return _buildInvestigationsContent(context, action, examination);
      case 'refer to lasers':
        return _buildLaserContent(context, action, examination);
      case 'keratoconus':
        return _buildKeratoconusContent(context, action, examination);
      case 'refer to or':
        return _buildORContent(context, action, examination);
      case 'book next appointment':
        return _buildAppointmentContent(context, action, examination);
      default:
        return const SizedBox.shrink();
    }
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

  Widget _buildHistorySection(
      BuildContext context, ExaminationModel examinationModel) {
    final examination = examinationModel.examination;

    // Create history data map and filter out empty/null values
    final historyData = Map<String, String>.fromEntries({
      'Family History': examination?.history?.familyHistory,
      'Present Illness': examination?.history?.presentIllness,
      'Past History': examination?.history?.pastHistory,
      'Medication History': examination?.history?.medicationHistory,
    }
        .entries
        .where((entry) => entry.value != null && entry.value!.isNotEmpty)
        .map((entry) => MapEntry(entry.key, entry.value!)));

    // Create complaints data map and filter out empty/null values
    final complaintsData = Map<String, String>.fromEntries({
      'Complain One': examination?.complain?.complainOne,
      'Complain Two': examination?.complain?.complainTwo,
      'Complain Three': examination?.complain?.complainThree,
    }
        .entries
        .where((entry) => entry.value != null && entry.value!.isNotEmpty)
        .map((entry) => MapEntry(entry.key, entry.value!)));

    return Column(
      children: [
        const HeightSpacer(size: 0),
        if (historyData.isNotEmpty)
          _buildExpandableCard(
            context,
            title: 'Medical History',
            icon: Icons.history,
            content: historyData,
            color: Colorz.primaryColor,
            isHistoryCard: true,
          ),
        if (complaintsData.isNotEmpty)
          _buildExpandableCard(
            context,
            title: 'Chief Complaints',
            icon: Icons.medical_information,
            content: complaintsData,
            color: Colorz.primaryColor,
            isComplaintCard: true,
          ),
      ],
    );
  }

  Widget _buildExpandableCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Map<String, String> content,
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
          ],
        ),
      ),
    );
  }
}
