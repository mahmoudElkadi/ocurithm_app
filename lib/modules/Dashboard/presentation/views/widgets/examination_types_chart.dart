import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../data/models/dashboard_model.dart';

class ExaminationTypesChart extends StatefulWidget {
  final List<ExaminationTypeDistribution>? distribution;

  const ExaminationTypesChart({super.key, this.distribution});

  @override
  State<ExaminationTypesChart> createState() => _ExaminationTypesChartState();
}

class _ExaminationTypesChartState extends State<ExaminationTypesChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final data = widget.distribution ?? [];
    if (data.isEmpty) return const SizedBox.shrink();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Calculate total count
    final num totalCount = data.fold<num>(0, (sum, item) => sum + (item.count ?? 0));

    // Determine what to show in center
    String centerValue;
    String centerLabel;
    
    if (touchedIndex != -1 && touchedIndex < data.length) {
      final item = data[touchedIndex];
      centerValue = item.count?.toString() ?? "0";
      centerLabel = item.typeName ?? "Unknown";
    } else {
      centerValue = totalCount.toString();
      centerLabel = "Total";
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Examination Types", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text("Most requested appointment types", style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey, fontSize: 12)),
            ],
          ),
        ),
        LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 600;
              return Flex(
                direction: isWide ? Axis.horizontal : Axis.vertical,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Pie Chart with Center Text
                  SizedBox(
                    height: 250,
                    width: isWide ? 300 : double.infinity,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        PieChart(
                          PieChartData(
                            pieTouchData: PieTouchData(
                              touchCallback: (FlTouchEvent event, pieTouchResponse) {
                                setState(() {
                                  if (!event.isInterestedForInteractions ||
                                      pieTouchResponse == null ||
                                      pieTouchResponse.touchedSection == null) {
                                    touchedIndex = -1;
                                    return;
                                  }
                                  touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                                });
                              },
                            ),
                            sectionsSpace: 4,
                            centerSpaceRadius: 60,
                            sections: _showingSections(data),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              transitionBuilder: (Widget child, Animation<double> animation) {
                                return ScaleTransition(scale: animation, child: child);
                              },
                              child: Text(
                                centerValue,
                                key: ValueKey<String>(centerValue),
                                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Text(centerLabel, style: TextStyle(fontSize: 14, color: isDark ? Colors.grey.shade400 : Colors.grey), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
                          ],
                        )
                      ],
                    ),
                  ),
                  SizedBox(width: isWide ? 32 : 0, height: isWide ? 0 : 24),
                  // Legend / List
                  if (isWide)
                    Expanded(
                      child: _buildRankedList(data, isDark),
                    )
                  else
                    _buildRankedList(data, isDark)
                ],
              );
            }
        )
      ],
    );
  }

  Widget _buildRankedList(List<ExaminationTypeDistribution> data, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("RANKED LIST", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? Colors.grey.shade400 : Colors.grey)),
        const SizedBox(height: 16),
        ...data.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final color = _getColor(index);
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Text("#${index + 1}", style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade400 : Colors.grey)),
                      const SizedBox(width: 8),
                      Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(item.typeName ?? "Unknown", 
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  children: [
                    Text(item.count?.toString() ?? "0", style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    Text("${item.percentage ?? 0}%", style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade400 : Colors.grey)),
                  ],
                )
              ],
            ),
          );
        }),
      ],
    );
  }

  List<PieChartSectionData> _showingSections(List<ExaminationTypeDistribution> data) {
    return List.generate(data.length, (i) {
      final isTouched = i == touchedIndex;
      final radius = isTouched ? 65.0 : 55.0;
      final item = data[i];
      final color = _getColor(i);

      return PieChartSectionData(
        color: color,
        value: (item.count ?? 0).toDouble(),
        title: '', // Hiding title on the chart itself to match clean design
        radius: radius,
        badgeWidget: isTouched ? Container(
             padding: const EdgeInsets.all(4),
             decoration: const BoxDecoration(
               color: Colors.white,
               shape: BoxShape.circle,
               boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]
             ),
             child: Text('${item.percentage}%', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color))
          ) : null,
        badgePositionPercentageOffset: .98,
        showTitle: false,
      );
    });
  }

  Color _getColor(int index) {
    const colors = [
      Colors.deepOrange,
      Colors.teal,
      Color(0xFF0F4C75), // Dark Blue
      Colors.amber,
      Colors.redAccent,
      Colors.purple,
      Colors.indigo,
      Colors.green,
      Colors.pinkAccent,
      Colors.cyan,
      Colors.brown,
      Colors.blueGrey,
      Colors.deepPurple,
      Colors.lime,
      Colors.lightBlue,
    ];
    return colors[index % colors.length];
  }
}
