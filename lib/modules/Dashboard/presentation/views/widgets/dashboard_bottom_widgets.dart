import 'package:flutter/material.dart';

import '../../../data/models/dashboard_model.dart';

class DashboardBottomWidgets extends StatelessWidget {
  final Analytics? analytics;

  const DashboardBottomWidgets({super.key, this.analytics});

  @override
  Widget build(BuildContext context) {
    if (analytics == null) return const SizedBox.shrink();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 800;
        return Flex(
          direction: isWide ? Axis.horizontal : Axis.vertical,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Statuses
            if (isWide)
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     _buildHeader("Statuses", "Distribution of appointment outcomes", isDark),
                     const SizedBox(height: 16),
                    _buildStatusChart(analytics!.appointmentStatusDistribution, isDark),
                  ],
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   _buildHeader("Statuses", "Distribution of appointment outcomes", isDark),
                   const SizedBox(height: 16),
                  _buildStatusChart(analytics!.appointmentStatusDistribution, isDark),
                ],
              ),
             SizedBox(width: isWide ? 32 : 0, height: isWide ? 0 : 32),
            // Performance
            if (isWide)
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     _buildHeader("Performance", "Completion and cancellation rates", isDark),
                     const SizedBox(height: 16),
                     _buildRateCard("COMPLETION RATE", analytics!.completionRate, Colors.teal, isDark),
                     const SizedBox(height: 16),
                     _buildRateCard("CANCELLATION RATE", analytics!.cancellationRate, Colors.redAccent, isDark),
                  ],
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   _buildHeader("Performance", "Completion and cancellation rates", isDark),
                   const SizedBox(height: 16),
                   _buildRateCard("COMPLETION RATE", analytics!.completionRate, Colors.teal, isDark),
                   const SizedBox(height: 16),
                   _buildRateCard("CANCELLATION RATE", analytics!.cancellationRate, Colors.redAccent, isDark),
                ],
              ),
          ],
        );
      }
    );
  }

  Widget _buildHeader(String title, String subtitle, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(subtitle, style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildStatusChart(List<AppointmentStatusDistribution> list, bool isDark) {
    // Sort
    final sorted = List<AppointmentStatusDistribution>.from(list)..sort((a,b) => (b.count ?? 0).compareTo(a.count ?? 0));
    final maxVal = sorted.isNotEmpty ? (sorted.first.count ?? 1) : 1;

    return Column(
      children: sorted.map((e) {
        final percentageOfMax = maxVal > 0 ? (e.count ?? 0) / maxVal : 0.0;
        final color = _getStatusColor(e.status);
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Row(
            children: [
              SizedBox(
                width: 80,
                child: Text(e.status ?? "", style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade400 : Colors.grey), textAlign: TextAlign.end),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: LayoutBuilder(builder: (ctx, cns) {
                   return Stack(
                     children: [
                       Container(
                         height: 24,
                         width: cns.maxWidth * percentageOfMax,
                         decoration: BoxDecoration(
                           color: color,
                           borderRadius: const BorderRadius.only(topRight: Radius.circular(4), bottomRight: Radius.circular(4))
                           ),
                       )
                     ],
                   );
                }),
              ),
              const SizedBox(width: 8),
              Text("${e.count}", style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRateCard(String title, TionRate? rate, Color color, bool isDark) {
    if (rate == null) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
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
              Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? Colors.grey.shade400 : Colors.grey)),
            ],
          ),
          const SizedBox(height: 8),
          Text("${rate.value ?? 0}%", style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text("Previous: ${rate.previousValue ?? 0}%", style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade400 : Colors.grey)),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    if (status == null) return Colors.grey;
    switch (status.toLowerCase()) {
      case 'examining': return Colors.deepOrange;
      case 'completed': return Colors.teal;
      case 'saved': return const Color(0xFF0F4C75);
      case 'waiting': return Colors.amber;
      case 'late': return Colors.orange;
      case 'scheduled': return Colors.blue;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }
}
