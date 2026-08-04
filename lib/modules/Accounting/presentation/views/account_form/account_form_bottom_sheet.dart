import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocurithm/core/Network/shared.dart';
import 'package:ocurithm/core/utils/app_style.dart';
import 'package:ocurithm/core/utils/capability_keys.dart';
import 'package:ocurithm/core/utils/services_locator.dart';
import 'package:ocurithm/core/utils/snackbar_service.dart';
import 'package:ocurithm/core/widgets/DropdownPackage.dart';
import 'package:ocurithm/core/widgets/height_spacer.dart';
import 'package:ocurithm/core/widgets/text_field.dart';
import 'package:ocurithm/modules/Clinics/presentation/manager/get_clinics_cubit/get_clinics_cubit.dart';

import '../../../data/models/account_model.dart';
import '../../manager/account_actions_cubit/account_actions_cubit.dart';
import '../../manager/account_actions_cubit/account_actions_event.dart';
import '../../manager/account_actions_cubit/account_actions_state.dart';
import '../../manager/account_form_cubit/account_form_cubit.dart';
import '../../manager/account_form_cubit/account_form_state.dart';

class AccountFormBottomSheet extends StatefulWidget {
  final Account? account;

  const AccountFormBottomSheet({super.key, this.account});

  @override
  State<AccountFormBottomSheet> createState() => _AccountFormBottomSheetState();
}

