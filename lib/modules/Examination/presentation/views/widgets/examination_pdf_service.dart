import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../../../../Appointment/data/models/appointment_model.dart';
import '../../manager/examination_form_cubit/examination_form_cubit.dart';
import '../../../../../core/utils/format_helper.dart';

class ExaminationPdfService {
  static final PdfColor primaryBlue = PdfColor.fromHex('#4A98F7');
  static final PdfColor secondaryBlue = PdfColor.fromHex('#6E77F6');
  static final PdfColor headerBg = PdfColor.fromHex('#F0F7FF');
  static final PdfColor tableHeaderBg = PdfColor.fromHex('#F8F9FB');
  static final PdfColor borderColor = PdfColor.fromHex('#E0E0E0');
  static final PdfColor textPrimary = PdfColor.fromHex('#212121');
  static final PdfColor textSecondary = PdfColor.fromHex('#757575');

  static Future<void> generateAndPrintExamination({
    required Appointment appointment,
    required ExaminationFormCubit cubit,
  }) async {
    final pdf = pw.Document();

    final regularFontData =
        await rootBundle.load("assets/fonts/Cairo-Regular.ttf");
    final boldFontData = await rootBundle.load("assets/fonts/Cairo-Bold.ttf");
    final font = pw.Font.ttf(regularFontData);
    final boldFont = pw.Font.ttf(boldFontData);

    final logoData = await rootBundle.load('assets/icons/logo.png');
    final logoBytes = logoData.buffer.asUint8List();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(30),
        theme: pw.ThemeData.withFont(base: font, bold: boldFont),
        header: (pw.Context context) => _buildHeader(logoBytes, boldFont, font),
        footer: (pw.Context context) => _buildFooter(context, font),
        build: (pw.Context context) {
          return [
            _buildPatientBanner(appointment, boldFont, font),
            pw.SizedBox(height: 15),
            _buildSectionTitle('1. CLINICAL HISTORY & COMPLAINTS', boldFont),
            _buildHistoryAndComplaints(cubit, boldFont, font),
            pw.SizedBox(height: 15),
            _buildSectionTitle('2. REFRACTION & VISUAL ACUITY', boldFont),
            _buildRefractionReflections(cubit, boldFont, font),
            pw.SizedBox(height: 15),
            _buildSectionTitle(
                '3. INTRAOCULAR PRESSURE (IOP) & PUPILS', boldFont),
            _buildIopAndPupils(cubit, boldFont, font),
            pw.SizedBox(height: 15),
            _buildSectionTitle('4. EXTERNAL & PHYSICAL EXAMINATION', boldFont),
            _buildPhysicalExamination(cubit, boldFont, font),
            pw.SizedBox(height: 15),
            _buildSectionTitle('5. SEGMENT & FUNDUS EXAMINATION', boldFont),
            _buildEyeStructureAndFundus(cubit, boldFont, font),
            pw.SizedBox(height: 15),
            _buildSectionTitle('6. CONFRONTATION FIELDS', boldFont),
            _buildFieldsSection(cubit, boldFont, font),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Examination_${appointment.patient?.name ?? 'Report'}.pdf',
    );
  }

  static pw.Widget _buildHeader(
      Uint8List logoBytes, pw.Font boldFont, pw.Font font) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 10),
      decoration: const pw.BoxDecoration(
          border: pw.Border(
              bottom: pw.BorderSide(color: PdfColors.blue900, width: 1.5))),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('OCURITHM MEDICAL CENTER',
                  style: pw.TextStyle(
                      font: boldFont, fontSize: 18, color: PdfColors.blue900)),
              pw.Text('Comprehensive Eye Examination Report',
                  style: pw.TextStyle(
                      font: font, fontSize: 10, color: textSecondary)),
            ],
          ),
          pw.Image(pw.MemoryImage(logoBytes), width: 45),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter(pw.Context context, pw.Font font) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(top: 15),
      child: pw.Text('Page ${context.pageNumber} of ${context.pagesCount}',
          style: pw.TextStyle(font: font, fontSize: 8, color: textSecondary)),
    );
  }

  static pw.Widget _buildPatientBanner(
      Appointment appointment, pw.Font boldFont, pw.Font font) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
          color: headerBg,
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8))),
      child: pw.Column(
        children: [
          pw.Row(
            children: [
              _bannerItem('Patient Name', appointment.patient?.name ?? 'N/A', 3,
                  boldFont, font),
              _bannerItem('National ID',
                  appointment.patient?.nationalId ?? 'N/A', 2, boldFont, font),
            ],
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            children: [
              _bannerItem(
                  'Age',
                  '${FormatHelper.calculateAge(appointment.patient?.birthDate)} Years',
                  1,
                  boldFont,
                  font),
              _bannerItem('Gender', appointment.patient?.gender ?? 'N/A', 1,
                  boldFont, font),
              _bannerItem('Phone', appointment.patient?.phone ?? 'N/A', 1,
                  boldFont, font),
              _bannerItem(
                  'Exam Date',
                  DateFormat('dd/MM/yyyy').format(DateTime.now()),
                  1,
                  boldFont,
                  font),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _bannerItem(
      String label, String value, int flex, pw.Font boldFont, pw.Font font) {
    return pw.Expanded(
      flex: flex,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(label,
              style: pw.TextStyle(
                  font: boldFont, fontSize: 7, color: PdfColors.blue700)),
          pw.Text(value,
              style:
                  pw.TextStyle(font: font, fontSize: 10, color: textPrimary)),
        ],
      ),
    );
  }

  static pw.Widget _buildSectionTitle(String title, pw.Font boldFont) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      margin: const pw.EdgeInsets.only(bottom: 8),
      decoration: pw.BoxDecoration(
          color: PdfColors.blue50,
          border: const pw.Border(
              left: pw.BorderSide(color: PdfColors.blue700, width: 3))),
      child: pw.Text(title,
          style: pw.TextStyle(
              font: boldFont, fontSize: 10, color: PdfColors.blue900)),
    );
  }

  static pw.Widget _buildHistoryAndComplaints(
      ExaminationFormCubit cubit, pw.Font boldFont, pw.Font font) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
            child: _buildDataTable(
                'Medical History',
                {
                  'Family History': cubit.familyHistoryController.text,
                  'Present Illness': cubit.presentIllnessController.text,
                  'Past History': cubit.pastHistoryController.text,
                  'Medication': cubit.medicationHistoryController.text,
                },
                boldFont,
                font)),
        pw.SizedBox(width: 15),
        pw.Expanded(
            child: _buildDataTable(
                'Chief Complaints',
                {
                  'Complaint 1': cubit.oneComplaintController.text,
                  'Complaint 2': cubit.twoComplaintController.text,
                  'Complaint 3': cubit.threeComplaintController.text,
                },
                boldFont,
                font)),
      ],
    );
  }

  static pw.Widget _buildRefractionReflections(
      ExaminationFormCubit cubit, pw.Font boldFont, pw.Font font) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
            child: _buildEyeMeasurementSection(
                'RIGHT EYE (OD)', false, cubit, boldFont, font)),
        pw.SizedBox(width: 15),
        pw.Expanded(
            child: _buildEyeMeasurementSection(
                'LEFT EYE (OS)', true, cubit, boldFont, font)),
      ],
    );
  }

  static pw.Widget _buildEyeMeasurementSection(String title, bool isL,
      ExaminationFormCubit c, pw.Font boldFont, pw.Font font) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(title,
            style: pw.TextStyle(
                font: boldFont, fontSize: 9, color: PdfColors.blue800)),
        pw.SizedBox(height: 5),
        _buildDataTable(
            'Current Glasses',
            {
              'Sph': FormatHelper.formatPositiveValue(isL
                  ? c.leftOldSpherical?.toString()
                  : c.rightOldSpherical?.toString()),
              'Cyl': FormatHelper.formatPositiveValue(isL
                  ? c.leftOldCylindrical?.toString()
                  : c.rightOldCylindrical?.toString()),
              'Axis': isL ? c.leftOldAxis : c.rightOldAxis,
            },
            boldFont,
            font,
            compact: true),
        pw.SizedBox(height: 5),
        _buildDataTable(
            'Autorefraction',
            {
              'Sph': FormatHelper.formatPositiveValue(isL
                  ? c.leftAurorefSpherical?.toString()
                  : c.rightAurorefSpherical?.toString()),
              'Cyl': FormatHelper.formatPositiveValue(isL
                  ? c.leftAurorefCylindrical?.toString()
                  : c.rightAurorefCylindrical?.toString()),
              'Axis': isL ? c.leftAurorefAxis : c.rightAurorefAxis,
            },
            boldFont,
            font,
            compact: true),
        pw.SizedBox(height: 5),
        _buildDataTable(
            'Refined Refraction',
            {
              'Sph': FormatHelper.formatPositiveValue(isL
                  ? c.leftRefinedRefractionSpherical?.toString()
                  : c.rightRefinedRefractionSpherical?.toString()),
              'Cyl': FormatHelper.formatPositiveValue(isL
                  ? c.leftRefinedRefractionCylindrical?.toString()
                  : c.rightRefinedRefractionCylindrical?.toString()),
              'Axis': isL
                  ? c.leftRefinedRefractionAxis
                  : c.rightRefinedRefractionAxis,
              'Near ADD': FormatHelper.formatPositiveValue(isL
                  ? c.leftNearVisionAddition?.toString()
                  : c.rightNearVisionAddition?.toString()),
            },
            boldFont,
            font,
            compact: true),
        pw.SizedBox(height: 5),
        _buildDataTable(
            'Visual Acuity',
            {
              'UCVA': isL ? c.leftUCVA : c.rightUCVA,
              'BCVA': isL ? c.leftBCVA : c.rightBCVA,
            },
            boldFont,
            font,
            compact: true),
      ],
    );
  }

  static pw.Widget _buildIopAndPupils(
      ExaminationFormCubit cubit, pw.Font boldFont, pw.Font font) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
            child: _buildDataTable(
                'IOP & Pupils (OD)',
                {
                  'IOP (mmHg)': cubit.rightIOP,
                  'IOP Method': cubit.rightMeansOfMeasurement,
                  'Pupil Shape': cubit.rightPupilsShape,
                  'Light Reflex': cubit.rightPupilsLightReflexTest,
                  'Near Reflex': cubit.rightPupilsNearReflexTest,
                  'Swinging Flashlight':
                      cubit.rightPupilsSwingingFlashLightTest,
                  'Other Pupil Dis.': cubit.rightPupilsOtherDisorders,
                },
                boldFont,
                font)),
        pw.SizedBox(width: 15),
        pw.Expanded(
            child: _buildDataTable(
                'IOP & Pupils (OS)',
                {
                  'IOP (mmHg)': cubit.leftIOP,
                  'IOP Method': cubit.leftMeansOfMeasurement,
                  'Pupil Shape': cubit.leftPupilsShape,
                  'Light Reflex': cubit.leftPupilsLightReflexTest,
                  'Near Reflex': cubit.leftPupilsNearReflexTest,
                  'Swinging Flashlight': cubit.leftPupilsSwingingFlashLightTest,
                  'Other Pupil Dis.': cubit.leftPupilsOtherDisorders,
                },
                boldFont,
                font)),
      ],
    );
  }

  static pw.Widget _buildPhysicalExamination(
      ExaminationFormCubit cubit, pw.Font boldFont, pw.Font font) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
            child: _buildDataTable(
                'Physical (OD)',
                {
                  'Eyelid Ptosis': cubit.rightEyelidPtosis,
                  'Lagophthalmos': cubit.rightEyelidLagophthalmos,
                  'Lymph Nodes': cubit.rightPalpableLymphNodes,
                  'Temporal Artery': cubit.rightPapableTemporalArtery,
                  'Exophthalmometry': cubit.rightExophthalmometry,
                  'External Lids': cubit.rightLidsController.text,
                  'Lashes': cubit.rightLashesController.text,
                  'Conjunctiva': cubit.rightConjunctivaController.text,
                  'Sclera': cubit.rightScleraController.text,
                  'Lacrimal': cubit.rightLacrimalController.text,
                },
                boldFont,
                font)),
        pw.SizedBox(width: 15),
        pw.Expanded(
            child: _buildDataTable(
                'Physical (OS)',
                {
                  'Eyelid Ptosis': cubit.leftEyelidPtosis,
                  'Lagophthalmos': cubit.leftEyelidLagophthalmos,
                  'Lymph Nodes': cubit.leftPalpableLymphNodes,
                  'Temporal Artery': cubit.leftPapableTemporalArtery,
                  'Exophthalmometry': cubit.leftExophthalmometry,
                  'External Lids': cubit.leftLidsController.text,
                  'Lashes': cubit.leftLashesController.text,
                  'Conjunctiva': cubit.leftConjunctivaController.text,
                  'Sclera': cubit.leftScleraController.text,
                  'Lacrimal': cubit.leftLacrimalController.text,
                },
                boldFont,
                font)),
      ],
    );
  }

  static pw.Widget _buildEyeStructureAndFundus(
      ExaminationFormCubit cubit, pw.Font boldFont, pw.Font font) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
            child: _buildDataTable(
                'Segments (OD)',
                {
                  'Cornea': cubit.rightCornea.join(', '),
                  'Ant. Chamber': cubit.rightAnteriorChambre.join(', '),
                  'Iris': cubit.rightIris.join(', '),
                  'Lens': cubit.rightLens.join(', '),
                  'Ant. Vitreous': cubit.rightAnteriorVitreous.join(', '),
                  'Fundus Disc': cubit.rightFundusOpticDisc.join(', '),
                  'Fundus Macula': cubit.rightFundusMacula.join(', '),
                  'Fundus Vessels': cubit.rightFundusVessels.join(', '),
                  'Fundus Periphery': cubit.rightFundusPeriphery.join(', '),
                },
                boldFont,
                font)),
        pw.SizedBox(width: 15),
        pw.Expanded(
            child: _buildDataTable(
                'Segments (OS)',
                {
                  'Cornea': cubit.leftCornea.join(', '),
                  'Ant. Chamber': cubit.leftAnteriorChambre.join(', '),
                  'Iris': cubit.leftIris.join(', '),
                  'Lens': cubit.leftLens.join(', '),
                  'Ant. Vitreous': cubit.leftAnteriorVitreous.join(', '),
                  'Fundus Disc': cubit.leftFundusOpticDisc.join(', '),
                  'Fundus Macula': cubit.leftFundusMacula.join(', '),
                  'Fundus Vessels': cubit.leftFundusVessels.join(', '),
                  'Fundus Periphery': cubit.leftFundusPeriphery.join(', '),
                },
                boldFont,
                font)),
      ],
    );
  }

  static pw.Widget _buildFieldsSection(
      ExaminationFormCubit cubit, pw.Font boldFont, pw.Font font) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
      children: [
        _buildFieldItem('RIGHT EYE (OD)', cubit, false, boldFont),
        _buildFieldItem('LEFT EYE (OS)', cubit, true, boldFont),
      ],
    );
  }

  static pw.Widget _buildFieldItem(
      String side, ExaminationFormCubit cubit, bool isL, pw.Font boldFont) {
    final counts = isL
        ? [
            cubit.leftTopLeftTapCount,
            cubit.leftTopRightTapCount,
            cubit.leftBottomLeftTapCount,
            cubit.leftBottomRightTapCount
          ]
        : [
            cubit.rightTopLeftTapCount,
            cubit.rightTopRightTapCount,
            cubit.rightBottomLeftTapCount,
            cubit.rightBottomRightTapCount
          ];

    PdfColor getColor(num count) {
      if (count == 1) return PdfColors.black;
      if (count == 2) return PdfColors.white;
      return PdfColors.grey300;
    }

    return pw.Column(
      children: [
        pw.Text(side,
            style: pw.TextStyle(
                font: boldFont, fontSize: 8, color: textSecondary)),
        pw.SizedBox(height: 5),
        pw.Container(
          width: 70,
          height: 70,
          decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.black, width: 0.8)),
          child: pw.Column(
            children: [
              pw.Expanded(
                child: pw.Row(
                  children: [
                    pw.Expanded(
                        child: pw.Container(
                            decoration: pw.BoxDecoration(
                                color: getColor(counts[0]),
                                border: pw.Border.all(
                                    color: PdfColors.white, width: 0.2)))),
                    pw.Expanded(
                        child: pw.Container(
                            decoration: pw.BoxDecoration(
                                color: getColor(counts[1]),
                                border: pw.Border.all(
                                    color: PdfColors.white, width: 0.2)))),
                  ],
                ),
              ),
              pw.Expanded(
                child: pw.Row(
                  children: [
                    pw.Expanded(
                        child: pw.Container(
                            decoration: pw.BoxDecoration(
                                color: getColor(counts[2]),
                                border: pw.Border.all(
                                    color: PdfColors.white, width: 0.2)))),
                    pw.Expanded(
                        child: pw.Container(
                            decoration: pw.BoxDecoration(
                                color: getColor(counts[3]),
                                border: pw.Border.all(
                                    color: PdfColors.white, width: 0.2)))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildDataTable(
      String title, Map<String, dynamic> data, pw.Font boldFont, pw.Font font,
      {bool compact = false}) {
    return pw.Container(
      decoration: pw.BoxDecoration(
          border: pw.Border.all(color: borderColor, width: 0.5),
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4))),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.symmetric(vertical: 2, horizontal: 6),
            decoration: pw.BoxDecoration(
                color: tableHeaderBg,
                border: pw.Border(
                    bottom: pw.BorderSide(color: borderColor, width: 0.5))),
            child: pw.Text(title,
                style: pw.TextStyle(
                    font: boldFont, fontSize: 8, color: PdfColors.blue800)),
          ),
          pw.Table(
            columnWidths: {
              0: const pw.FixedColumnWidth(80),
              1: const pw.FlexColumnWidth()
            },
            children: data.entries.map((entry) {
              final val = (entry.value == null ||
                      entry.value.toString().isEmpty ||
                      entry.value.toString() == 'null')
                  ? '---'
                  : entry.value.toString();
              return pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(
                        horizontal: 6, vertical: 3),
                    child: pw.Text(entry.key,
                        style: pw.TextStyle(
                            font: font,
                            fontSize: compact ? 7 : 8,
                            color: textSecondary)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(
                        horizontal: 6, vertical: 3),
                    child: pw.Text(val,
                        style: pw.TextStyle(
                            font: boldFont,
                            fontSize: compact ? 7 : 8,
                            color: textPrimary)),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
