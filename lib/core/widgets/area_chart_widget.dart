import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

class AreaChartDataPoint {
  final String date; // "YYYY-MM-DD"
  final int count;

  AreaChartDataPoint({required this.date, required this.count});
}

class AreaChartWidget extends StatelessWidget {
  final List<AreaChartDataPoint> data;
  final Color primaryColor;

  const AreaChartWidget({
    Key? key,
    required this.data,
    this.primaryColor = const Color(0xFF009688), // Default teal, matches modern vibe
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(
        child: Text('No data available'),
      );
    }

    // Parse dates and prepare FlSpots
    List<DateTime> parsedDates = [];
    List<FlSpot> spots = [];

    for (int i = 0; i < data.length; i++) {
      try {
        final date = DateTime.parse(data[i].date);
        parsedDates.add(date);
        spots.add(FlSpot(i.toDouble(), data[i].count.toDouble()));
      } catch (e) {
        // Fallback for unparseable dates
        parsedDates.add(DateTime.now());
        spots.add(FlSpot(i.toDouble(), data[i].count.toDouble()));
      }
    }

    // Calculate Y-axis maximum
    double maxY = 0;
    if (data.isNotEmpty) {
      final maxDataCount = data.map((e) => e.count).reduce(math.max).toDouble();
      // Provide some padding at the top, ensuring it steps nicely
      maxY = maxDataCount <= 0 ? 5 : (maxDataCount * 1.2).ceilToDouble();
    }

    // Calculate dynamic interval for Y-Axis
    double yInterval = math.max(1.0, (maxY / 5).floorToDouble());
    
    // Safety check for X max to prevent layout breaking when only 1 data point exists
    final double maxX = math.max(0.1, (data.length - 1).toDouble());

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: maxX,
        minY: 0,
        maxY: maxY,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false, // Completely hide vertical grid lines
          drawHorizontalLine: true,
          horizontalInterval: yInterval,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.4),
              strokeWidth: 1,
              dashArray: [5, 5], // Dashed pattern
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
              reservedSize: 30, // Small margin between labels and chart area
              interval: 1,
              getTitlesWidget: (value, meta) {
                int index = value.toInt();
                
                // Hide out-of-bounds or fractional labels
                if (value % 1 != 0 || index < 0 || index >= parsedDates.length) {
                  return const SizedBox.shrink();
                }

                // Format strictly as "MM/DD"
                String formattedDate = DateFormat('MM/dd').format(parsedDates[index]);

                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 8,
                  child: Text(
                    formattedDate,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).brightness == Brightness.dark 
                           ? Colors.white70 
                           : Colors.black54,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36, // Fixed reserved width to prevent layout shift
              interval: yInterval,
              getTitlesWidget: (value, meta) {
                // Ensure axis steps focus on whole integers
                if (value % 1 != 0) {
                  return const SizedBox.shrink();
                }

                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 8,
                  child: Text(
                    value.toInt().toString(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).brightness == Brightness.dark 
                           ? Colors.white70 
                           : Colors.black54,
                    ),
                    textAlign: TextAlign.right,
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: false, // Hides main axis lines surrounding the chart
        ),
        lineTouchData: LineTouchData(
          enabled: true,
          handleBuiltInTouches: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => Theme.of(context).brightness == Brightness.dark 
                                  ? Colors.grey[800]! 
                                  : Colors.white,
            tooltipRoundedRadius: 8,
            tooltipPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            getTooltipItems: (List<LineBarSpot> touchedSpots) {
              return touchedSpots.map((touchedSpot) {
                int index = touchedSpot.x.toInt();
                String dateStr = '';
                
                if (index >= 0 && index < parsedDates.length) {
                  dateStr = DateFormat('MM/dd').format(parsedDates[index]);
                }
                
                return LineTooltipItem(
                  '$dateStr\n',
                  TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark 
                         ? Colors.white70 
                         : Colors.black87,
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                  ),
                  children: [
                    TextSpan(
                      text: touchedSpot.y.toInt().toString(),
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                );
              }).toList();
            },
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: primaryColor,
            barWidth: 3.0,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false), // Hide individual dots
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  primaryColor.withValues(alpha: 0.35),
                  primaryColor.withValues(alpha: 0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
