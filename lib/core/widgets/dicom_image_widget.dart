import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:dicom_parser/dicom_parser.dart';
import 'package:http/http.dart' as http;
import 'package:ocurithm/core/utils/colors.dart';

/// A widget that parses and renders DICOM (.dcm) files.
/// Supports both local file paths and network URLs.
class DicomImageWidget extends StatefulWidget {
  /// Local file path to a .dcm file (takes priority over [url])
  final String? filePath;

  /// Network URL to a .dcm file
  final String? url;

  /// How the image should be inscribed into the space.
  final BoxFit fit;

  /// Widget to show while loading/parsing
  final Widget? loadingWidget;

  /// Widget builder to show on error
  final Widget Function(BuildContext context)? errorBuilder;

  /// Whether to show DICOM metadata overlay
  final bool showMetadata;

  const DicomImageWidget({
    super.key,
    this.filePath,
    this.url,
    this.fit = BoxFit.cover,
    this.loadingWidget,
    this.errorBuilder,
    this.showMetadata = false,
  }) : assert(filePath != null || url != null,
            'Either filePath or url must be provided');

  @override
  State<DicomImageWidget> createState() => _DicomImageWidgetState();
}

class _DicomImageWidgetState extends State<DicomImageWidget> {
  Uint8List? _imageBytes;
  String? _modality;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _parseDicom();
  }

  @override
  void didUpdateWidget(covariant DicomImageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.filePath != widget.filePath || oldWidget.url != widget.url) {
      _parseDicom();
    }
  }

  Future<void> _parseDicom() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _imageBytes = null;
    });

    try {
      Uint8List? fileBytes;

      if (widget.filePath != null) {
        // Read from local file
        final file = File(widget.filePath!);
        if (await file.exists()) {
          fileBytes = await file.readAsBytes();
        } else {
          throw Exception('File not found');
        }
      } else if (widget.url != null) {
        // Download from network
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

      final dicomParser = DICOMParser();
      final DICOMModel? dicomModel =
          await dicomParser.parseDICOMFile(fileBytes);

      if (dicomModel != null && dicomModel.imageBytes != null) {
        if (mounted) {
          setState(() {
            _imageBytes = dicomModel.imageBytes;
            _modality = dicomModel.getModality();
            _isLoading = false;
          });
        }
      } else {
        throw Exception('Could not parse DICOM image');
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return widget.loadingWidget ?? _buildDefaultLoading();
    }

    if (_error != null || _imageBytes == null) {
      return widget.errorBuilder?.call(context) ?? _buildDefaultError();
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.memory(
          _imageBytes!,
          fit: widget.fit,
          gaplessPlayback: true,
        ),
        if (widget.showMetadata && _modality != null)
          Positioned(
            top: 6,
            left: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                _modality!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDefaultLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: Colorz.primaryColor,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Parsing DICOM...',
            style: TextStyle(fontSize: 9, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultError() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.medical_services, size: 32, color: Colorz.primaryColor),
        const SizedBox(height: 4),
        const Text(
          'DICOM',
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

/// A static utility to parse DICOM bytes and return image bytes.
/// Useful for cases where you need the raw image data (e.g., fullscreen viewer).
class DicomParserUtil {
  static final DICOMParser _parser = DICOMParser();

  /// Parse DICOM file bytes and return the rendered image bytes.
  static Future<Uint8List?> parseFromBytes(Uint8List fileBytes) async {
    try {
      final model = await _parser.parseDICOMFile(fileBytes);
      return model?.imageBytes;
    } catch (_) {
      return null;
    }
  }

  /// Parse DICOM from a local file path.
  static Future<Uint8List?> parseFromFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        return parseFromBytes(bytes);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Parse DICOM from a network URL.
  static Future<Uint8List?> parseFromUrl(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return parseFromBytes(response.bodyBytes);
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
