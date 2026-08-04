import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../api/api_constants.dart';
import '../api/api_handler.dart';
import '../utils/snackbar_service.dart';

/// Image picker that uploads through the backend's own `/storage/upload/:category`
/// endpoint, rather than a third-party CDN. The backend validates an entity's
/// `image` field against its own storage key prefix (e.g. `category-image/…`)
/// and rejects anything else — including a resolved display URL — with a 400,
/// so [onImageUploaded] always receives the storage **key**, not a URL.
class BackendImagePicker extends StatefulWidget {
  /// Resolved, directly-viewable URL of the existing image, if any.
  final String? initialImageUrl;
  /// The backend `FileCategory` this upload belongs to, e.g. `category-image`,
  /// `product-image`.
  final String fileCategory;
  final IconData placeholderIcon;
  final VoidCallback onDelete;
  final ValueChanged<String> onImageUploaded;

  const BackendImagePicker({
    super.key,
    this.initialImageUrl,
    required this.fileCategory,
    this.placeholderIcon = Icons.image,
    required this.onDelete,
    required this.onImageUploaded,
  });

  @override
  State<BackendImagePicker> createState() => _BackendImagePickerState();
}

class _BackendImagePickerState extends State<BackendImagePicker> {
  File? _imageFile;
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();
  final ApiHandler _apiHandler = ApiHandler();

  Future<void> _pickImage(ImageSource source) async {
    final XFile? picked = await _picker.pickImage(
        source: source, maxWidth: 800, maxHeight: 800, imageQuality: 85);
    if (picked == null) return;
    if (mounted) setState(() => _imageFile = File(picked.path));
    await _upload(picked.path);
  }

  Future<void> _upload(String path) async {
    if (mounted) setState(() => _isUploading = true);
    try {
      final response = await _apiHandler.uploadFile<Map<String, dynamic>>(
        ApiConstants.storageUploadSingle(widget.fileCategory),
        path,
        fromJson: (json) => Map<String, dynamic>.from(json as Map),
      );
      final key = response.data?['key'] as String?;
      if (response.success && key != null) {
        widget.onImageUploaded(key);
      } else if (mounted) {
        SnackbarService.showError(context,
            message: response.message ?? "Upload failed");
      }
    } catch (e) {
      if (mounted) SnackbarService.showError(context, message: "Error: $e");
    } finally {
      if (mounted) setState(() => _isUploading = false);
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
                          : Icon(widget.placeholderIcon,
                              size: 50, color: Colors.grey),
                ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: _showSourceActionSheet,
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
                if (mounted) setState(() => _imageFile = null);
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
