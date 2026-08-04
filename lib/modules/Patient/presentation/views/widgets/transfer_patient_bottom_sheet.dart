import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocurithm/core/utils/services_locator.dart';
import 'package:ocurithm/core/utils/snackbar_service.dart';
import 'package:ocurithm/core/widgets/DropdownPackage.dart';
import 'package:ocurithm/core/widgets/height_spacer.dart';
import 'package:ocurithm/modules/Patient/data/model/patients_model.dart';
import 'package:ocurithm/modules/Patient/data/repos/patient_repo.dart';
import 'package:ocurithm/modules/Patient/presentation/manager/patient_actions_cubit/patient_actions_cubit.dart';

/// Mirrors web's TransferPatientDialog.tsx: search/select a destination
/// patient, type "confirm" to acknowledge the warning, optionally delete the
/// source. Irreversible — every record (appointments, examinations, billings,
/// surgeries, scans, leads) moves server-side in one transaction.
class TransferPatientBottomSheet extends StatefulWidget {
  final String sourceId;
  final String? sourceName;

  const TransferPatientBottomSheet({
    super.key,
    required this.sourceId,
    this.sourceName,
  });

  /// Shows the sheet and returns the [TransferPatientResult] on success, or
  /// null if the user cancelled.
  static Future<TransferPatientResult?> show(
    BuildContext context, {
    required String sourceId,
    String? sourceName,
  }) {
    final actionsCubit = context.read<PatientActionsCubit>();
    return showModalBottomSheet<TransferPatientResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: actionsCubit,
        child: TransferPatientBottomSheet(
          sourceId: sourceId,
          sourceName: sourceName,
        ),
      ),
    );
  }

  @override
  State<TransferPatientBottomSheet> createState() =>
      _TransferPatientBottomSheetState();
}

class _TransferPatientBottomSheetState
    extends State<TransferPatientBottomSheet> {
  static const _confirmWord = 'confirm';

  final TextEditingController _confirmController = TextEditingController();
  Patient? _selectedTarget;
  List<Patient> _lookupResults = [];
  bool _isSearching = false;
  bool _deleteSource = false;

  bool get _canConfirm =>
      _selectedTarget?.id != null &&
      _confirmController.text.trim().toLowerCase() == _confirmWord;

  @override
  void dispose() {
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _onSearchChanged(String query) async {
    if (query.trim().length < 2) {
      setState(() => _lookupResults = []);
      return;
    }
    setState(() => _isSearching = true);
    try {
      final result =
          await sl<PatientRepo>().getAllPatients(page: 1, search: query);
      if (!mounted) return;
      setState(() {
        _lookupResults =
            result.patients.where((p) => p.id != widget.sourceId).toList();
        _isSearching = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSearching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocListener<PatientActionsCubit, PatientActionsState>(
      listenWhen: (previous, current) =>
          current.actionType == PatientActionType.transfer,
      listener: (context, state) {
        if (state.isTransferSuccess) {
          Navigator.pop(context, state.transferResult);
        } else if (state.isTransferError) {
          SnackbarService.showError(context,
              message: state.errorMessage ?? "Failed to transfer patient");
        }
      },
      child: Container(
        padding: EdgeInsets.fromLTRB(
            20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Transfer Patient",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const HeightSpacer(size: 6),
              Text(
                "Move all records${widget.sourceName != null ? ' from ${widget.sourceName}' : ''} "
                "into another patient profile.",
                style: TextStyle(fontSize: 13, color: theme.hintColor),
              ),
              const HeightSpacer(size: 20),
              const Text("Transfer to patient",
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const HeightSpacer(size: 8),
              DropdownItem<Patient>(
                items: _lookupResults,
                radius: 30,
                isShadow: false,
                color: theme.cardColor,
                hintText: "Search and select a patient...",
                itemAsString: (p) =>
                    "${p.name ?? 'N/A'}${p.serialNumber != null ? ' (#${p.serialNumber})' : ''}",
                onItemSelected: (p) => setState(() => _selectedTarget = p),
                onChanged: _onSearchChanged,
                selectedValue: _selectedTarget?.name,
                isLoading: _isSearching,
              ),
              const HeightSpacer(size: 20),
              const Text(
                "This action is irreversible and cannot be undone. All data "
                "from this profile will be transferred to the selected profile.",
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
              ),
              const HeightSpacer(size: 10),
              RichText(
                text: TextSpan(
                  style: TextStyle(
                      fontSize: 14,
                      color: theme.textTheme.bodyMedium?.color ?? Colors.black),
                  children: const [
                    TextSpan(text: "Type "),
                    TextSpan(
                        text: "confirm",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: " to proceed"),
                  ],
                ),
              ),
              const HeightSpacer(size: 8),
              TextField(
                controller: _confirmController,
                autocorrect: false,
                decoration: InputDecoration(
                  hintText: "confirm",
                  filled: true,
                  fillColor: theme.cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const HeightSpacer(size: 12),
              CheckboxListTile(
                value: _deleteSource,
                onChanged: (v) => setState(() => _deleteSource = v ?? false),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                title: const Text("Delete current patient"),
              ),
              const HeightSpacer(size: 20),
              BlocBuilder<PatientActionsCubit, PatientActionsState>(
                builder: (context, state) {
                  final isLoading = state.state == PatientActionsStatus.loading &&
                      state.actionType == PatientActionType.transfer;
                  return Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed:
                              isLoading ? null : () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                          ),
                          child: const Text("Cancel"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: (!_canConfirm || isLoading)
                              ? null
                              : () {
                                  context.read<PatientActionsCubit>().add(
                                        TransferPatientEvent(
                                          sourceId: widget.sourceId,
                                          targetId: _selectedTarget!.id!,
                                          deleteSource: _deleteSource,
                                        ),
                                      );
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2))
                              : const Text("Transfer",
                                  style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
