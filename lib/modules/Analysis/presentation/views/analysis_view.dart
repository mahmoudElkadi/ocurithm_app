import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/services_locator.dart';
import '../manager/analysis_cubit/get_analysis_cubit.dart';
import 'widgets/analysis_view_body.dart';
import 'widgets/chart_selection_dialog.dart';
import '../../data/models/analysis_model.dart';

class AnalysisView extends StatefulWidget {
  const AnalysisView({super.key, required this.patientId});
  final String patientId;

  @override
  State<AnalysisView> createState() => _AnalysisViewState();
}

class _AnalysisViewState extends State<AnalysisView> {
  EyeSelection _selectedEye = EyeSelection.both;
  int _resetCounter =
      0; // Used to signal charts to reset their local selections

  void _showPrintSelectionDialog(BuildContext context, AnalysisModel analysis) {
    showDialog(
      context: context,
      builder: (context) => ChartSelectionDialog(
        analysis: analysis,
        currentEyeSelection: _selectedEye,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<GetAnalysisCubit>()
        ..add(GetPatientAnalysisEvent(patientId: widget.patientId)),
      child: BlocBuilder<GetAnalysisCubit, GetAnalysisState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: const Text(
                'Analysis',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              actions: [
                if (state.isSuccess && state.analysis != null)
                  IconButton(
                    icon: Icon(
                      Icons.print,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black87,
                    ),
                    onPressed: () =>
                        _showPrintSelectionDialog(context, state.analysis!),
                  ),
                _buildOptionsMenu(
                    Theme.of(context).brightness == Brightness.dark)
              ],
            ),
            body: AnalysisViewBody(
              selectedEye: _selectedEye,
              resetCounter: _resetCounter,
            ),
          );
        },
      ),
    );
  }

  Widget _buildOptionsMenu(bool isDark) {
    return PopupMenuButton<EyeSelection>(
      icon: Icon(
        Icons.more_vert,
        color: isDark ? Colors.white : Colors.black87,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: isDark ? Colors.grey[850] : Colors.white,
      offset: const Offset(0, 45),
      itemBuilder: (BuildContext context) => <PopupMenuEntry<EyeSelection>>[
        _buildMenuItem(
          value: EyeSelection.left,
          icon: Icons.visibility,
          label: 'Left Eye',
          isDark: isDark,
        ),
        _buildMenuItem(
          value: EyeSelection.right,
          icon: Icons.remove_red_eye,
          label: 'Right Eye',
          isDark: isDark,
        ),
        _buildMenuItem(
          value: EyeSelection.both,
          icon: Icons.compare_arrows,
          label: 'Both Eyes',
          isDark: isDark,
        ),
      ],
      onSelected: (EyeSelection value) {
        setState(() {
          _selectedEye = value;
          _resetCounter++; // Increment to signal all charts to reset
        });
      },
    );
  }

  PopupMenuItem<EyeSelection> _buildMenuItem({
    required EyeSelection value,
    required IconData icon,
    required String label,
    required bool isDark,
  }) {
    final isSelected = _selectedEye == value;
    final primaryColor = Theme.of(context).primaryColor;
    final textColor = isDark ? Colors.white : Colors.black87;

    return PopupMenuItem<EyeSelection>(
      value: value,
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isSelected ? primaryColor : textColor,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected ? primaryColor : textColor,
            ),
          ),
          const Spacer(),
          if (isSelected)
            Icon(
              Icons.check,
              size: 20,
              color: primaryColor,
            ),
        ],
      ),
    );
  }
}
