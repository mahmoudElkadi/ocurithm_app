import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocurithm/core/Network/shared.dart';
import 'package:ocurithm/core/utils/services_locator.dart';
import 'package:ocurithm/core/utils/snackbar_service.dart';
import 'package:ocurithm/core/widgets/DropdownPackage.dart';
import 'package:ocurithm/core/widgets/backend_image_picker.dart';
import 'package:ocurithm/core/widgets/height_spacer.dart';
import 'package:ocurithm/core/widgets/text_field.dart';
import 'package:ocurithm/modules/Clinics/presentation/manager/get_clinics_cubit/get_clinics_cubit.dart';
import 'package:ocurithm/modules/SubCategory/presentation/manager/get_sub_categories_cubit/get_sub_categories_cubit.dart';

import '../../../data/models/product_model.dart';
import '../../manager/product_actions_cubit/product_actions_cubit.dart';
import 'package:ocurithm/core/utils/capability_keys.dart';

class ProductFormBottomSheet extends StatefulWidget {
  final Product? product;

  const ProductFormBottomSheet({super.key, this.product});

  @override
  State<ProductFormBottomSheet> createState() => _ProductFormBottomSheetState();
}

class _ProductFormBottomSheetState extends State<ProductFormBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _skuController;
  /// Storage key to resubmit — starts as the existing image's key so an
  /// unrelated field edit doesn't drop the image; replaced with the new
  /// upload's key when the user picks a different image.
  String? _imageKey;
  String? _selectedClinicId;
  String? _selectedSubCategoryId;
  bool _isActive = true;

  bool get _isEditMode => widget.product != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name);
    _descriptionController =
        TextEditingController(text: widget.product?.description);
    _priceController =
        TextEditingController(text: widget.product?.price?.toString());
    _skuController = TextEditingController(text: widget.product?.sku);
    _imageKey = widget.product?.imageKey;
    _isActive = widget.product?.isActive ?? true;
    _selectedClinicId = widget.product?.clinicId;
    _selectedSubCategoryId = widget.product?.subCategoryId;

    if (!CacheHelper.getStringList(key: "capabilities")
        .contains(CapabilityKeys.manageCapability)) {
      _selectedClinicId = CacheHelper.getUser("user")?.clinic?.id;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _skuController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedClinicId == null) {
      SnackbarService.showError(context, message: "Please select a clinic");
      return;
    }
    if (_selectedSubCategoryId == null) {
      SnackbarService.showError(context,
          message: "Please select a sub-category");
      return;
    }

    final cubit = context.read<ProductActionsCubit>();
    final double price = double.tryParse(_priceController.text) ?? 0;

    if (_isEditMode) {
      cubit.add(UpdateProductEvent(
        id: widget.product!.id!,
        name: _nameController.text.trim(),
        price: price,
        subCategory: _selectedSubCategoryId!,
        description: _descriptionController.text.trim(),
        image: _imageKey,
        sku: _skuController.text.trim(),
        isActive: _isActive,
      ));
    } else {
      cubit.add(CreateProductEvent(
        name: _nameController.text.trim(),
        price: price,
        subCategory: _selectedSubCategoryId!,
        clinic: _selectedClinicId!,
        description: _descriptionController.text.trim(),
        image: _imageKey,
        sku: _skuController.text.trim(),
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
        BlocProvider(
            create: (_) => sl<GetSubCategoriesCubit>()
              ..add(GetAllSubCategoriesEvent(noPagination: true))),
      ],
      child: BlocListener<ProductActionsCubit, ProductActionsState>(
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
                    _isEditMode ? "Edit Product" : "Add Product",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const HeightSpacer(size: 20),
                  BackendImagePicker(
                    initialImageUrl: widget.product?.image,
                    fileCategory: 'product-image',
                    placeholderIcon: Icons.inventory_2,
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
                    hintText: "Product Name",
                    validator: (v) =>
                        v == null || v.isEmpty ? "Name is required" : null,
                  ),
                  const HeightSpacer(size: 15),
                  TextField2(
                    controller: _priceController,
                    required: true,
                    radius: 30,
                    fillColor: theme.cardColor,
                    isShadow: false,
                    hintText: "Price",
                    type: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.isEmpty) return "Price is required";
                      final price = double.tryParse(v);
                      if (price == null || price <= 0) {
                        return "Price must be greater than 0";
                      }
                      return null;
                    },
                  ),
                  const HeightSpacer(size: 15),
                  TextField2(
                    controller: _skuController,
                    required: false,
                    radius: 30,
                    fillColor: theme.cardColor,
                    isShadow: false,
                    hintText: "SKU (Optional)",
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
                  const HeightSpacer(size: 15),
                  BlocBuilder<GetSubCategoriesCubit, GetSubCategoriesState>(
                    builder: (context, state) {
                      return DropdownItem(
                        radius: 30,
                        color: theme.cardColor,
                        isShadow: false,
                        items: state.subCategories?.subCategories ?? [],
                        selectedValue: state.subCategories?.subCategories
                            .where((sc) => sc.id == _selectedSubCategoryId)
                            .firstOrNull
                            ?.name,
                        hintText: "Select Sub-Category",
                        itemAsString: (item) => item.name,
                        onItemSelected: (item) =>
                            setState(() => _selectedSubCategoryId = item.id),
                        isLoading: state.isLoading,
                      );
                    },
                  ),
                  const HeightSpacer(size: 25),
                  BlocBuilder<ProductActionsCubit, ProductActionsState>(
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

