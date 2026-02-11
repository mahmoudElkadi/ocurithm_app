import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:ocurithm/core/utils/colors.dart';
import 'package:ocurithm/core/utils/services_locator.dart';
import 'package:ocurithm/core/widgets/DropdownPackage.dart';
import 'package:ocurithm/core/widgets/custom_date_picker.dart';
import 'package:ocurithm/core/utils/snackbar_service.dart';
import 'package:ocurithm/core/widgets/dicom_image_widget.dart';
import 'package:ocurithm/modules/Doctor/data/model/doctor_model.dart';
import 'package:ocurithm/modules/Doctor/presentation/manager/get_doctors_cubit/get_doctors_cubit.dart';
import 'package:ocurithm/modules/Storage/presentation/manager/storage_cubit/storage_cubit.dart';
import 'package:ocurithm/modules/Storage/data/model/upload_response_model.dart';
import 'package:ocurithm/modules/Patient/presentation/manager/scan_actions_cubit/scan_actions_cubit.dart';
import 'package:ocurithm/core/widgets/custom_freeze_loading.dart';
import 'package:ocurithm/core/utils/custom_pop_scope.dart';

class ScanFormPage extends StatefulWidget {
  final String patientId;
  const ScanFormPage({super.key, required this.patientId});

  @override
  State<ScanFormPage> createState() => _ScanFormPageState();
}

