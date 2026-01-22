import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../core/utils/services_locator.dart';
import '../../../../../core/utils/snackbar_service.dart';
import '../../../../../core/widgets/custom_buttons.dart';
import '../../../../../core/widgets/custom_freeze_loading.dart';
import '../../../data/model/clinics_model.dart';
import '../../manager/clinic_actions_cubit/clinic_actions_cubit.dart';
import '../../manager/get_single_clinic_cubit/get_single_clinic_cubit.dart';

/// Enum to define the mode of the clinic form dialog
enum ClinicFormMode { add, edit, view }

/// A unified dialog for adding, editing, and viewing clinic details
/// This eliminates code duplication between add and edit dialogs
/// GetSingleClinicCubit is provided internally when needed (edit/view modes)
class ClinicFormDialog extends StatefulWidget {
  final ClinicFormMode mode;
  final String? clinicId; // Required for edit and view modes
  final ClinicActionsCubit actionsCubit;

  const ClinicFormDialog({
    super.key,
    required this.mode,
    required this.actionsCubit,
    this.clinicId,
  }) : assert(
          mode == ClinicFormMode.add || clinicId != null,
          'clinicId is required for edit and view modes',
        );

  @override
  State<ClinicFormDialog> createState() => _ClinicFormDialogState();
}

