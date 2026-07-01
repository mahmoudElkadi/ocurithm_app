import 'dart:io';
import 'dart:typed_data';
import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:ocurithm/core/utils/services_locator.dart';
import 'package:ocurithm/core/utils/snackbar_service.dart';
import 'package:ocurithm/modules/Storage/presentation/manager/storage_cubit/storage_cubit.dart';
import 'package:ocurithm/modules/Patient/presentation/manager/scan_actions_cubit/scan_actions_cubit.dart';
import 'package:ocurithm/core/utils/colors.dart';

/// A real DICOM viewer that extracts and displays all frames from a DICOM file.
/// This viewer properly handles both uncompressed and JPEG-compressed encapsulated pixel data.
class RealDicomViewer extends StatefulWidget {
  /// Local file path to a .dcm file (takes priority over [url])
  final String? filePath;

  /// Network URL to a .dcm file
  final String? url;

  /// Whether to show metadata panel
  final bool showMetadata;

  /// Optional Hero tag for animations
  final String? heroTag;

  final String? patientId;
  final String? scanId;
  final String? fileId;

  const RealDicomViewer({
    super.key,
    this.filePath,
    this.url,
    this.showMetadata = false,
    this.heroTag,
    this.patientId,
    this.scanId,
    this.fileId,
  }) : assert(filePath != null || url != null,
  'Either filePath or url must be provided');

  @override
  State<RealDicomViewer> createState() => _RealDicomViewerState();
}

class _RealDicomViewerState extends State<RealDicomViewer> {
  List<Uint8List> _frames = [];
  int _currentFrameIndex = 0;
  bool _isLoading = true;
  String? _error;
  final TransformationController _transformationController =
  TransformationController();
  bool _isMetadataVisible = false;
  bool _isPlaying = false;
  Timer? _playbackTimer;
  double _playbackSpeed = 1.0;
  bool _isZooming = false;
  bool _showFallbackImage = false;

  // DICOM metadata
  Map<String, String> _metadata = {};
  String? _modality;
  int _numberOfFrames = 1;
  int _rows = 0;
  int _columns = 0;
  int _bitsAllocated = 16;
  String? _transferSyntax;

  @override
  void initState() {
    super.initState();
    _transformationController.value = Matrix4.identity()..scale(0.85);
    _parseDicom();
  }

