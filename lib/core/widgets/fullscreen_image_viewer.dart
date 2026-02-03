import 'package:flutter/material.dart';
import 'package:ocurithm/core/utils/colors.dart';

class FullscreenImageViewer extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const FullscreenImageViewer({
    super.key,
    required this.imageUrls,
    this.initialIndex = 0,
  });

  @override
  State<FullscreenImageViewer> createState() => _FullscreenImageViewerState();
}

class _FullscreenImageViewerState extends State<FullscreenImageViewer> with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late int _currentIndex;
  double _verticalOffset = 0.0;
  double _backgroundOpacity = 1.0;
  bool _isZooming = false;
  final TransformationController _transformationController = TransformationController();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
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
      // Calculate opacity: starts fading after 50px, fully transparent at 300px
      _backgroundOpacity = (1.0 - (_verticalOffset.abs() / 300)).clamp(0.0, 1.0);
    });
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    if (_isZooming) return;
    if (_verticalOffset.abs() > 150 || details.primaryVelocity!.abs() > 500) {
      Navigator.of(context).pop();
    } else {
      // Snap back if swipe wasn't far enough
      setState(() {
        _verticalOffset = 0.0;
        _backgroundOpacity = 1.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Dynamic black background for fade effect
          Positioned.fill(
            child: Opacity(
              opacity: _backgroundOpacity,
              child: Container(color: Colors.black),
            ),
          ),
          
          // Image Content with Swipe and Transform
          Transform.translate(
            offset: Offset(0, _verticalOffset),
            child: GestureDetector(
              onVerticalDragUpdate: _isZooming ? null : _onVerticalDragUpdate,
              onVerticalDragEnd: _isZooming ? null : _onVerticalDragEnd,
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.imageUrls.length,
                physics: _isZooming ? const NeverScrollableScrollPhysics() : const BouncingScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  return InteractiveViewer(
                    transformationController: _transformationController,
                    minScale: 1.0,
                    maxScale: 5.0,
                    onInteractionStart: (_) => setState(() => _isZooming = true),
                    onInteractionEnd: (_) {
                      // Check if we are actually zoomed in or just touched
                      if (_transformationController.value.getMaxScaleOnAxis() <= 1.0) {
                        setState(() => _isZooming = false);
                      }
                    },
                    child: Center(
                      child: Hero(
                        tag: widget.imageUrls[index],
                        child: Image.network(
                          widget.imageUrls[index],
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(color: Colors.white70),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return _buildErrorWidget(widget.imageUrls[index]);
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          
          // UI Controls (Close button and Index)
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
                        icon: const Icon(Icons.close, color: Colors.white, size: 28),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      if (widget.imageUrls.length > 1)
                        Text(
                          "${_currentIndex + 1} / ${widget.imageUrls.length}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      const SizedBox(width: 48), // Spacer to balance the close button
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
        const Text("Failed to load image", style: TextStyle(color: Colors.white70)),
        if (url.toLowerCase().endsWith('.dcm')) ...[
          const SizedBox(height: 8),
          const Text("(DICOM files cannot be previewed)",
              style: TextStyle(color: Colors.white38, fontSize: 12)),
        ]
      ],
    );
  }
}
