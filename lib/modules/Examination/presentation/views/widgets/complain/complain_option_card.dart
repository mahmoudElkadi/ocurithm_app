import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/catalog/complain_catalog.dart';
import '../../../../data/catalog/history_catalog.dart';
import '../../../manager/examination_form_cubit/examination_form_cubit.dart';
import '../history/catalog_field.dart';

/// One complaint option: a checkbox bound to `selectedComplaints`. When checked
/// (and it has fields), its fields lazily mount and only currently-visible ones
/// render. Options with no fields are a checkbox only.
class ComplainOptionCard extends StatefulWidget {
  const ComplainOptionCard({super.key, required this.option});

  final ComplainOptionDef option;

  @override
  State<ComplainOptionCard> createState() => _ComplainOptionCardState();
}

class _ComplainOptionCardState extends State<ComplainOptionCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ExaminationFormCubit>();
    final checked = cubit.selectedComplaints.contains(widget.option.key);
    final hasFields = widget.option.fieldKeys.isNotEmpty;
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: checked
              ? theme.primaryColor.withValues(alpha: 0.5)
              : theme.dividerColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              final next = !checked;
              cubit.toggleComplaint(widget.option.key, next);
              setState(() => _expanded = next && hasFields);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              child: Row(
                children: [
                  Checkbox(
                    value: checked,
                    onChanged: (v) {
                      final next = v ?? false;
                      cubit.toggleComplaint(widget.option.key, next);
                      setState(() => _expanded = next && hasFields);
                    },
                  ),
                  Expanded(
                    child: Text(
                      widget.option.label,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                  ),
                  if (checked && hasFields)
                    IconButton(
                      icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                      onPressed: () => setState(() => _expanded = !_expanded),
                    ),
                ],
              ),
            ),
          ),
          if (checked && hasFields && _expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final key in widget.option.fieldKeys)
                    if (_visible(cubit, key))
                      CatalogField(
                        key: ValueKey('${widget.option.key}:$key'),
                        def: complainFields[key]!,
                        values: cubit.complainValues,
                        onChanged: cubit.setComplainValue,
                        useDropdownItem: true,
                      ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  bool _visible(ExaminationFormCubit cubit, String key) {
    final def = complainFields[key];
    if (def == null) return false;
    return isFieldVisible(def, cubit.complainValues);
  }
}
