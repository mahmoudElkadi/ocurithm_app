import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocurithm/core/Network/shared.dart';
import 'package:ocurithm/core/utils/capability_services.dart';
import 'package:ocurithm/core/utils/services_locator.dart';
import 'package:ocurithm/core/utils/snackbar_service.dart';
import 'package:ocurithm/core/widgets/DropdownPackage.dart';
import 'package:ocurithm/core/widgets/choose_hours_range.dart';
import 'package:ocurithm/core/widgets/custom_buttons.dart';
import 'package:ocurithm/core/widgets/custom_freeze_loading.dart';
import 'package:ocurithm/core/widgets/manage_capabilities.dart';
import 'package:ocurithm/core/widgets/work_day_selector.dart';
import 'package:ocurithm/generated/l10n.dart';
import 'package:ocurithm/modules/Branch/data/model/add_branch_model.dart';
import 'package:ocurithm/modules/Branch/presentation/manager/branch_actions_cubit/branch_actions_cubit.dart';
import 'package:ocurithm/modules/Branch/presentation/manager/get_single_branch_cubit/get_single_branch_cubit.dart';
import 'package:ocurithm/modules/Clinics/data/model/clinics_model.dart';
import 'package:ocurithm/modules/Clinics/presentation/manager/get_clinics_cubit/get_clinics_cubit.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../core/utils/colors.dart';

/// Enum to define the mode of the branch form dialog
enum BranchFormMode { add, edit, view }

/// A unified dialog for adding, editing, and viewing branch details
/// This eliminates code duplication between add and edit dialogs
/// GetSingleBranchCubit is provided internally when needed (edit/view modes)
class BranchFormDialog extends StatefulWidget {
  final BranchFormMode mode;
  final String? branchId; // Required for edit and view modes
  final BranchActionsCubit actionsCubit;
  final ClinicsModel? clinics; // Pass clinics data from parent

  const BranchFormDialog({
    super.key,
    required this.mode,
    required this.actionsCubit,
    this.branchId,
    this.clinics,
  }) : assert(
          mode == BranchFormMode.add || branchId != null,
          'branchId is required for edit and view modes',
        );

  @override
  State<BranchFormDialog> createState() => _BranchFormDialogState();
}