  @override
  void didUpdateWidget(covariant RealDicomViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.filePath != widget.filePath || oldWidget.url != widget.url) {
      _parseDicom();
    }
  }

  @override
  void dispose() {
    _playbackTimer?.cancel();
    _transformationController.dispose();
    super.dispose();
  }

  Future<void> _parseDicom() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _frames = [];
      _currentFrameIndex = 0;
      _isPlaying = false;
      _showFallbackImage = false;
      _playbackTimer?.cancel();
    });

    try {
      Uint8List? fileBytes;

      if (widget.filePath != null) {
        final file = File(widget.filePath!);
        if (await file.exists()) {
          fileBytes = await file.readAsBytes();
        } else {
          throw Exception('File not found');
        }
      } else if (widget.url != null) {
        final response = await http.get(Uri.parse(widget.url!));
        if (response.statusCode == 200) {
          fileBytes = response.bodyBytes;
        } else {
          throw Exception('Failed to download DICOM file');
        }
      }

      if (fileBytes == null) {
        throw Exception('No file data available');
      }

      // Parse DICOM file and extract all frames
      final frames = await _extractAllFrames(fileBytes);

      if (frames.isNotEmpty) {
        if (mounted) {
          setState(() {
            _frames = frames;
            _numberOfFrames = frames.length;
            _isLoading = false;
          });
        }
      } else {
        throw Exception('Could not extract any frames from DICOM file');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<List<Uint8List>> _extractAllFrames(Uint8List fileBytes) async {
    final List<Uint8List> frames = [];

    try {
      // Check if file has DICM header
      final hasDicmHeader = fileBytes.length > 132 &&
          String.fromCharCodes(fileBytes.sublist(128, 132)) == 'DICM';

      final startPos = hasDicmHeader ? 132 : 0;

      // Extract basic metadata
      _extractMetadata(fileBytes, startPos);

      // Find and extract pixel data
      final pixelDataInfo = _findPixelData(fileBytes, startPos);

      if (pixelDataInfo != null) {
        final pixelDataStart = pixelDataInfo['start'] as int;
        final pixelDataLength = pixelDataInfo['length'] as int;
        final isEncapsulated = pixelDataInfo['encapsulated'] as bool;

        if (isEncapsulated) {
          // Parse encapsulated (compressed) pixel data - typically JPEG
          frames.addAll(await _extractEncapsulatedFrames(
            fileBytes,
            pixelDataStart,
          ));
        } else {
          // Parse uncompressed pixel data
          frames.addAll(await _extractUncompressedFrames(
            fileBytes,
            pixelDataStart,
            pixelDataLength,
          ));
        }
      }

      // Update metadata with frame count
      _metadata['Frames'] = '${frames.length}';

    } catch (e) {
      throw Exception('Failed to extract frames: $e');
    }

    return frames;
  }

  void _extractMetadata(Uint8List fileBytes, int startPos) {
    // Extract Number of Frames (0028,0008)
    final numFramesValue = _findAndExtractTag(fileBytes, 0x0028, 0x0008, startPos);
    if (numFramesValue != null) {
      _numberOfFrames = int.tryParse(numFramesValue.trim()) ?? 1;
    }

    // Extract Rows (0028,0010)
    final rowsValue = _findAndExtractTag(fileBytes, 0x0028, 0x0010, startPos);
    if (rowsValue != null) {
      _rows = _parseNumericValue(rowsValue);
    }

    // Extract Columns (0028,0011)
    final colsValue = _findAndExtractTag(fileBytes, 0x0028, 0x0011, startPos);
    if (colsValue != null) {
      _columns = _parseNumericValue(colsValue);
    }

    // Extract Bits Allocated (0028,0100)
    final bitsValue = _findAndExtractTag(fileBytes, 0x0028, 0x0100, startPos);
    if (bitsValue != null) {
      _bitsAllocated = _parseNumericValue(bitsValue);
    }

    // Extract Modality (0008,0060)
    _modality = _findAndExtractTag(fileBytes, 0x0008, 0x0060, startPos);

    // Extract Transfer Syntax UID (0002,0010)
    _transferSyntax = _findAndExtractTag(fileBytes, 0x0002, 0x0010, startPos);

    // Build metadata map
    _metadata = {
      'Modality': _modality ?? 'Unknown',
      'Rows': '$_rows',
      'Columns': '$_columns',
      'Bits Allocated': '$_bitsAllocated',
      'Number of Frames': '$_numberOfFrames',
      if (_transferSyntax != null) 'Transfer Syntax': _transferSyntax!,
    };
  }

  String? _findAndExtractTag(Uint8List fileBytes, int group, int element, int startPos) {
    final positions = _findTag(fileBytes, group, element, startPos);
    if (positions.isEmpty) return null;

    try {
      final pos = positions.first;
      // Skip tag (4 bytes)
      var offset = pos + 4;

      // Read VR (Value Representation) - 2 bytes
      final vr = String.fromCharCodes(fileBytes.sublist(offset, offset + 2));
      offset += 2;

      int valueLength;

      // Handle different VR types
      if (vr == 'OB' || vr == 'OW' || vr == 'OF' || vr == 'SQ' ||
          vr == 'UT' || vr == 'UN' || vr == 'UC') {
        // These VRs have 2 reserved bytes, then 4-byte length
        offset += 2; // Skip reserved bytes
        final lengthBytes = fileBytes.sublist(offset, offset + 4);
        valueLength = ByteData.sublistView(Uint8List.fromList(lengthBytes)).getUint32(0, Endian.little);
        offset += 4;
      } else {
        // Standard VRs have 2-byte length
        final lengthBytes = fileBytes.sublist(offset, offset + 2);
        valueLength = ByteData.sublistView(Uint8List.fromList(lengthBytes)).getUint16(0, Endian.little);
        offset += 2;
      }

      if (valueLength == 0 || valueLength > 1000) return null;

      // Extract value based on VR type
      if (vr == 'US' && valueLength == 2) {
        // Unsigned Short
        final value = ByteData.sublistView(fileBytes).getUint16(offset, Endian.little);
        return value.toString();
      } else if (vr == 'SS' && valueLength == 2) {
        // Signed Short
        final value = ByteData.sublistView(fileBytes).getInt16(offset, Endian.little);
        return value.toString();
      } else {
        // String types (IS, DS, CS, LO, SH, PN, etc.)
        final valueBytes = fileBytes.sublist(offset, offset + valueLength);
        return String.fromCharCodes(valueBytes).trim();
      }
    } catch (e) {
      return null;
    }
  }

  int _parseNumericValue(String value) {
    try {
      return int.parse(value.trim());
    } catch (e) {
      return 0;
    }
  }

  List<int> _findTag(Uint8List fileBytes, int group, int element, int startPos) {
    final positions = <int>[];

    // Create tag bytes in little-endian format
    final tagBytes = Uint8List(4);
    ByteData.sublistView(tagBytes)
      ..setUint16(0, group, Endian.little)
      ..setUint16(2, element, Endian.little);

    // Search for the tag
    for (var i = startPos; i < fileBytes.length - 4; i++) {
      if (fileBytes[i] == tagBytes[0] &&
          fileBytes[i + 1] == tagBytes[1] &&
          fileBytes[i + 2] == tagBytes[2] &&
          fileBytes[i + 3] == tagBytes[3]) {
        positions.add(i);
      }
    }

    return positions;
  }

  Map<String, dynamic>? _findPixelData(Uint8List fileBytes, int startPos) {
    // Find Pixel Data tag (7FE0,0010)
    final positions = _findTag(fileBytes, 0x7FE0, 0x0010, startPos);
    if (positions.isEmpty) return null;

    try {
      final pos = positions.first;
      var offset = pos + 4; // Skip tag

      // Read VR
      final vr = String.fromCharCodes(fileBytes.sublist(offset, offset + 2));
      offset += 2;

      int valueLength;
      bool isEncapsulated = false;

      if (vr == 'OB' || vr == 'OW') {
        // Skip 2 reserved bytes
        offset += 2;
        // Read 4-byte length
        final lengthBytes = fileBytes.sublist(offset, offset + 4);
        valueLength = ByteData.sublistView(Uint8List.fromList(lengthBytes)).getUint32(0, Endian.little);
        offset += 4;

        // Undefined length (0xFFFFFFFF) indicates encapsulated data
        if (valueLength == 0xFFFFFFFF) {
          isEncapsulated = true;
          // For encapsulated data, we need to parse until sequence delimiter
          valueLength = fileBytes.length - offset;
        }
      } else {
        return null;
      }

      return {
        'start': offset,
        'length': valueLength,
        'encapsulated': isEncapsulated,
      };
    } catch (e) {
      return null;
    }
  }

  Future<List<Uint8List>> _extractEncapsulatedFrames(
      Uint8List fileBytes,
      int startPos,
      ) async {
    final frames = <Uint8List>[];
    var currentPos = startPos;

    // Encapsulated data format:
    // - Basic Offset Table (optional) - Item tag (FFFE,E000) with offsets
    // - Frame items - Each frame is Item tag (FFFE,E000) + length + compressed data
    // - Sequence Delimiter (FFFE,E0DD)

    while (currentPos < fileBytes.length - 8) {
      // Read tag (4 bytes)
      final tag = ByteData.sublistView(fileBytes).getUint32(currentPos, Endian.little);

      if (tag == 0xE000FFFE) {
        // Item tag - this is a frame or offset table
        final itemLength = ByteData.sublistView(fileBytes).getUint32(currentPos + 4, Endian.little);

        if (itemLength == 0) {
          // Empty item, skip it
          currentPos += 8;
          continue;
        }

        final frameStart = currentPos + 8;
        final frameEnd = frameStart + itemLength;

        if (frameEnd > fileBytes.length) {
          break;
        }

        final frameData = fileBytes.sublist(frameStart, frameEnd);

        // Check if this is JPEG data (starts with 0xFFD8)
        // First item might be offset table, skip if it doesn't look like image data
        if (frameData.length > 2 && frameData[0] == 0xFF && frameData[1] == 0xD8) {
          frames.add(frameData);
        }

        currentPos = frameEnd;
      } else if (tag == 0xE0DDFFFE) {
        // Sequence Delimiter - end of pixel data
        break;
      } else {
        // Unknown tag, stop parsing
        break;
      }
    }

    return frames;
  }

  Future<List<Uint8List>> _extractUncompressedFrames(
      Uint8List fileBytes,
      int startPos,
      int pixelDataLength,
      ) async {
    final frames = <Uint8List>[];

    if (_rows == 0 || _columns == 0) {
      return frames;
    }

    final bytesPerPixel = _bitsAllocated ~/ 8;
    final bytesPerFrame = _rows * _columns * bytesPerPixel;

    // Extract frames
    for (var i = 0; i < _numberOfFrames; i++) {
      final frameStart = startPos + (i * bytesPerFrame);
      final frameEnd = frameStart + bytesPerFrame;

      if (frameEnd > fileBytes.length) {
        break;
      }

      final rawPixelData = fileBytes.sublist(frameStart, frameEnd);

      // Convert to displayable image
      final imageData = await _convertRawToImage(rawPixelData);
      if (imageData != null) {
        frames.add(imageData);
      }
    }

    return frames;
  }

  Future<Uint8List?> _convertRawToImage(Uint8List rawPixelData) async {
    // For now, this is a placeholder
    // In a production app, you would:
    // 1. Apply window/level adjustments
    // 2. Convert to 8-bit grayscale if needed
    // 3. Encode as PNG or another format Flutter can display

    // This basic implementation assumes 8-bit grayscale
    // and creates a PNG

    if (_bitsAllocated == 8) {
      return _createGrayscalePNG(rawPixelData, _columns, _rows);
    }

    return null;
  }

  Future<Uint8List?> _createGrayscalePNG(
      Uint8List grayscaleData,
      int width,
      int height,
      ) async {
    // Convert grayscale to RGBA for Flutter
    final rgba = Uint8List(width * height * 4);
    for (var i = 0; i < grayscaleData.length; i++) {
      final gray = grayscaleData[i];
      rgba[i * 4] = gray;     // R
      rgba[i * 4 + 1] = gray; // G
      rgba[i * 4 + 2] = gray; // B
      rgba[i * 4 + 3] = 255;  // A
    }

    final completer = Completer<Uint8List?>();
    ui.decodeImageFromPixels(
      rgba,
      width,
      height,
      ui.PixelFormat.rgba8888,
          (ui.Image image) async {
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        completer.complete(byteData?.buffer.asUint8List());
      },
    );

    return completer.future;
  }

  void _toggleMetadata() {
    setState(() {
      _isMetadataVisible = !_isMetadataVisible;
    });
  }

  void _resetZoom() {
    _transformationController.value = Matrix4.identity()..scale(0.85);
  }

  void _zoomIn() {
    final currentScale = _transformationController.value.getMaxScaleOnAxis();
    final newScale = (currentScale * 1.2).clamp(0.5, 10.0);
    _transformationController.value = Matrix4.identity()..scale(newScale);
  }

  void _zoomOut() {
    final currentScale = _transformationController.value.getMaxScaleOnAxis();
    final newScale = (currentScale / 1.2).clamp(0.5, 10.0);
    _transformationController.value = Matrix4.identity()..scale(newScale);
  }

  void _onFrameChanged(double value) {
    setState(() {
      _currentFrameIndex = value.round();
    });
  }


  void _startPlayback() {
    if (_frames.length <= 1) return;

    setState(() {
      _isPlaying = true;
    });

    _playbackTimer?.cancel();
    _playbackTimer = Timer.periodic(
      Duration(milliseconds: (100 / _playbackSpeed).round()),
          (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        setState(() {
          _currentFrameIndex = (_currentFrameIndex + 1) % _frames.length;
        });
      },
    );
  }

  void _stopPlayback() {
    setState(() {
      _isPlaying = false;
    });
    _playbackTimer?.cancel();
  }

  void _togglePlayback() {
    if (_isPlaying) {
      _stopPlayback();
    } else {
      _startPlayback();
    }
  }

  void _onZoomStart(_) {
    setState(() {
      _isZooming = true;
    });
  }

  void _onZoomEnd(_) {
    if (_transformationController.value.getMaxScaleOnAxis() <= 1.0) {
      setState(() {
        _isZooming = false;
      });
    }
  }

  void _openEditor() {
    if (_frames.isEmpty) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProImageEditor.memory(
          _frames[_currentFrameIndex],
          callbacks: ProImageEditorCallbacks(
            onImageEditingComplete: (Uint8List bytes) async {
              await _uploadEditedImage(bytes);
              if (mounted) {
                Navigator.pop(context);
              }
            },
          ),
        ),
      ),
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
          '${tempDir.path}/edited_dicom_${DateTime.now().millisecondsSinceEpoch}.jpg');
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
            _frames[_currentFrameIndex] = bytes;
          });

          if (widget.patientId != null && widget.scanId != null && widget.fileId != null) {
            try {
              context.read<ScanActionsCubit>().add(EditScanFileEvent(
                patientId: widget.patientId!,
                scanId: widget.scanId!,
                fileId: widget.fileId!,
                newKey: uploads.first.key,
              ));
            } catch (e) {
              // Ignore if ScanActionsCubit is not available in context
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
      backgroundColor: Colors.black,
      appBar: _buildAppBar(),
      body: _isLoading
          ? _buildLoadingState()
          : (_error != null && !_showFallbackImage)
          ? _buildErrorState()
          : _showFallbackImage
          ? _buildFallbackImageViewer()
          : _buildViewer(),
    );
  }

  Widget _buildFallbackImageViewer() {
    final heroTag = widget.heroTag ?? widget.url ?? widget.filePath ?? "dicom_fallback";
    return Center(
      child: InteractiveViewer(
        minScale: 0.5,
        maxScale: 10.0,
        child: Hero(
          tag: heroTag,
          child: Image.network(
            widget.url ?? "",
            fit: BoxFit.contain,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(child: CircularProgressIndicator(color: Colors.white));
            },
            errorBuilder: (context, error, stackTrace) => _buildErrorState(),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.black,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: const Text(
        'DICOM Viewer',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        if (widget.showMetadata)
          IconButton(
            icon: Icon(
              _isMetadataVisible ? Icons.info_outline : Icons.info,
              color: Colors.white,
            ),
            onPressed: _toggleMetadata,
            tooltip: 'Toggle metadata',
          ),
        if (!_isLoading && _frames.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: _openEditor,
            tooltip: 'Edit Image',
          ),
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: _parseDicom,
          tooltip: 'Reload',
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              strokeWidth: 4,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          SizedBox(height: 24),
          Text(
            'Loading DICOM file...',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 24),
            const Text(
              'Failed to load DICOM file',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _error ?? 'Unknown error',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _parseDicom,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () => setState(() => _showFallbackImage = true),
              icon: const Icon(Icons.image, color: Colors.white70),
              label: const Text('View as regular Image', 
                style: TextStyle(color: Colors.white70)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewer() {
    return Stack(
      children: [
        // Main image viewer
        Positioned.fill(
          child: GestureDetector(
            onDoubleTap: _resetZoom,
            child: InteractiveViewer(
              transformationController: _transformationController,
              minScale: 0.5,
              maxScale: 10.0,
              constrained: false,
              onInteractionStart: _onZoomStart,
              onInteractionEnd: _onZoomEnd,
              child: Center(
                child: Hero(
                  tag: widget.heroTag ?? widget.url ?? widget.filePath ?? "dicom_image",
                  child: Image.memory(
                    _frames[_currentFrameIndex],
                    fit: BoxFit.contain,
                    gaplessPlayback: true,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.broken_image, color: Colors.white54, size: 64),
                            SizedBox(height: 16),
                            Text(
                              'Failed to display frame',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),

        // Frame counter
        Positioned(
          top: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white24, width: 1),
            ),
            child: Text(
              '${_currentFrameIndex + 1} / ${_frames.length}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        // Frame slider and controls (bottom)
        Positioned(
          left: 16,
          right: 16,
          bottom: 16,
          child: _buildFrameControls(),
        ),

        // Metadata panel
        if (widget.showMetadata && _isMetadataVisible)
          Positioned(
            left: 16,
            top: 80,
            child: _buildMetadataPanel(),
          ),

        // Modality badge
        if (_modality != null)
          Positioned(
            left: 16,
            bottom: 120,
            child: _buildModalityBadge(),
          ),
      ],
    );
  }

  Widget _buildFrameControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Frame slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Colors.white,
              inactiveTrackColor: Colors.white24,
              thumbColor: Colors.white,
              overlayColor: Colors.white.withValues(alpha: 0.2),
              trackHeight: 3,
            ),
            child: Slider(
              value: _currentFrameIndex.toDouble(),
              min: 0,
              max: (_frames.length - 1).toDouble(),
              divisions: _frames.length > 1 ? _frames.length - 1 : 1,
              label: '${_currentFrameIndex + 1}',
              onChanged: _onFrameChanged,
            ),
          ),

          const SizedBox(height: 12),

          // Playback and zoom controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Playback buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(
                      _isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                    ),
                    onPressed: _togglePlayback,
                    tooltip: _isPlaying ? 'Pause' : 'Play',
                  ),
                  const SizedBox(width: 16),
                  // Speed control
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Speed:',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      const SizedBox(width: 4),
                      DropdownButton<double>(
                        value: _playbackSpeed,
                        dropdownColor: Colors.black87,
                        iconEnabledColor: Colors.white,
                        style: const TextStyle(color: Colors.white),
                        items: const [
                          DropdownMenuItem(value: 0.5, child: Text('0.5x')),
                          DropdownMenuItem(value: 1.0, child: Text('1x')),
                          DropdownMenuItem(value: 2.0, child: Text('2x')),
                          DropdownMenuItem(value: 4.0, child: Text('4x')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _playbackSpeed = value;
                            });
                            // Restart playback with new speed if playing
                            if (_isPlaying) {
                              _startPlayback();
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),

              // Zoom controls
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.zoom_out, color: Colors.white),
                    onPressed: _zoomOut,
                    tooltip: 'Zoom out',
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.zoom_in, color: Colors.white),
                    onPressed: _zoomIn,
                    tooltip: 'Zoom in',
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    onPressed: _resetZoom,
                    tooltip: 'Reset zoom',
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataPanel() {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.description,
                  color: Colors.white,
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  'File Details',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Metadata items
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _metadata.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.key,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        entry.value,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModalityBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getModalityColor(_modality),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24, width: 1),
      ),
      child: Text(
        _modality ?? 'Unknown',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getModalityColor(String? modality) {
    switch (modality?.toUpperCase()) {
      case 'CT':
        return Colors.blue.withValues(alpha: 0.8);
      case 'MR':
        return Colors.green.withValues(alpha: 0.8);
      case 'XA':
      case 'RF':
        return Colors.orange.withValues(alpha: 0.8);
      case 'US':
        return Colors.purple.withValues(alpha: 0.8);
      case 'PT':
        return Colors.red.withValues(alpha: 0.8);
      case 'NM':
        return Colors.teal.withValues(alpha: 0.8);
      case 'CR':
      case 'DR':
      case 'DX':
        return Colors.grey.withValues(alpha: 0.8);
      default:
        return Colors.indigo.withValues(alpha: 0.8);
    }
  }
}