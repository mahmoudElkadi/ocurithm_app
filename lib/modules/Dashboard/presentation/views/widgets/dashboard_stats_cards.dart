import 'package:flutter/material.dart';
import '../../../data/models/dashboard_model.dart';

class DashboardStatsCards extends StatelessWidget {
  final Operational? operational;

  const DashboardStatsCards({super.key, this.operational});

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Daily snapshot", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        Text("Monitor appointments, branch activity, and patient flow at a glance.", 
          style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey)
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            // Check if we have enough space for 3 cards side by side
            // 350 is roughly the minimum width to fit them comfortably without squishing content too much
            bool useScroll = constraints.maxWidth < 600; 

            if (useScroll) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    SizedBox(width: 160, child: _buildCard(context, "TODAY", operational?.today?.total?.toString() ?? "0", "Appointments", Colors.green, isDark)),
                    const SizedBox(width: 12),
                    SizedBox(width: 160, child: _buildCard(context, "TOMORROW", operational?.tomorrow?.total?.toString() ?? "0", "Scheduled", Colors.blue, isDark)),
                    const SizedBox(width: 12),
                    SizedBox(width: 160, child: _buildCard(context, "PENDING", operational?.pendingFinalizations?.toString() ?? "0", "Finalizations", Colors.deepOrange, isDark)),
                  ],
                ),
              );
            }

            return Row(
              children: [
                Expanded(child: _buildCard(context, "TODAY", operational?.today?.total?.toString() ?? "0", "Appointments", Colors.green, isDark)),
                const SizedBox(width: 12),
                Expanded(child: _buildCard(context, "TOMORROW", operational?.tomorrow?.total?.toString() ?? "0", "Scheduled", Colors.blue, isDark)),
                const SizedBox(width: 12),
                Expanded(child: _buildCard(context, "PENDING", operational?.pendingFinalizations?.toString() ?? "0", "Finalizations", Colors.deepOrange, isDark)),
              ],
            );
          }
        ),
      ],
    );
  }

  Widget _buildCard(BuildContext context, String title, String value, String subtitle, MaterialColor color, bool isDark) {
    final bgColor = isDark ? color.withOpacity(0.15) : color.shade50;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(isDark ? 0.3 : 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
               Icon(Icons.calendar_today_outlined, color: color, size: 18),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 32))
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(subtitle, style: TextStyle(color: color.withOpacity(0.8), fontSize: 14))
          ),
        ],
      ),
    );
  }
}
