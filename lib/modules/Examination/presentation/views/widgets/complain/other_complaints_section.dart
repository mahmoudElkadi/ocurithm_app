import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../manager/examination_form_cubit/examination_form_cubit.dart';

/// Always-available collapsible holding the 3 legacy free-text complaint fields.
/// For old (pre-catalog) exams this is the primary editable surface; for new
/// exams it is the "Other complaints" escape hatch alongside the checklist.
class OtherComplaintsSection extends StatefulWidget {
  const OtherComplaintsSection({super.key});

  @override
  State<OtherComplaintsSection> createState() => _OtherComplaintsSectionState();
}

class _OtherComplaintsSectionState extends State<OtherComplaintsSection> {
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<ExaminationFormCubit>();
    _expanded = cubit.oneComplaintController.text.isNotEmpty ||
        cubit.twoComplaintController.text.isNotEmpty ||
        cubit.threeComplaintController.text.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ExaminationFormCubit>();
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Icon(Icons.notes, size: 20, color: theme.primaryColor),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Other complaints (free text)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                  ),
                  Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                ],
              ),
            ),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _textArea('Complaint One', cubit.oneComplaintController),
                  _textArea('Complaint Two', cubit.twoComplaintController),
                  _textArea('Complaint Three', cubit.threeComplaintController),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _textArea(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Describe the complaint...',
              isDense: true,
              contentPadding: const EdgeInsets.all(14),
              filled: true,
              fillColor: Theme.of(context).scaffoldBackgroundColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Theme.of(context).dividerColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Theme.of(context).dividerColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
