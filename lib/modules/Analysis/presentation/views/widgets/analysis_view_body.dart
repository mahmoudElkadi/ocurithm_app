import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import '../../../data/models/analysis_model.dart' as model;
import '../../manager/analysis_cubit/get_analysis_cubit.dart';

enum EyeSelection { left, right, both }

class AnalysisViewBody extends StatefulWidget {
  final EyeSelection selectedEye;
  final int resetCounter;

  const AnalysisViewBody({
    super.key,
    required this.selectedEye,
    required this.resetCounter,
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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetAnalysisCubit, GetAnalysisState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const _AnalysisShimmerLoading();
        } else if (state.isError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 60),
                  const SizedBox(height: 16),
                  Text(
                    state.errorMessage ?? 'Error loading analysis',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          );
        } else if (state.noConnection) {
          return const Center(child: Text('No internet connection'));
        } else if (state.isSuccess && state.analysis != null) {
          final trends = state.analysis!.trends;
          if (trends == null) {
            return const Center(child: Text('No analysis data available'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section 1: Autorefraction
                if (trends.autoRefraction != null)
                  _buildExpandableSection(
                    context: context,
                    sectionKey: 'autorefraction',
                    sectionTitle: 'Autorefraction',
                    charts: _buildRefractionCharts(trends.autoRefraction!),
                  ),
                const SizedBox(height: 16),

                // Section 2: Refined Refraction
                if (trends.refinedRefraction != null ||
                    trends.nearVision != null)
                  _buildExpandableSection(
                    context: context,
                    sectionKey: 'refined_refraction',
                    sectionTitle: 'Refined Refraction',
                    charts: [
                      ..._buildRefractionCharts(trends.refinedRefraction),
                      if (trends.nearVision?.addition != null)
                        _buildChartConfigFromAxis(
                          title: 'Near Vision Addition',
                          axis: trends.nearVision!.addition!,
                          defaultMinY: 0,
                          defaultMaxY: 10.0,
                        ),
                    ],
                  ),
                const SizedBox(height: 16),

                // Section 4: IOP (mmHg)
                if (trends.iop != null)
                  _buildExpandableSection(
                    context: context,
                    sectionKey: 'iop',
                    sectionTitle: 'IOP (mmHg)',
                    charts: [
                      if (trends.iop!.primary != null)
                        _buildChartConfigFromAxis(
                          title: 'IOP',
                          axis: trends.iop!.primary!,
                          defaultMinY: 0,
                          defaultMaxY: 70,
                        ),
                      if (trends.iop!.secondary != null)
                        _buildChartConfigFromAxis(
                          title: 'IOP Measurement',
                          axis: trends.iop!.secondary!,
                          defaultMinY: 0,
                          defaultMaxY: 70,
                        ),
                    ],
                  ),
              ],
            ),
          );
        }
        return const Center(child: Text('No data found'));
      },
    );
  }

  List<ChartConfig> _buildRefractionCharts(model.Refraction? refraction) {
    if (refraction == null) return [];
    List<ChartConfig> configs = [];

    if (refraction.spherical != null) {
      configs.add(_buildChartConfigFromAxis(
        title: 'Spherical',
        axis: refraction.spherical!,
        defaultMinY: -25,
        defaultMaxY: 20,
      ));
    }
    if (refraction.cylindrical != null) {
      configs.add(_buildChartConfigFromAxis(
        title: 'Cylindrical',
        axis: refraction.cylindrical!,
        defaultMinY: -25,
        defaultMaxY: 20,
      ));
    }
    if (refraction.axis != null) {
      configs.add(_buildChartConfigFromAxis(
        title: 'Axis',
        axis: refraction.axis!,
        defaultMinY: 0,
        defaultMaxY: 180,
      ));
    }

    return configs;
  }

  ChartConfig _buildChartConfigFromAxis({
    required String title,
    required model.Axis axis,
    required double defaultMinY,
    required double defaultMaxY,
  }) {
    // Collect all dates to find range
    List<DateTime> allDates = [];
    for (var m in axis.left) {
      if (m.date != null) allDates.add(m.date!);
    }
    for (var m in axis.right) {
      if (m.date != null) allDates.add(m.date!);
    }

    DateTime minDate = allDates.isEmpty
        ? DateTime.now().subtract(const Duration(days: 30))
        : allDates.reduce((a, b) => a.isBefore(b) ? a : b);
    DateTime maxDate = allDates.isEmpty
        ? DateTime.now()
        : allDates.reduce((a, b) => a.isAfter(b) ? a : b);

    // Ensure we have at least some range for the chart to look good
    if (maxDate.difference(minDate).inDays < 7) {
      minDate = minDate.subtract(const Duration(days: 3));
      maxDate = maxDate.add(const Duration(days: 3));
    }

    // Convert measurements to spots
    List<FlSpot> dataLeft = _convertToSpots(axis.left, minDate);
    List<FlSpot> dataRight = _convertToSpots(axis.right, minDate);

    // Dynamic Y bounds based on data
    double minY = defaultMinY;
    double maxY = defaultMaxY;

    List<num> allValues = [];
    for (var m in axis.left) {
      if (m.value != null) allValues.add(m.value!);
    }
    for (var m in axis.right) {
      if (m.value != null) allValues.add(m.value!);
    }

    if (allValues.isNotEmpty) {
      double dataMin = allValues.reduce((a, b) => a < b ? a : b).toDouble();
      double dataMax = allValues.reduce((a, b) => a > b ? a : b).toDouble();

      // Add padding
      double range = dataMax - dataMin;
      double padding = range * 0.2;
      if (padding == 0) padding = 1.0;

      minY = math.min(defaultMinY, dataMin - padding);
      maxY = math.max(defaultMaxY, dataMax + padding);
    }

    return ChartConfig(
      title: title,
      dataLeft: dataLeft,
      dataRight: dataRight,
      minY: minY,
      maxY: maxY,
      minDate: minDate,
      maxDate: maxDate,
    );
  }

  List<FlSpot> _convertToSpots(
      List<model.Left> measurements, DateTime minDate) {
    List<FlSpot> spots = [];
    for (var m in measurements) {
      if (m.value != null && m.date != null) {
        double x = m.date!.difference(minDate).inDays.toDouble();
        spots.add(FlSpot(x, m.value!.toDouble()));
      }
    }
    // Sort spots by X to ensure correct line drawing
    spots.sort((a, b) => a.x.compareTo(b.x));
    return spots;
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
                            resetCounter: widget.resetCounter,
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
  final int resetCounter;

  const ChartCard({
    super.key,
    required this.config,
    required this.selectedEye,
    required this.resetCounter,
  });

  @override
  State<ChartCard> createState() => _ChartCardState();
}

