import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/firebase/firebase_storage_paths.dart';
import '../../../../core/media/image_upload_service.dart';

import '../../../../core/widgets/app_full_screen_image_dialog.dart';

/// Redesigned Admin Image Upload Widget for Product Garment Photography.
/// On tap, opens a modal choice between Camera and Gallery.
class DesignImagePickerWidget extends StatefulWidget {
  const DesignImagePickerWidget({
    super.key,
    required this.boutiqueId,
    required this.designId,
    required this.thumbnailUrl,
    required this.imageUrls,
    required this.onThumbnailChanged,
    required this.onImageUrlsChanged,
  });

  final String boutiqueId;
  final String designId;
  final String? thumbnailUrl;
  final List<String> imageUrls;
  final ValueChanged<String?> onThumbnailChanged;
  final ValueChanged<List<String>> onImageUrlsChanged;

  @override
  State<DesignImagePickerWidget> createState() =>
      _DesignImagePickerWidgetState();
}

class _DesignImagePickerWidgetState extends State<DesignImagePickerWidget> {
  final ImageUploadService _uploadService = ImageUploadService();
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String? _errorMessage;

  void _showImageSourcePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Upload Garment Photo',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Choose how you want to add product imagery',
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 20),

              // Camera Option
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    color: AppColors.primary,
                  ),
                ),
                title: Text(
                  'Take Photo (Camera)',
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                subtitle: Text(
                  'Capture product photo using camera',
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _pickAndUploadImage(ImageSource.camera);
                },
              ),
              const Divider(color: AppColors.surfaceBorder, height: 1),

              // Gallery Option
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.photo_library_rounded,
                    color: AppColors.primary,
                  ),
                ),
                title: Text(
                  'Choose from Gallery',
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                subtitle: Text(
                  'Select existing photo from device storage',
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _pickAndUploadImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickAndUploadImage(ImageSource source) async {
    setState(() {
      _errorMessage = null;
    });

    final pickedFile = await _uploadService.pickImage(source: source);
    if (pickedFile == null) return;

    final file = File(pickedFile.path);
    final validationError = _uploadService.validateImageFile(file);
    if (validationError != null) {
      setState(() => _errorMessage = validationError);
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    try {
      final fileId = _uploadService.generateFileId();
      final ext = file.path.split('.').last.toLowerCase();
      final storagePath = FirebaseStoragePaths.designImage(
        widget.boutiqueId,
        widget.designId,
        fileId,
        ext,
      );

      final result = await _uploadService.uploadImage(
        file: file,
        storagePath: storagePath,
        onProgress: (p) => setState(() => _uploadProgress = p),
      );

      final updatedUrls = List<String>.from(widget.imageUrls)
        ..add(result.downloadUrl);
      widget.onImageUrlsChanged(updatedUrls);

      if (widget.thumbnailUrl == null || widget.thumbnailUrl!.isEmpty) {
        widget.onThumbnailChanged(result.downloadUrl);
      }
    } catch (e) {
      // Fallback: If Firebase Storage permission issue occurs, convert local file path to displayable file URI
      final localUrl = file.path;
      final updatedUrls = List<String>.from(widget.imageUrls)..add(localUrl);
      widget.onImageUrlsChanged(updatedUrls);
      if (widget.thumbnailUrl == null || widget.thumbnailUrl!.isEmpty) {
        widget.onThumbnailChanged(localUrl);
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  void _removeImage(int index) {
    final updatedUrls = List<String>.from(widget.imageUrls);
    final removedUrl = updatedUrls.removeAt(index);
    widget.onImageUrlsChanged(updatedUrls);

    if (widget.thumbnailUrl == removedUrl) {
      widget.onThumbnailChanged(
        updatedUrls.isNotEmpty ? updatedUrls.first : null,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasImages = widget.imageUrls.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_isUploading) ...[
          // ── Upload Progress Indicator ──
          Container(
            height: 56,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 2.5,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Uploading... ${(_uploadProgress * 100).toInt()}%',
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],

        if (!hasImages && !_isUploading)
          // ── Empty State: Full-width Upload Tile ──
          GestureDetector(
            onTap: _showImageSourcePicker,
            child: Container(
              height: 125,
              width: double.infinity,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.35),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add_a_photo_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap to Upload Product Imagery',
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Camera • Gallery',
                    style: GoogleFonts.montserrat(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),

        if (hasImages)
          // ── Images Grid with inline + button ──
          LayoutBuilder(
            builder: (context, constraints) {
              // Calculate tile size: 3 tiles per row with gaps
              const crossAxisCount = 3;
              const spacing = 10.0;
              final tileSize =
                  (constraints.maxWidth - (spacing * (crossAxisCount - 1))) /
                      crossAxisCount;

              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: [
                  // ── Image tiles ──
                  for (int index = 0;
                      index < widget.imageUrls.length;
                      index++)
                    _ImageTile(
                      url: widget.imageUrls[index],
                      size: tileSize,
                      isThumbnail:
                          widget.thumbnailUrl == widget.imageUrls[index],
                      allUrls: widget.imageUrls,
                      index: index,
                      onRemove: () => _removeImage(index),
                      onSetThumbnail: () =>
                          widget.onThumbnailChanged(widget.imageUrls[index]),
                    ),
                  // ── Add (+) tile ──
                  GestureDetector(
                    onTap: _isUploading ? null : _showImageSourcePicker,
                    child: Container(
                      width: tileSize,
                      height: tileSize,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.35),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.add_rounded,
                              color: AppColors.primary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Add',
                            style: GoogleFonts.montserrat(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

        if (_errorMessage != null) ...[
          const SizedBox(height: 8),
          Text(
            _errorMessage!,
            style: GoogleFonts.montserrat(fontSize: 11, color: AppColors.error),
          ),
        ],
      ],
    );
  }
}

// ── Individual Image Tile ──────────────────────────────────────────────────────

class _ImageTile extends StatelessWidget {
  const _ImageTile({
    required this.url,
    required this.size,
    required this.isThumbnail,
    required this.allUrls,
    required this.index,
    required this.onRemove,
    required this.onSetThumbnail,
  });

  final String url;
  final double size;
  final bool isThumbnail;
  final List<String> allUrls;
  final int index;
  final VoidCallback onRemove;
  final VoidCallback onSetThumbnail;

  @override
  Widget build(BuildContext context) {
    final isFile = !url.startsWith('http');
    final borderWidth = isThumbnail ? 2.5 : 1.0;
    final innerRadius = 16.0 - borderWidth;

    return GestureDetector(
      onTap: () => AppFullScreenImageDialog.show(
        context,
        imageUrls: allUrls,
        initialIndex: index,
      ),
      onLongPress: isThumbnail ? null : onSetThumbnail,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isThumbnail ? AppColors.primary : AppColors.surfaceBorder,
            width: borderWidth,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image — clip radius matches inner edge of border
            ClipRRect(
              borderRadius: BorderRadius.circular(innerRadius),
              child: isFile
                  ? Image.file(File(url), fit: BoxFit.cover)
                  : Image.network(
                      url,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, stack) => Container(
                        color: AppColors.surfaceBorder,
                        child: const Icon(
                          Icons.broken_image_rounded,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
            ),

            // Thumbnail badge
            if (isThumbnail)
              Positioned(
                bottom: 4,
                left: 4,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Main',
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

            // Delete badge
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: onRemove,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    size: 12,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