class _ClinicFormDialogState extends State<ClinicFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isReadOnly = false;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  /// Initialize the form based on the mode
  void _initializeForm() {
    if (widget.mode == ClinicFormMode.view) {
      _isReadOnly = true;
    }

    if (widget.mode != ClinicFormMode.add) {
      _fetchClinicData();
    }
  }

  /// Fetch clinic data for edit and view modes
  Future<void> _fetchClinicData() async {
    if (widget.clinicId != null) {
      context
          .read<GetSingleClinicCubit>()
          .add(GetClinicByIdEvent(widget.clinicId!));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Toggle between read-only and edit mode
  void _toggleEditMode() {
    setState(() {
      _isReadOnly = !_isReadOnly;
    });
  }

  /// Submit the form
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Show loading dialog
    customLoading(context, "");

    // Check internet connection
    final hasConnection = await InternetConnection().hasInternetAccess;
    if (!mounted) return;

    if (!hasConnection) {
      Navigator.of(context).pop(); // Close loading dialog
      SnackbarService.showError(
        context,
        message: "No Internet Connection",
      );
      return;
    }

    // Create clinic model
    final clinic = Clinic(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
    );

    // Dispatch appropriate event based on mode
    if (widget.mode == ClinicFormMode.add) {
      widget.actionsCubit.add(AddClinicEvent(clinic));
    } else if (widget.mode == ClinicFormMode.edit ||
        widget.mode == ClinicFormMode.view) {
      widget.actionsCubit.add(UpdateClinicEvent(
        clinicId: widget.clinicId!,
        clinic: clinic,
      ));
    }
  }

  /// Get the dialog title based on mode
  String get _dialogTitle {
    switch (widget.mode) {
      case ClinicFormMode.add:
        return 'Add Clinic';
      case ClinicFormMode.edit:
        return 'Edit Clinic';
      case ClinicFormMode.view:
        return 'Clinic Details';
    }
  }

  /// Build shimmer loading effect
  Widget _buildShimmer(Widget child) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: child,
    );
  }

  /// Build shimmer placeholder for text fields
  Widget _buildShimmerField() {
    return _buildShimmer(
      Container(
        width: MediaQuery.sizeOf(context).width,
        height: 60,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          color: Theme.of(context).cardColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // Listen to actions cubit for add/update/delete results
        BlocListener<ClinicActionsCubit, ClinicActionsState>(
          bloc: widget.actionsCubit,
          listener: (context, state) {
            // Close loading dialog if it's open
            if (state.isSuccess || state.isError) {
              Navigator.of(context).pop(); // Close loading dialog
            }

            // Handle success
            if (state.isAddSuccess || state.isUpdateSuccess) {
              SnackbarService.showSuccess(
                context,
                message:
                    state.successMessage ?? 'Operation completed successfully',
              );
              Navigator.of(context).pop(); // Go back to list
            }

            // Handle error
            if (state.isAddError || state.isUpdateError) {
              SnackbarService.showError(
                context,
                message: state.errorMessage ?? 'An error occurred',
              );
            }

            // Handle no connection
            if (state.noConnection) {
              SnackbarService.showWarning(
                context,
                message: state.errorMessage ?? 'No internet connection',
              );
            }
          },
        ),

        // Listen to single clinic cubit for fetching clinic data (edit/view modes)
        if (widget.mode != ClinicFormMode.add)
          BlocListener<GetSingleClinicCubit, GetSingleClinicState>(
            listener: (context, state) {
              if (state.isSuccess && state.clinic != null) {
                _nameController.text = state.clinic?.name ?? '';
                _descriptionController.text = state.clinic?.description ?? '';
              }

              if (state.isError) {
                SnackbarService.showError(
                  context,
                  message: state.errorMessage ?? 'Failed to load clinic data',
                );
              }
            },
          ),
      ],
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: _buildDialogContent(),
      ),
    );
  }

  Widget _buildDialogContent() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        // Add subtle border in dark mode for better definition
        border: isDark
            ? Border.all(
                color: Colors.white.withValues(alpha:0.1),
                width: 1,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha:0.5)
                : Colors.black.withValues(alpha:0.15),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: 2,
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            const Divider(),
            const SizedBox(height: 16),
            _buildForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          _dialogTitle,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Row(
          children: [
            // Show edit button only in view mode
            if (widget.mode == ClinicFormMode.view && _isReadOnly)
              IconButton(
                onPressed: _toggleEditMode,
                icon: const Icon(Icons.edit),
                splashRadius: 20,
              ),
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close),
              splashRadius: 20,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildForm() {
    // Show loading state for edit/view modes
    if (widget.mode != ClinicFormMode.add) {
      return BlocBuilder<GetSingleClinicCubit, GetSingleClinicState>(
        builder: (context, state) {
          final isLoading = state.isLoading;

          return Form(
            key: _formKey,
            child: Column(
              children: [
                _buildNameField(isLoading),
                const SizedBox(height: 16),
                _buildDescriptionField(isLoading),
                const SizedBox(height: 24),
                if (!_isReadOnly) _buildSubmitButton(),
              ],
            ),
          );
        },
      );
    }

    // For add mode, no loading state needed
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildNameField(false),
          const SizedBox(height: 16),
          _buildDescriptionField(false),
          const SizedBox(height: 24),
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildNameField(bool isLoading) {
    if (isLoading) {
      return _buildShimmerField();
    }

    return TextFormField(
      controller: _nameController,
      cursorColor: Theme.of(context).textTheme.bodyLarge?.color,
      readOnly: _isReadOnly,
      decoration: InputDecoration(
        hintText: 'Enter Title',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        prefixIcon: Icon(Icons.business,
            color: Theme.of(context).iconTheme.color?.withValues(alpha:0.6)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter a title';
        }
        return null;
      },
    );
  }

  Widget _buildDescriptionField(bool isLoading) {
    if (isLoading) {
      return _buildShimmerField();
    }

    return TextFormField(
      controller: _descriptionController,
      cursorColor: Theme.of(context).textTheme.bodyLarge?.color,
      readOnly: _isReadOnly,
      decoration: InputDecoration(
        hintText: 'Enter Description',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        prefixIcon: Icon(Icons.description,
            color: Theme.of(context).iconTheme.color?.withValues(alpha:0.6)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter a description';
        }
        return null;
      },
    );
  }

  Widget _buildSubmitButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CoolDownButton(
          onTap: _submitForm,
          text: widget.mode == ClinicFormMode.add ? 'Submit' : 'Update',
        ),
      ],
    );
  }
}

/// Helper function to show the clinic form dialog
/// GetSingleClinicCubit is provided internally when needed (edit/view modes)
void showClinicFormDialog(
  BuildContext context, {
  required ClinicFormMode mode,
  required ClinicActionsCubit actionsCubit,
  String? clinicId,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) {
      // For edit/view modes, provide GetSingleClinicCubit
      if (mode != ClinicFormMode.add) {
        return BlocProvider(
          create: (_) => sl<GetSingleClinicCubit>(),
          child: ClinicFormDialog(
            mode: mode,
            actionsCubit: actionsCubit,
            clinicId: clinicId,
          ),
        );
      }

      // For add mode, no need for GetSingleClinicCubit
      return ClinicFormDialog(
        mode: mode,
        actionsCubit: actionsCubit,
        clinicId: clinicId,
      );
    },
  );
}
