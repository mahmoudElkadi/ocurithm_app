import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocurithm/core/Network/shared.dart';
import 'package:ocurithm/core/utils/services_locator.dart';
import 'package:ocurithm/core/widgets/DropdownPackage.dart';
import 'package:ocurithm/core/widgets/height_spacer.dart';
import 'package:ocurithm/core/widgets/text_field.dart';
import 'package:ocurithm/modules/Clinics/presentation/manager/get_clinics_cubit/get_clinics_cubit.dart';

import '../../../data/models/supplier_model.dart';
import '../../manager/supplier_actions_cubit/supplier_actions_cubit.dart';

class SupplierFormBottomSheet extends StatefulWidget {
  final Supplier? supplier;

  const SupplierFormBottomSheet({super.key, this.supplier});

  @override
  State<SupplierFormBottomSheet> createState() =>
      _SupplierFormBottomSheetState();
}

class _SupplierFormBottomSheetState extends State<SupplierFormBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _descriptionController;
  String? _selectedClinicId;
  bool _isActive = true;

  bool get _isEditMode => widget.supplier != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.supplier?.name);
    _phoneController =
        TextEditingController(text: widget.supplier?.phoneNumber);
    _descriptionController =
        TextEditingController(text: widget.supplier?.description);
    _isActive = widget.supplier?.isActive ?? true;
    _selectedClinicId = widget.supplier?.clinic?.id;

    if (!_isEditMode &&
        !CacheHelper.getStringList(key: "capabilities")
            .contains("manageCapability")) {
      _selectedClinicId = CacheHelper.getUser("user")?.clinic?.id;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;

    final cubit = context.read<SupplierActionsCubit>();

    if (_isEditMode) {
      cubit.add(UpdateSupplierEvent(
        id: widget.supplier!.id!,
        name: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        description: _descriptionController.text.trim(),
        isActive: _isActive,
      ));
    } else {
      cubit.add(CreateSupplierEvent(
        name: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        description: _descriptionController.text.trim(),
        clinic: _selectedClinicId,
        isActive: _isActive,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<SupplierActionsCubit, SupplierActionsState>(
      listener: (context, state) {
        if (state.isSuccess) {
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _isEditMode ? "Edit Supplier" : "Add Supplier",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const HeightSpacer(size: 25),
                TextField2(
                  controller: _nameController,
                  required: true,
                  radius: 30,
                  fillColor: theme.cardColor,
                  isShadow: false,
                  hintText: "Supplier Name",
                  validator: (v) =>
                      v == null || v.isEmpty ? "Name is required" : null,
                ),
                const HeightSpacer(size: 15),
                TextField2(
                  controller: _phoneController,
                  required: true,
                  radius: 30,
                  fillColor: theme.cardColor,
                  isShadow: false,
                  hintText: "Phone Number",
                  type: TextInputType.phone,
                  validator: (v) => v == null || v.isEmpty
                      ? "Phone number is required"
                      : null,
                ),
                const HeightSpacer(size: 15),
                TextField2(
                  controller: _descriptionController,
                  required: false,
                  radius: 30,
                  fillColor: theme.cardColor,
                  isShadow: false,
                  hintText: "Description (Optional)",
                  maxLines: 3,
                ),
                const HeightSpacer(size: 15),
                if (!_isEditMode &&
                    CacheHelper.getStringList(key: "capabilities")
                        .contains("manageCapability"))
                  BlocProvider(
                    create: (context) => sl<GetClinicsCubit>()
                      ..add(GetAllClinicsEvent(noPagination: true)),
                    child: BlocBuilder<GetClinicsCubit, GetClinicsState>(
                      builder: (context, state) {
                        return DropdownItem(
                          radius: 30,
                          color: theme.cardColor,
                          isShadow: false,
                          items: state.clinics?.clinics ?? [],
                          selectedValue: state.clinics?.clinics
                              .where((c) => c.id == _selectedClinicId)
                              .firstOrNull
                              ?.name,
                          hintText: "Select Clinic",
                          itemAsString: (item) => item.name,
                          onItemSelected: (item) =>
                              setState(() => _selectedClinicId = item.id),
                          isLoading: state.isLoading,
                        );
                      },
                    ),
                  ),
                const HeightSpacer(size: 25),
                BlocBuilder<SupplierActionsCubit, SupplierActionsState>(
                  builder: (context, state) {
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                      ),
                      onPressed: state.isLoading ? null : _handleSubmit,
                      child: state.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(_isEditMode ? "Update" : "Create",
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
