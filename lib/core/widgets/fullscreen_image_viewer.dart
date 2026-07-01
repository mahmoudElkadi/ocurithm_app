import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocurithm/core/utils/colors.dart';
import 'package:ocurithm/core/utils/services_locator.dart';
import 'package:ocurithm/core/utils/snackbar_service.dart';
import 'package:ocurithm/core/widgets/dicom_image_widget.dart';
import 'package:ocurithm/modules/Patient/presentation/manager/scan_actions_cubit/scan_actions_cubit.dart';
import 'package:ocurithm/modules/Storage/presentation/manager/storage_cubit/storage_cubit.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

class FullscreenImageViewer extends StatefulWidget {
  final List<dynamic> imageUrls; // Can be String (URL) or File
  final int initialIndex;
  final String? patientId;
  final String? scanId;
  final List<String>? fileIds;

  const FullscreenImageViewer({
    super.key,
    required this.imageUrls,
    this.initialIndex = 0,
    this.patientId,
    this.scanId,
    this.fileIds,
  });

  @override
  State<FullscreenImageViewer> createState() => _FullscreenImageViewerState();
}

class _FullscreenImageViewerState extends State<FullscreenImageViewer>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late int _currentIndex;
  late List<dynamic> _imageUrls;
  double _verticalOffset = 0.0;
  double _backgroundOpacity = 1.0;
  bool _isZooming = false;
  final TransformationController _transformationController =
      TransformationController();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _imageUrls = List.from(widget.imageUrls);
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    if (_isZooming) return;
    setState(() {
      _verticalOffset += details.delta.dy;
      _backgroundOpacity =
          (1.0 - (_verticalOffset.abs() / 300)).clamp(0.0, 1.0);
    });
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    if (_isZooming) return;
    if (_verticalOffset.abs() > 150 || details.primaryVelocity!.abs() > 500) {
      Navigator.of(context).pop();
    } else {
      setState(() {
        _verticalOffset = 0.0;
        _backgroundOpacity = 1.0;
      });
    }
  }

  bool _isDicomUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri != null) {
      return uri.path.toLowerCase().endsWith('.dcm');
    }
    return url.toLowerCase().endsWith('.dcm');
  }

  void _openEditor(dynamic item, bool isFile) {
    final editor = isFile
        ? ProImageEditor.file(
            item as File,
            callbacks: ProImageEditorCallbacks(
              onImageEditingComplete: (Uint8List bytes) async {
                await _uploadEditedImage(bytes);
                if (mounted) {
                  Navigator.pop(context);
                }
              },
            ),
          )
        : ProImageEditor.network(
            item as String,
            callbacks: ProImageEditorCallbacks(
              onImageEditingComplete: (Uint8List bytes) async {
                await _uploadEditedImage(bytes);
                if (mounted) {
                  Navigator.pop(context);
                }
              },
            ),
          );

    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => editor),
    );
  }

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
                          const Text(
                            "Uploading Edited Image",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                            textAlign: TextAlign.center,
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

  Future<void> _uploadEditedImage(Uint8List bytes) async {
    try {
      final tempDir = Directory.systemTemp;
      final tempFile = File(
          '${tempDir.path}/edited_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await tempFile.writeAsBytes(bytes);

      if (!mounted) return;
      final storageCubit = sl<StorageCubit>();
      _showProgressDialog(context, storageCubit);

      final uploads = await storageCubit.uploadMultipleFiles(
        filePaths: [tempFile.path],
        category: 'patient-scan',
      );

      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop(); // Close dialog
        if (uploads.isNotEmpty) {
          setState(() {
            _imageUrls[_currentIndex] = tempFile; // Display the new local file
          });

          if (widget.patientId != null &&
              widget.scanId != null &&
              widget.fileIds != null &&
              _currentIndex < widget.fileIds!.length) {
            try {
              context.read<ScanActionsCubit>().add(EditScanFileEvent(
                    patientId: widget.patientId!,
                    scanId: widget.scanId!,
                    fileId: widget.fileIds![_currentIndex],
                    newKey: uploads.first.key,
                  ));
            } catch (e) {
              // Ignore if ScanActionsCubit is not available
            }
          }

          SnackbarService.showSuccess(context,
              message: "Image uploaded successfully");
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop(); // Close dialog
        SnackbarService.showError(context, message: "Failed to upload image");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: _backgroundOpacity,
              child: Container(color: Colors.black),
            ),
          ),
          Transform.translate(
            offset: Offset(0, _verticalOffset),
            child: GestureDetector(
              onVerticalDragUpdate: _isZooming ? null : _onVerticalDragUpdate,
              onVerticalDragEnd: _isZooming ? null : _onVerticalDragEnd,
              child: PageView.builder(
                controller: _pageController,
                itemCount: _imageUrls.length,
                physics: _isZooming
                    ? const NeverScrollableScrollPhysics()
                    : const BouncingScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  final item = _imageUrls[index];
                  final isFile = item is File;
                  final isDcm = !isFile && _isDicomUrl(item as String);

                  return InteractiveViewer(
                    transformationController: _transformationController,
                    minScale: 1.0,
                    maxScale: 5.0,
                    onInteractionStart: (_) =>
                        setState(() => _isZooming = true),
                    onInteractionEnd: (_) {
                      if (_transformationController.value.getMaxScaleOnAxis() <=
                          1.0) {
                        setState(() => _isZooming = false);
                      }
                    },
                    child: Center(
                      child: Hero(
                        tag: item,
                        child: isFile
                            ? Image.file(
                                item,
                                fit: BoxFit.contain,
                              )
                            : isDcm
                                ? DicomImageWidget(
                                    url: item as String,
                                    fit: BoxFit.contain,
                                    showMetadata: true,
                                  )
                                : Image.network(
                                    item as String,
                                    fit: BoxFit.contain,
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return const Center(
                                        child: CircularProgressIndicator(
                                            color: Colors.white70),
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      return _buildErrorWidget(item as String);
                                    },
                                  ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          if (!_isZooming)
            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              left: 0,
              right: 0,
              child: Opacity(
                opacity: _backgroundOpacity,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close,
                            color: Colors.white, size: 28),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      if (_imageUrls.length > 1)
                        Text(
                          "${_currentIndex + 1} / ${_imageUrls.length}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      Builder(builder: (context) {
                        final currentItem = _imageUrls[_currentIndex];
                        final isFile = currentItem is File;
                        final isDcm =
                            !isFile && _isDicomUrl(currentItem as String);
                        if (!isDcm) {
                          return IconButton(
                            icon: const Icon(Icons.edit,
                                color: Colors.white, size: 28),
                            onPressed: () => _openEditor(currentItem, isFile),
                          );
                        }
                        return const SizedBox(width: 48);
                      }),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String url) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.broken_image_rounded, color: Colors.white54, size: 64),
        const SizedBox(height: 16),
        Text(
          _isDicomUrl(url)
              ? "Failed to parse DICOM file"
              : "Failed to load image",
          style: const TextStyle(color: Colors.white70),
        ),
      ],
    );
  }
}
