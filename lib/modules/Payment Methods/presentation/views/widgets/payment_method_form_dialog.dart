import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocurithm/core/Network/shared.dart';
import 'package:ocurithm/core/utils/network_connection.dart';
import 'package:ocurithm/core/utils/services_locator.dart';
import 'package:ocurithm/core/utils/snackbar_service.dart';
import 'package:ocurithm/core/widgets/DropdownPackage.dart';
import 'package:ocurithm/core/widgets/custom_buttons.dart';
import 'package:ocurithm/core/widgets/custom_freeze_loading.dart';
import 'package:ocurithm/modules/Clinics/data/model/clinics_model.dart';
import 'package:ocurithm/modules/Clinics/presentation/manager/get_clinics_cubit/get_clinics_cubit.dart';
import 'package:shimmer/shimmer.dart';

import '../../../data/model/payment_method_model.dart';
import '../../manager/get_single_payment_method_cubit/get_single_payment_method_cubit.dart';
import '../../manager/payment_method_actions_cubit/payment_method_actions_cubit.dart';

/// Enum to define the mode of the payment method form dialog
enum PaymentMethodFormMode { add, edit, view }

/// A unified dialog for adding, editing, and viewing payment method details
/// This eliminates code duplication between add and edit dialogs
class PaymentMethodFormDialog extends StatefulWidget {
  final PaymentMethodFormMode mode;
  final String? paymentMethodId; // Required for edit and view modes
  final PaymentMethodActionsCubit actionsCubit;

  const PaymentMethodFormDialog({
    super.key,
    required this.mode,
    required this.actionsCubit,
    this.paymentMethodId,
  }) : assert(
          mode == PaymentMethodFormMode.add || paymentMethodId != null,
          'paymentMethodId is required for edit and view modes',
        );

  @override
  State<PaymentMethodFormDialog> createState() =>
      _PaymentMethodFormDialogState();
}

