import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/catalog/history_catalog.dart';
import '../../../manager/examination_form_cubit/examination_form_cubit.dart';
import 'catalog_field.dart';

/// One history category: a checkbox header bound to `selectedCategories`. When
/// checked, its fields lazily mount and only the currently-visible ones (per
/// `showIf`) render.
class CategoryCard extends StatefulWidget {
  const CategoryCard({super.key, required this.category});

  final CategoryDef category;

  @override
  State<CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ExaminationFormCubit>();
    final checked = cubit.selectedHistoryCategories.contains(widget.category.key);
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
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
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              final next = !checked;
              cubit.toggleHistoryCategory(widget.category.key, next);
              setState(() => _expanded = next);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                children: [
                  Checkbox(
                    value: checked,
                    onChanged: (v) {
                      final next = v ?? false;
                      cubit.toggleHistoryCategory(widget.category.key, next);
                      setState(() => _expanded = next);
                    },
                  ),
                  Expanded(
                    child: Text(
                      widget.category.label,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                  ),
                  if (checked)
                    IconButton(
                      icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                      onPressed: () => setState(() => _expanded = !_expanded),
                    ),
                ],
              ),
            ),
          ),
          if (checked && _expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final key in widget.category.fieldKeys)
                    if (_visible(cubit, key))
                      CatalogField(
                        key: ValueKey('${widget.category.key}:$key'),
                        def: historyFields[key]!,
                        values: cubit.historyValues,
                        onChanged: cubit.setHistoryValue,
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
    final def = historyFields[key];
    if (def == null) return false;
    return isFieldVisible(def, cubit.historyValues);
  }
}
