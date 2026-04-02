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

                // Section 3: Visual Acuity
                if (trends.visualAcuity != null)
                  _buildExpandableSection(
                    context: context,
                    sectionKey: 'visual_acuity',
                    sectionTitle: 'Visual Acuity',
                    charts: [
                      if (trends.visualAcuity!.ucva != null)
                        _buildChartConfigFromAxis(
                          title: 'UCVA',
                          axis: trends.visualAcuity!.ucva!,
                          defaultMinY: 0,
                          defaultMaxY: 1.2,
                        ),
                      if (trends.visualAcuity!.bcva != null)
                        _buildChartConfigFromAxis(
                          title: 'BCVA',
                          axis: trends.visualAcuity!.bcva!,
                          defaultMinY: 0,
                          defaultMaxY: 1.2,
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
    // Collect all unique dates
    Set<DateTime> dateSet = {};
    for (var m in axis.left) {
      if (m.date != null && m.value != null) {
        dateSet.add(DateTime(m.date!.year, m.date!.month, m.date!.day));
      }
    }
    for (var m in axis.right) {
      if (m.date != null && m.value != null) {
        dateSet.add(DateTime(m.date!.year, m.date!.month, m.date!.day));
      }
    }

    List<DateTime> sortedDates = dateSet.toList()..sort();
    
    // Limit to 7 dates
    if (sortedDates.length > 7) {
      sortedDates = sortedDates.sublist(sortedDates.length - 7);
    }
    
    // Provide a default date if empty
    if (sortedDates.isEmpty) {
        sortedDates = [DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)];
    }

    // Convert measurements to spots using index in sortedDates
    List<FlSpot> dataLeft = _convertToSpotsDates(axis.left, sortedDates);
    List<FlSpot> dataRight = _convertToSpotsDates(axis.right, sortedDates);

    double minY = defaultMinY;
    double maxY = defaultMaxY;

    List<double> allY = [];
    allY.addAll(dataLeft.map((e) => e.y));
    allY.addAll(dataRight.map((e) => e.y));

    if (allY.isNotEmpty) {
      double dataMin = allY.reduce(math.min);
      double dataMax = allY.reduce(math.max);

      double range = dataMax - dataMin;
      double padding = range == 0 ? 0.2 : range * 0.2;

      minY = dataMin - padding;
      maxY = dataMax + padding;
    }

    return ChartConfig(
      title: title,
      dataLeft: dataLeft,
      dataRight: dataRight,
      minY: minY,
      maxY: maxY,
      xAxisDates: sortedDates,
    );
  }

  List<FlSpot> _convertToSpotsDates(List<model.Left> measurements, List<DateTime> allowedDates) {
    List<FlSpot> spots = [];
    for (var m in measurements) {
      if (m.value != null && m.date != null) {
        DateTime dateDay = DateTime(m.date!.year, m.date!.month, m.date!.day);
        int index = allowedDates.indexOf(dateDay);
        if (index != -1) {
          spots.add(FlSpot(index.toDouble(), m.value!.toDouble()));
        }
      }
    }
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
  final List<DateTime> xAxisDates;

  ChartConfig({
    required this.title,
    required this.dataLeft,
    required this.dataRight,
    required this.minY,
    required this.maxY,
    required this.xAxisDates,
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
    if (range <= 0.1) return 0.02;
    if (range <= 0.5) return 0.1;
    if (range <= 1.5) return 0.2;
    if (range <= 3) return 0.5;
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
    int index = value.toInt();
    if (index >= 0 && index < widget.config.xAxisDates.length) {
      return DateFormat('dd-MM', 'en').format(widget.config.xAxisDates[index]);
    }
    return '';
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
    final double maxX = math.max(0.1, widget.config.xAxisDates.length - 1.0);
    double xInterval = 1.0;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          drawHorizontalLine: true,
          horizontalInterval: yInterval,
          verticalInterval: xInterval,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
              strokeWidth: 1,
              dashArray: [5, 5],
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
              reservedSize: 40,
              interval: xInterval,
              getTitlesWidget: (value, meta) {
                final style = TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white70 : Colors.black87,
                );

                if (value % 1 != 0 || value < 0 || value >= widget.config.xAxisDates.length) {
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
              reservedSize: 46,
              getTitlesWidget: (value, meta) {
                final style = TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white70 : Colors.black87,
                );
                
                String text = value.toStringAsFixed(2);
                if (text.endsWith('.00')) {
                  text = text.substring(0, text.length - 3);
                } else if (text.endsWith('0')) {
                  text = text.substring(0, text.length - 1);
                }
                
                return Text(
                  text,
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
        maxX: maxX,
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
                String valueStr = yInterval < 1 
                    ? flSpot.y.toStringAsFixed(3) 
                    : flSpot.y.toStringAsFixed(1);

                return LineTooltipItem(
                  '$eyeLabel ($dateStr)\n$valueStr',
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
    return LineChartBarData(
      spots: spots,
      isCurved: false,
      color: color,
      barWidth: 2.0,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: true, 
        getDotPainter: (spot, percent, barData, index) {
          return FlDotCirclePainter(
            radius: 3.5,
            color: color,
            strokeWidth: 0,
            strokeColor: color,
          );
        },
      ),
      belowBarData: BarAreaData(
        show: false,
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