class _AccountFormBottomSheetState extends State<AccountFormBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _balanceController;

  bool get _isEditMode => widget.account != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.account?.name);
    _balanceController = TextEditingController(
        text: widget.account?.initialBalance?.toString() ?? "0");
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  void _handleSubmit(AccountFormState formState) {
    if (!_formKey.currentState!.validate()) return;

    if (formState.isSuperAdmin && formState.selectedClinicId == null) {
      SnackbarService.showError(context, message: "Please select a clinic");
      return;
    }
    if (formState.selectedAccountType != 'other') {
      final bool hasOwner = _isEditMode 
          ? (formState.selectedOwnerId != null || widget.account?.entityId != null)
          : (formState.selectedOwnerId != null);
          
      if (!hasOwner) {
        SnackbarService.showError(context, message: "Please select an owner");
        return;
      }
    }

    final cubit = context.read<AccountActionsCubit>();
    final double balance = double.tryParse(_balanceController.text) ?? 0;

    if (_isEditMode) {
      cubit.add(UpdateAccountEvent(
        id: widget.account!.id!,
        name: _nameController.text.trim(),
        isActive: widget.account!.isActive,
        accountType: formState.selectedAccountType ?? widget.account?.accountType,
        entityId: formState.selectedOwnerId ?? widget.account?.entityId,
      ));
    } else {
      cubit.add(CreateAccountEvent(
        name: _nameController.text.trim(),
        accountType: formState.selectedAccountType!,
        entityId: formState.selectedOwnerId,
        initialBalance: balance,
        clinicId: formState.selectedClinicId,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final capabilities = CacheHelper.getStringList(key: "capabilities");
    final bool isSuperAdmin =
        capabilities.contains(CapabilityKeys.manageCapability);

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<AccountFormCubit>(param1: isSuperAdmin)
            ..onAccountTypeChanged(widget.account?.accountType)
            ..onClinicChanged(widget.account?.clinic?.id),
        ),
        BlocProvider(
            create: (_) => sl<GetClinicsCubit>()
              ..add(GetAllClinicsEvent(noPagination: true))),
      ],
      child: BlocListener<AccountActionsCubit, AccountActionsState>(
        listener: (context, state) {
          if (state.status == AccountActionsStatus.success) {
            Navigator.pop(context);
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
            child: Form(
              key: _formKey,
              child: BlocBuilder<AccountFormCubit, AccountFormState>(
                builder: (context, formState) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _isEditMode ? "Edit Account" : "Add Account",
                                style: appStyle(context, 20, theme.brightness == Brightness.dark ? Colors.white : Colors.black, FontWeight.w800),
                              ),
                              Text(
                                _isEditMode ? "Update the account details below." : "Enter the account details below.",
                                style: appStyle(context, 12, Colors.grey, FontWeight.w500),
                              ),
                            ],
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close, color: Colors.grey),
                          ),
                        ],
                      ),
                      const HeightSpacer(size: 24),
                      
                      BlocBuilder<GetClinicsCubit, GetClinicsState>(
                        builder: (context, state) {
                          final clinics = state.clinics?.clinics ?? [];
                          final selectedClinic = clinics.where((c) => c.id == (formState.selectedClinicId ?? widget.account?.clinic?.id)).firstOrNull;
                          
                          return DropdownItem(
                            radius: 15,
                            color: theme.cardColor,
                            isShadow: false,
                            border: Colors.grey.shade300,
                            label: "Clinic",
                            items: clinics,
                            selectedValue: selectedClinic?.name,
                            hintText: "Select Clinic",
                            itemAsString: (item) => (item as dynamic).name,
                            onItemSelected: (item) => context
                                .read<AccountFormCubit>()
                                .onClinicChanged((item as dynamic).id),
                            isLoading: state.isLoading,
                            // In edit mode, usually clinic is fixed, but image shows it editable
                            // I'll keep it editable if superAdmin
                          );
                        },
                      ),
                      const HeightSpacer(size: 16),
                      
                      DropdownItem(
                        radius: 15,
                        color: theme.cardColor,
                        isShadow: false,
                        border: Colors.grey.shade300,
                        label: "Account Type",
                        items: const [
                          "clinic", "doctor", "consultant", "receptionist", 
                          "branch", "paymentMethod", "supplier", "other"
                        ],
                        selectedValue: _isEditMode ? widget.account?.accountType : formState.selectedAccountType,
                        hintText: "Select account type",
                        itemAsString: (item) => (item as String).toUpperCase(),
                        onItemSelected: (item) => context
                            .read<AccountFormCubit>()
                            .onAccountTypeChanged(item as String),
                        isLoading: false,
                        readOnly: false, // Type is now editable as requested
                      ),
                      const HeightSpacer(size: 16),
                      
                      DropdownItem(
                        radius: 15,
                        color: theme.cardColor,
                        isShadow: false,
                        border: Colors.grey.shade300,
                        label: "Account Owner",
                        items: formState.ownerOptions,
                        selectedValue: formState.ownerOptions.where((o) => o.id == (formState.selectedOwnerId ?? widget.account?.entityId)).firstOrNull?.name ?? (_isEditMode ? widget.account?.name : null),
                        hintText: "Select Owner",
                        itemAsString: (item) => (item as dynamic).name,
                        onItemSelected: (item) => context
                            .read<AccountFormCubit>()
                            .onOwnerChanged((item as dynamic).id),
                        isLoading: formState.status == AccountFormStatus.loading,
                        readOnly: !formState.isOwnerEnabled,
                      ),
                      const HeightSpacer(size: 16),
                      
                      TextField2(
                        controller: _nameController,
                        text: "Account Name",
                        required: true,
                        radius: 15,
                        fillColor: theme.cardColor,
                        isShadow: false,
                        border: Colors.grey.shade300,
                        hintText: "Enter account name",
                        validator: (v) =>
                            v == null || v.isEmpty ? "Name is required" : null,
                      ),
                      
                      if (!_isEditMode) ...[
                        const HeightSpacer(size: 16),
                        TextField2(
                          controller: _balanceController,
                          text: "Initial Balance",
                          required: true,
                          radius: 15,
                          fillColor: theme.cardColor,
                          isShadow: false,
                          border: Colors.grey.shade300,
                          hintText: "0.00",
                          type: TextInputType.number,
                        ),
                      ],
                      
                      const HeightSpacer(size: 32),
                      
                      BlocBuilder<AccountActionsCubit, AccountActionsState>(
                        builder: (context, actionState) {
                          return Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => Navigator.pop(context),
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size(0, 55),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                  ),
                                  child: Text("Cancel", style: appStyle(context, 16, theme.brightness == Brightness.dark ? Colors.white : Colors.black, FontWeight.w600)),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: actionState.status == AccountActionsStatus.loading
                                      ? null
                                      : () => _handleSubmit(formState),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1A1F26), // Dark color from image
                                    minimumSize: const Size(0, 55),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                    elevation: 0,
                                  ),
                                  child: actionState.status == AccountActionsStatus.loading
                                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                      : Text(_isEditMode ? "Update Account" : "Create Account",
                                          style: appStyle(context, 16, Colors.white, FontWeight.w700)),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
