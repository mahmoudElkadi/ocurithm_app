import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../../../data/models/analysis_model.dart' as model;
import 'analysis_view_body.dart';

class AnalysisPdfService {
  static Future<void> generateAndPrintAnalysis({
    required model.AnalysisModel analysis,
    required Set<String> selectedChartKeys,
    required EyeSelection eyeSelection,
  }) async {
    final pdf = pw.Document();

    final regularFontData =
        await rootBundle.load("assets/fonts/Cairo-Regular.ttf");
    final boldFontData = await rootBundle.load("assets/fonts/Cairo-Bold.ttf");
    final font = pw.Font.ttf(regularFontData);
    final boldFont = pw.Font.ttf(boldFontData);

    final logoData = await rootBundle.load('assets/icons/logo.png');
    final logoBytes = logoData.buffer.asUint8List();

    // Prepare charts to be printed
    final chartsToPrint = _getChartsToPrint(analysis, selectedChartKeys);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (pw.Context context) =>
            _buildHeader(analysis, logoBytes, font, boldFont),
        footer: (pw.Context context) => _buildFooter(context, font),
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text('Patient Trend Analysis Report',
                  style: pw.TextStyle(
                      font: boldFont, fontSize: 18, color: PdfColors.blue900)),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              'This report shows the visual health trends for ${analysis.patientName ?? 'Patient'}. '
              'Generated on ${DateFormat('dd MMM yyyy HH:mm').format(DateTime.now())}.',
              style: pw.TextStyle(
                  font: font, fontSize: 12, color: PdfColors.grey700),
            ),
            pw.SizedBox(height: 20),
            ...chartsToPrint
                .map((chart) =>
                    _buildPdfChart(chart, eyeSelection, font, boldFont))
                .toList(),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name:
          'Analysis_${analysis.patientName}_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf',
    );
  }

  static Future<void> addAnalysisPagesToDocument({
    required pw.Document pdf,
    required model.AnalysisModel analysis,
    required Set<String> selectedChartKeys,
    required EyeSelection eyeSelection,
  }) async {
    final regularFontData =
        await rootBundle.load("assets/fonts/Cairo-Regular.ttf");
    final boldFontData = await rootBundle.load("assets/fonts/Cairo-Bold.ttf");
    final font = pw.Font.ttf(regularFontData);
    final boldFont = pw.Font.ttf(boldFontData);

    final logoData = await rootBundle.load('assets/icons/logo.png');
    final logoBytes = logoData.buffer.asUint8List();

    // Prepare charts to be printed
    final chartsToPrint = _getChartsToPrint(analysis, selectedChartKeys);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (pw.Context context) =>
            _buildHeader(analysis, logoBytes, font, boldFont),
        footer: (pw.Context context) => _buildFooter(context, font),
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text('Patient Trend Analysis Report',
                  style: pw.TextStyle(
                      font: boldFont, fontSize: 18, color: PdfColors.blue900)),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              'This report shows the visual health trends for ${analysis.patientName ?? 'Patient'}. '
              'Generated on ${DateFormat('dd MMM yyyy HH:mm').format(DateTime.now())}.',
              style: pw.TextStyle(
                  font: font, fontSize: 12, color: PdfColors.grey700),
            ),
            pw.SizedBox(height: 20),
            ...chartsToPrint
                .map((chart) =>
                    _buildPdfChart(chart, eyeSelection, font, boldFont))
                .toList(),
          ];
        },
      ),
    );
  }

  static List<_PrintableChartData> _getChartsToPrint(
      model.AnalysisModel analysis, Set<String> keys) {
    final List<_PrintableChartData> results = [];
    final trends = analysis.trends;
    if (trends == null) return results;

    // Autorefraction
    if (trends.autoRefraction != null) {
      if (keys.contains('auto_spherical') &&
          trends.autoRefraction!.spherical != null) {
        results.add(_PrintableChartData(
          title: 'Autorefraction - Spherical',
          axis: trends.autoRefraction!.spherical!,
          defaultMinY: -25,
          defaultMaxY: 20,
        ));
      }
      if (keys.contains('auto_cylindrical') &&
          trends.autoRefraction!.cylindrical != null) {
        results.add(_PrintableChartData(
          title: 'Autorefraction - Cylindrical',
          axis: trends.autoRefraction!.cylindrical!,
          defaultMinY: -25,
          defaultMaxY: 20,
        ));
      }
      if (keys.contains('auto_axis') && trends.autoRefraction!.axis != null) {
        results.add(_PrintableChartData(
          title: 'Autorefraction - Axis',
          axis: trends.autoRefraction!.axis!,
          defaultMinY: 0,
          defaultMaxY: 180,
        ));
      }
    }

    // Refined Refraction
    if (trends.refinedRefraction != null) {
      if (keys.contains('refined_spherical') &&
          trends.refinedRefraction!.spherical != null) {
        results.add(_PrintableChartData(
          title: 'Refined Refraction - Spherical',
          axis: trends.refinedRefraction!.spherical!,
          defaultMinY: -25,
          defaultMaxY: 20,
        ));
      }
      if (keys.contains('refined_cylindrical') &&
          trends.refinedRefraction!.cylindrical != null) {
        results.add(_PrintableChartData(
          title: 'Refined Refraction - Cylindrical',
          axis: trends.refinedRefraction!.cylindrical!,
          defaultMinY: -25,
          defaultMaxY: 20,
        ));
      }
      if (keys.contains('refined_axis') &&
          trends.refinedRefraction!.axis != null) {
        results.add(_PrintableChartData(
          title: 'Refined Refraction - Axis',
          axis: trends.refinedRefraction!.axis!,
          defaultMinY: 0,
          defaultMaxY: 180,
        ));
      }
    }

    // Near Vision
    if (trends.nearVision != null) {
      if (keys.contains('near_vision') && trends.nearVision!.addition != null) {
        results.add(_PrintableChartData(
          title: 'Near Vision - Addition',
          axis: trends.nearVision!.addition!,
          defaultMinY: 0,
          defaultMaxY: 10,
        ));
      }
    }

    // IOP
    if (trends.iop != null) {
      if (keys.contains('iop_primary') && trends.iop!.primary != null) {
        results.add(_PrintableChartData(
          title: 'IOP',
          axis: trends.iop!.primary!,
          defaultMinY: 0,
          defaultMaxY: 70,
        ));
      }
      if (keys.contains('iop_secondary') && trends.iop!.secondary != null) {
        results.add(_PrintableChartData(
          title: 'IOP Measurement',
          axis: trends.iop!.secondary!,
          defaultMinY: 0,
          defaultMaxY: 70,
        ));
      }
    }

    return results;
  }

  static pw.Widget _buildHeader(model.AnalysisModel analysis,
      Uint8List logoBytes, pw.Font font, pw.Font boldFont) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 20),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
            bottom: pw.BorderSide(color: PdfColors.blue900, width: 2)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Ocurithm Analysis Report',
                  style: pw.TextStyle(
                      font: boldFont, fontSize: 24, color: PdfColors.blue900)),
              pw.SizedBox(height: 4),
              pw.Text('Comprehensive Eye Health Tracking',
                  style: pw.TextStyle(
                      font: font, fontSize: 12, color: PdfColors.grey600)),
            ],
          ),
          pw.Image(pw.MemoryImage(logoBytes), width: 60),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter(pw.Context context, pw.Font font) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(top: 20),
      child: pw.Text(
        'Page ${context.pageNumber} of ${context.pagesCount}',
        style: pw.TextStyle(font: font, fontSize: 10, color: PdfColors.grey500),
      ),
    );
  }

  static pw.Widget _buildPdfChart(_PrintableChartData chartData,
      EyeSelection eyeSelection, pw.Font font, pw.Font boldFont) {
    // Recreate the data spots like in the UI
    List<DateTime> allDates = [];
    for (var m in chartData.axis.left) {
      if (m.date != null) allDates.add(m.date!);
    }
    for (var m in chartData.axis.right) {
      if (m.date != null) allDates.add(m.date!);
    }

    if (allDates.isEmpty) return pw.SizedBox.shrink();

    DateTime minDate = allDates.reduce((a, b) => a.isBefore(b) ? a : b);
    DateTime maxDate = allDates.reduce((a, b) => a.isAfter(b) ? a : b);

    if (maxDate.difference(minDate).inDays < 7) {
      minDate = minDate.subtract(const Duration(days: 3));
      maxDate = maxDate.add(const Duration(days: 3));
    }

    final totalDays = maxDate.difference(minDate).inDays.toDouble();

    // Data points for Left Eye
    final leftPoints = chartData.axis.left
        .where((m) => m.date != null && m.value != null)
        .map((m) => pw.PointChartValue(
              m.date!.difference(minDate).inDays.toDouble(),
              m.value!.toDouble(),
            ))
        .toList()
      ..sort((a, b) => a.x.compareTo(b.x));

    // Data points for Right Eye
    final rightPoints = chartData.axis.right
        .where((m) => m.date != null && m.value != null)
        .map((m) => pw.PointChartValue(
              m.date!.difference(minDate).inDays.toDouble(),
              m.value!.toDouble(),
            ))
        .toList()
      ..sort((a, b) => a.x.compareTo(b.x));

    // Calculate Y bounds
    List<num> allValues = [
      ...chartData.axis.left.map((m) => m.value ?? 0),
      ...chartData.axis.right.map((m) => m.value ?? 0),
    ];

    double minY = chartData.defaultMinY;
    double maxY = chartData.defaultMaxY;

    if (allValues.isNotEmpty) {
      double dataMin = allValues.reduce((a, b) => a < b ? a : b).toDouble();
      double dataMax = allValues.reduce((a, b) => a > b ? a : b).toDouble();
      double padding = (dataMax - dataMin) * 0.2;
      if (padding == 0) padding = 1.0;
      minY = math.min(chartData.defaultMinY, dataMin - padding).floorToDouble();
      maxY = math.max(chartData.defaultMaxY, dataMax + padding).ceilToDouble();
    }

    List<pw.Dataset> datasets = [];
    if (eyeSelection == EyeSelection.both ||
        eyeSelection == EyeSelection.left) {
      if (leftPoints.isNotEmpty) {
        datasets.add(pw.LineDataSet(
          pointColor: PdfColors.blue700,
          color: PdfColors.blue700,
          data: leftPoints,
          pointSize: 3,
          drawPoints: true,
          drawLine: true,
        ));
      }
    }
    if (eyeSelection == EyeSelection.both ||
        eyeSelection == EyeSelection.right) {
      if (rightPoints.isNotEmpty) {
        datasets.add(pw.LineDataSet(
          pointColor: PdfColors.red700,
          color: PdfColors.red700,
          data: rightPoints,
          pointSize: 3,
          drawPoints: true,
          drawLine: true,
        ));
      }
    }

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 30),
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(chartData.title,
              style: pw.TextStyle(
                  font: boldFont, fontSize: 14, color: PdfColors.blue800)),
          pw.SizedBox(height: 10),
          pw.SizedBox(
            height: 200,
            child: pw.Chart(
              grid: pw.CartesianGrid(
                xAxis: pw.FixedAxis(
                  _generateIntervals(0, totalDays, 5),
                  buildLabel: (value) {
                    final date = minDate.add(Duration(days: value.toInt()));
                    return pw.Text(DateFormat('dd/MM').format(date),
                        style: const pw.TextStyle(fontSize: 8));
                  },
                ),
                yAxis: pw.FixedAxis(
                  _generateIntervals(minY, maxY, 6),
                  buildLabel: (value) => pw.Text(value.toStringAsFixed(1),
                      style: const pw.TextStyle(fontSize: 8)),
                ),
              ),
              datasets: datasets,
            ),
          ),
          pw.SizedBox(height: 10),
          _buildLegend(eyeSelection, font),
        ],
      ),
    );
  }

  static List<double> _generateIntervals(double min, double max, int count) {
    if (max <= min) return [min];
    List<double> intervals = [];
    double step = (max - min) / count;
    for (int i = 0; i <= count; i++) {
      intervals.add(min + (step * i));
    }
    return intervals;
  }

  static pw.Widget _buildLegend(EyeSelection selection, pw.Font font) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.center,
      children: [
        if (selection == EyeSelection.both || selection == EyeSelection.left)
          _legendItem('Left Eye', PdfColors.blue700, font),
        if (selection == EyeSelection.both) pw.SizedBox(width: 20),
        if (selection == EyeSelection.both || selection == EyeSelection.right)
          _legendItem('Right Eye', PdfColors.red700, font),
      ],
    );
  }

  static pw.Widget _legendItem(String label, PdfColor color, pw.Font font) {
    return pw.Row(
      children: [
        pw.Container(width: 10, height: 10, color: color),
        pw.SizedBox(width: 5),
        pw.Text(label, style: pw.TextStyle(font: font, fontSize: 10)),
      ],
    );
  }
}

class _PrintableChartData {
  final String title;
  final model.Axis axis;
  final double defaultMinY;
  final double defaultMaxY;

  _PrintableChartData({
    required this.title,
    required this.axis,
    required this.defaultMinY,
    required this.defaultMaxY,
  });
}
