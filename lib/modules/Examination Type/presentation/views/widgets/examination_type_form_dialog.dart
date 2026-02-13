import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocurithm/core/Network/shared.dart';
import 'package:ocurithm/core/utils/services_locator.dart';
import 'package:ocurithm/core/utils/snackbar_service.dart';
import 'package:ocurithm/core/widgets/DropdownPackage.dart';
import 'package:ocurithm/core/widgets/custom_buttons.dart';
import 'package:ocurithm/core/widgets/custom_freeze_loading.dart';
import 'package:ocurithm/modules/Clinics/data/model/clinics_model.dart';
import 'package:ocurithm/modules/Clinics/presentation/manager/get_clinics_cubit/get_clinics_cubit.dart';
import 'package:shimmer/shimmer.dart';

import '../../../data/model/examination_type_model.dart';
import '../../manager/examination_type_actions_cubit/examination_type_actions_cubit.dart';
import '../../manager/get_single_examination_type_cubit/get_single_examination_type_cubit.dart';

/// Enum to define the mode of the examination type form dialog
enum ExaminationTypeFormMode { add, edit, view }

/// A unified dialog for adding, editing, and viewing examination type details
/// This eliminates code duplication between add and edit dialogs
class ExaminationTypeFormDialog extends StatefulWidget {
  final ExaminationTypeFormMode mode;
  final String? examinationTypeId; // Required for edit and view modes
  final ExaminationTypeActionsCubit actionsCubit;

  const ExaminationTypeFormDialog({
    super.key,
    required this.mode,
    required this.actionsCubit,
    this.examinationTypeId,
  }) : assert(
          mode == ExaminationTypeFormMode.add || examinationTypeId != null,
          'examinationTypeId is required for edit and view modes',
        );

  @override
  State<ExaminationTypeFormDialog> createState() =>
      _ExaminationTypeFormDialogState();
}