class _BranchFormDialogState extends State<BranchFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();

  List selectedDays = [];
  String openingTime = "08:00";
  String closingTime = "18:00";
  Clinic? selectedClinic;
  bool clinicValidation = true;
  bool weekDayValidation = true;
  bool _isReadOnly = false;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  /// Initialize the form based on the mode
  void _initializeForm() {
    if (widget.mode == BranchFormMode.view) {
      _isReadOnly = true;
    }

    // Set clinic if user doesn't have manageCapability
    if (!CacheHelper.getStringList(key: "capabilities")
        .contains("manageCapability")) {
      selectedClinic = CacheHelper.getUser("user")?.clinic;
    }

    if (widget.mode != BranchFormMode.add) {
      _fetchBranchData();
    }
  }

  /// Fetch branch data for edit and view modes
  Future<void> _fetchBranchData() async {
    if (widget.branchId != null) {
      context
          .read<GetSingleBranchCubit>()
          .add(GetBranchByIdEvent(widget.branchId!));
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
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
    setState(() {
      clinicValidation = selectedClinic != null;
      weekDayValidation = selectedDays.isNotEmpty;
    });

    if (!_formKey.currentState!.validate() ||
        !clinicValidation ||
        !weekDayValidation) {
      return;
    }

    // Show loading dialog
    customLoading(
        context,
        widget.mode == BranchFormMode.add
            ? "Adding Branch..."
            : "Updating Branch...");

    // Create branch model
    final branchModel = AddBranchModel(
      code: _codeController.text.trim(),
      name: _nameController.text.trim(),
      address: _addressController.text.trim(),
      workDays: selectedDays,
      openTime: openingTime,
      closeTime: closingTime,
      clinic: selectedClinic,
      phone: _phoneController.text.trim(),
    );

    // Dispatch appropriate event based on mode
    if (widget.mode == BranchFormMode.add) {
      widget.actionsCubit.add(AddBranchEvent(branchModel));
    } else if (widget.mode == BranchFormMode.edit) {
      widget.actionsCubit.add(UpdateBranchEvent(
        branchId: widget.branchId!,
        addBranchModel: branchModel,
      ));
    }
  }

  /// Get the dialog title based on mode
  String get _dialogTitle {
    switch (widget.mode) {
      case BranchFormMode.add:
        return 'Add New Branch';
      case BranchFormMode.edit:
        return 'Edit Branch';
      case BranchFormMode.view:
        return 'Branch Details';
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
        BlocListener<BranchActionsCubit, BranchActionsState>(
          bloc: widget.actionsCubit,
          listener: (context, state) {
            // Only handle success, error, and noConnection states to dismiss loading
            if (state.state == BranchActionsStatus.loading) {
              return;
            }

            // Pop the loading dialog if it's open
            // We check if the state is NOT initial and NOT loading
            if (state.state != BranchActionsStatus.initial) {
              Navigator.of(context).pop();
            }

            // Handle Success
            if (state.isSuccess) {
              SnackbarService.showSuccess(
                context,
                message:
                    state.successMessage ?? 'Operation completed successfully',
              );
              // Pop the Form Dialog with true to indicate success
              Navigator.of(context).pop(true);
            }

            // Handle Error
            if (state.isError) {
              SnackbarService.showError(
                context,
                message: state.errorMessage ?? 'An error occurred',
              );
            }

            // Handle No Connection
            if (state.noConnection) {
              SnackbarService.showWarning(
                context,
                message: state.errorMessage ?? 'No internet connection',
              );
            }
          },
        ),

        // Listen to single branch cubit for fetching branch data (edit/view modes)
        if (widget.mode != BranchFormMode.add)
          BlocListener<GetSingleBranchCubit, GetSingleBranchState>(
            listener: (context, state) {
              if (state.isSuccess && state.branch != null) {
                _codeController.text = state.branch?.code ?? '';
                _nameController.text = state.branch?.name ?? '';
                _addressController.text = state.branch?.address ?? '';
                _phoneController.text = state.branch?.phone ?? '';
                selectedDays = state.branch?.workDays ?? [];
                openingTime = state.branch?.openTime ?? "08:00";
                closingTime = state.branch?.closeTime ?? "18:00";
                selectedClinic = state.branch?.clinic;
                setState(() {});
              }

              if (state.isError) {
                SnackbarService.showError(
                  context,
                  message: state.errorMessage ?? 'Failed to load branch data',
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
    return GestureDetector(
      onTap: () => WidgetsBinding.instance.focusManager.primaryFocus!.unfocus(),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          // Add subtle border in dark mode for better definition
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
            if (widget.mode == BranchFormMode.view && _isReadOnly)
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
    if (widget.mode != BranchFormMode.add) {
      return BlocBuilder<GetSingleBranchCubit, GetSingleBranchState>(
        builder: (context, state) {
          final isLoading = state.isLoading;

          return Form(
            key: _formKey,
            child: Column(
              children: [
                if (CacheHelper.getStringList(key: "capabilities")
                    .contains("manageCapability"))
                  _buildClinicDropdown(isLoading),
                if (CacheHelper.getStringList(key: "capabilities")
                    .contains("manageCapability"))
                  const SizedBox(height: 16),
                _buildCodeField(isLoading),
                const SizedBox(height: 16),
                _buildNameField(isLoading),
                const SizedBox(height: 16),
                _buildAddressField(isLoading),
                const SizedBox(height: 16),
                _buildPhoneField(isLoading),
                const SizedBox(height: 16),
                _buildWorkDaysSelector(isLoading),
                const SizedBox(height: 16),
                _buildBusinessHoursSelector(isLoading),
                const SizedBox(height: 24),
                if (!_isReadOnly)
                  manageCapability(
                      capability: 'manageBranches',
                      child: _buildSubmitButton()),
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
          manageCapability(
              capability: 'manageCapability',
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildClinicDropdown(false),
              )),
          _buildCodeField(false),
          const SizedBox(height: 16),
          _buildNameField(false),
          const SizedBox(height: 16),
          _buildAddressField(false),
          const SizedBox(height: 16),
          _buildPhoneField(false),
          const SizedBox(height: 16),
          _buildWorkDaysSelector(false),
          const SizedBox(height: 16),
          _buildBusinessHoursSelector(false),
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

    // If user has permission, use BlocBuilder to get clinics from cubit
    if (CapabilityServices.hasCapability('manageCapability')) {
      return BlocBuilder<GetClinicsCubit, GetClinicsState>(
        builder: (context, clinicsState) {
          return DropdownItem(
            radius: 8,
            border: Colorz.grey,
            color: Theme.of(context).cardColor,
            isShadow: false,
            height: 14,
            iconData: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colorz.grey,
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
                  selectedClinic = item;
                });
              }
            },
            isLoading: clinicsState.isLoading,
          );
        },
      );
    }

    // Fallback: use widget.clinics if no permission (shouldn't happen)
    return DropdownItem(
      radius: 8,
      border: Colorz.grey,
      color: Theme.of(context).cardColor,
      isShadow: false,
      height: 14,
      iconData: Icon(
        Icons.keyboard_arrow_down_rounded,
        color: Colorz.grey,
      ),
      items: widget.clinics?.clinics,
      isValid: clinicValidation,
      validateText: 'Please choose a clinic',
      selectedValue: selectedClinic?.name,
      hintText: 'Select Clinic',
      itemAsString: (item) => item.name.toString(),
      onItemSelected: (item) {
        if (!_isReadOnly) {
          setState(() {
            selectedClinic = item;
          });
        }
      },
      isLoading: widget.clinics == null,
    );
  }

  Widget _buildCodeField(bool isLoading) {
    if (isLoading) {
      return _buildShimmerField();
    }

    return TextFormField(
      controller: _codeController,
      cursorColor: Theme.of(context).textTheme.bodyLarge?.color,
      readOnly: _isReadOnly,
      enabled: widget.mode != BranchFormMode.edit,
      decoration: InputDecoration(
        labelText: 'Code',
        hintText: 'Enter code',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        prefixIcon: Icon(
          Icons.code,
          color: Theme.of(context).iconTheme.color?.withValues(alpha: 0.6),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter a code';
        }
        return null;
      },
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
        labelText: 'Name',
        hintText: 'Enter name',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        prefixIcon: Icon(
          Icons.person,
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

  Widget _buildAddressField(bool isLoading) {
    if (isLoading) {
      return _buildShimmerField();
    }

    return TextFormField(
      controller: _addressController,
      cursorColor: Theme.of(context).textTheme.bodyLarge?.color,
      readOnly: _isReadOnly,
      decoration: InputDecoration(
        labelText: 'Address',
        hintText: 'Enter address',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        prefixIcon: Icon(
          Icons.location_on,
          color: Theme.of(context).iconTheme.color?.withValues(alpha: 0.6),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter an address';
        }
        return null;
      },
    );
  }

  Widget _buildPhoneField(bool isLoading) {
    if (isLoading) {
      return _buildShimmerField();
    }

    return TextFormField(
      controller: _phoneController,
      cursorColor: Theme.of(context).textTheme.bodyLarge?.color,
      readOnly: _isReadOnly,
      decoration: InputDecoration(
        labelText: 'Phone Number',
        hintText: 'Enter phone number',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        prefixIcon: Icon(
          Icons.phone,
          color: Theme.of(context).iconTheme.color?.withValues(alpha: 0.6),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
      ),
      keyboardType: TextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter a phone number';
        } else if (!RegExp(r'^01[0125][0-9]{8}$').hasMatch(value)) {
          return S.of(context).invalidPhoneNumber;
        }
        return null;
      },
    );
  }

  Widget _buildWorkDaysSelector(bool isLoading) {
    if (isLoading) {
      return _buildShimmerField();
    }

    return WorkDaysSelector(
      onDaysSelected: (List days) {
        if (!_isReadOnly) {
          setState(() {
            selectedDays = days;
          });
        }
      },
      isValid: weekDayValidation,
      initialSelectedDays: selectedDays,
    );
  }

  Widget _buildBusinessHoursSelector(bool isLoading) {
    if (isLoading) {
      return _buildShimmerField();
    }

    return BusinessHoursSelector(
      onTimeRangeSelected: (openTime, closeTime) {
        if (!_isReadOnly) {
          openingTime =
              '${openTime.hour.toString().padLeft(2, '0')}:${openTime.minute.toString().padLeft(2, '0')}';
          closingTime =
              '${closeTime.hour.toString().padLeft(2, '0')}:${closeTime.minute.toString().padLeft(2, '0')}';
        }
      },
      use24HourFormat: true,
      initialOpenTime: TimeOfDay(
        hour: int.parse(openingTime.split(':')[0]),
        minute: int.parse(openingTime.split(':')[1]),
      ),
      initialCloseTime: TimeOfDay(
        hour: int.parse(closingTime.split(':')[0]),
        minute: int.parse(closingTime.split(':')[1]),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CoolDownButton(
          onTap: _submitForm,
          text: widget.mode == BranchFormMode.add ? 'Submit' : 'Update',
        ),
      ],
    );
  }
}

/// Helper function to show the branch form dialog
/// GetSingleBranchCubit and GetClinicsCubit are provided internally when needed
void showBranchFormDialog(
  BuildContext context, {
  required BranchFormMode mode,
  required BranchActionsCubit actionsCubit,
  String? branchId,
  ClinicsModel? clinics,
}) {
  // Check if user has permission to manage capabilities (needs clinic selection)
  final needsClinicCubit = CacheHelper.getStringList(key: "capabilities")
      .contains("manageCapability");

  log('needsClinicCubit $needsClinicCubit');

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) {
      Widget dialog;

      // For edit/view modes, provide GetSingleBranchCubit
      if (mode != BranchFormMode.add) {
        dialog = BlocProvider(
          create: (_) => sl<GetSingleBranchCubit>(),
          child: BranchFormDialog(
            mode: mode,
            actionsCubit: actionsCubit,
            branchId: branchId,
            clinics: clinics,
          ),
        );
      } else {
        // For add mode, no need for GetSingleBranchCubit
        dialog = BranchFormDialog(
          mode: mode,
          actionsCubit: actionsCubit,
          branchId: branchId,
          clinics: clinics,
        );
      }

      // If user needs clinic selection, provide GetClinicsCubit
      if (needsClinicCubit) {
        return BlocProvider(
          create: (_) => sl<GetClinicsCubit>()
            ..add(GetAllClinicsEvent(noPagination: true)),
          child: dialog,
        );
      }

      return dialog;
    },
  );
}
