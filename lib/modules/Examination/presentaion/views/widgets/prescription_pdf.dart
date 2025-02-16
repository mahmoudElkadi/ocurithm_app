import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../../../core/utils/format_helper.dart';
import '../../../../Patient/data/model/one_exam.dart';

Future<void> generateAndPrintPrescription(
    {required ExaminationModel examination, required Action action, String? diagnosis, bool showPrescriptionTable = false}) async {
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
                    textDirection:
                        isPredominantlyArabic(examination.examination?.patient?.clinic?.name ?? "N/A") ? pw.TextDirection.rtl : pw.TextDirection.ltr,
                  ),
                  pw.SizedBox(height: 5),
                  pw.Text(
                    'Dr. ${examination.doctor?.name ?? ""}',
                    style: pw.TextStyle(
                      font: font,
                      fontSize: 16,
                      color: PdfColors.blue800,
                    ),
                    textDirection: isPredominantlyArabic(examination.doctor?.name ?? "N/A") ? pw.TextDirection.rtl : pw.TextDirection.ltr,
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
                    textDirection:
                        isPredominantlyArabic(examination.examination?.patient?.name ?? "N/A") ? pw.TextDirection.rtl : pw.TextDirection.ltr,
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
                  textDirection: isPredominantlyArabic(examination.finalization?.diagnosis ?? "N/A") ? pw.TextDirection.rtl : pw.TextDirection.ltr,
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
                  textDirection: isPredominantlyArabic(action.action ?? "N/A") ? pw.TextDirection.rtl : pw.TextDirection.ltr,
                ),
                if (action.data != null && action.data!.isNotEmpty)
                  pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
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
                        action.data ?? '',
                        style: pw.TextStyle(font: font, fontSize: 14),
                        textDirection: isPredominantlyArabic("examination.finalization?.data" ?? "N/A") ? pw.TextDirection.rtl : pw.TextDirection.ltr,
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
                                      child: pw.Text(examination.examination?.measurements[1].refinedRefractionSpherical ?? '-'),
                                    ),
                                  ),
                                  pw.Container(
                                    height: 20,
                                    child: pw.Center(
                                      child: pw.Text(examination.examination?.measurements[1].refinedRefractionCylindrical ?? '-'),
                                    ),
                                  ),
                                  pw.Container(
                                    height: 20,
                                    child: pw.Center(
                                      child: pw.Text(examination.examination?.measurements[1].refinedRefractionAxis ?? '-'),
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
                                      child: pw.Text(examination.examination?.measurements[1].nearVisionAddition ?? '-'),
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
                                      child: pw.Text(examination.examination?.measurements[0].refinedRefractionSpherical ?? '-'),
                                    ),
                                  ),
                                  pw.Container(
                                    height: 20,
                                    child: pw.Center(
                                      child: pw.Text(examination.examination?.measurements[0].refinedRefractionCylindrical ?? '-'),
                                    ),
                                  ),
                                  pw.Container(
                                    height: 20,
                                    child: pw.Center(
                                      child: pw.Text(examination.examination?.measurements[0].refinedRefractionAxis ?? '-'),
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
                                      child: pw.Text(examination.examination?.measurements[0].nearVisionAddition ?? '-'),
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
        ];
      },
    ),
  );

  // Print the document
  await Printing.layoutPdf(
    onLayout: (PdfPageFormat format) async => pdf.save(),
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
