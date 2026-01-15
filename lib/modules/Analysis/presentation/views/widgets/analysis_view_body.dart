import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

enum EyeSelection { left, right, both }

class AnalysisViewBody extends StatefulWidget {
  final EyeSelection selectedEye;

  const AnalysisViewBody({
    super.key,
    required this.selectedEye,
  });

  @override
  State<AnalysisViewBody> createState() => _AnalysisViewBodyState();
}

class _AnalysisViewBodyState extends State<AnalysisViewBody> {
  // Track which sections are expanded - all sections open by default
  final Set<String> _expandedSections = {
    'autorefraction',
    'refined_refraction',
    'visual_acuity',
    'iop',
  };

  // Helper to generate a date N days ago
  DateTime _daysAgo(int days) {
    return DateTime.now().subtract(Duration(days: days));
  }

  // Sample data generator - generates a point for every day in the range
  List<FlSpot> _generateSampleData(
      int seed, double min, double max, DateTime minDate, DateTime maxDate) {
    int totalDays = maxDate.difference(minDate).inDays;
    if (totalDays <= 0) totalDays = 1;

    return List.generate(totalDays + 1, (index) {
      // Create some realistic-looking variations
      double range = max - min;
      double randomNoise = ((seed * index * 13) % 100) / 100.0; // Pseudo-random

      double value = min +
          (range * 0.5) +
          (range * 0.3 * math.sin(index * 0.2)) + // Wave pattern
          (range * 0.2 * (randomNoise - 0.5)); // Random jitter

      return FlSpot(index.toDouble(), value.clamp(min, max));
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section 1: Autorefraction
          _buildExpandableSection(
            context: context,
            sectionKey: 'autorefraction',
            sectionTitle: 'Autorefraction',
            charts: [
              _buildChartConfig(
                title: 'Spherical',
                seed: 1,
                minY: -10,
                maxY: 6,
                minDate: _daysAgo(90),
                maxDate: _daysAgo(0),
              ),
              _buildChartConfig(
                title: 'Cylindrical',
                seed: 3,
                minY: -6,
                maxY: 0.5,
                minDate: _daysAgo(60),
                maxDate: _daysAgo(0),
              ),
              _buildChartConfig(
                title: 'Axis',
                seed: 5,
                minY: 0,
                maxY: 200,
                minDate: _daysAgo(14),
                maxDate: _daysAgo(0),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Section 2: Refined Refraction
          _buildExpandableSection(
            context: context,
            sectionKey: 'refined_refraction',
            sectionTitle: 'Refined Refraction',
            charts: [
              _buildChartConfig(
                title: 'Spherical',
                seed: 7,
                minY: -12,
                maxY: 7,
                minDate: _daysAgo(90),
                maxDate: _daysAgo(0),
              ),
              _buildChartConfig(
                title: 'Cylindrical',
                seed: 9,
                minY: -5,
                maxY: 0.5,
                minDate: _daysAgo(45),
                maxDate: _daysAgo(0),
              ),
              _buildChartConfig(
                title: 'Axis',
                seed: 11,
                minY: 0,
                maxY: 180,
                minDate: _daysAgo(10),
                maxDate: _daysAgo(0),
              ),
              _buildChartConfig(
                title: 'Near Vision Addition',
                seed: 13,
                minY: 0,
                maxY: 4.0,
                minDate: _daysAgo(180),
                maxDate: _daysAgo(0),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Section 3: Visual Acuity
          _buildExpandableSection(
            context: context,
            sectionKey: 'visual_acuity',
            sectionTitle: 'Visual Acuity',
            charts: [
              _buildChartConfig(
                title: 'UCVA',
                seed: 15,
                minY: 0.0,
                maxY: 1.0,
                minDate: _daysAgo(7),
                maxDate: _daysAgo(0),
              ),
              _buildChartConfig(
                title: 'BCVA',
                seed: 17,
                minY: 0.0,
                maxY: 1.2,
                minDate: _daysAgo(7),
                maxDate: _daysAgo(0),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Section 4: IOP (mmHg)
          _buildExpandableSection(
            context: context,
            sectionKey: 'iop',
            sectionTitle: 'IOP (mmHg)',
            charts: [
              _buildChartConfig(
                title: 'IOP',
                seed: 19,
                minY: 8,
                maxY: 30,
                minDate: _daysAgo(20),
                maxDate: _daysAgo(0),
              ),
              _buildChartConfig(
                title: 'IOP Measurement',
                seed: 21,
                minY: 8,
                maxY: 30,
                minDate: _daysAgo(5),
                maxDate: _daysAgo(0),
              ),
            ],
          ),
        ],
      ),
    );
  }

  ChartConfig _buildChartConfig({
    required String title,
    required int seed,
    required double minY,
    required double maxY,
    required DateTime minDate,
    required DateTime maxDate,
  }) {
    // Determine data range (slightly inside min/max Y for aesthetics)
    double range = maxY - minY;
    double dataMin = minY + (range * 0.2);
    double dataMax = maxY - (range * 0.2);

    return ChartConfig(
      title: title,
      dataLeft: _generateSampleData(seed, dataMin, dataMax, minDate, maxDate),
      dataRight:
          _generateSampleData(seed + 1, dataMin, dataMax, minDate, maxDate),
      minY: minY,
      maxY: maxY,
      minDate: minDate,
      maxDate: maxDate,
    );
  }

  Widget _buildExpandableSection({
    required BuildContext context,
    required String sectionKey,
    required String sectionTitle,
    required List<ChartConfig> charts,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final cardColor = isDark ? Colors.grey[850] : Colors.white;
    final isExpanded = _expandedSections.contains(sectionKey);

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Section Header (Always visible)
          InkWell(
            onTap: () {
              setState(() {
                if (isExpanded) {
                  _expandedSections.remove(sectionKey);
                } else {
                  _expandedSections.add(sectionKey);
                }
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    sectionTitle,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: textColor,
                  ),
                ],
              ),
            ),
          ),

          // Expandable Content
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: Column(
                children: charts
                    .map((chartConfig) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: ChartCard(
                            config: chartConfig,
                            selectedEye: widget.selectedEye,
                          ),
                        ))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}

class ChartConfig {
  final String title;
  final List<FlSpot> dataLeft;
  final List<FlSpot> dataRight;
  final double minY;
  final double maxY;
  final DateTime minDate;
  final DateTime maxDate;

  ChartConfig({
    required this.title,
    required this.dataLeft,
    required this.dataRight,
    required this.minY,
    required this.maxY,
    required this.minDate,
    required this.maxDate,
  });
}

class ChartCard extends StatefulWidget {
  final ChartConfig config;
  final EyeSelection selectedEye;

  const ChartCard({
    super.key,
    required this.config,
    required this.selectedEye,
  });

  @override
  State<ChartCard> createState() => _ChartCardState();
}

class _ChartCardState extends State<ChartCard> {
  // Clamp data values to be within min/max bounds
  List<FlSpot> _clampData(List<FlSpot> data) {
    return data.map((spot) {
      double clampedY = spot.y.clamp(widget.config.minY, widget.config.maxY);
      return FlSpot(spot.x, clampedY);
    }).toList();
  }

  // Calculate dynamic Y-axis interval based on range
  double _calculateYInterval() {
    double range = widget.config.maxY - widget.config.minY;
    if (range <= 10) return 1;
    if (range <= 20) return 2;
    if (range <= 50) return 5;
    if (range <= 100) return 10;
    if (range <= 200) return 20;
    if (range <= 500) return 50;
    if (range <= 1000) return 100;
    return 200;
  }

  String _formatDate(double value) {
    int daysOffset = value.toInt();
    // Safety check just in case
    if (daysOffset < 0) daysOffset = 0;

    DateTime date = widget.config.minDate.add(Duration(days: daysOffset));
    return DateFormat('dd/MM', 'en').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final cardColor = isDark ? Colors.grey[800] : Colors.grey[50];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chart title
          Text(
            '${widget.config.title} - ${_getChartSubtitle()}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 250,
            child: _buildChart(isDark),
          ),
          const SizedBox(height: 12),
          _buildLegend(isDark),
        ],
      ),
    );
  }

  Widget _buildChart(bool isDark) {
    final yInterval = _calculateYInterval();
    final totalDays = widget.config.maxDate
        .difference(widget.config.minDate)
        .inDays
        .toDouble();
    // Calculate interval to show roughly 6-7 labels
    double xInterval = (totalDays / 6).ceilToDouble();
    if (xInterval < 1) xInterval = 1;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: yInterval,
          verticalInterval: xInterval,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
              strokeWidth: 0.5,
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
              strokeWidth: 0.5,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: xInterval,
              getTitlesWidget: (value, meta) {
                final style = TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white70 : Colors.black87,
                );

                // Show label only if within range
                if (value < 0 || value > totalDays) {
                  return const SizedBox.shrink();
                }

                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(_formatDate(value), style: style),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: yInterval,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                final style = TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white70 : Colors.black87,
                );
                return Text(
                  value.toInt().toString(),
                  style: style,
                  textAlign: TextAlign.left,
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(
            color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
            width: 0.5,
          ),
        ),
        minX: 0,
        maxX: totalDays,
        minY: widget.config.minY,
        maxY: widget.config.maxY,
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (touchedSpot) =>
                isDark ? Colors.grey[800]! : Colors.white,
            tooltipRoundedRadius: 8,
            tooltipPadding: const EdgeInsets.all(8),
            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
              return touchedBarSpots.map((barSpot) {
                final flSpot = barSpot;
                String eyeLabel = '';
                Color color = Colors.blue;

                if (widget.selectedEye == EyeSelection.both) {
                  if (barSpot.barIndex == 0) {
                    eyeLabel = 'Left Eye';
                    color = Colors.blue;
                  } else {
                    eyeLabel = 'Right Eye';
                    color = Colors.red;
                  }
                } else if (widget.selectedEye == EyeSelection.left) {
                  eyeLabel = 'Left Eye';
                  color = Colors.blue;
                } else {
                  eyeLabel = 'Right Eye';
                  color = Colors.red;
                }

                String dateStr = _formatDate(flSpot.x);

                return LineTooltipItem(
                  '$eyeLabel ($dateStr)\n${flSpot.y.toStringAsFixed(1)}',
                  TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                );
              }).toList();
            },
          ),
          handleBuiltInTouches: true,
          getTouchedSpotIndicator:
              (LineChartBarData barData, List<int> spotIndexes) {
            return spotIndexes.map((spotIndex) {
              return TouchedSpotIndicatorData(
                FlLine(
                  color: barData.color?.withValues(alpha: 0.5) ?? Colors.blue,
                  strokeWidth: 2,
                  dashArray: [5, 5],
                ),
                FlDotData(
                  getDotPainter: (spot, percent, barData, index) {
                    // Only show dots if we have few points, otherwise it's too crowded
                    // For dense data, show dots only on touch
                    // We can check totalDays here
                    return FlDotCirclePainter(
                      radius: 2.5,
                      color: barData.color ?? Colors.blue,
                      strokeWidth: 0,
                      strokeColor: barData.color ?? Colors.blue,
                    );
                  },
                ),
              );
            }).toList();
          },
        ),
        lineBarsData: _getLineBarsData(),
      ),
    );
  }