class _PaymentMethodFormDialogState extends State<PaymentMethodFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

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
    if (widget.mode == PaymentMethodFormMode.view) {
      _isReadOnly = true;
    }

    // Set clinic if user doesn't have manageCapability
    if (!CacheHelper.getStringList(key: "capabilities")
        .contains("manageCapability")) {
      selectedClinic = CacheHelper.getUser("user")?.clinic;
    }

    if (widget.mode != PaymentMethodFormMode.add) {
      _fetchPaymentMethodData();
    }
  }

  /// Fetch payment method data for edit and view modes
  Future<void> _fetchPaymentMethodData() async {
    if (widget.paymentMethodId != null) {
      context
          .read<GetSinglePaymentMethodCubit>()
          .add(GetPaymentMethodByIdEvent(widget.paymentMethodId!));
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
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
    setState(() {
      clinicValidation = selectedClinic != null;
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Only validate clinic in add mode
    if (widget.mode == PaymentMethodFormMode.add && !clinicValidation) {
      return;
    }

    // Show loading dialog
    customLoading(context, "");

    // Check internet connection
    final hasConnection = await NetworkStatus().hasInternetConnection();
    if (!mounted) return;

    if (!hasConnection) {
      Navigator.of(context).pop(); // Close loading dialog
      SnackbarService.showError(
        context,
        message: "No Internet Connection",
      );
      return;
    }

    // Create payment method model
    // Only include clinic in add mode
    final paymentMethod = PaymentMethod(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      // clinic: widget.mode == PaymentMethodFormMode.add ? selectedClinic : null,
    );

    // Dispatch appropriate event based on mode
    if (widget.mode == PaymentMethodFormMode.add) {
      widget.actionsCubit.add(AddPaymentMethodEvent(paymentMethod));
    } else if (widget.mode == PaymentMethodFormMode.edit) {
      widget.actionsCubit.add(UpdatePaymentMethodEvent(
        paymentMethodId: widget.paymentMethodId!,
        paymentMethod: paymentMethod,
      ));
    }
  }

  /// Get the dialog title based on mode
  String get _dialogTitle {
    switch (widget.mode) {
      case PaymentMethodFormMode.add:
        return 'Add New Payment Method';
      case PaymentMethodFormMode.edit:
        return 'Edit Payment Method';
      case PaymentMethodFormMode.view:
        return 'Payment Method Details';
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
        BlocListener<PaymentMethodActionsCubit, PaymentMethodActionsState>(
          bloc: widget.actionsCubit,
          listener: (context, state) {
            // Close loading dialog if it's open
            if (state.isSuccess || state.isError) {
              Navigator.of(context).pop(); // Close loading dialog
            }

            // Handle success
            if (state.isAddSuccess || state.isUpdateSuccess) {
              Navigator.of(context).pop(); // Close form dialog
            }
          },
        ),

        // Listen to single payment method cubit for fetching data (edit/view modes)
        if (widget.mode != PaymentMethodFormMode.add)
          BlocListener<GetSinglePaymentMethodCubit,
              GetSinglePaymentMethodState>(
            listener: (context, state) {
              if (state.isSuccess && state.paymentMethod != null) {
                _titleController.text = state.paymentMethod?.title ?? '';
                _descriptionController.text =
                    state.paymentMethod?.description ?? '';
                // Don't set selectedClinic in edit mode since it won't be sent
                if (widget.mode == PaymentMethodFormMode.view) {
                  selectedClinic = state.paymentMethod?.clinic;
                }
                setState(() {});
              }

              if (state.isError) {
                SnackbarService.showError(
                  context,
                  message: state.errorMessage ??
                      'Failed to load payment method data',
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
            if (widget.mode == PaymentMethodFormMode.view && _isReadOnly)
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
    if (widget.mode != PaymentMethodFormMode.add) {
      return BlocBuilder<GetSinglePaymentMethodCubit,
          GetSinglePaymentMethodState>(
        builder: (context, state) {
          final isLoading = state.isLoading;

          return Form(
            key: _formKey,
            child: Column(
              children: [
                // Only show clinic dropdown in add mode
                if (widget.mode == PaymentMethodFormMode.add &&
                    CacheHelper.getStringList(key: "capabilities")
                        .contains("manageCapability"))
                  _buildClinicDropdown(isLoading),
                if (widget.mode == PaymentMethodFormMode.add &&
                    CacheHelper.getStringList(key: "capabilities")
                        .contains("manageCapability"))
                  const SizedBox(height: 16),
                _buildTitleField(isLoading),
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
          if (CacheHelper.getStringList(key: "capabilities")
              .contains("manageCapability"))
            _buildClinicDropdown(false),
          if (CacheHelper.getStringList(key: "capabilities")
              .contains("manageCapability"))
            const SizedBox(height: 16),
          _buildTitleField(false),
          const SizedBox(height: 16),
          _buildDescriptionField(false),
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

    // Fallback: shouldn't happen for payment methods
    return const SizedBox.shrink();
  }

  Widget _buildTitleField(bool isLoading) {
    if (isLoading) {
      return _buildShimmerField();
    }

    return TextFormField(
      controller: _titleController,
      cursorColor: Theme.of(context).textTheme.bodyLarge?.color,
      readOnly: _isReadOnly,
      decoration: InputDecoration(
        hintText: 'Enter title',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        prefixIcon: Icon(
          Icons.payment,
          color: Theme.of(context).iconTheme.color?.withValues(alpha: 0.6),
        ),
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
      maxLines: 3,
      decoration: InputDecoration(
        hintText: 'Enter description',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        prefixIcon: Icon(
          Icons.description,
          color: Theme.of(context).iconTheme.color?.withValues(alpha: 0.6),
        ),
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
          text: widget.mode == PaymentMethodFormMode.add ? 'Submit' : 'Update',
        ),
      ],
    );
  }
}

/// Helper function to show the payment method form dialog
/// GetSinglePaymentMethodCubit and GetClinicsCubit are provided internally when needed
void showPaymentMethodFormDialog(
  BuildContext context, {
  required PaymentMethodFormMode mode,
  required PaymentMethodActionsCubit actionsCubit,
  String? paymentMethodId,
}) {
  // Check if user has permission to manage capabilities (needs clinic selection)
  final needsClinicCubit = CacheHelper.getStringList(key: "capabilities")
      .contains("manageCapability");

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) {
      Widget dialog;

      // For edit/view modes, provide GetSinglePaymentMethodCubit
      if (mode != PaymentMethodFormMode.add) {
        dialog = BlocProvider(
          create: (_) => sl<GetSinglePaymentMethodCubit>(),
          child: PaymentMethodFormDialog(
            mode: mode,
            actionsCubit: actionsCubit,
            paymentMethodId: paymentMethodId,
          ),
        );
      } else {
        // For add mode, no need for GetSinglePaymentMethodCubit
        dialog = PaymentMethodFormDialog(
          mode: mode,
          actionsCubit: actionsCubit,
          paymentMethodId: paymentMethodId,
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
