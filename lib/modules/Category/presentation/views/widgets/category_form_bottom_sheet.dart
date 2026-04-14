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
import 'package:ocurithm/modules/Category/data/models/category_model.dart';
import 'package:ocurithm/modules/Category/presentation/manager/category_actions_cubit/category_actions_cubit.dart';
import 'package:ocurithm/modules/Clinics/presentation/manager/get_clinics_cubit/get_clinics_cubit.dart';

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
  String? _imageUrl;
  String? _selectedClinicId;
  bool _isActive = true;

  bool get _isEditMode => widget.category != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name);
    _descriptionController =
        TextEditingController(text: widget.category?.description);
    _imageUrl = widget.category?.image;
    _isActive = widget.category?.isActive ?? true;
    _selectedClinicId = widget.category?.clinicId;

    // Set default clinic if not admin
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

    final cubit = context.read<CategoryActionsCubit>();
    if (_isEditMode) {
      cubit.add(UpdateCategoryEvent(
        id: widget.category!.id!,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        clinicId: _selectedClinicId,
        image: _imageUrl,
        isActive: _isActive,
      ));
    } else {
      cubit.add(AddCategoryEvent(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        clinicId: _selectedClinicId!,
        image: _imageUrl,
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
                  ProfileImagePicker(
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
                    isShadow: true,
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
                    isShadow: true,
                    hintText: "Description (Optional)",
                  ),
                  const HeightSpacer(size: 15),
                  if (CacheHelper.getStringList(key: "capabilities")
                      .contains("manageCapability"))
                    BlocBuilder<GetClinicsCubit, GetClinicsState>(
                      builder: (context, state) {
                        return DropdownItem(
                          radius: 30,
                          color: theme.cardColor,
                          isShadow: true,
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

// Reuse logic from Receptionist
class ProfileImagePicker extends StatefulWidget {
  final String? initialImageUrl;
  final VoidCallback onDelete;
  final Function(String) onImageUploaded;

  const ProfileImagePicker({
    super.key,
    this.initialImageUrl,
    required this.onDelete,
    required this.onImageUploaded,
  });

  @override
  State<ProfileImagePicker> createState() => _ProfileImagePickerState();
}

class _ProfileImagePickerState extends State<ProfileImagePicker> {
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
      final url = await CloudinaryService.uploadImage(_imageFile!);
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
              shape: BoxShape.circle,
              color: theme.cardColor,
              border: Border.all(color: theme.primaryColor)),
          child: _isUploading
              ? const Center(child: CircularProgressIndicator())
              : ClipOval(
                  child: _imageFile != null
                      ? Image.file(_imageFile!, fit: BoxFit.cover)
                      : widget.initialImageUrl != null
                          ? Image.network(widget.initialImageUrl!,
                              fit: BoxFit.cover)
                          : const Icon(Icons.category,
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

class CloudinaryService {
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
