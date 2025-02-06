import 'package:flutter/material.dart';
import 'package:ocurithm/core/utils/colors.dart';

class BuildExaminationSection extends StatefulWidget {
  const BuildExaminationSection({super.key, required this.title, required this.data, required this.sectionIndex, required this.isLeft});
  final String title;
  final Map<String, dynamic> data;
  final int sectionIndex;
  final bool isLeft;

  @override
  State<BuildExaminationSection> createState() => _BuildExaminationSectionState();
}

class _BuildExaminationSectionState extends State<BuildExaminationSection> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      shadowColor: Colorz.primaryColor.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          maintainState: false, // Add this
          initiallyExpanded: true,
          enabled: false, // Ad d this
          tilePadding: const EdgeInsets.symmetric(horizontal: 16), // Optional for better spacing
          expandedCrossAxisAlignment: CrossAxisAlignment.start, // Add this for better alignment
          childrenPadding: const EdgeInsets.all(16), // Add this for better padding

          title: Text(
            widget.title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colorz.primaryColor,
            ),
          ),
          children: [
            Column(
              spacing: 8,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.data.entries.map((entry) => _buildDataRow(entry.key, entry.value)).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataRow(String label, dynamic value) {
    final displayValue = value?.toString() ?? 'N/A';
    final isLongText = displayValue.length > 30;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colorz.primaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
          ),
          child: Text(
            displayValue,
            style: TextStyle(
              fontSize: isLongText ? 13 : 14,
              color: Colorz.black,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