class _ScanFormPageState extends State<ScanFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  Doctor? _selectedDoctor;
  final List<UploadResponse> _uploadedFiles = [];
  bool _isSaving = false;

  void _showProgressDialog(BuildContext context, StorageCubit cubit) {
    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (dialogContext) {
        return BlocProvider.value(
          value: cubit,
          child: PopScope(
            canPop: false,
            child: Material(
              color: Colors.black.withValues(alpha: 0.6),
              child: Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      )
                    ],
                  ),
                  child: BlocBuilder<StorageCubit, StorageState>(
                    builder: (context, state) {
                      final progress = state.progress;
                      final total = state.totalFiles;

                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 100,
                                height: 100,
                                child: CircularProgressIndicator(
                                  value: progress > 0 ? progress : null,
                                  strokeWidth: 10,
                                  backgroundColor: Colors.grey[200],
                                  color: Colorz.primaryColor,
                                  strokeCap: StrokeCap.round,
                                ),
                              ),
                              Text(
                                "${(progress * 100).toInt()}%",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colorz.primaryColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          Text(
                            "Uploading ${total} Files",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "Processing files. Please do not close the app.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.grey, fontSize: 13, height: 1.4),
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
      },
    );
  }

  Future<bool?> _showDiscardDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Discard Scan?"),
        content: const Text(
            "You have uploaded images. Going back will delete them and discard this record."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Cancel"),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Discard"),
          ),
        ],
      ),
    );
  }

  Future<void> _cleanupAndExit(BuildContext context) async {
    customLoading(context, "Discarding changes..."); // Use custom loading

    try {
      final keys = _uploadedFiles.map((e) => e.key).toList();
      await context.read<StorageCubit>().deleteFiles(keys);
    } catch (e) {
      log("Error cleaning up files: $e");
    } finally {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop(); // Close loading

        setState(() {
          _uploadedFiles
              .clear(); // Clear so canPop allows exit if using variable,
          // or just pop manually now that we are done.
        });

        Navigator.of(context).pop(); // Exit Page
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await CustomDatePicker.show(
      context: context,
      initialDate: _selectedDate,
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (context) =>
                sl<GetDoctorsCubit>()..add(GetAllDoctorsEvent())),
        BlocProvider(create: (context) => sl<StorageCubit>()),
        BlocProvider(create: (context) => sl<ScanActionsCubit>()),
      ],
      child: Builder(builder: (context) {
        return CustomPopScope(
          enabled: _uploadedFiles.isNotEmpty,
          onWillPop: () async {
            // Only called when enabled (files exist)
            final shouldDiscard = await _showDiscardDialog(context);
            if (shouldDiscard == true) {
              if (context.mounted) _cleanupAndExit(context);
            }
          },
          child: Scaffold(
            backgroundColor:
                isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FE),
            appBar: AppBar(
              title: const Text("Create New Scan",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              centerTitle: true,
              elevation: 0,
              backgroundColor: Colors.transparent,
              foregroundColor: isDark ? Colors.white : Colors.black87,
            ),
            body: Builder(builder: (context) {
              return BlocListener<ScanActionsCubit, ScanActionsState>(
                listener: (context, state) {
                  if (state.state == ScanActionsStatus.loading) {
                    // Loading is handled by _showSaveLoading
                  } else if (state.state == ScanActionsStatus.success) {
                    if (Navigator.canPop(context)) {
                      Navigator.of(context, rootNavigator: true)
                          .pop(); // Close loading dialog
                    }
                    if (Navigator.canPop(context)) {
                      Navigator.of(context).pop(); // Close page
                    }
                    SnackbarService.showSuccess(context,
                        message: state.successMessage ??
                            "Scan record finalized successfully");
                  } else if (state.state == ScanActionsStatus.error) {
                    if (Navigator.canPop(context)) {
                      Navigator.of(context, rootNavigator: true)
                          .pop(); // Close loading dialog
                    }
                    SnackbarService.showError(context,
                        message:
                            state.errorMessage ?? "Failed to save scan record");
                  }
                },
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader(
                            context, "General Information", Icons.info_outline),
                        const SizedBox(height: 16),
                        DatePickerField(
                          label: "Examination Date",
                          selectedDate: _selectedDate,
                          onTap: () => _selectDate(context),
                          icon: Icons.event,
                        ),
                        const SizedBox(height: 20),
                        BlocBuilder<GetDoctorsCubit, GetDoctorsState>(
                          builder: (context, state) {
                            final doctors = state.doctors?.doctors ?? [];
                            return DropdownItem<Doctor>(
                              label: "Referring Doctor",
                              hintText: "Select Medical Professional",
                              items: doctors,
                              isLoading:
                                  state.state == GetDoctorsStatus.loading,
                              itemAsString: (doctor) => doctor.name ?? "",
                              onItemSelected: (doctor) {
                                setState(() {
                                  _selectedDoctor = doctor;
                                });
                              },
                              selectedValue: _selectedDoctor?.name,
                              iconData: Icon(Icons.person_pin_outlined,
                                  color: Colorz.primaryColor),
                              color:
                                  isDark ? Colors.grey[900] : Colors.grey[50],
                              radius: 12,
                              border:
                                  isDark ? Colors.grey[800] : Colors.grey[200],
                            );
                          },
                        ),
                        const SizedBox(height: 30),
                        _buildSectionHeader(
                            context, "Clinical Notes", Icons.notes),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _commentController,
                          maxLines: 4,
                          style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87),
                          decoration: InputDecoration(
                            hintText:
                                "Enter findings, observations or specific instructions...",
                            hintStyle: TextStyle(
                                color: isDark
                                    ? Colors.grey[500]
                                    : Colors.grey[400]),
                            filled: true,
                            fillColor:
                                isDark ? Colors.grey[900] : Colors.grey[50],
                            contentPadding: const EdgeInsets.all(16),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                  color: isDark
                                      ? Colors.grey[800]!
                                      : Colors.grey[200]!,
                                  width: 1.5),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                  color: isDark
                                      ? Colors.grey[800]!
                                      : Colors.grey[200]!,
                                  width: 1.5),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                  color: Colorz.primaryColor, width: 2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        _buildSectionHeader(context,
                            "Diagnostic Scans (DCM/Images)", Icons.biotech),
                        const SizedBox(height: 16),
                        Builder(
                          builder: (context) =>
                              _buildFilePickerButton(context, isDark),
                        ),
                        const SizedBox(height: 20),
                        if (_uploadedFiles.isNotEmpty)
                          _buildUploadedFilesList(context, isDark)
                        else
                          _buildEmptyState(isDark),
                        const SizedBox(height: 40),
                        _buildSaveButton(context),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      }),
    );
  }

  Widget _buildSectionHeader(
      BuildContext context, String title, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Icon(icon, size: 20, color: Colorz.primaryColor),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }

  Future<void> _pickFiles(BuildContext context) async {
    // context here comes from the Builder in the body
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['dcm', 'jpg', 'jpeg', 'png'],
    );

    if (result != null && result.paths.isNotEmpty) {
      final paths = result.paths.whereType<String>().toList();
      if (context.mounted) {
        // Read the cubit using the valid context
        final storageCubit = context.read<StorageCubit>();

        _showProgressDialog(context, storageCubit);

        try {
          await Future.delayed(const Duration(milliseconds: 100));

          final uploads = await storageCubit.uploadMultipleFiles(
            filePaths: paths,
            category: 'patient-scan',
          );

          final uploadsWithPaths = <UploadResponse>[];
          for (int i = 0; i < uploads.length; i++) {
            if (i < paths.length) {
              uploadsWithPaths.add(
                UploadResponse(
                  key: uploads[i].key,
                  localPath: paths[i],
                ),
              );
            }
          }

          setState(() {
            _uploadedFiles.addAll(uploadsWithPaths);
          });
          if (context.mounted) {
            SnackbarService.showSuccess(context,
                message: "Scans uploaded successfully");
          }
        } catch (e) {
          if (context.mounted) {
            SnackbarService.showError(context,
                message: "Upload failed. Please try again.");
          }
        } finally {
          if (context.mounted) {
            Navigator.of(context, rootNavigator: true).pop();
          }
        }
      }
    }
  }

  Future<void> _removeFile(int index, BuildContext context) async {
    final file = _uploadedFiles[index];

    customLoading(context, "Deleting file...");

    try {
      // Use the passed context which contains the provider
      await context.read<StorageCubit>().deleteFile(file.key);

      if (context.mounted) {
        Navigator.of(context, rootNavigator: true)
            .pop(); // Close loading dialog

        setState(() {
          _uploadedFiles.removeAt(index);
        });

        SnackbarService.showSuccess(context,
            message: "File deleted successfully");
      }
    } catch (e) {
      log(e.toString());
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true)
            .pop(); // Close loading dialog

        SnackbarService.showError(context,
            message: "Failed to delete file from server.");
      }
    }
  }

  Widget _buildFilePickerButton(BuildContext context, bool isDark) {
    return InkWell(
      onTap: () => _pickFiles(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: Colorz.primaryColor.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colorz.primaryColor.withValues(alpha: 0.3),
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          children: [
            Icon(Icons.upload_file_rounded,
                size: 40, color: Colorz.primaryColor),
            const SizedBox(height: 10),
            Text(
              "Select Scans or DICOM Files",
              style: TextStyle(
                color: Colorz.primaryColor,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Supports .DCM, .PNG, .JPG",
              style: TextStyle(
                color: isDark ? Colors.grey[500] : Colors.grey[500],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadedFilesList(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "${_uploadedFiles.length} files uploaded",
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 130,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _uploadedFiles.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final file = _uploadedFiles[index];
              final isDicom = file.key.toLowerCase().endsWith('.dcm');

              return Stack(
                children: [
                  Container(
                    width: 110,
                    height: 110,
                    margin: const EdgeInsets.only(top: 10),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[900] : Colors.grey[100],
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                          color:
                              isDark ? Colors.grey[800]! : Colors.grey[200]!),
                    ),
                    child: isDicom
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: DicomImageWidget(
                              filePath: file.localPath,
                              fit: BoxFit.cover,
                              showMetadata: true,
                            ),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: file.localPath != null
                                ? Image.file(
                                    // Use dart:io File
                                    // We need to import dart:io
                                    // But since we can't add imports easily with this tool without overwriting top,
                                    // Let's assume user has it or we add it.
                                    // Actually, we'll use dynamic or just check path.
                                    // See instruction: update ScanFormPage to assign localPath.
                                    // We will use Image.file
                                    // Wait, we need 'import 'dart:io';' at the top.
                                    // I will add it in a separate edit or use 'AssetImage' if it was an asset? No, it's a file.
                                    // I'll stick to Image.file and ensure import is added.
                                    // Since I can't add import here, I will use a different tool call or assume it exists/add it.
                                    // Let's just use Image.file.
                                    // Wait, I can't easily add the import in this block.
                                    // I will use extended Image widget or similar?
                                    // No, I'll add the import in a separate chunk.
                                    File(file.localPath!),
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(Icons.broken_image),
                                  )
                                : const Icon(Icons.image_not_supported),
                          ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () => _removeFile(index, context),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.delete_forever,
                            color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.folder_open_outlined,
                color: isDark ? Colors.grey[700] : Colors.grey[300], size: 40),
            const SizedBox(height: 8),
            Text(
              "No files uploaded yet",
              style: TextStyle(
                  color: isDark ? Colors.grey[600] : Colors.grey[400]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            Colorz.primaryColor,
            Colorz.primaryColor.withValues(alpha: 0.8)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colorz.primaryColor.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: ElevatedButton(
        onPressed: _isSaving ? null : () => _handleSave(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: _isSaving
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
              )
            : const Text(
                "Finalize Scan Record",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5),
              ),
      ),
    );
  }

  void _handleSave(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      if (_uploadedFiles.isEmpty) {
        SnackbarService.showWarning(context,
            message: "Please upload at least one scan file.");
        return;
      }
      if (_selectedDoctor == null) {
        SnackbarService.showWarning(context,
            message: "Please select a referring doctor.");
        return;
      }

      customLoading(context, "Saving Scan Record...");

      final files = _uploadedFiles.map((e) => e.key).toList();

      context.read<ScanActionsCubit>().add(CreateScanRecordEvent(
            patientId: widget.patientId,
            doctorId: _selectedDoctor!.id!,
            comment: _commentController.text,
            scanDate: _selectedDate.toIso8601String(),
            files: files,
          ));
    }
  }
}
