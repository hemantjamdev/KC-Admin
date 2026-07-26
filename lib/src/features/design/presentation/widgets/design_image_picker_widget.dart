import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/firebase/firebase_storage_paths.dart';
import '../../../../core/media/image_upload_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';

/// Admin image uploader widget for design galleries.
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
  State<DesignImagePickerWidget> createState() => _DesignImagePickerWidgetState();
}

class _DesignImagePickerWidgetState extends State<DesignImagePickerWidget> {
  final ImageUploadService _uploadService = ImageUploadService();
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String? _errorMessage;

  Future<void> _pickAndUploadImage() async {
    setState(() {
      _errorMessage = null;
    });

    final pickedFile = await _uploadService.pickImage();
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

      final updatedUrls = List<String>.from(widget.imageUrls)..add(result.downloadUrl);
      widget.onImageUrlsChanged(updatedUrls);

      // Set as thumbnail if first image
      if (widget.thumbnailUrl == null || widget.thumbnailUrl!.isEmpty) {
        widget.onThumbnailChanged(result.downloadUrl);
      }
    } catch (e) {
      setState(() => _errorMessage = 'Upload failed: $e');
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
      widget.onThumbnailChanged(updatedUrls.isNotEmpty ? updatedUrls.first : null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Design Gallery Images', style: AppTypography.cardTitle),
            Text(
              '${widget.imageUrls.length} image(s)',
              style: AppTypography.caption,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),

        // Upload progress indicator
        if (_isUploading) ...[
          LinearProgressIndicator(
            value: _uploadProgress,
            backgroundColor: AppColors.borderSoft,
            color: AppColors.brandGreen800,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Uploading image... ${(_uploadProgress * 100).toInt()}%',
            style: AppTypography.caption,
          ),
          const SizedBox(height: AppSpacing.sm),
        ],

        // Error message
        if (_errorMessage != null) ...[
          Text(
            _errorMessage!,
            style: AppTypography.caption.copyWith(color: AppColors.error),
          ),
          const SizedBox(height: AppSpacing.xs),
        ],

        // Image grid / gallery
        if (widget.imageUrls.isNotEmpty)
          SizedBox(
            height: 110,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: widget.imageUrls.length,
              separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
              itemBuilder: (context, index) {
                final url = widget.imageUrls[index];
                final isThumbnail = widget.thumbnailUrl == url;

                return Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: AppRadius.borderMd,
                        border: Border.all(
                          color: isThumbnail ? AppColors.brandGreen800 : AppColors.borderSoft,
                          width: isThumbnail ? 2.0 : 1.0,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: AppRadius.borderMd,
                        child: Image.network(
                          url,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: AppColors.softCream,
                            child: const Icon(Icons.broken_image_rounded, color: AppColors.mutedText),
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
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.brandGreen800,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Main',
                            style: TextStyle(color: AppColors.surfaceWhite, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),

                    // Remove button
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => _removeImage(index),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close_rounded, size: 14, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

        const SizedBox(height: AppSpacing.sm),

        // Action button
        AppButton(
          text: 'Upload Image to Storage',
          icon: Icons.cloud_upload_rounded,
          isLoading: _isUploading,
          onPressed: _isUploading ? null : _pickAndUploadImage,
        ),
      ],
    );
  }
}
