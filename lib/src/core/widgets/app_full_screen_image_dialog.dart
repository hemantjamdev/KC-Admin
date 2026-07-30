import 'dart:io';
import 'package:flutter/material.dart';

/// Full screen interactive image preview dialog for KC-Admin application.
/// Supports single image or multi-image galleries with pinch-to-zoom and pan.
class AppFullScreenImageDialog extends StatefulWidget {
  const AppFullScreenImageDialog({
    super.key,
    required this.imageUrls,
    this.initialIndex = 0,
  });

  final List<String> imageUrls;
  final int initialIndex;

  /// Helper launcher to present the fullscreen dialog.
  static Future<void> show(
    BuildContext context, {
    required List<String> imageUrls,
    int initialIndex = 0,
  }) async {
    if (imageUrls.isEmpty) return;
    await showDialog<void>(
      context: context,
      useSafeArea: false,
      barrierColor: Colors.black.withValues(alpha: 0.92),
      builder: (ctx) => AppFullScreenImageDialog(
        imageUrls: imageUrls,
        initialIndex: initialIndex,
      ),
    );
  }

  /// Helper launcher for a single image URL or path.
  static Future<void> showSingle(BuildContext context, String imageUrl) async {
    if (imageUrl.isEmpty) return;
    await show(context, imageUrls: [imageUrl], initialIndex: 0);
  }

  @override
  State<AppFullScreenImageDialog> createState() =>
      _AppFullScreenImageDialogState();
}

class _AppFullScreenImageDialogState extends State<AppFullScreenImageDialog> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, widget.imageUrls.length - 1);
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildImageWidget(String url) {
    final isFile = !url.startsWith('http://') && !url.startsWith('https://');

    if (isFile) {
      return Image.file(
        File(url),
        fit: BoxFit.contain,
        errorBuilder: (ctx, err, stack) => _buildErrorState(),
      );
    }

    return Image.network(
      url,
      fit: BoxFit.contain,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const Center(
          child: CircularProgressIndicator(
            color: Colors.white70,
            strokeWidth: 2,
          ),
        );
      },
      errorBuilder: (context, err, stack) => _buildErrorState(),
    );
  }

  Widget _buildErrorState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.broken_image_rounded, color: Colors.white54, size: 64),
          SizedBox(height: 12),
          Text(
            'Unable to display image',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Dismiss on tap background
          Positioned.fill(
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(color: Colors.transparent),
            ),
          ),

          // Main Interactive PageView
          Positioned.fill(
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.imageUrls.length,
              onPageChanged: (index) {
                setState(() => _currentIndex = index);
              },
              itemBuilder: (context, index) {
                return InteractiveViewer(
                  minScale: 0.8,
                  maxScale: 4.0,
                  child: Center(
                    child: _buildImageWidget(widget.imageUrls[index]),
                  ),
                );
              },
            ),
          ),

          // Top Action Bar with Close Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 16,
            child: Material(
              color: Colors.transparent,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white24),
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ),
          ),

          // Page counter indicator for multiple images
          if (widget.imageUrls.length > 1)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 20,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Text(
                    '${_currentIndex + 1} / ${widget.imageUrls.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
