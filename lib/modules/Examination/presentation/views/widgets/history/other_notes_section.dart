import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../manager/examination_form_cubit/examination_form_cubit.dart';

/// Always-available collapsible holding the 4 legacy free-text fields. For old
/// (pre-catalog) exams this is the primary editable surface; for new exams it is
/// the "Other notes" escape hatch alongside the structured checklist.
class OtherNotesSection extends StatefulWidget {
  const OtherNotesSection({super.key});

  @override
  State<OtherNotesSection> createState() => _OtherNotesSectionState();
}

class _OtherNotesSectionState extends State<OtherNotesSection> {
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    // Auto-expand when legacy text is already present (e.g. an old examination).
    final cubit = context.read<ExaminationFormCubit>();
    _expanded = cubit.presentIllnessController.text.isNotEmpty ||
        cubit.pastHistoryController.text.isNotEmpty ||
        cubit.medicationHistoryController.text.isNotEmpty ||
        cubit.familyHistoryController.text.isNotEmpty;
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
                      'Other notes (free text)',
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
                  _textArea('Present Illness', cubit.presentIllnessController),
                  _textArea('Past History', cubit.pastHistoryController),
                  _textArea('Medication History', cubit.medicationHistoryController),
                  _textArea('Family History', cubit.familyHistoryController),
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
              hintText: 'Type here...',
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