class _ChartCardState extends State<ChartCard> {
  // Local selection overrides global selection
  EyeSelection? _localSelectedEye;
  int? _lastResetCounter;

  @override
  void didUpdateWidget(ChartCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If resetCounter changed, clear local selection to use global
    if (widget.resetCounter != _lastResetCounter) {
      _lastResetCounter = widget.resetCounter;
      if (_localSelectedEye != null) {
        setState(() {
          _localSelectedEye = null;
        });
      }
    }
  }

  // Get the effective selection (local overrides global)
  EyeSelection _getEffectiveSelection() {
    return _localSelectedEye ?? widget.selectedEye;
  }

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
          // Chart title with menu
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${widget.config.title} - ${_getChartSubtitle()}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              _buildOptionsMenu(isDark),
            ],
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

  Widget _buildOptionsMenu(bool isDark) {
    return PopupMenuButton<EyeSelection>(
      icon: Icon(
        Icons.more_vert,
        color: isDark ? Colors.white70 : Colors.black87,
        size: 20,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: isDark ? Colors.grey[850] : Colors.white,
      offset: const Offset(0, 40),
      itemBuilder: (BuildContext context) => <PopupMenuEntry<EyeSelection>>[
        _buildMenuItem(
          value: EyeSelection.left,
          icon: Icons.visibility,
          label: 'Left Eye',
          isDark: isDark,
        ),
        _buildMenuItem(
          value: EyeSelection.right,
          icon: Icons.remove_red_eye,
          label: 'Right Eye',
          isDark: isDark,
        ),
        _buildMenuItem(
          value: EyeSelection.both,
          icon: Icons.compare_arrows,
          label: 'Both Eyes',
          isDark: isDark,
        ),
      ],
      onSelected: (EyeSelection value) {
        setState(() {
          _localSelectedEye = value;
        });
      },
    );
  }

  PopupMenuItem<EyeSelection> _buildMenuItem({
    required EyeSelection value,
    required IconData icon,
    required String label,
    required bool isDark,
  }) {
    final isSelected = _getEffectiveSelection() == value;
    final primaryColor = Theme.of(context).primaryColor;
    final textColor = isDark ? Colors.white : Colors.black87;

    return PopupMenuItem<EyeSelection>(
      value: value,
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: isSelected ? primaryColor : textColor,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected ? primaryColor : textColor,
            ),
          ),
          const Spacer(),
          if (isSelected)
            Icon(
              Icons.check,
              size: 18,
              color: primaryColor,
            ),
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

                final effectiveSelection = _getEffectiveSelection();
                if (effectiveSelection == EyeSelection.both) {
                  if (barSpot.barIndex == 0) {
                    eyeLabel = 'Left Eye';
                    color = Colors.blue;
                  } else {
                    eyeLabel = 'Right Eye';
                    color = Colors.red;
                  }
                } else if (effectiveSelection == EyeSelection.left) {
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

    final effectiveSelection = _getEffectiveSelection();
    switch (effectiveSelection) {
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
        // Apply tiny X offset to Right Eye spots if they overlap with Left Eye spots
        // This ensures both points are visible when they have identical values
        final processedRightData = clampedRightData.map((rSpot) {
          final isOverlap = clampedLeftData.any((lSpot) =>
              (lSpot.x - rSpot.x).abs() < 0.05 &&
              (lSpot.y - rSpot.y).abs() < 0.05);
          return isOverlap ? FlSpot(rSpot.x + 0.1, rSpot.y) : rSpot;
        }).toList();

        return [
          _createLineChartBarData(
            clampedLeftData,
            Colors.blue,
            'Left Eye',
          ),
          _createLineChartBarData(
            processedRightData,
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
    final effectiveSelection = _getEffectiveSelection();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (effectiveSelection == EyeSelection.left ||
            effectiveSelection == EyeSelection.both)
          _buildLegendItem('Left Eye', Colors.blue, textColor),
        if (effectiveSelection == EyeSelection.both) const SizedBox(width: 20),
        if (effectiveSelection == EyeSelection.right ||
            effectiveSelection == EyeSelection.both)
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
    final effectiveSelection = _getEffectiveSelection();
    switch (effectiveSelection) {
      case EyeSelection.left:
        return 'Left Eye';
      case EyeSelection.right:
        return 'Right Eye';
      case EyeSelection.both:
        return 'Both Eyes';
    }
  }
}

class _AnalysisShimmerLoading extends StatelessWidget {
  const _AnalysisShimmerLoading();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey[800] : Colors.grey[300];
    final highlightColor = isDark ? Colors.grey[700] : Colors.grey[100];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Shimmer.fromColors(
        baseColor: baseColor!,
        highlightColor: highlightColor!,
        child: Column(
          children: List.generate(
              3, (index) => _buildShimmerSection(context, isDark)),
        ),
      ),
    );
  }

  Widget _buildShimmerSection(BuildContext context, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: 20,
                  width: 150,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Container(
                  height: 20,
                  width: 20,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Column(
              children: List.generate(1, (index) => _buildShimmerChart(isDark)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerChart(bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 16,
            width: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 12,
                width: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 20),
              Container(
                height: 12,
                width: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
