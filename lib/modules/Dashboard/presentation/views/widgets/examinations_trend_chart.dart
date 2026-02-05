import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/dashboard_model.dart';

class ExaminationsTrendChart extends StatelessWidget {
  final List<ExaminationsTrend>? trends;

  const ExaminationsTrendChart({super.key, this.trends});

  @override
  Widget build(BuildContext context) {
    if (trends == null || trends!.isEmpty) return const SizedBox.shrink();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Sort trends by date
    final data = List<ExaminationsTrend>.from(trends!)..sort((a, b) => a.date!.compareTo(b.date!));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
          Padding(
          padding: const EdgeInsets.only(bottom: 24.0),
          child: Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               const Text("Examinations trend", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
               Text("Daily examination volume over time", style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey, fontSize: 12)),
             ],
           ),
        ),
        SizedBox(
          height: 250,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: false),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 22,
                    interval: _getInterval(data.length),
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index >= 0 && index < data.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            DateFormat('MM/dd').format(data[index].date!),
                            style: TextStyle(fontSize: 10, color: isDark ? Colors.grey.shade400 : Colors.grey),
                          ),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                       return Text(value.toInt().toString(), style: TextStyle(fontSize: 10, color: isDark ? Colors.grey.shade400 : Colors.grey));
                    },
                    reservedSize: 28,
                    interval: 5, // Adjust based on max value
                  ),
                ),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              minX: 0,
              maxX: (data.length - 1).toDouble(),
              minY: 0,
              // Add some padding to top Y
              maxY: ((data.map((e) => e.count ?? 0).reduce((curr, next) => curr > next ? curr : next) + 5) / 5).ceil() * 5.0,
              lineBarsData: [
                LineChartBarData(
                  spots: data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), (e.value.count ?? 0).toDouble())).toList(),
                  isCurved: true,
                  color: Colors.deepOrange,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        Colors.deepOrange.withOpacity(0.3),
                        Colors.deepOrange.withOpacity(0.0),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  double _getInterval(int count) {
    if (count <= 5) return 1;
    if (count <= 10) return 2;
    return (count / 5).roundToDouble();
  }
}
