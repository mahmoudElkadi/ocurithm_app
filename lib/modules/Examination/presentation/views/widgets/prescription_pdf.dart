import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:ocurithm/modules/Analysis/presentation/views/widgets/analysis_pdf_service.dart';
import 'package:ocurithm/modules/Analysis/data/models/analysis_model.dart' as analysis_model;
import 'package:ocurithm/modules/Analysis/presentation/views/widgets/analysis_view_body.dart' as analysis_view;

import '../../../../../core/utils/format_helper.dart';
import '../../../../../core/utils/glasses_prescription.dart';
import '../../../../Patient/data/model/one_exam.dart';
import '../../../data/catalog/printable_measurement_fields.dart';

Future<void> generateAndPrintPrescription(
    {required ExaminationModel examination,
    required Action action,
    String? diagnosis,
    List<Medicine>? prescriptionList,
    bool showPrescriptionTable = false,
    analysis_model.AnalysisModel? analysis,
    Set<String>? selectedChartKeys,
    Set<String>? selectedExaminationFieldIds,
    analysis_view.EyeSelection? eyeSelection}) async {
  // Readings the doctor picked to print alongside the prescription, with their
  // labels. Anything with no reading is dropped rather than printed as a dash.
  final selectedExaminationValues = resolvePrintableFields(
    selectedExaminationFieldIds ?? const <String>{},
    examination.examination?.measurements ?? const [],
  );
  final isGlassesPrescription =
      action.action?.toLowerCase() == 'prescribe glasses';
  // Older records hold "IPD: 63" in `data`, typed by hand back when the printout
  // carried no label; strip it so the label is not doubled up.
  final actionDataValue = isGlassesPrescription
      ? GlassesPrescription.normalizeIpd(action.data)
      : (action.data ?? '');

  // measurements[1] is the right eye and measurements[0] the left, matching how the
  // rest of this document indexes them.
  final rightMeasurement = (examination.examination?.measurements.length ?? 0) > 1
      ? examination.examination?.measurements[1]
      : null;
  final leftMeasurement = (examination.examination?.measurements.isNotEmpty ?? false)
      ? examination.examination?.measurements[0]
      : null;

  final rightNearVisionRow = GlassesPrescription.buildNearVisionRow(
    nStyle: action.nStyle,
    spherical: rightMeasurement?.refinedRefractionSpherical,
    cylindrical: rightMeasurement?.refinedRefractionCylindrical,
    axis: rightMeasurement?.refinedRefractionAxis,
    nearVisionAddition: rightMeasurement?.nearVisionAddition,
  );
  final leftNearVisionRow = GlassesPrescription.buildNearVisionRow(
    nStyle: action.nStyle,
    spherical: leftMeasurement?.refinedRefractionSpherical,
    cylindrical: leftMeasurement?.refinedRefractionCylindrical,
    axis: leftMeasurement?.refinedRefractionAxis,
    nearVisionAddition: leftMeasurement?.nearVisionAddition,
  );

  final pdf = pw.Document();
  final regularFont = await rootBundle.load("assets/fonts/Cairo-Regular.ttf");
  final bold = await rootBundle.load("assets/fonts/Cairo-Bold.ttf");
  final font = pw.Font.ttf(regularFont);
  final boldFont = pw.Font.ttf(bold);

  final logoData = await rootBundle.load('assets/icons/logo.png');
  final logoBytes = logoData.buffer.asUint8List();

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(20),
      header: (pw.Context context) {
        return pw.Container(
          padding: const pw.EdgeInsets.all(15),
          decoration: pw.BoxDecoration(
            color: PdfColors.blue50,
            borderRadius: pw.BorderRadius.circular(10),
            border: pw.Border.all(color: PdfColors.blue200),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    examination.examination?.patient?.clinic?.name ?? '',
                    style: pw.TextStyle(
                      font: boldFont,
                      fontSize: 24,
                      color: PdfColors.blue900,
                    ),
                    textDirection: isPredominantlyArabic(examination.examination?.patient?.clinic?.name ?? "N/A")
                        ? pw.TextDirection.rtl
                        : pw.TextDirection.ltr,
                  ),
                  pw.SizedBox(height: 5),
                  pw.Text(
                    'Dr. ${examination.doctor?.name ?? ""}',
                    style: pw.TextStyle(
                      font: font,
                      fontSize: 16,
                      color: PdfColors.blue800,
                    ),
                    textDirection: isPredominantlyArabic(examination.doctor?.name ?? "N/A")
                        ? pw.TextDirection.rtl
                        : pw.TextDirection.ltr,
                  ),
                  pw.SizedBox(height: 3),
                  pw.Text(
                    'Phone: ${examination.doctor?.phone ?? ""}',
                    style: pw.TextStyle(font: font, fontSize: 12),
                  ),
                ],
              ),
              pw.Container(
                width: 80,
                height: 80,
                decoration: const pw.BoxDecoration(
                  shape: pw.BoxShape.circle,
                  color: PdfColors.blue100,
                ),
                child: pw.Center(
                  child: pw.Image(pw.MemoryImage(logoBytes), width: 100),
                ),
              ),
            ],
          ),
        );
      },
      footer: (pw.Context context) {
        return pw.Container(
          padding: const pw.EdgeInsets.all(15),
          margin: const pw.EdgeInsets.only(top: 10),
          decoration: pw.BoxDecoration(
            color: PdfColors.grey100,
            borderRadius: pw.BorderRadius.circular(10),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Patient Information',
                    style: pw.TextStyle(
                      font: boldFont,
                      fontSize: 14,
                      color: PdfColors.blue900,
                    ),
                  ),
                  pw.SizedBox(height: 5),
                  pw.Text(
                    'Name: ${examination.examination?.patient?.name ?? ""}',
                    style: pw.TextStyle(font: font, fontSize: 12),
                    textDirection: isPredominantlyArabic(examination.examination?.patient?.name ?? "N/A")
                        ? pw.TextDirection.rtl
                        : pw.TextDirection.ltr,
                  ),
                  pw.Text(
                    'ID: ${examination.examination?.patient?.serialNumber ?? ""}',
                    style: pw.TextStyle(font: font, fontSize: 12),
                  ),
                ],
              ),
              pw.Column(
                children: [
                  pw.Container(
                    width: 100,
                    height: 40,
                    child: pw.Center(
                      child: pw.Text(
                        'Doctor\'s Signature',
                        style: pw.TextStyle(
                          font: font,
                          fontSize: 10,
                          color: PdfColors.grey600,
                        ),
                      ),
                    ),
                  ),
                  pw.Container(
                    width: 100,
                    decoration: const pw.BoxDecoration(
                      border: pw.Border(
                        top: pw.BorderSide(color: PdfColors.grey400),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
      build: (pw.Context context) {
        return [
          pw.SizedBox(height: 30),
          pw.Container(
            padding: const pw.EdgeInsets.all(15),
            width: double.infinity,
            decoration: pw.BoxDecoration(
              borderRadius: pw.BorderRadius.circular(10),
              border: pw.Border.all(color: PdfColors.grey300),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Text(
                      'Date: ${examination.examination?.createdAt?.toString().split(' ')[0] ?? ""}',
                      style: pw.TextStyle(font: font, fontSize: 12),
                    ),
                  ],
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  'Diagnosis:',
                  style: pw.TextStyle(
                    font: boldFont,
                    fontSize: 16,
                    color: PdfColors.blue900,
                  ),
                ),
                pw.Text(
                  diagnosis ?? "",
                  style: pw.TextStyle(font: font, fontSize: 14),
                  textDirection: isPredominantlyArabic(examination.finalization?.diagnosis ?? "N/A")
                      ? pw.TextDirection.rtl
                      : pw.TextDirection.ltr,
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'Treatment Plan:',
                  style: pw.TextStyle(
                    font: boldFont,
                    fontSize: 16,
                    color: PdfColors.blue900,
                  ),
                ),
                pw.Text(
                  action.action ?? "",
                  style: pw.TextStyle(font: font, fontSize: 16),
                  textDirection:
                      isPredominantlyArabic(action.action ?? "N/A") ? pw.TextDirection.rtl : pw.TextDirection.ltr,
                ),
                if (actionDataValue.isNotEmpty &&
                    action.action?.toLowerCase() != 'prescribe medications')
                  pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                    pw.Text(
                      // On a glasses prescription `data` is the IPD, so it is
                      // labelled as such instead of as generic information.
                      isGlassesPrescription ? 'IPD:' : 'Information:',
                      style: pw.TextStyle(
                        font: boldFont,
                        fontSize: 16,
                        color: PdfColors.blue900,
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(left: 10),
                      child: pw.Text(
                        actionDataValue,
                        style: pw.TextStyle(font: font, fontSize: 14),
                        textDirection: isPredominantlyArabic(actionDataValue)
                            ? pw.TextDirection.rtl
                            : pw.TextDirection.ltr,
                      ),
                    ),
                  ]),
                if (action.metaData != null && action.metaData!.isNotEmpty)
                  pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                    pw.Text(
                      'Details:',
                      style: pw.TextStyle(
                        font: boldFont,
                        fontSize: 16,
                        color: PdfColors.blue900,
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(left: 10),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: action.metaData!
                            .map((metaData) => pw.Text(
                                  ' ${FormatHelper.capitalizeFirstLetter(metaData)}',
                                  style: pw.TextStyle(font: font, fontSize: 14),
                                  textDirection: isPredominantlyArabic(FormatHelper.capitalizeFirstLetter(metaData))
                                      ? pw.TextDirection.rtl
                                      : pw.TextDirection.ltr,
                                ))
                            .toList(),
                      ),
                    ),
                  ]),
              ],
            ),
          ),
          if (showPrescriptionTable)
            pw.Container(
              margin: const pw.EdgeInsets.symmetric(vertical: 15),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Expanded(
                    child: pw.Container(
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.blue900),
                        borderRadius: pw.BorderRadius.circular(8),
                      ),
                      child: pw.Column(
                        children: [
                          pw.Container(
                            padding: const pw.EdgeInsets.all(5),
                            decoration: const pw.BoxDecoration(
                              color: PdfColors.blue100,
                              borderRadius: pw.BorderRadius.vertical(top: pw.Radius.circular(7)),
                            ),
                            child: pw.Center(
                              child: pw.Text(
                                'RIGHT',
                                style: pw.TextStyle(
                                  font: boldFont,
                                  color: PdfColors.blue900,
                                ),
                              ),
                            ),
                          ),
                          pw.Table(
                            border: pw.TableBorder.all(color: PdfColors.blue900),
                            children: [
                              pw.TableRow(
                                children: [
                                  pw.Container(),
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.all(4),
                                    child: pw.Text('SPH.', style: pw.TextStyle(font: boldFont)),
                                  ),
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.all(4),
                                    child: pw.Text('CYL.', style: pw.TextStyle(font: boldFont)),
                                  ),
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.all(4),
                                    child: pw.Text('AXIS', style: pw.TextStyle(font: boldFont)),
                                  ),
                                ],
                              ),
                              pw.TableRow(
                                children: [
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.all(4),
                                    child: pw.Text('F', style: pw.TextStyle(font: boldFont)),
                                  ),
                                  pw.Container(
                                    height: 20,
                                    child: pw.Center(
                                      child: pw.Text(FormatHelper.formatPositiveValue(
                                              examination.examination?.measurements[1]
                                                  .refinedRefractionSpherical) ??
                                          '-'),
                                    ),
                                  ),
                                  pw.Container(
                                    height: 20,
                                    child: pw.Center(
                                      child: pw.Text(FormatHelper.formatPositiveValue(
                                              examination.examination?.measurements[1].refinedRefractionCylindrical) ??
                                          '-'),
                                    ),
                                  ),
                                  pw.Container(
                                    height: 20,
                                    child: pw.Center(
                                      child: pw.Text(
                                          examination.examination?.measurements[1].refinedRefractionAxis ?? '-'),
                                    ),
                                  ),
                                ],
                              ),
                              // Four cells to match the header; the two right-hand
                              // ones stay blank in manual mode.
                              pw.TableRow(
                                children: [
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.all(4),
                                    child: pw.Text('N', style: pw.TextStyle(font: boldFont)),
                                  ),
                                  pw.Container(
                                    height: 20,
                                    child: pw.Center(
                                      child: pw.Text(rightNearVisionRow.spherical),
                                    ),
                                  ),
                                  pw.Container(
                                    height: 20,
                                    child: pw.Center(
                                      child: pw.Text(rightNearVisionRow.cylindrical),
                                    ),
                                  ),
                                  pw.Container(
                                    height: 20,
                                    child: pw.Center(
                                      child: pw.Text(rightNearVisionRow.axis),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 20),
                  pw.Expanded(
                    child: pw.Container(
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.blue900),
                        borderRadius: pw.BorderRadius.circular(8),
                      ),
                      child: pw.Column(
                        children: [
                          pw.Container(
                            padding: const pw.EdgeInsets.all(5),
                            decoration: const pw.BoxDecoration(
                              color: PdfColors.blue100,
                              borderRadius: pw.BorderRadius.vertical(top: pw.Radius.circular(7)),
                            ),
                            child: pw.Center(
                              child: pw.Text(
                                'LEFT',
                                style: pw.TextStyle(
                                  font: boldFont,
                                  color: PdfColors.blue900,
                                ),
                              ),
                            ),
                          ),
                          pw.Table(
                            border: pw.TableBorder.all(color: PdfColors.blue900),
                            children: [
                              pw.TableRow(
                                children: [
                                  pw.Container(),
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.all(4),
                                    child: pw.Text('SPH.', style: pw.TextStyle(font: boldFont)),
                                  ),
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.all(4),
                                    child: pw.Text('CYL.', style: pw.TextStyle(font: boldFont)),
                                  ),
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.all(4),
                                    child: pw.Text('AXIS', style: pw.TextStyle(font: boldFont)),
                                  ),
                                ],
                              ),
                              pw.TableRow(
                                children: [
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.all(4),
                                    child: pw.Text('F', style: pw.TextStyle(font: boldFont)),
                                  ),
                                  pw.Container(
                                    height: 20,
                                    child: pw.Center(
                                      child: pw.Text(FormatHelper.formatPositiveValue(
                                              examination.examination?.measurements[0]
                                                  .refinedRefractionSpherical) ??
                                          '-'),
                                    ),
                                  ),
                                  pw.Container(
                                    height: 20,
                                    child: pw.Center(
                                      child: pw.Text(FormatHelper.formatPositiveValue(
                                              examination.examination?.measurements[0].refinedRefractionCylindrical) ??
                                          '-'),
                                    ),
                                  ),
                                  pw.Container(
                                    height: 20,
                                    child: pw.Center(
                                      child: pw.Text(
                                          examination.examination?.measurements[0].refinedRefractionAxis ?? '-'),
                                    ),
                                  ),
                                ],
                              ),
                              pw.TableRow(
                                children: [
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.all(4),
                                    child: pw.Text('N', style: pw.TextStyle(font: boldFont)),
                                  ),
                                  pw.Container(
                                    height: 20,
                                    child: pw.Center(
                                      child: pw.Text(leftNearVisionRow.spherical),
                                    ),
                                  ),
                                  pw.Container(
                                    height: 20,
                                    child: pw.Center(
                                      child: pw.Text(leftNearVisionRow.cylindrical),
                                    ),
                                  ),
                                  pw.Container(
                                    height: 20,
                                    child: pw.Center(
                                      child: pw.Text(leftNearVisionRow.axis),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (action.action?.toLowerCase() == 'prescribe medications' &&
              prescriptionList != null &&
              prescriptionList.isNotEmpty)
            pw.Container(
              margin: const pw.EdgeInsets.symmetric(vertical: 15),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.blue900),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                children: [
                  pw.Container(
                    padding: const pw.EdgeInsets.all(10),
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.blue100,
                      borderRadius: pw.BorderRadius.vertical(top: pw.Radius.circular(7)),
                    ),
                    child: pw.Center(
                      child: pw.Text(
                        'Medications:',
                        style: pw.TextStyle(
                          font: boldFont,
                          fontSize: 16,
                          color: PdfColors.blue900,
                        ),
                      ),
                    ),
                  ),
                  pw.Table(
                    border: pw.TableBorder.all(color: PdfColors.blue900),
                    columnWidths: {
                      0: const pw.FlexColumnWidth(2),
                      1: const pw.FlexColumnWidth(1.5),
                      2: const pw.FlexColumnWidth(1.5),
                    },
                    children: [
                      // Header row
                      pw.TableRow(
                        decoration: const pw.BoxDecoration(color: PdfColors.blue50),
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                              'Name',
                              style: pw.TextStyle(font: boldFont, fontSize: 14),
                              textAlign: pw.TextAlign.center,
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                              'Dosage',
                              style: pw.TextStyle(font: boldFont, fontSize: 14),
                              textAlign: pw.TextAlign.center,
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                              'Duration',
                              style: pw.TextStyle(font: boldFont, fontSize: 14),
                              textAlign: pw.TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                      // Data rows
                      ...prescriptionList
                          .map(
                            (medication) => pw.TableRow(
                              children: [
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(8),
                                  child: pw.Text(
                                    FormatHelper.capitalizeFirstLetter(medication.name ?? ''),
                                    style: pw.TextStyle(font: font, fontSize: 12),
                                    textAlign: pw.TextAlign.center,
                                    textDirection: isPredominantlyArabic(medication.name ?? '')
                                        ? pw.TextDirection.rtl
                                        : pw.TextDirection.ltr,
                                  ),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(8),
                                  child: pw.Text(
                                    FormatHelper.capitalizeFirstLetter(medication.dosage ?? ''),
                                    style: pw.TextStyle(font: font, fontSize: 12),
                                    textAlign: pw.TextAlign.center,
                                    textDirection: isPredominantlyArabic(medication.dosage ?? '')
                                        ? pw.TextDirection.rtl
                                        : pw.TextDirection.ltr,
                                  ),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(8),
                                  child: pw.Text(
                                    FormatHelper.capitalizeFirstLetter(medication.duration ?? ''),
                                    style: pw.TextStyle(font: font, fontSize: 12),
                                    textAlign: pw.TextAlign.center,
                                    textDirection: isPredominantlyArabic(medication.duration ?? '')
                                        ? pw.TextDirection.rtl
                                        : pw.TextDirection.ltr,
                                  ),
                                ),
                              ],
                            ),
                          )
                          .toList(),
                    ],
                  ),
                ],
              ),
            ),
          if (selectedExaminationValues.isNotEmpty)
            _buildExaminationValuesSection(
              values: selectedExaminationValues,
              font: font,
              boldFont: boldFont,
            ),
        ];
      },
    ),
  );

  if (analysis != null && selectedChartKeys != null && eyeSelection != null) {
    await AnalysisPdfService.addAnalysisPagesToDocument(
      pdf: pdf,
      analysis: analysis,
      selectedChartKeys: selectedChartKeys,
      eyeSelection: eyeSelection,
    );
  }

  // Print the document
  await Printing.layoutPdf(
    onLayout: (PdfPageFormat format) async => pdf.save(),
  );
}