  List<LineChartBarData> _getLineBarsData() {
    // Clamp data to ensure all values are within min/max bounds
    final clampedLeftData = _clampData(widget.config.dataLeft);
    final clampedRightData = _clampData(widget.config.dataRight);

    switch (widget.selectedEye) {
      case EyeSelection.left:
        return [
          _createLineChartBarData(
            clampedLeftData,
            Colors.blue,
            'Left Eye',
          ),
        ];
      case EyeSelection.right:
        return [
          _createLineChartBarData(
            clampedRightData,
            Colors.red,
            'Right Eye',
          ),
        ];
      case EyeSelection.both:
        return [
          _createLineChartBarData(
            clampedLeftData,
            Colors.blue,
            'Left Eye',
          ),
          _createLineChartBarData(
            clampedRightData,
            Colors.red,
            'Right Eye',
          ),
        ];
    }
  }

  LineChartBarData _createLineChartBarData(
    List<FlSpot> spots,
    Color color,
    String label,
  ) {
    // Logic to show/hide dots based on density can be improved,
    // but for now keeping it simple: show all dots.
    // Ideally if spots.length > 30, maybe set show: false.
    bool showDots = spots.length < 20;

    return LineChartBarData(
      spots: spots,
      isCurved: true,
      color: color,
      barWidth: 2.5,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show:
            showDots, // Hide distinct dots if too many points for cleaner look
        getDotPainter: (spot, percent, barData, index) {
          return FlDotCirclePainter(
            radius: 2.5,
            color: color,
            strokeWidth: 0,
            strokeColor: color,
          );
        },
      ),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.3),
            color.withValues(alpha: 0.05),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }

  Widget _buildLegend(bool isDark) {
    final textColor = isDark ? Colors.white70 : Colors.black87;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.selectedEye == EyeSelection.left ||
            widget.selectedEye == EyeSelection.both)
          _buildLegendItem('Left Eye', Colors.blue, textColor),
        if (widget.selectedEye == EyeSelection.both) const SizedBox(width: 20),
        if (widget.selectedEye == EyeSelection.right ||
            widget.selectedEye == EyeSelection.both)
          _buildLegendItem('Right Eye', Colors.red, textColor),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color, Color textColor) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _getChartSubtitle() {
    switch (widget.selectedEye) {
      case EyeSelection.left:
        return 'Left Eye';
      case EyeSelection.right:
        return 'Right Eye';
      case EyeSelection.both:
        return 'Both Eyes';
    }
  }
}
