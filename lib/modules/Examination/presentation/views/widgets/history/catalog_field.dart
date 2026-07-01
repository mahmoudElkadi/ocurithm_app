import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ocurithm/core/widgets/DropdownPackage.dart';

import '../../../../data/catalog/history_catalog.dart';

/// Renders a single catalog [FieldDef], stage-agnostic: it reads from [values]
/// and reports edits via [onChanged] (`(key, value)`), so History and Complain
/// share one field renderer. Dispatches on [FieldDef.kind].
///
/// When [useDropdownItem] is true, enum fields render with the app's custom
/// [DropdownItem] search dropdown instead of a plain Material dropdown.
class CatalogField extends StatefulWidget {
  const CatalogField({
    super.key,
    required this.def,
    required this.values,
    required this.onChanged,
    this.useDropdownItem = false,
  });

  final FieldDef def;
  final Map<String, dynamic> values;
  final void Function(String key, dynamic value) onChanged;
  final bool useDropdownItem;

  @override
  State<CatalogField> createState() => _CatalogFieldState();
}

class _CatalogFieldState extends State<CatalogField> {
  TextEditingController? _controller;
  FocusNode? _focusNode;

  bool get _isTextual =>
      widget.def.kind == FieldKind.number || widget.def.kind == FieldKind.text;

  @override
  void initState() {
    super.initState();
    if (_isTextual) {
      _controller = TextEditingController(text: _currentString());
      _focusNode = FocusNode();
    }
  }

  String _currentString() {
    final v = widget.values[widget.def.key];
    return v == null ? '' : v.toString();
  }

  @override
  void dispose() {
    _controller?.dispose();
    _focusNode?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.def.kind) {
      case FieldKind.number:
        return _buildTextual(isNumber: true);
      case FieldKind.text:
        return _buildTextual(isNumber: false);
      case FieldKind.enumField:
        return _buildEnum();
      case FieldKind.date:
        return _buildDate();
      case FieldKind.computed:
        return _buildComputed();
      case FieldKind.multiEnum:
        return _buildMultiEnum();
    }
  }

  // ── Label ──
  Widget _label() {
    final def = widget.def;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        def.unit != null ? '${def.label} (${def.unit})' : def.label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).textTheme.bodyMedium?.color,
        ),
      ),
    );
  }

  InputDecoration _decoration({String? hint, Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      isDense: true,
      suffixIcon: suffix,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      filled: true,
      fillColor: Theme.of(context).cardColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Theme.of(context).dividerColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Theme.of(context).dividerColor),
      ),
    );
  }

  Widget _field(Widget child) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [_label(), child],
        ),
      );

  // ── number / text ──
  Widget _buildTextual({required bool isNumber}) {
    // Keep the controller in sync with the stored value (e.g. a canonical key
    // edited from another section) without disturbing the user's active edit.
    final current = _currentString();
    if (!(_focusNode?.hasFocus ?? false) && _controller!.text != current) {
      _controller!.text = current;
    }
    final def = widget.def;
    return _field(
      TextFormField(
        controller: _controller,
        focusNode: _focusNode,
        keyboardType: isNumber
            ? const TextInputType.numberWithOptions(decimal: true, signed: false)
            : (def.multiline ? TextInputType.multiline : TextInputType.text),
        maxLines: def.multiline ? 3 : 1,
        inputFormatters: isNumber
            ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))]
            : null,
        decoration: _decoration(hint: def.placeholder ?? 'Enter ${def.label.toLowerCase()}'),
        onChanged: (value) => widget.onChanged(def.key, value.trim()),
      ),
    );
  }

  // ── enum ──
  Widget _buildEnum() {
    final def = widget.def;
    final options = def.options ?? const [];
    final raw = widget.values[def.key]?.toString();
    // Guard against catalog drift: include an unknown stored value so the
    // dropdown never fails to display it.
    final items = <String>[
      ...options,
      if (raw != null && raw.isNotEmpty && !options.contains(raw)) raw,
    ];
    final selected = (raw != null && raw.isNotEmpty) ? raw : null;

    if (widget.useDropdownItem) {
      return _field(
        DropdownItem<String>(
          items: items,
          hintText: 'Select',
          radius: 12,
          height: 12,
          isShadow: false,
          border: Theme.of(context).dividerColor,
          selectedValue: selected,
          iconData: const Icon(Icons.arrow_drop_down, color: Colors.grey),
          itemAsString: (item) => item,
          onItemSelected: (item) => widget.onChanged(def.key, item),
          isLoading: false,
        ),
      );
    }

    return _field(
      DropdownButtonFormField<String>(
        initialValue: selected,
        isExpanded: true,
        decoration: _decoration(hint: 'Select'),
        items: items
            .map((o) => DropdownMenuItem<String>(value: o, child: Text(o)))
            .toList(),
        onChanged: (value) => widget.onChanged(def.key, value),
      ),
    );
  }

  // ── multiEnum ──
  Widget _buildMultiEnum() {
    final def = widget.def;
    final options = def.options ?? const [];
    final selected = (widget.values[def.key] as List?)?.map((e) => e.toString()).toSet() ?? <String>{};
    return _field(
      Wrap(
        spacing: 8,
        runSpacing: 4,
        children: options.map((o) {
          final isSel = selected.contains(o);
          return FilterChip(
            label: Text(o),
            selected: isSel,
            onSelected: (sel) {
              final next = {...selected};
              if (sel) {
                next.add(o);
              } else {
                next.remove(o);
              }
              widget.onChanged(def.key, next.toList());
            },
          );
        }).toList(),
      ),
    );
  }

  // ── date ──
  Widget _buildDate() {
    final def = widget.def;
    final raw = widget.values[def.key]?.toString();
    DateTime? parsed = (raw != null && raw.isNotEmpty) ? DateTime.tryParse(raw) : null;
    return _field(
      InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          final now = DateTime.now();
          final picked = await showDatePicker(
            context: context,
            initialDate: parsed ?? now,
            firstDate: DateTime(1900),
            lastDate: DateTime(now.year + 1),
          );
          if (picked != null) {
            // Store as yyyy-MM-dd (date-only, locale-independent).
            final iso =
                '${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
            widget.onChanged(def.key, iso);
          }
        },
        child: InputDecorator(
          decoration: _decoration(suffix: const Icon(Icons.calendar_today, size: 18)),
          child: Text(
            raw != null && raw.isNotEmpty ? raw : 'Select date',
            style: TextStyle(
              color: raw != null && raw.isNotEmpty
                  ? Theme.of(context).textTheme.bodyLarge?.color
                  : Theme.of(context).hintColor,
            ),
          ),
        ),
      ),
    );
  }

  // ── computed (read-only) ──
  Widget _buildComputed() {
    final def = widget.def;
    final value = widget.values[def.key];
    final display = value == null ? '—' : value.toString();
    return _field(
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).disabledColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Row(
          children: [
            const Icon(Icons.calculate_outlined, size: 18),
            const SizedBox(width: 8),
            Text(
              def.unit != null && value != null ? '$display ${def.unit}' : display,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            Text('auto', style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor)),
          ],
        ),
      ),
    );
  }
}
