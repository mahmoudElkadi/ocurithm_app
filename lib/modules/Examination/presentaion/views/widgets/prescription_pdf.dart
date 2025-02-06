import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../../../core/utils/format_helper.dart';
import '../../../../Patient/data/model/one_exam.dart';

Future<void> generateAndPrintPrescription(ExaminationModel examination, {bool showPrescriptionTable = false}) async {
  final pdf = pw.Document();

  // Load custom font (optional)
  final font = await PdfGoogleFonts.nunitoRegular();
  final boldFont = await PdfGoogleFonts.nunitoBold();
  final logoData = await rootBundle.load('assets/icons/logo.png');
  final logoBytes = logoData.buffer.asUint8List();

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Container(
          padding: const pw.EdgeInsets.all(20),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Container(
                padding: const pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue50,
                  borderRadius: pw.BorderRadius.circular(10),
                  border: pw.Border.all(color: PdfColors.blue200),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    // Clinic Info
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
                        ),
                        pw.SizedBox(height: 5),
                        pw.Text(
                          'Dr. ${examination.doctor?.name ?? ""}',
                          style: pw.TextStyle(
                            font: font,
                            fontSize: 16,
                            color: PdfColors.blue800,
                          ),
                        ),
                        pw.SizedBox(height: 3),
                        pw.Text(
                          'Phone: ${examination.doctor?.phone ?? ""}',
                          style: pw.TextStyle(font: font, fontSize: 12),
                        ),
                      ],
                    ),
                    // Logo placeholder
                    pw.Container(
                      width: 80,
                      height: 80,
                      decoration: pw.BoxDecoration(
                        shape: pw.BoxShape.circle,
                        color: PdfColors.blue100,
                      ),
                      child: pw.Center(
                        child: pw.Image(pw.MemoryImage(logoBytes), width: 100),
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 30),

              // Prescription Details
              pw.Container(
                padding: const pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  borderRadius: pw.BorderRadius.circular(10),
                  border: pw.Border.all(color: PdfColors.grey300),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Date
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

                    // Finalization Details
                    pw.Text(
                      'Diagnosis:',
                      style: pw.TextStyle(
                        font: boldFont,
                        fontSize: 16,
                        color: PdfColors.blue900,
                      ),
                    ),
                    pw.Text(
                      examination.finalization?.diagnosis ?? "",
                      style: pw.TextStyle(font: font, fontSize: 14),
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
                      examination.finalization?.action ?? "",
                      style: pw.TextStyle(font: font, fontSize: 16),
                    ),
                    if (examination.finalization?.data != null && examination.finalization!.data!.isNotEmpty)
                      pw.Column(children: [
                        pw.Text(
                          'Information:',
                          style: pw.TextStyle(
                            font: boldFont,
                            fontSize: 16,
                            color: PdfColors.blue900,
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.only(left: 10),
                          child: pw.Text(
                            examination.finalization?.data ?? '',
                            style: pw.TextStyle(font: font, fontSize: 14),
                          ),
                        ),
                      ]),

                    if (examination.finalization?.metaData != null && examination.finalization!.metaData!.isNotEmpty)
                      pw.Column(children: [
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
                            child: pw.Wrap(
                                spacing: 5,
                                children: examination.finalization!.metaData!
                                    .map((metaData) => pw.Text(
                                          ' ${FormatHelper.capitalizeFirstLetter(metaData)}',
                                          style: pw.TextStyle(font: font, fontSize: 14),
                                        ))
                                    .toList()))
                      ]),

                    // pw.ListView.builder(
                    //   itemCount: examination.finalization?.metaData?.length ?? 0,
                    //   itemBuilder: (context, index) {
                    //     return pw.Wrap(
                    //       ' ${examination.finalization?.metaData?[index] ?? ""}',
                    //       style: pw.TextStyle(font: font, fontSize: 14),
                    //     );
                    //   },
                    // )
                  ],
                ),
              ),

              if (showPrescriptionTable)
                pw.Container(
                  margin: const pw.EdgeInsets.symmetric(vertical: 15),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      // RIGHT EYE
                      pw.Expanded(
                          child: pw.Container(
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: PdfColors.blue900),
                          borderRadius: pw.BorderRadius.circular(8),
                        ),
                        child: pw.Column(
                          children: [
                            // Header
                            pw.Container(
                              padding: const pw.EdgeInsets.all(5),
                              decoration: pw.BoxDecoration(
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
                            // Table
                            pw.Table(
                              border: pw.TableBorder.all(color: PdfColors.blue900),
                              children: [
                                // Headers
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
                                // Far vision row
                                pw.TableRow(
                                  children: [
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(4),
                                      child: pw.Text('F', style: pw.TextStyle(font: boldFont)),
                                    ),
                                    pw.Container(
                                        height: 20,
                                        child: pw.Center(
                                            child: pw.Text(examination.examination?.measurements[1].refinedRefractionSpherical ??
                                                '-'))), //pw.Container(height: 20, child: pw.Text("text")) pw.Text("text1")),
                                    pw.Container(
                                        height: 20,
                                        child:
                                            pw.Center(child: pw.Text(examination.examination?.measurements[1].refinedRefractionCylindrical ?? '-'))),
                                    pw.Container(
                                        height: 20,
                                        child: pw.Center(child: pw.Text(examination.examination?.measurements[1].refinedRefractionAxis ?? '-'))),
                                  ],
                                ),
                                // Near vision row
                                pw.TableRow(
                                  children: [
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(4),
                                      child: pw.Text('N', style: pw.TextStyle(font: boldFont)),
                                    ),
                                    pw.Container(
                                        height: 20,
                                        child: pw.Center(child: pw.Text(examination.examination?.measurements[1].nearVisionAddition ?? '-'))),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      )),
                      pw.SizedBox(width: 20),
                      // LEFT EYE
                      pw.Expanded(
                          child: pw.Container(
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: PdfColors.blue900),
                          borderRadius: pw.BorderRadius.circular(8),
                        ),
                        child: pw.Column(
                          children: [
                            // Header
                            pw.Container(
                              padding: const pw.EdgeInsets.all(5),
                              decoration: pw.BoxDecoration(
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
                            // Table
                            pw.Table(
                              border: pw.TableBorder.all(color: PdfColors.blue900),
                              children: [
                                // Headers
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
                                // Far vision row
                                pw.TableRow(
                                  children: [
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(4),
                                      child: pw.Text('F', style: pw.TextStyle(font: boldFont)),
                                    ),
                                    pw.Container(
                                        height: 20,
                                        child: pw.Center(
                                            child: pw.Text(examination.examination?.measurements[0].refinedRefractionSpherical ??
                                                '-'))), //pw.Container(height: 20, child: pw.Text("text")) pw.Text("text1")),
                                    pw.Container(
                                        height: 20,
                                        child:
                                            pw.Center(child: pw.Text(examination.examination?.measurements[0].refinedRefractionCylindrical ?? '-'))),
                                    pw.Container(
                                        height: 20,
                                        child: pw.Center(child: pw.Text(examination.examination?.measurements[0].refinedRefractionAxis ?? '-'))),
                                  ],
                                ),
                                // Near vision row
                                pw.TableRow(
                                  children: [
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(4),
                                      child: pw.Text('N', style: pw.TextStyle(font: boldFont)),
                                    ),
                                    pw.Container(
                                        height: 20,
                                        child: pw.Center(child: pw.Text(examination.examination?.measurements[0].nearVisionAddition ?? '-'))),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      )),
                    ],
                  ),
                ),
              pw.Spacer(),
              // Footer with patient info
              pw.Container(
                padding: const pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: pw.BorderRadius.circular(10),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    // Patient Info
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
                        ),
                        pw.Text(
                          'ID: ${examination.examination?.patient?.serialNumber ?? ""}',
                          style: pw.TextStyle(font: font, fontSize: 12),
                        ),
                      ],
                    ),
                    // Doctor's Signature placeholder
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
                          decoration: pw.BoxDecoration(
                            border: pw.Border(
                              top: pw.BorderSide(color: PdfColors.grey400),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    ),
  );

  // Print the document
  await Printing.layoutPdf(
    onLayout: (PdfPageFormat format) async => pdf.save(),
  );
}
