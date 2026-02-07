import 'package:flutter/material.dart';
import '../../../data/models/analysis_model.dart';
import 'analysis_view_body.dart';
import 'analysis_pdf_service.dart';

class ChartSelectionDialog extends StatefulWidget {
  final AnalysisModel analysis;
  final EyeSelection currentEyeSelection;

  const ChartSelectionDialog({
    super.key,
    required this.analysis,
    required this.currentEyeSelection,
    this.onSelectionConfirmed,
  });

  final Function(Set<String> selectedKeys, EyeSelection eyeSelection)? onSelectionConfirmed;

  @override
  State<ChartSelectionDialog> createState() => _ChartSelectionDialogState();
}

class _ChartSelectionDialogState extends State<ChartSelectionDialog> {
  final Set<String> _selectedKeys = {};
  late List<_ChartOption> _availableOptions;

  @override
  void initState() {
    super.initState();
    _availableOptions = _getAvailableOptions();
    // Select all by default
    for (var option in _availableOptions) {
      _selectedKeys.add(option.key);
    }
  }

  List<_ChartOption> _getAvailableOptions() {
    final List<_ChartOption> options = [];
    final trends = widget.analysis.trends;
    if (trends == null) return options;

    // Autorefraction
    if (trends.autoRefraction != null) {
      if (trends.autoRefraction!.spherical != null) {
        options.add(_ChartOption(
            key: 'auto_spherical',
            label: 'Autorefraction - Spherical',
            category: 'Autorefraction'));
      }
      if (trends.autoRefraction!.cylindrical != null) {
        options.add(_ChartOption(
            key: 'auto_cylindrical',
            label: 'Autorefraction - Cylindrical',
            category: 'Autorefraction'));
      }
      if (trends.autoRefraction!.axis != null) {
        options.add(_ChartOption(
            key: 'auto_axis',
            label: 'Autorefraction - Axis',
            category: 'Autorefraction'));
      }
    }

    // Refined Refraction
    if (trends.refinedRefraction != null) {
      if (trends.refinedRefraction!.spherical != null) {
        options.add(_ChartOption(
            key: 'refined_spherical',
            label: 'Refined Refraction - Spherical',
            category: 'Refined Refraction'));
      }
      if (trends.refinedRefraction!.cylindrical != null) {
        options.add(_ChartOption(
            key: 'refined_cylindrical',
            label: 'Refined Refraction - Cylindrical',
            category: 'Refined Refraction'));
      }
      if (trends.refinedRefraction!.axis != null) {
        options.add(_ChartOption(
            key: 'refined_axis',
            label: 'Refined Refraction - Axis',
            category: 'Refined Refraction'));
      }
    }

    // Near Vision
    if (trends.nearVision?.addition != null) {
      options.add(_ChartOption(
          key: 'near_vision',
          label: 'Near Vision - Addition',
          category: 'Refined Refraction'));
    }

    // IOP
    if (trends.iop != null) {
      if (trends.iop!.primary != null) {
        options.add(
            _ChartOption(key: 'iop_primary', label: 'IOP', category: 'IOP'));
      }
      if (trends.iop!.secondary != null) {
        options.add(_ChartOption(
            key: 'iop_secondary', label: 'IOP Measurement', category: 'IOP'));
      }
    }

    return options;
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return AlertDialog(
      title: const Text('Select Graphs to Print'),
      content: SizedBox(
        width: double.maxFinite,
        child: _availableOptions.isEmpty
            ? const Text('No data available to print.')
            : ListView.builder(
                shrinkWrap: true,
                itemCount: _availableOptions.length,
                itemBuilder: (context, index) {
                  final option = _availableOptions[index];
                  final isFirstInCategory = index == 0 ||
                      _availableOptions[index - 1].category != option.category;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isFirstInCategory) ...[
                        Padding(
                          padding: const EdgeInsets.only(top: 16, bottom: 8),
                          child: Text(
                            option.category,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                        ),
                      ],
                      CheckboxListTile(
                        title: Text(option.label,
                            style: const TextStyle(fontSize: 14)),
                        value: _selectedKeys.contains(option.key),
                        activeColor: primaryColor,
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              _selectedKeys.add(option.key);
                            } else {
                              _selectedKeys.remove(option.key);
                            }
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                      ),
                    ],
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _selectedKeys.isEmpty
              ? null
              : () {
                  if (widget.onSelectionConfirmed != null) {
                    widget.onSelectionConfirmed!(
                        _selectedKeys, widget.currentEyeSelection);
                    Navigator.pop(context, true);
                  } else {
                    Navigator.pop(context, true);
                    AnalysisPdfService.generateAndPrintAnalysis(
                      analysis: widget.analysis,
                      selectedChartKeys: _selectedKeys,
                      eyeSelection: widget.currentEyeSelection,
                    );
                  }
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
          ),
          child: const Text('Print PDF'),
        ),
      ],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }
}

class _ChartOption {
  final String key;
  final String label;
  final String category;

  _ChartOption(
      {required this.key, required this.label, required this.category});
}
