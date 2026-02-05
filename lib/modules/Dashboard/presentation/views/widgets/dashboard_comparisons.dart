import 'package:flutter/material.dart';
import '../../../data/models/dashboard_model.dart';

class DashboardComparisons extends StatelessWidget {
  final Comparisons? comparisons;

  const DashboardComparisons({super.key, this.comparisons});

  @override
  Widget build(BuildContext context) {
    if (comparisons == null) return const SizedBox.shrink();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 800;
        return Flex(
          direction: isWide ? Axis.horizontal : Axis.vertical,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isWide)
              Expanded(
                flex: 1,
                child: _ComparisonCard(
                  title: "Branches",
                  subtitle: "Examinations by location",
                  items: comparisons!.branches.map((e) => _ComparisonItem(e.branchName ?? "Unknown", e.examinationCount ?? 0)).toList(),
                  color: Colors.deepOrange,
                  isDark: isDark,
                ),
              )
            else
              _ComparisonCard(
                title: "Branches",
                subtitle: "Examinations by location",
                items: comparisons!.branches.map((e) => _ComparisonItem(e.branchName ?? "Unknown", e.examinationCount ?? 0)).toList(),
                color: Colors.deepOrange,
                isDark: isDark,
              ),
            SizedBox(width: isWide ? 16 : 0, height: isWide ? 0 : 16),
            if (isWide)
              Expanded(
                flex: 1,
                child: _ComparisonCard(
                  title: "Clinics",
                  subtitle: "Examinations by clinic",
                  items: comparisons!.clinics.map((e) => _ComparisonItem(e.clinicName ?? "Unknown", e.examinationCount ?? 0)).toList(),
                  color: Colors.teal,
                  isDark: isDark,
                ),
              )
            else
              _ComparisonCard(
                title: "Clinics",
                subtitle: "Examinations by clinic",
                items: comparisons!.clinics.map((e) => _ComparisonItem(e.clinicName ?? "Unknown", e.examinationCount ?? 0)).toList(),
                color: Colors.teal,
                isDark: isDark,
              ),
          ],
        );
      }
    );
  }
}

class _ComparisonCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<_ComparisonItem> items;
  final Color color;
  final bool isDark;

  const _ComparisonCard({
    required this.title, 
    required this.subtitle, 
    required this.items, 
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    // Sort items desc
    final sortedItems = List<_ComparisonItem>.from(items)..sort((a,b) => b.value.compareTo(a.value));
    final maxVal = sortedItems.isNotEmpty ? sortedItems.first.value : 1;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: [
               Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                   Text(subtitle, style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade400 : Colors.grey)),
                 ],
               ),
               Container(
                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                 decoration: BoxDecoration(
                   color: isDark ? Colors.grey.shade800 : Colors.grey.shade100, 
                   borderRadius: BorderRadius.circular(12)
                 ),
                 child: Text("${items.length} total", style: TextStyle(fontSize: 10, color: isDark ? Colors.grey.shade400 : Colors.grey)),
               )
             ],
           ),
           const SizedBox(height: 16),
           if (items.isEmpty) Text("No data available", style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey)),
           ...sortedItems.take(5).map((item) {
             final percentage = maxVal > 0 ? item.value / maxVal : 0.0;
             return Padding(
               padding: const EdgeInsets.symmetric(vertical: 8.0),
               child: Row(
                 children: [
                   SizedBox(
                     width: 100,
                     child: Text(item.label, style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade400 : Colors.grey), overflow: TextOverflow.ellipsis),
                   ),
                   const SizedBox(width: 8),
                   Expanded(
                     child: Stack(
                       children: [
                         Container(height: 24, 
                           decoration: BoxDecoration(
                             color: color, 
                             borderRadius: const BorderRadius.only(topRight: Radius.circular(4), bottomRight: Radius.circular(4))
                           ),
                           width:  (MediaQuery.of(context).size.width) * percentage * 0.5, // approximate
                         ),
                       ],
                     ),
                   ),
                   const SizedBox(width: 8),
                   Text(item.value.toString(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                 ],
               ),
             );
           })
        ],
      ),
    );
  }
}

class _ComparisonItem {
  final String label;
  final num value;
  _ComparisonItem(this.label, this.value);
}
