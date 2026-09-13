import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocurithm/core/Network/shared.dart';
import 'package:ocurithm/core/utils/capability_keys.dart';
import 'package:ocurithm/core/utils/network_connection.dart';
import 'package:ocurithm/core/utils/services_locator.dart';
import 'package:ocurithm/core/utils/snackbar_service.dart';
import 'package:ocurithm/core/widgets/custom_buttons.dart';
import 'package:ocurithm/core/widgets/custom_freeze_loading.dart';
import 'package:ocurithm/core/widgets/DropdownPackage.dart';
import 'package:ocurithm/modules/Clinics/data/model/clinics_model.dart';
import 'package:ocurithm/modules/Clinics/presentation/manager/get_clinics_cubit/get_clinics_cubit.dart';

import '../../../data/model/save_reason_model.dart';
import '../../manager/save_reason_actions_cubit/save_reason_actions_cubit.dart';

enum SaveReasonFormMode { add, edit }

/// Add / edit dialog for one save reason.
///
/// The existing reason is handed in from the list rather than re-fetched: the list
/// already carries every field the form edits.
class SaveReasonFormDialog extends StatefulWidget {
  final SaveReasonFormMode mode;
  final SaveReason? saveReason;
  final SaveReasonActionsCubit actionsCubit;

  const SaveReasonFormDialog({
    super.key,
    required this.mode,
    required this.actionsCubit,
    this.saveReason,
  }) : assert(
          mode == SaveReasonFormMode.add || saveReason != null,
          'saveReason is required in edit mode',
        );

  @override
  State<SaveReasonFormDialog> createState() => _SaveReasonFormDialogState();
}

class _SaveReasonFormDialogState extends State<SaveReasonFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();

  Clinic? selectedClinic;
  bool clinicValidation = true;
  bool _allowCycloplegicRefraction = false;

  /// A clinic user has exactly one clinic, so the picker is hidden and theirs is
  /// used; only a super admin chooses where the reason is filed.
  bool get _isSuperAdmin => CacheHelper.getStringList(key: "capabilities")
      .contains(CapabilityKeys.manageCapability);

  @override
  void initState() {
    super.initState();

    if (!_isSuperAdmin) {
      selectedClinic = CacheHelper.getUser("user")?.clinic;
    }

    if (widget.mode == SaveReasonFormMode.edit) {
      _nameController.text = widget.saveReason?.name ?? '';
      _priceController.text = (widget.saveReason?.price ?? 0).toString();
      _allowCycloplegicRefraction =
          widget.saveReason?.allowCycloplegicRefraction ?? false;
    } else {
      _priceController.text = '0';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    setState(() {
      clinicValidation = !_isSuperAdmin || selectedClinic != null;
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!clinicValidation) {
      return;
    }

    customLoading(context, "");

    final hasConnection = await NetworkStatus().hasInternetConnection();
    if (!mounted) return;

    if (!hasConnection) {
      Navigator.of(context).pop();
      SnackbarService.showError(context, message: "No Internet Connection");
      return;
    }

    final saveReason = SaveReason(
      name: _nameController.text.trim(),
      // Optional for the user; an empty field means no fee rather than no value.
      price: num.tryParse(_priceController.text.trim()) ?? 0,
      allowCycloplegicRefraction: _allowCycloplegicRefraction,
      clinic: widget.mode == SaveReasonFormMode.add ? selectedClinic : null,
    );

    if (widget.mode == SaveReasonFormMode.add) {
      widget.actionsCubit.add(AddSaveReasonEvent(saveReason));
    } else {
      widget.actionsCubit.add(UpdateSaveReasonEvent(
        saveReasonId: widget.saveReason!.id!,
        saveReason: saveReason,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SaveReasonActionsCubit, SaveReasonActionsState>(
      bloc: widget.actionsCubit,
      listener: (context, state) {
        if (state.isSuccess || state.isError || state.noConnection) {
          Navigator.of(context).pop(); // Close the loading dialog
        }

        if (state.isSuccess) {
          Navigator.of(context).pop(); // Close the form
        }
      },
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
      onTap: () => WidgetsBinding.instance.focusManager.primaryFocus?.unfocus(),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: isDark
              ? Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1)
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
          widget.mode == SaveReasonFormMode.add
              ? 'Add New Save Reason'
              : 'Edit Save Reason',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close),
          splashRadius: 20,
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          if (widget.mode == SaveReasonFormMode.add && _isSuperAdmin) ...[
            _buildClinicDropdown(),
            const SizedBox(height: 16),
          ],
          _buildNameField(),
          const SizedBox(height: 16),
          _buildPriceField(),
          const SizedBox(height: 8),
          _buildCycloplegicToggle(),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CoolDownButton(
                onTap: _submitForm,
                text: widget.mode == SaveReasonFormMode.add
                    ? 'Submit'
                    : 'Update',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildClinicDropdown() {
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
            setState(() {
              selectedClinic = item;
            });
          },
          isLoading: clinicsState.isLoading,
        );
      },
    );
  }

  /// The wording is about the *next* visit: ticking this is what lets a doctor record
  /// a cycloplegic refraction after reopening a visit parked for this reason.
  Widget _buildCycloplegicToggle() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        value: _allowCycloplegicRefraction,
        onChanged: (value) =>
            setState(() => _allowCycloplegicRefraction = value),
        title: const Text(
          'Allow cycloplegic refraction',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        subtitle: const Text(
          'The doctor can record a cycloplegic refraction after reopening a visit saved for this reason.',
          style: TextStyle(fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      cursorColor: Theme.of(context).textTheme.bodyLarge?.color,
      decoration: InputDecoration(
        hintText: 'e.g. Waiting for investigation results',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        prefixIcon: Icon(
          Icons.bookmark_outline,
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
        if (value.trim().length < 2) {
          return 'Name must be at least 2 characters';
        }
        return null;
      },
    );
  }

  Widget _buildPriceField() {
    return TextFormField(
      controller: _priceController,
      cursorColor: Theme.of(context).textTheme.bodyLarge?.color,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
      decoration: InputDecoration(
        hintText: 'Price (optional)',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
          return null;
        }
        final parsed = num.tryParse(value.trim());
        if (parsed == null) {
          return 'Price must be a number';
        }
        if (parsed < 0) {
          return 'Price cannot be negative';
        }
        return null;
      },
    );
  }
}

/// Shows the save-reason form, providing the clinic list only when the user is
/// actually allowed to choose one.
void showSaveReasonFormDialog(
  BuildContext context, {
  required SaveReasonFormMode mode,
  required SaveReasonActionsCubit actionsCubit,
  SaveReason? saveReason,
}) {
  final needsClinicCubit = CacheHelper.getStringList(key: "capabilities")
      .contains(CapabilityKeys.manageCapability);

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) {
      final dialog = SaveReasonFormDialog(
        mode: mode,
        actionsCubit: actionsCubit,
        saveReason: saveReason,
      );

      if (needsClinicCubit && mode == SaveReasonFormMode.add) {
        return BlocProvider(
          create: (_) =>
              sl<GetClinicsCubit>()..add(GetAllClinicsEvent(noPagination: true)),
          child: dialog,
        );
      }

      return dialog;
    },
  );
}