/// Selected examination readings, grouped by eye and measurement group so the
/// printout reads the way the examination form does.
pw.Widget _buildExaminationValuesSection({
  required List<ResolvedPrintableField> values,
  required pw.Font font,
  required pw.Font boldFont,
}) {
  final groupHeadings = <String>[];
  final grouped = <String, List<ResolvedPrintableField>>{};

  for (final value in values) {
    final heading = '${value.eye} Eye - ${value.group}';
    if (!grouped.containsKey(heading)) {
      grouped[heading] = [];
      groupHeadings.add(heading);
    }
    grouped[heading]!.add(value);
  }

  return pw.Container(
    margin: const pw.EdgeInsets.only(top: 15),
    padding: const pw.EdgeInsets.all(15),
    width: double.infinity,
    decoration: pw.BoxDecoration(
      borderRadius: pw.BorderRadius.circular(10),
      border: pw.Border.all(color: PdfColors.grey300),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Examination Values:',
          style: pw.TextStyle(
            font: boldFont,
            fontSize: 16,
            color: PdfColors.blue900,
          ),
        ),
        pw.SizedBox(height: 8),
        for (final heading in groupHeadings) ...[
          pw.SizedBox(height: 6),
          pw.Text(
            heading,
            style: pw.TextStyle(
              font: boldFont,
              fontSize: 12,
              color: PdfColors.blue900,
            ),
          ),
          pw.SizedBox(height: 4),
          for (final field in grouped[heading]!)
            pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 3),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    field.label,
                    style: pw.TextStyle(
                      font: font,
                      fontSize: 12,
                      color: PdfColors.grey700,
                    ),
                  ),
                  pw.Text(
                    field.value,
                    style: pw.TextStyle(font: boldFont, fontSize: 12),
                  ),
                ],
              ),
            ),
        ],
      ],
    ),
  );
}

bool isPredominantlyArabic(String text) {
  int arabicCount = 0;
  int otherCount = 0;

  for (int i = 0; i < text.length; i++) {
    int charCode = text.codeUnitAt(i);
    if (charCode >= 0x0600 && charCode <= 0x06FF) {
      arabicCount++;
    } else if (charCode > 32) {
      otherCount++;
    }
  }

  return arabicCount > otherCount;
}