class _ExaminationTypeFormDialogState extends State<ExaminationTypeFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _durationController = TextEditingController();

  Clinic? selectedClinic;
  bool clinicValidation = true;
  bool _isReadOnly = false;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  /// Initialize the form based on the mode
  void _initializeForm() {
    if (widget.mode == ExaminationTypeFormMode.view) {
      _isReadOnly = true;
    }

    // Set clinic if user doesn't have manageCapability
    if (!CacheHelper.getStringList(key: "capabilities")
        .contains("manageCapability")) {
      selectedClinic = CacheHelper.getUser("user")?.clinic;
    }

    if (widget.mode != ExaminationTypeFormMode.add) {
      _fetchExaminationTypeData();
    }
  }

  /// Fetch examination type data for edit and view modes
  Future<void> _fetchExaminationTypeData() async {
    if (widget.examinationTypeId != null) {
      context
          .read<GetSingleExaminationTypeCubit>()
          .add(GetExaminationTypeByIdEvent(widget.examinationTypeId!));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  /// Toggle between read-only and edit mode
  void _toggleEditMode() {
    setState(() {
      _isReadOnly = !_isReadOnly;
    });
  }

  // Submit the form
  Future<void> _submitForm() async {
    // Only validate clinic selection in add mode
    if (widget.mode == ExaminationTypeFormMode.add) {
      setState(() {
        clinicValidation = selectedClinic != null;
      });

      if (!clinicValidation) {
        return;
      }
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Show loading dialog
    customLoading(context, "");

    // Create examination type model - only include clinic in add mode
    final examinationType = ExaminationType(
      name: _nameController.text.trim(),
      price: num.tryParse(_priceController.text.trim()),
      duration: num.tryParse(_durationController.text.trim()),
      clinic: selectedClinic,
    );

    // Dispatch appropriate event based on mode
    if (widget.mode == ExaminationTypeFormMode.add) {
      widget.actionsCubit.add(AddExaminationTypeEvent(examinationType));
    } else if (widget.mode == ExaminationTypeFormMode.edit) {
      widget.actionsCubit.add(UpdateExaminationTypeEvent(
        examinationTypeId: widget.examinationTypeId!,
        examinationType: examinationType,
      ));
    }
  }

  /// Get the dialog title based on mode
  String get _dialogTitle {
    switch (widget.mode) {
      case ExaminationTypeFormMode.add:
        return 'Add New Examination Type';
      case ExaminationTypeFormMode.edit:
        return 'Edit Examination Type';
      case ExaminationTypeFormMode.view:
        return 'Examination Type Details';
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
        BlocListener<ExaminationTypeActionsCubit, ExaminationTypeActionsState>(
          bloc: widget.actionsCubit,
          listener: (context, state) {
            // Close loading dialog if it's open
            if (state.status != ExaminationTypeActionStatus.loading &&
                state.status != ExaminationTypeActionStatus.initial) {
              // We check if the dialog is still showing before popping
              Navigator.of(context).pop(); // Close loading dialog
            }

            // Handle success
            if (state.isAddSuccess || state.isUpdateSuccess) {
              Navigator.of(context).pop(); // Close form dialog
            }
          },
        ),

        // Listen to single examination type cubit for fetching data (edit/view modes)
        if (widget.mode != ExaminationTypeFormMode.add)
          BlocListener<GetSingleExaminationTypeCubit,
              GetSingleExaminationTypeState>(
            listener: (context, state) {
              if (state.isSuccess && state.examinationType != null) {
                _nameController.text = state.examinationType?.name ?? '';
                _priceController.text =
                    state.examinationType?.price?.toString() ?? '';
                _durationController.text =
                    state.examinationType?.duration?.toString() ?? '';
                selectedClinic = state.examinationType?.clinic;
                setState(() {});
              }

              if (state.isError) {
                SnackbarService.showError(
                  context,
                  message: state.errorMessage ??
                      'Failed to load examination type data',
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
        border: isDark
            ? Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.5)
                : Colors.black.withValues(alpha: 0.15),
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
            if (widget.mode == ExaminationTypeFormMode.view && _isReadOnly)
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
    if (widget.mode != ExaminationTypeFormMode.add) {
      return BlocBuilder<GetSingleExaminationTypeCubit,
          GetSingleExaminationTypeState>(
        builder: (context, state) {
          final isLoading = state.isLoading;

          return Form(
            key: _formKey,
            child: Column(
              children: [
                // Only show clinic dropdown in add mode
                if (widget.mode == ExaminationTypeFormMode.add &&
                    CacheHelper.getStringList(key: "capabilities")
                        .contains("manageCapability"))
                  _buildClinicDropdown(isLoading),
                if (widget.mode == ExaminationTypeFormMode.add &&
                    CacheHelper.getStringList(key: "capabilities")
                        .contains("manageCapability"))
                  const SizedBox(height: 16),
                _buildNameField(isLoading),
                const SizedBox(height: 16),
                _buildPriceField(isLoading),
                const SizedBox(height: 16),
                _buildDurationField(isLoading),
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
          if (CacheHelper.getStringList(key: "capabilities")
              .contains("manageCapability"))
            _buildClinicDropdown(false),
          if (CacheHelper.getStringList(key: "capabilities")
              .contains("manageCapability"))
            const SizedBox(height: 16),
          _buildNameField(false),
          const SizedBox(height: 16),
          _buildPriceField(false),
          const SizedBox(height: 16),
          _buildDurationField(false),
          const SizedBox(height: 24),
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildClinicDropdown(bool isLoading) {
    if (isLoading) {
      return _buildShimmerField();
    }

    // Check if user has permission to manage capabilities
    final hasmanageCapability = CacheHelper.getStringList(key: "capabilities")
        .contains("manageCapability");

    // If user has permission, use BlocBuilder to get clinics from cubit
    if (hasmanageCapability) {
      return BlocBuilder<GetClinicsCubit, GetClinicsState>(
        builder: (context, clinicsState) {
          return DropdownItem(
            radius: 8,
            border: Theme.of(context).dividerColor,
            color: Theme.of(context).cardColor,
            isShadow: false,
            height: 14,
            iconData: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Theme.of(context).iconTheme.color,
            ),
            items: clinicsState.clinics?.clinics,
            isValid: clinicValidation,
            validateText: 'Please choose a clinic',
            selectedValue: selectedClinic?.name,
            hintText: 'Select Clinic',
            itemAsString: (item) => item.name.toString(),
            onItemSelected: (item) {
              if (!_isReadOnly) {
                setState(() {
                  if (item != "Not Found") {
                    selectedClinic = item;
                  }
                });
              }
            },
            isLoading: clinicsState.isLoading,
          );
        },
      );
    }

    // Fallback: shouldn't happen for examination types
    return const SizedBox.shrink();
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
        hintText: 'Enter name',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        prefixIcon: Icon(
          Icons.medical_services,
          color: Theme.of(context).iconTheme.color?.withValues(alpha: 0.6),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter a name';
        }
        return null;
      },
    );
  }

  Widget _buildPriceField(bool isLoading) {
    if (isLoading) {
      return _buildShimmerField();
    }

    return TextFormField(
      controller: _priceController,
      cursorColor: Theme.of(context).textTheme.bodyLarge?.color,
      readOnly: _isReadOnly,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      decoration: InputDecoration(
        hintText: 'Enter price',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        prefixIcon: Icon(
          Icons.attach_money,
          color: Theme.of(context).iconTheme.color?.withValues(alpha: 0.6),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter a price';
        }
        final price = num.tryParse(value);
        if (price == null || price <= 0) {
          return 'Please enter a valid price';
        }
        return null;
      },
    );
  }

  Widget _buildDurationField(bool isLoading) {
    if (isLoading) {
      return _buildShimmerField();
    }

    return TextFormField(
      controller: _durationController,
      cursorColor: Theme.of(context).textTheme.bodyLarge?.color,
      readOnly: _isReadOnly,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
      decoration: InputDecoration(
        hintText: 'Enter duration (minutes)',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        prefixIcon: Icon(
          Icons.timer,
          color: Theme.of(context).iconTheme.color?.withValues(alpha: 0.6),
        ),
        suffixText: 'min',
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter duration';
        }
        final duration = num.tryParse(value);
        if (duration == null || duration <= 0) {
          return 'Please enter a valid duration';
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
          text:
              widget.mode == ExaminationTypeFormMode.add ? 'Submit' : 'Update',
        ),
      ],
    );
  }
}

/// Helper function to show the examination type form dialog
/// GetSingleExaminationTypeCubit and GetClinicsCubit are provided internally when needed
void showExaminationTypeFormDialog(
  BuildContext context, {
  required ExaminationTypeFormMode mode,
  required ExaminationTypeActionsCubit actionsCubit,
  String? examinationTypeId,
}) {
  // Reset actions state before showing dialog
  actionsCubit.add(ResetExaminationTypeActionsEvent());

  // Check if user has permission to manage capabilities (needs clinic selection)
  final needsClinicCubit = CacheHelper.getStringList(key: "capabilities")
      .contains("manageCapability");

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) {
      Widget dialog;

      // For edit/view modes, provide GetSingleExaminationTypeCubit
      if (mode != ExaminationTypeFormMode.add) {
        dialog = BlocProvider(
          create: (_) => sl<GetSingleExaminationTypeCubit>(),
          child: ExaminationTypeFormDialog(
            mode: mode,
            actionsCubit: actionsCubit,
            examinationTypeId: examinationTypeId,
          ),
        );
      } else {
        // For add mode, no need for GetSingleExaminationTypeCubit
        dialog = ExaminationTypeFormDialog(
          mode: mode,
          actionsCubit: actionsCubit,
          examinationTypeId: examinationTypeId,
        );
      }

      // If user needs clinic selection, provide GetClinicsCubit
      if (needsClinicCubit) {
        return BlocProvider(
          create: (_) => sl<GetClinicsCubit>()..add(GetAllClinicsEvent()),
          child: dialog,
        );
      }

      return dialog;
    },
  );
}
