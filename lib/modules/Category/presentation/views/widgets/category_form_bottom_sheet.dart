import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocurithm/core/Network/shared.dart';
import 'package:ocurithm/core/utils/services_locator.dart';
import 'package:ocurithm/core/utils/snackbar_service.dart';
import 'package:ocurithm/core/widgets/DropdownPackage.dart';
import 'package:ocurithm/core/widgets/backend_image_picker.dart';
import 'package:ocurithm/core/widgets/height_spacer.dart';
import 'package:ocurithm/core/widgets/text_field.dart';
import 'package:ocurithm/modules/Category/data/models/category_model.dart';
import 'package:ocurithm/modules/Category/presentation/manager/category_actions_cubit/category_actions_cubit.dart';
import 'package:ocurithm/modules/Clinics/presentation/manager/get_clinics_cubit/get_clinics_cubit.dart';
import 'package:ocurithm/core/utils/capability_keys.dart';

class CategoryFormBottomSheet extends StatefulWidget {
  final Category? category; // If null, it's "Add" mode

  const CategoryFormBottomSheet({super.key, this.category});

  @override
  State<CategoryFormBottomSheet> createState() =>
      _CategoryFormBottomSheetState();
}

class _CategoryFormBottomSheetState extends State<CategoryFormBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  /// Storage key to resubmit — starts as the existing image's key so an
  /// unrelated field edit doesn't drop the image; replaced with the new
  /// upload's key when the user picks a different image.
  String? _imageKey;
  String? _selectedClinicId;
  bool _isActive = true;

  bool get _isEditMode => widget.category != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name);
    _descriptionController =
        TextEditingController(text: widget.category?.description);
    _imageKey = widget.category?.imageKey;
    _isActive = widget.category?.isActive ?? true;
    _selectedClinicId = widget.category?.clinicId;

    // Set default clinic if not admin
    if (!CacheHelper.getStringList(key: "capabilities")
        .contains(CapabilityKeys.manageCapability)) {
      _selectedClinicId = CacheHelper.getUser("user")?.clinic?.id;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedClinicId == null) {
      SnackbarService.showError(context, message: "Please select a clinic");
      return;
    }

    final cubit = context.read<CategoryActionsCubit>();
    if (_isEditMode) {
      cubit.add(UpdateCategoryEvent(
        id: widget.category!.id!,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        clinicId: _selectedClinicId,
        image: _imageKey,
        isActive: _isActive,
      ));
    } else {
      cubit.add(AddCategoryEvent(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        clinicId: _selectedClinicId!,
        image: _imageKey,
        isActive: _isActive,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (_) => sl<GetClinicsCubit>()
              ..add(GetAllClinicsEvent(noPagination: true))),
      ],
      child: BlocListener<CategoryActionsCubit, CategoryActionsState>(
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
                    _isEditMode ? "Edit Category" : "Add Category",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const HeightSpacer(size: 20),
                  BackendImagePicker(
                    initialImageUrl: widget.category?.image,
                    fileCategory: 'category-image',
                    placeholderIcon: Icons.category,
                    onDelete: () => setState(() => _imageKey = null),
                    onImageUploaded: (key) => setState(() => _imageKey = key),
                  ),
                  const HeightSpacer(size: 20),
                  TextField2(
                    controller: _nameController,
                    required: true,
                    radius: 30,
                    fillColor: theme.cardColor,
                    isShadow: false,
                    hintText: "Category Name",
                    validator: (v) =>
                        v == null || v.isEmpty ? "Name is required" : null,
                  ),
                  const HeightSpacer(size: 15),
                  TextField2(
                    controller: _descriptionController,
                    required: false,
                    radius: 30,
                    fillColor: theme.cardColor,
                    isShadow: false,
                    hintText: "Description (Optional)",
                  ),
                  const HeightSpacer(size: 15),
                  if (CacheHelper.getStringList(key: "capabilities")
                      .contains(CapabilityKeys.manageCapability))
                    BlocBuilder<GetClinicsCubit, GetClinicsState>(
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
                  const HeightSpacer(size: 25),
                  BlocBuilder<CategoryActionsCubit, CategoryActionsState>(
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
                            ? const CircularProgressIndicator(
                                color: Colors.white)
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
      ),
    );
  }
}

