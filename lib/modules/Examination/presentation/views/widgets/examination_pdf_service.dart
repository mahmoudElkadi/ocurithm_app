import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../../../core/utils/format_helper.dart';
import '../../../../Appointment/data/models/appointment_model.dart';
import '../../manager/examination_form_cubit/examination_form_cubit.dart';
import '../../../../Patient/data/model/one_exam.dart' as one_exam;
import '../../../data/catalog/history_catalog.dart';
import '../../../data/catalog/complain_catalog.dart';

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
            _buildPatientBanner(
              name: appointment.patient?.name ?? 'N/A',
              nationalId: appointment.patient?.nationalId ?? 'N/A',
              birthDate: appointment.patient?.birthDate,
              gender: appointment.patient?.gender ?? 'N/A',
              phone: appointment.patient?.phone ?? 'N/A',
              boldFont: boldFont,
              font: font,
            ),
            pw.SizedBox(height: 15),
            _buildSectionTitle('1. CLINICAL HISTORY & COMPLAINTS', boldFont),
            _buildHistoryAndComplaintsFromCubit(cubit, boldFont, font),
            pw.SizedBox(height: 15),
            _buildSectionTitle('2. REFRACTION & VISUAL ACUITY', boldFont),
            _buildRefractionReflectionsFromCubit(cubit, boldFont, font),
            pw.SizedBox(height: 15),
            _buildSectionTitle(
                '3. INTRAOCULAR PRESSURE (IOP) & PUPILS', boldFont),
            _buildIopAndPupilsFromCubit(cubit, boldFont, font),
            pw.SizedBox(height: 15),
            _buildSectionTitle('4. EXTERNAL & PHYSICAL EXAMINATION', boldFont),
            _buildPhysicalExaminationFromCubit(cubit, boldFont, font),
            pw.SizedBox(height: 15),
            _buildSectionTitle('5. SEGMENT & FUNDUS EXAMINATION', boldFont),
            _buildEyeStructureAndFundusFromCubit(cubit, boldFont, font),
            pw.SizedBox(height: 15),
            _buildSectionTitle('6. CONFRONTATION FIELDS', boldFont),
            _buildFieldsSectionFromCubit(cubit, boldFont, font),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Examination_${appointment.patient?.name ?? 'Report'}.pdf',
    );
  }

  static Future<void> generateAndPrintOneExamination(
      one_exam.ExaminationModel model) async {
    final pdf = pw.Document();

    final regularFontData =
        await rootBundle.load("assets/fonts/Cairo-Regular.ttf");
    final boldFontData = await rootBundle.load("assets/fonts/Cairo-Bold.ttf");
    final font = pw.Font.ttf(regularFontData);
    final boldFont = pw.Font.ttf(boldFontData);

    final logoData = await rootBundle.load('assets/icons/logo.png');
    final logoBytes = logoData.buffer.asUint8List();

    final examination = model.examination;
    if (examination == null) return;

    // Based on OneExaminationContent, index 0 is Left, index 1 is Right
    final leftMeasurement = examination.measurements.isNotEmpty
        ? examination.measurements[0]
        : one_exam.Measurement();
    final rightMeasurement = examination.measurements.length > 1
        ? examination.measurements[1]
        : one_exam.Measurement();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(30),
        theme: pw.ThemeData.withFont(base: font, bold: boldFont),
        header: (pw.Context context) => _buildHeader(logoBytes, boldFont, font),
        footer: (pw.Context context) => _buildFooter(context, font),
        build: (pw.Context context) {
          return [
            _buildPatientBanner(
              name: examination.patient?.name ?? 'N/A',
              nationalId: examination.patient?.nationalId ?? 'N/A',
              birthDate: examination.patient?.birthDate,
              gender: examination.patient?.gender ?? 'N/A',
              phone: examination.patient?.phone ?? 'N/A',
              boldFont: boldFont,
              font: font,
            ),
            pw.SizedBox(height: 15),
            _buildSectionTitle('1. CLINICAL HISTORY & COMPLAINTS', boldFont),
            _buildHistoryAndComplaints(
              history: _mergeStructuredHistory(
                examination.history?.selectedCategories ?? const [],
                examination.history?.values ?? const {},
                {
                  'Family History': examination.history?.familyHistory ?? '',
                  'Present Illness': examination.history?.presentIllness ?? '',
                  'Past History': examination.history?.pastHistory ?? '',
                  'Medication': examination.history?.medicationHistory ?? '',
                },
              ),
              complaints: _mergeStructuredComplain(
                examination.complain?.selectedComplaints ?? const [],
                examination.complain?.values ?? const {},
                {
                  'Complaint 1': examination.complain?.complainOne ?? '',
                  'Complaint 2': examination.complain?.complainTwo ?? '',
                  'Complaint 3': examination.complain?.complainThree ?? '',
                },
              ),
              boldFont: boldFont,
              font: font,
            ),
            pw.SizedBox(height: 15),
            _buildSectionTitle('2. REFRACTION & VISUAL ACUITY', boldFont),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: _buildEyeMeasurementSectionRaw(
                    title: 'RIGHT EYE (OD)',
                    oldSph: rightMeasurement.oldSpherical?.toString(),
                    oldCyl: rightMeasurement.oldCylindrical?.toString(),
                    oldAxis: rightMeasurement.oldAxis?.toString(),
                    oldGlassesVa: rightMeasurement.oldGlassesVa?.toString(),
                    autoSph: rightMeasurement.autorefSpherical?.toString(),
                    autoCyl: rightMeasurement.autorefCylindrical?.toString(),
                    autoAxis: rightMeasurement.autorefAxis?.toString(),
                    refinedSph:
                        rightMeasurement.refinedRefractionSpherical?.toString(),
                    refinedCyl: rightMeasurement
                        .refinedRefractionCylindrical
                        ?.toString(),
                    refinedAxis:
                        rightMeasurement.refinedRefractionAxis?.toString(),
                    nearAdd: rightMeasurement.nearVisionAddition?.toString(),
                    cycloSph:
                        rightMeasurement.cycloplegicSpherical?.toString(),
                    cycloCyl:
                        rightMeasurement.cycloplegicCylindrical?.toString(),
                    cycloAxis: rightMeasurement.cycloplegicAxis?.toString(),
                    ucva: rightMeasurement.ucva?.toString(),
                    bcva: rightMeasurement.bcva?.toString(),
                    boldFont: boldFont,
                    font: font,
                  ),
                ),
                pw.SizedBox(width: 15),
                pw.Expanded(
                  child: _buildEyeMeasurementSectionRaw(
                    title: 'LEFT EYE (OS)',
                    oldSph: leftMeasurement.oldSpherical?.toString(),
                    oldCyl: leftMeasurement.oldCylindrical?.toString(),
                    oldAxis: leftMeasurement.oldAxis?.toString(),
                    oldGlassesVa: leftMeasurement.oldGlassesVa?.toString(),
                    autoSph: leftMeasurement.autorefSpherical?.toString(),
                    autoCyl: leftMeasurement.autorefCylindrical?.toString(),
                    autoAxis: leftMeasurement.autorefAxis?.toString(),
                    refinedSph:
                        leftMeasurement.refinedRefractionSpherical?.toString(),
                    refinedCyl: leftMeasurement.refinedRefractionCylindrical
                        ?.toString(),
                    refinedAxis:
                        leftMeasurement.refinedRefractionAxis?.toString(),
                    nearAdd: leftMeasurement.nearVisionAddition?.toString(),
                    cycloSph:
                        leftMeasurement.cycloplegicSpherical?.toString(),
                    cycloCyl:
                        leftMeasurement.cycloplegicCylindrical?.toString(),
                    cycloAxis: leftMeasurement.cycloplegicAxis?.toString(),
                    ucva: leftMeasurement.ucva?.toString(),
                    bcva: leftMeasurement.bcva?.toString(),
                    boldFont: boldFont,
                    font: font,
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 15),
            _buildSectionTitle(
                '3. INTRAOCULAR PRESSURE (IOP) & PUPILS', boldFont),
            _buildIopAndPupils(
              rightData: {
                'IOP (mmHg)': rightMeasurement.iop?.toString() ?? '',
                'IOP Method': rightMeasurement.meansOfMeasurement ?? '',
                'Pupil Shape': rightMeasurement.pupilsShape ?? '',
                'Light Reflex': rightMeasurement.pupilsLightReflexTest ?? '',
                'Near Reflex': rightMeasurement.pupilsNearReflexTest ?? '',
                'Swinging Flashlight':
                    rightMeasurement.pupilsSwingingFlashLightTest ?? '',
                'Other Pupil Dis.': rightMeasurement.pupilsOtherDisorders ?? '',
              },
              leftData: {
                'IOP (mmHg)': leftMeasurement.iop?.toString() ?? '',
                'IOP Method': leftMeasurement.meansOfMeasurement ?? '',
                'Pupil Shape': leftMeasurement.pupilsShape ?? '',
                'Light Reflex': leftMeasurement.pupilsLightReflexTest ?? '',
                'Near Reflex': leftMeasurement.pupilsNearReflexTest ?? '',
                'Swinging Flashlight':
                    leftMeasurement.pupilsSwingingFlashLightTest ?? '',
                'Other Pupil Dis.': leftMeasurement.pupilsOtherDisorders ?? '',
              },
              boldFont: boldFont,
              font: font,
            ),
            pw.SizedBox(height: 15),
            _buildSectionTitle('4. EXTERNAL & PHYSICAL EXAMINATION', boldFont),
            _buildPhysicalExamination(
              rightData: {
                'Eyelid Ptosis': rightMeasurement.eyelidPtosis ?? '',
                'Lagophthalmos': rightMeasurement.eyelidLagophthalmos ?? '',
                'Lymph Nodes': rightMeasurement.palpableLymphNodes ?? '',
                'Temporal Artery': rightMeasurement.palpableTemporalArtery ?? '',
                'Exophthalmometry': rightMeasurement.exophthalmometry ?? '',
                'External Lids': rightMeasurement.lids ?? '',
                'Lashes': rightMeasurement.lashes ?? '',
                'Conjunctiva': rightMeasurement.conjunctiva ?? '',
                'Sclera': rightMeasurement.sclera ?? '',
                'Lacrimal': rightMeasurement.lacrimalSystem ?? '',
              },
              leftData: {
                'Eyelid Ptosis': leftMeasurement.eyelidPtosis ?? '',
                'Lagophthalmos': leftMeasurement.eyelidLagophthalmos ?? '',
                'Lymph Nodes': leftMeasurement.palpableLymphNodes ?? '',
                'Temporal Artery': leftMeasurement.palpableTemporalArtery ?? '',
                'Exophthalmometry': leftMeasurement.exophthalmometry ?? '',
                'External Lids': leftMeasurement.lids ?? '',
                'Lashes': leftMeasurement.lashes ?? '',
                'Conjunctiva': leftMeasurement.conjunctiva ?? '',
                'Sclera': leftMeasurement.sclera ?? '',
                'Lacrimal': leftMeasurement.lacrimalSystem ?? '',
              },
              boldFont: boldFont,
              font: font,
            ),
            pw.SizedBox(height: 15),
            _buildSectionTitle('5. SEGMENT & FUNDUS EXAMINATION', boldFont),
            _buildEyeStructureAndFundus(
              rightData: {
                'Cornea': (rightMeasurement.cornea as List?)?.join(', ') ?? '',
                'Ant. Chamber':
                    (rightMeasurement.anteriorChamber as List?)?.join(', ') ??
                        '',
                'Iris': (rightMeasurement.iris as List?)?.join(', ') ?? '',
                'Lens': (rightMeasurement.lens as List?)?.join(', ') ?? '',
                'Ant. Vitreous':
                    (rightMeasurement.anteriorVitreous as List?)?.join(', ') ??
                        '',
                if ((rightMeasurement.vitreousHemorrhageGrade ?? '')
                    .toString()
                    .isNotEmpty)
                  'VH Grade': rightMeasurement.vitreousHemorrhageGrade!,
                'Fundus Disc':
                    (rightMeasurement.fundusOpticDisc as List?)?.join(', ') ??
                        '',
                if ((rightMeasurement.cupDiscRatio ?? '').toString().isNotEmpty)
                  'Cup Disc Ratio': rightMeasurement.cupDiscRatio.toString(),
                'Fundus Macula':
                    (rightMeasurement.fundusMacula as List?)?.join(', ') ?? '',
                'Fundus Vessels':
                    (rightMeasurement.fundusVessels as List?)?.join(', ') ?? '',
                'Fundus Periphery':
                    (rightMeasurement.fundusPeriphery as List?)?.join(', ') ??
                        '',
              },
              leftData: {
                'Cornea': (leftMeasurement.cornea as List?)?.join(', ') ?? '',
                'Ant. Chamber':
                    (leftMeasurement.anteriorChamber as List?)?.join(', ') ??
                        '',
                'Iris': (leftMeasurement.iris as List?)?.join(', ') ?? '',
                'Lens': (leftMeasurement.lens as List?)?.join(', ') ?? '',
                'Ant. Vitreous':
                    (leftMeasurement.anteriorVitreous as List?)?.join(', ') ??
                        '',
                if ((leftMeasurement.vitreousHemorrhageGrade ?? '')
                    .toString()
                    .isNotEmpty)
                  'VH Grade': leftMeasurement.vitreousHemorrhageGrade!,
                'Fundus Disc':
                    (leftMeasurement.fundusOpticDisc as List?)?.join(', ') ??
                        '',
                if ((leftMeasurement.cupDiscRatio ?? '').toString().isNotEmpty)
                  'Cup Disc Ratio': leftMeasurement.cupDiscRatio.toString(),
                'Fundus Macula':
                    (leftMeasurement.fundusMacula as List?)?.join(', ') ?? '',
                'Fundus Vessels':
                    (leftMeasurement.fundusVessels as List?)?.join(', ') ?? '',
                'Fundus Periphery':
                    (leftMeasurement.fundusPeriphery as List?)?.join(', ') ??
                        '',
              },
              boldFont: boldFont,
              font: font,
            ),
            pw.SizedBox(height: 15),
            _buildSectionTitle('6. CONFRONTATION FIELDS', boldFont),
            _buildFieldsSection(
              rightCounts: [
                rightMeasurement.topLeft ?? 0,
                rightMeasurement.topRight ?? 0,
                rightMeasurement.bottomLeft ?? 0,
                rightMeasurement.bottomRight ?? 0,
              ],
              leftCounts: [
                leftMeasurement.topLeft ?? 0,
                leftMeasurement.topRight ?? 0,
                leftMeasurement.bottomLeft ?? 0,
                leftMeasurement.bottomRight ?? 0,
              ],
              boldFont: boldFont,
              font: font,
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Examination_${examination.patient?.name ?? 'Report'}.pdf',
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

  static pw.Widget _buildPatientBanner({
    required String name,
    required String nationalId,
    DateTime? birthDate,
    required String gender,
    required String phone,
    required pw.Font boldFont,
    required pw.Font font,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
          color: headerBg,
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8))),
      child: pw.Column(
        children: [
          pw.Row(
            children: [
              _bannerItem('Patient Name', name, 3, boldFont, font),
              _bannerItem('National ID', nationalId, 2, boldFont, font),
            ],
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            children: [
              _bannerItem('Age',
                  '${FormatHelper.calculateAge(birthDate)} Years', 1, boldFont, font),
              _bannerItem('Gender', gender, 1, boldFont, font),
              _bannerItem('Phone', phone, 1, boldFont, font),
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

  static pw.Widget _buildHistoryAndComplaintsFromCubit(
      ExaminationFormCubit cubit, pw.Font boldFont, pw.Font font) {
    return _buildHistoryAndComplaints(
      history: _mergeStructuredHistory(
        cubit.selectedHistoryCategories,
        cubit.historyValues,
        {
          'Family History': cubit.familyHistoryController.text,
          'Present Illness': cubit.presentIllnessController.text,
          'Past History': cubit.pastHistoryController.text,
          'Medication': cubit.medicationHistoryController.text,
        },
      ),
      complaints: _mergeStructuredComplain(
        cubit.selectedComplaints,
        cubit.complainValues,
        {
          'Complaint 1': cubit.oneComplaintController.text,
          'Complaint 2': cubit.twoComplaintController.text,
          'Complaint 3': cubit.threeComplaintController.text,
        },
      ),
      boldFont: boldFont,
      font: font,
    );
  }

  /// Merge structured checklist entries (visible, non-empty per selected
  /// category) ahead of the legacy free-text history map for the PDF.
  static Map<String, dynamic> _mergeStructuredHistory(
    List<String> selectedCategories,
    Map<String, dynamic> values,
    Map<String, dynamic> legacy,
  ) {
    final out = <String, dynamic>{};
    for (final catKey in selectedCategories) {
      for (final e in visibleHistoryEntries(catKey, values)) {
        out['${historyCategoryLabel(catKey)} — ${e.key}'] = e.value;
      }
    }
    out.addAll(legacy);
    return out;
  }

  /// Merge structured complaint entries (visible fields per selected option;
  /// zero-field options show as "Present") ahead of the legacy free-text map.
  static Map<String, dynamic> _mergeStructuredComplain(
    List<String> selectedComplaints,
    Map<String, dynamic> values,
    Map<String, dynamic> legacy,
  ) {
    final out = <String, dynamic>{};
    for (final optKey in selectedComplaints) {
      final entries = visibleComplainEntries(optKey, values);
      if (entries.isEmpty) {
        out[complainOptionLabel(optKey)] = 'Present';
      } else {
        for (final e in entries) {
          out['${complainOptionLabel(optKey)} — ${e.key}'] = e.value;
        }
      }
    }
    out.addAll(legacy);
    return out;
  }

  static pw.Widget _buildHistoryAndComplaints({
    required Map<String, dynamic> history,
    required Map<String, dynamic> complaints,
    required pw.Font boldFont,
    required pw.Font font,
  }) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
            child: _buildDataTable('Medical History', history, boldFont, font)),
        pw.SizedBox(width: 15),
        pw.Expanded(
            child: _buildDataTable('Chief Complaints', complaints, boldFont, font)),
      ],
    );
  }

  static pw.Widget _buildRefractionReflectionsFromCubit(
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
    return _buildEyeMeasurementSectionRaw(
      title: title,
      oldSph: isL
          ? c.leftOldSpherical?.toString()
          : c.rightOldSpherical?.toString(),
      oldCyl: isL
          ? c.leftOldCylindrical?.toString()
          : c.rightOldCylindrical?.toString(),
      oldAxis: isL ? c.leftOldAxis : c.rightOldAxis,
      oldGlassesVa: isL ? c.leftOldGlassesVa : c.rightOldGlassesVa,
      autoSph: isL
          ? c.leftAurorefSpherical?.toString()
          : c.rightAurorefSpherical?.toString(),
      autoCyl: isL
          ? c.leftAurorefCylindrical?.toString()
          : c.rightAurorefCylindrical?.toString(),
      autoAxis: isL ? c.leftAurorefAxis : c.rightAurorefAxis,
      refinedSph:
          isL ? c.leftRefinedRefractionSpherical : c.rightRefinedRefractionSpherical,
      refinedCyl:
          isL ? c.leftRefinedRefractionCylindrical : c.rightRefinedRefractionCylindrical,
      refinedAxis: isL
          ? c.leftRefinedRefractionAxis
          : c.rightRefinedRefractionAxis,
      cycloSph: isL
          ? c.leftCycloplegicSpherical?.toString()
          : c.rightCycloplegicSpherical?.toString(),
      cycloCyl: isL
          ? c.leftCycloplegicCylindrical?.toString()
          : c.rightCycloplegicCylindrical?.toString(),
      cycloAxis: isL
          ? c.leftCycloplegicAxis?.toString()
          : c.rightCycloplegicAxis?.toString(),
      nearAdd: isL ? c.leftNearVisionAddition : c.rightNearVisionAddition,
      ucva: isL ? c.leftUCVA : c.rightUCVA,
      bcva: isL ? c.leftBCVA : c.rightBCVA,
      boldFont: boldFont,
      font: font,
    );
  }

  static bool _hasAnyReading(List<String?> values) => values.any((value) {
        if (value == null) return false;
        final text = value.trim();
        return text.isNotEmpty && text != '-' && text != 'N/A';
      });

  static pw.Widget _buildEyeMeasurementSectionRaw({
    required String title,
    String? oldSph,
    String? oldCyl,
    String? oldAxis,
    String? oldGlassesVa,
    String? autoSph,
    String? autoCyl,
    String? autoAxis,
    String? refinedSph,
    String? refinedCyl,
    String? refinedAxis,
    String? nearAdd,
    String? cycloSph,
    String? cycloCyl,
    String? cycloAxis,
    String? ucva,
    String? bcva,
    required pw.Font boldFont,
    required pw.Font font,
  }) {
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
              'Sph': FormatHelper.formatPositiveValue(oldSph),
              'Cyl': FormatHelper.formatPositiveValue(oldCyl),
              'Axis': oldAxis,
              'VA': oldGlassesVa,
            },
            boldFont,
            font,
            compact: true),
        pw.SizedBox(height: 5),
        _buildDataTable(
            'Autorefraction',
            {
              'Sph': FormatHelper.formatPositiveValue(autoSph),
              'Cyl': FormatHelper.formatPositiveValue(autoCyl),
              'Axis': autoAxis,
            },
            boldFont,
            font,
            compact: true),
        pw.SizedBox(height: 5),
        // Absent from almost every visit, so the table is skipped rather than
        // printed as a row of dashes.
        if (_hasAnyReading([cycloSph, cycloCyl, cycloAxis])) ...[
          _buildDataTable(
              'Cycloplegic Refraction',
              {
                'Sph': FormatHelper.formatPositiveValue(cycloSph),
                'Cyl': FormatHelper.formatPositiveValue(cycloCyl),
                'Axis': cycloAxis,
              },
              boldFont,
              font,
              compact: true),
          pw.SizedBox(height: 5),
        ],
        _buildDataTable(
            'Refined Refraction',
            {
              'Sph': FormatHelper.formatPositiveValue(refinedSph),
              'Cyl': FormatHelper.formatPositiveValue(refinedCyl),
              'Axis': refinedAxis,
              'Near ADD': FormatHelper.formatPositiveValue(nearAdd),
            },
            boldFont,
            font,
            compact: true),
        pw.SizedBox(height: 5),
        _buildDataTable(
            'Visual Acuity',
            {
              'UCVA': ucva,
              'BCVA': bcva,
            },
            boldFont,
            font,
            compact: true),
      ],
    );
  }

  static pw.Widget _buildIopAndPupilsFromCubit(
      ExaminationFormCubit cubit, pw.Font boldFont, pw.Font font) {
    return _buildIopAndPupils(
      rightData: {
        'IOP (mmHg)': cubit.rightIOP,
        'IOP Method': cubit.rightMeansOfMeasurement,
        'Pupil Shape': cubit.rightPupilsShape,
        'Light Reflex': cubit.rightPupilsLightReflexTest,
        'Near Reflex': cubit.rightPupilsNearReflexTest,
        'Swinging Flashlight': cubit.rightPupilsSwingingFlashLightTest,
        'Other Pupil Dis.': cubit.rightPupilsOtherDisorders,
      },
      leftData: {
        'IOP (mmHg)': cubit.leftIOP,
        'IOP Method': cubit.leftMeansOfMeasurement,
        'Pupil Shape': cubit.leftPupilsShape,
        'Light Reflex': cubit.leftPupilsLightReflexTest,
        'Near Reflex': cubit.leftPupilsNearReflexTest,
        'Swinging Flashlight': cubit.leftPupilsSwingingFlashLightTest,
        'Other Pupil Dis.': cubit.leftPupilsOtherDisorders,
      },
      boldFont: boldFont,
      font: font,
    );
  }

  static pw.Widget _buildIopAndPupils({
    required Map<String, dynamic> rightData,
    required Map<String, dynamic> leftData,
    required pw.Font boldFont,
    required pw.Font font,
  }) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
            child: _buildDataTable('IOP & Pupils (OD)', rightData, boldFont, font)),
        pw.SizedBox(width: 15),
        pw.Expanded(
            child: _buildDataTable('IOP & Pupils (OS)', leftData, boldFont, font)),
      ],
    );
  }

  static pw.Widget _buildPhysicalExaminationFromCubit(
      ExaminationFormCubit cubit, pw.Font boldFont, pw.Font font) {
    return _buildPhysicalExamination(
      rightData: {
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
      leftData: {
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
      boldFont: boldFont,
      font: font,
    );
  }

  static pw.Widget _buildPhysicalExamination({
    required Map<String, dynamic> rightData,
    required Map<String, dynamic> leftData,
    required pw.Font boldFont,
    required pw.Font font,
  }) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
            child: _buildDataTable('Physical (OD)', rightData, boldFont, font)),
        pw.SizedBox(width: 15),
        pw.Expanded(
            child: _buildDataTable('Physical (OS)', leftData, boldFont, font)),
      ],
    );
  }

  static pw.Widget _buildEyeStructureAndFundusFromCubit(
      ExaminationFormCubit cubit, pw.Font boldFont, pw.Font font) {
    return _buildEyeStructureAndFundus(
      rightData: {
        'Cornea': cubit.rightCornea.join(', '),
        'Ant. Chamber': cubit.rightAnteriorChambre.join(', '),
        'Iris': cubit.rightIris.join(', '),
        'Lens': cubit.rightLens.join(', '),
        'Ant. Vitreous': cubit.rightAnteriorVitreous.join(', '),
        if ((cubit.rightVitreousHemorrhageGrade ?? '').toString().isNotEmpty)
          'VH Grade': cubit.rightVitreousHemorrhageGrade.toString(),
        'Fundus Disc': cubit.rightFundusOpticDisc.join(', '),
        if ((cubit.rightCupDiscRatio ?? '').toString().isNotEmpty)
          'Cup Disc Ratio': cubit.rightCupDiscRatio.toString(),
        'Fundus Macula': cubit.rightFundusMacula.join(', '),
        'Fundus Vessels': cubit.rightFundusVessels.join(', '),
        'Fundus Periphery': cubit.rightFundusPeriphery.join(', '),
      },
      leftData: {
        'Cornea': cubit.leftCornea.join(', '),
        'Ant. Chamber': cubit.leftAnteriorChambre.join(', '),
        'Iris': cubit.leftIris.join(', '),
        'Lens': cubit.leftLens.join(', '),
        'Ant. Vitreous': cubit.leftAnteriorVitreous.join(', '),
        if ((cubit.leftVitreousHemorrhageGrade ?? '').toString().isNotEmpty)
          'VH Grade': cubit.leftVitreousHemorrhageGrade.toString(),
        'Fundus Disc': cubit.leftFundusOpticDisc.join(', '),
        if ((cubit.leftCupDiscRatio ?? '').toString().isNotEmpty)
          'Cup Disc Ratio': cubit.leftCupDiscRatio.toString(),
        'Fundus Macula': cubit.leftFundusMacula.join(', '),
        'Fundus Vessels': cubit.leftFundusVessels.join(', '),
        'Fundus Periphery': cubit.leftFundusPeriphery.join(', '),
      },
      boldFont: boldFont,
      font: font,
    );
  }

  static pw.Widget _buildEyeStructureAndFundus({
    required Map<String, dynamic> rightData,
    required Map<String, dynamic> leftData,
    required pw.Font boldFont,
    required pw.Font font,
  }) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
            child: _buildDataTable('Segments (OD)', rightData, boldFont, font)),
        pw.SizedBox(width: 15),
        pw.Expanded(
            child: _buildDataTable('Segments (OS)', leftData, boldFont, font)),
      ],
    );
  }

  static pw.Widget _buildFieldsSectionFromCubit(
      ExaminationFormCubit cubit, pw.Font boldFont, pw.Font font) {
    return _buildFieldsSection(
      rightCounts: [
        cubit.rightTopLeftTapCount,
        cubit.rightTopRightTapCount,
        cubit.rightBottomLeftTapCount,
        cubit.rightBottomRightTapCount
      ],
      leftCounts: [
        cubit.leftTopLeftTapCount,
        cubit.leftTopRightTapCount,
        cubit.leftBottomLeftTapCount,
        cubit.leftBottomRightTapCount
      ],
      boldFont: boldFont,
      font: font,
    );
  }

  static pw.Widget _buildFieldsSection({
    required List<num> rightCounts,
    required List<num> leftCounts,
    required pw.Font boldFont,
    required pw.Font font,
  }) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
      children: [
        _buildFieldItemDetails('RIGHT EYE (OD)', rightCounts, boldFont),
        _buildFieldItemDetails('LEFT EYE (OS)', leftCounts, boldFont),
      ],
    );
  }

  static pw.Widget _buildFieldItemDetails(
      String side, List<num> counts, pw.Font boldFont) {
    PdfColor getColor(num count) {
      if (count == 1) return PdfColors.black;
      if (count == 2) return PdfColors.white;
      return PdfColors.grey400;
    }

    pw.Widget buildQuadrant(num count, pw.BorderRadius borderRadius) {
      return pw.Container(
        width: 35,
        height: 35,
        decoration: pw.BoxDecoration(
          color: getColor(count),
          borderRadius: borderRadius,
          border: pw.Border.all(color: PdfColors.white, width: 0.5),
        ),
        child: pw.Center(
          child: pw.Text(
            count == 2 ? 'CF' : '',
            style: pw.TextStyle(
              font: boldFont,
              fontSize: 10,
              color: PdfColors.black,
            ),
          ),
        ),
      );
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
          child: pw.Column(
            children: [
              pw.Row(
                mainAxisSize: pw.MainAxisSize.min,
                children: [
                  buildQuadrant(counts[0],
                      const pw.BorderRadius.only(topLeft: pw.Radius.circular(35))),
                  buildQuadrant(counts[1],
                      const pw.BorderRadius.only(topRight: pw.Radius.circular(35))),
                ],
              ),
              pw.Row(
                mainAxisSize: pw.MainAxisSize.min,
                children: [
                  buildQuadrant(counts[2],
                      const pw.BorderRadius.only(bottomLeft: pw.Radius.circular(35))),
                  buildQuadrant(counts[3],
                      const pw.BorderRadius.only(bottomRight: pw.Radius.circular(35))),
                ],
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
