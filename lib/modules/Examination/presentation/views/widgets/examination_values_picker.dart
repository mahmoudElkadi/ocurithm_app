import 'package:flutter/material.dart';

import '../../../../../core/utils/colors.dart';
import '../../../../Patient/data/model/one_exam.dart';
import '../../../data/catalog/printable_measurement_fields.dart';

/// Lets the doctor pick readings from this visit to print alongside the
/// prescription or action, with their labels. Only fields that actually hold a
/// reading are offered, so the list stays short and nothing prints as a dash.
class ExaminationValuesPicker extends StatelessWidget {
  const ExaminationValuesPicker({
    super.key,
    required this.measurements,
    required this.selectedIds,
    required this.onChanged,
  });

  final List<Measurement> measurements;
  final Set<String> selectedIds;
  final ValueChanged<Set<String>> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final available = _availableFields();

    if (available.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Examination Values for Print',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
              ),
              if (selectedIds.isNotEmpty)
                TextButton(
                  onPressed: () => onChanged(<String>{}),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: const Size(0, 28),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Clear',
                    style:
                        TextStyle(fontSize: 12, color: Colorz.primaryColor),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            selectedIds.isEmpty
                ? 'Optional — pick readings to print with the prescription.'
                : '${selectedIds.length} value${selectedIds.length == 1 ? '' : 's'} selected for print.',
            style: TextStyle(fontSize: 12, color: theme.hintColor),
          ),
          const SizedBox(height: 8),
          for (final entry in available.entries) ...[
            Padding(
              padding: const EdgeInsets.only(top: 6, bottom: 4),
              child: Text(
                entry.key,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colorz.primaryColor,
                ),
              ),
            ),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: entry.value
                  .map((field) => _chip(context, field))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _chip(BuildContext context, _AvailableField field) {
    final isSelected = selectedIds.contains(field.id);

    return FilterChip(
      label: Text(
        '${field.label}: ${field.value}',
        style: TextStyle(
          fontSize: 12,
          color: isSelected
              ? Colors.white
              : Theme.of(context).textTheme.bodyMedium?.color,
        ),
      ),
      selected: isSelected,
      showCheckmark: false,
      selectedColor: Colorz.primaryColor,
      onSelected: (selected) {
        final next = Set<String>.from(selectedIds);
        if (selected) {
          next.add(field.id);
        } else {
          next.remove(field.id);
        }
        onChanged(next);
      },
    );
  }

  /// Fields that hold a reading, keyed by "<Eye> Eye - <Group>".
  Map<String, List<_AvailableField>> _availableFields() {
    final result = <String, List<_AvailableField>>{};

    for (final eye in const ['Right', 'Left']) {
      Measurement? measurement;
      for (final candidate in measurements) {
        if (candidate.eye?.toLowerCase() == eye.toLowerCase()) {
          measurement = candidate;
          break;
        }
      }
      if (measurement == null) continue;

      for (final group in printableMeasurementGroups) {
        for (final field in group.fields) {
          final value = formatPrintableMeasurementValue(field.read(measurement));
          if (value == null) continue;

          final heading = '$eye Eye - ${group.title}';
          result.putIfAbsent(heading, () => []).add(
                _AvailableField(
                  id: printableFieldId(eye, field.key),
                  label: field.label,
                  value: value,
                ),
              );
        }
      }
    }

    return result;
  }
}

class _AvailableField {
  const _AvailableField({
    required this.id,
    required this.label,
    required this.value,
  });

  final String id;
  final String label;
  final String value;
}
