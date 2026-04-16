import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:ocurithm/core/Network/shared.dart';
import 'package:ocurithm/core/utils/services_locator.dart';
import 'package:ocurithm/core/utils/snackbar_service.dart';
import 'package:ocurithm/core/widgets/DropdownPackage.dart';
import 'package:ocurithm/core/widgets/height_spacer.dart';
import 'package:ocurithm/core/widgets/text_field.dart';
import 'package:ocurithm/modules/Category/presentation/manager/get_categories_cubit/get_categories_cubit.dart';
import 'package:ocurithm/modules/Clinics/presentation/manager/get_clinics_cubit/get_clinics_cubit.dart';
import 'package:ocurithm/modules/SubCategory/data/models/sub_category_model.dart';
import 'package:ocurithm/modules/SubCategory/presentation/manager/sub_category_actions_cubit/sub_category_actions_cubit.dart';

class SubCategoryFormBottomSheet extends StatefulWidget {
  final SubCategory? subCategory;

  const SubCategoryFormBottomSheet({super.key, this.subCategory});

  @override
  State<SubCategoryFormBottomSheet> createState() =>
      _SubCategoryFormBottomSheetState();
}

class _SubCategoryFormBottomSheetState
    extends State<SubCategoryFormBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  String? _imageUrl;
  String? _selectedClinicId;
  String? _selectedCategoryId;

  bool get _isEditMode => widget.subCategory != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.subCategory?.name);
    _descriptionController =
        TextEditingController(text: widget.subCategory?.description);
    _imageUrl = widget.subCategory?.image;
    _selectedClinicId = widget.subCategory?.clinicId;
    _selectedCategoryId = widget.subCategory?.categoryId;

    if (!CacheHelper.getStringList(key: "capabilities")
        .contains("manageCapability")) {
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

    if (_selectedCategoryId == null) {
      SnackbarService.showError(context, message: "Please select a category");
      return;
    }

    final cubit = context.read<SubCategoryActionsCubit>();
    if (_isEditMode) {
      cubit.add(UpdateSubCategoryEvent(
        id: widget.subCategory!.id!,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        clinicId: _selectedClinicId,
        categoryId: _selectedCategoryId,
        image: _imageUrl,
        isActive: true,
      ));
    } else {
      cubit.add(AddSubCategoryEvent(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        clinicId: _selectedClinicId!,
        categoryId: _selectedCategoryId!,
        image: _imageUrl,
        isActive: true,
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
            create: (_) =>
                sl<GetCategoriesCubit>()..add(GetAllCategoriesEvent())),
      ],
      child: BlocListener<SubCategoryActionsCubit, SubCategoryActionsState>(
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
                    _isEditMode ? "Edit Sub-Category" : "Add Sub-Category",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const HeightSpacer(size: 20),
                  SubCategoryImagePicker(
                    initialImageUrl: _imageUrl,
                    onDelete: () => setState(() => _imageUrl = null),
                    onImageUploaded: (url) => setState(() => _imageUrl = url),
                  ),
                  const HeightSpacer(size: 20),
                  TextField2(
                    controller: _nameController,
                    required: true,
                    radius: 30,
                    fillColor: theme.cardColor,
                    isShadow: false,
                    hintText: "Sub-Category Name",
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
                      .contains("manageCapability"))
                    BlocBuilder<GetClinicsCubit, GetClinicsState>(
                      builder: (context, state) {
                        return DropdownItem(
                          radius: 30,
                          isShadow: false,
                          color: theme.cardColor,
                          items: state.clinics?.clinics ?? [],
                          selectedValue: state.clinics?.clinics
                              .where((c) => c.id == _selectedClinicId)
                              .firstOrNull
                              ?.name,
                          hintText: "Select Clinic",
                          itemAsString: (item) => item.name ?? "",
                          onItemSelected: (item) {
                            setState(() {
                              _selectedClinicId = item.id;
                              _selectedCategoryId =
                                  null; // Reset category when clinic changes
                            });
                          },
                          isLoading: state.isLoading,
                        );
                      },
                    ),
                  const HeightSpacer(size: 15),
                  BlocBuilder<GetCategoriesCubit, GetCategoriesState>(
                    builder: (context, state) {
                      final categories = _selectedClinicId == null
                          ? state.categories?.categories ?? []
                          : state.categories?.categories
                                  .where((c) => c.clinicId == _selectedClinicId)
                                  .toList() ??
                              [];

                      return DropdownItem(
                        radius: 30,
                        isShadow: false,
                        color: theme.cardColor,
                        items: categories,
                        selectedValue: categories
                            .where((c) => c.id == _selectedCategoryId)
                            .firstOrNull
                            ?.name,
                        hintText: "Select Category",
                        itemAsString: (item) => item.name ?? "",
                        onItemSelected: (item) =>
                            setState(() => _selectedCategoryId = item.id),
                        isLoading: state.isLoading,
                      );
                    },
                  ),
                  const HeightSpacer(size: 30),
                  BlocBuilder<SubCategoryActionsCubit, SubCategoryActionsState>(
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

class SubCategoryImagePicker extends StatefulWidget {
  final String? initialImageUrl;
  final VoidCallback onDelete;
  final Function(String) onImageUploaded;

  const SubCategoryImagePicker({
    super.key,
    this.initialImageUrl,
    required this.onDelete,
    required this.onImageUploaded,
  });

  @override
  State<SubCategoryImagePicker> createState() => _SubCategoryImagePickerState();
}

class _SubCategoryImagePickerState extends State<SubCategoryImagePicker> {
  File? _imageFile;
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final XFile? picked = await _picker.pickImage(
        source: source, maxWidth: 800, maxHeight: 800, imageQuality: 85);
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
      await _uploadToCloudinary();
    }
  }

  Future<void> _uploadToCloudinary() async {
    if (_imageFile == null) return;
    setState(() => _isUploading = true);
    try {
      final url = await CloudinarySubService.uploadImage(_imageFile!);
      if (url != null) {
        widget.onImageUploaded(url);
      } else {
        SnackbarService.showError(context, message: "Upload failed");
      }
    } catch (e) {
      SnackbarService.showError(context, message: "Error: $e");
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(15),
              color: theme.cardColor,
              border: Border.all(color: theme.primaryColor)),
          child: _isUploading
              ? const Center(child: CircularProgressIndicator())
              : ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: _imageFile != null
                      ? Image.file(_imageFile!, fit: BoxFit.cover)
                      : widget.initialImageUrl != null
                          ? Image.network(widget.initialImageUrl!,
                              fit: BoxFit.cover)
                          : const Icon(Icons.category_outlined,
                              size: 50, color: Colors.grey),
                ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: () => _showSourceActionSheet(),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                  color: theme.primaryColor, shape: BoxShape.circle),
              child:
                  const Icon(Icons.camera_alt, color: Colors.white, size: 20),
            ),
          ),
        ),
      ],
    );
  }

  void _showSourceActionSheet() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
              child: const Text("Camera")),
          CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
              child: const Text("Gallery")),
          CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                widget.onDelete();
                setState(() => _imageFile = null);
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red))),
        ],
        cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel")),
      ),
    );
  }
}

class CloudinarySubService {
  static const String cloudName = 'dxsrhu3ku';
  static const String uploadPreset = 'ocurithm';
  static const String _baseUrl = 'https://api.cloudinary.com/v1_1/$cloudName';

  static Future<String?> uploadImage(File imageFile) async {
    try {
      final url = Uri.parse('$_baseUrl/image/upload');
      final request = http.MultipartRequest('POST', url);
      request.fields['upload_preset'] = uploadPreset;
      request.fields['folder'] = 'public';
      final bytes = await imageFile.readAsBytes();
      request.files.add(http.MultipartFile.fromBytes('file', bytes,
          filename: imageFile.path.split('/').last));
      final response = await http.Response.fromStream(await request.send());
      if (response.statusCode == 200) {
        return json.decode(response.body)['secure_url'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
