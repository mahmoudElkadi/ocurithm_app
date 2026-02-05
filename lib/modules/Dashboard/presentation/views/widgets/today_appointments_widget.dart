import 'package:flutter/material.dart';
import '../../../data/models/dashboard_model.dart';

class TodayAppointmentsWidget extends StatelessWidget {
  final Today? today;

  const TodayAppointmentsWidget({super.key, this.today});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final statusList = [
      _StatusItem("SCHEDULED", today?.byStatus?.scheduled, Icons.calendar_today, Colors.blue),
      _StatusItem("WAITING", today?.byStatus?.waiting, Icons.access_time, Colors.amber),
      _StatusItem("EXAMINING", today?.byStatus?.examining, Icons.medical_services_outlined, Colors.purple),
      _StatusItem("EXAMINED", today?.byStatus?.examined, Icons.assignment_turned_in_outlined, Colors.teal),
      _StatusItem("COMPLETED", today?.byStatus?.completed, Icons.check_circle_outline, Colors.green),
      _StatusItem("CANCELLED", today?.byStatus?.cancelled, Icons.cancel_outlined, Colors.red),
      _StatusItem("LATE", today?.byStatus?.late, Icons.warning_amber_rounded, Colors.deepOrange),
      _StatusItem("SAVED", today?.byStatus?.saved, Icons.save_outlined, Colors.blueGrey),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
             Container(
               padding: const EdgeInsets.all(8),
               decoration: BoxDecoration(
                 color: isDark ? Colors.deepPurple.withOpacity(0.2) : Colors.deepPurple.shade50, 
                 borderRadius: BorderRadius.circular(8)
               ),
               child: const Icon(Icons.show_chart, color: Colors.deepPurple),
             ),
             const SizedBox(width: 12),
             Expanded(
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   const Text("Today's appointments by status", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                   Text("Live distribution with a quick status breakdown", style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey, fontSize: 12)),
                 ],
               ),
             )
          ],
        ),
        const SizedBox(height: 16),
        LayoutBuilder(builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;
          return Flex(
            direction: isWide ? Axis.horizontal : Axis.vertical,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Total Card
              Container(
                width: isWide ? 300 : double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("TOTAL APPOINTMENTS TODAY", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? Colors.grey.shade400 : Colors.grey)),
                    const SizedBox(height: 8),
                    Text(today?.total?.toString() ?? "0", style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Text("Live snapshot • Updated on refresh", style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade400 : Colors.grey)),
                    const SizedBox(height: 12),
                    // Progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (today?.total ?? 0) > 0 ? 1 : 0, 
                        color: Colors.deepOrange, 
                        backgroundColor: isDark ? Colors.deepOrange.withOpacity(0.2) : Colors.deepOrange.shade100,
                        minHeight: 6,
                      ),
                    ),
                     if ((today?.byStatus?.late ?? 0) > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          children: [
                            const Icon(Icons.circle, size: 8, color: Colors.deepOrange),
                            const SizedBox(width: 4),
                            Text("Late ${today?.byStatus?.late} (${((today?.byStatus?.late ?? 0) / (today?.total ?? 1) * 100).toStringAsFixed(0)}%)", style: const TextStyle(fontSize: 12, color: Colors.deepOrange, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      )
                  ],
                ),
              ),
              SizedBox(width: isWide ? 16 : 0, height: isWide ? 0 : 16),
              // Grid of statuses
              if (isWide)
                Expanded(
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: statusList.map((item) {
                       return SizedBox(
                         width: 160, 
                         height: 100,
                         child: _statusCard(context, item, isDark),
                       );
                    }).toList(),
                  ),
                )
              else
                 Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: statusList.map((item) {
                       return SizedBox(
                         width: (constraints.maxWidth - 12) / 2, 
                         height: 100,
                         child: _statusCard(context, item, isDark),
                       );
                    }).toList(),
                 )
            ],
          );
        })
      ],
    );
  }

  Widget _statusCard(BuildContext context, _StatusItem item, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
         color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
         borderRadius: BorderRadius.circular(12),
         border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(item.title, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isDark ? Colors.grey.shade400 : Colors.grey)),
              Icon(item.icon, size: 18, color: item.color),
            ],
          ),
          Text(item.count?.toString() ?? "0", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _StatusItem {
  final String title;
  final num? count;
  final IconData icon;
  final Color color;
  
  _StatusItem(this.title, this.count, this.icon, this.color);
}
