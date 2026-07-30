import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

/// Result of an image upload operation.
class ImageUploadResult {
  const ImageUploadResult({
    required this.downloadUrl,
    required this.storagePath,
  });

  final String downloadUrl;
  final String storagePath;
}

/// Service handling image selection, validation, and upload to Firebase Storage.
class ImageUploadService {
  ImageUploadService({FirebaseStorage? storage, ImagePicker? picker})
    : _storage = storage ?? FirebaseStorage.instance,
      _picker = picker ?? ImagePicker();

  final FirebaseStorage _storage;
  final ImagePicker _picker;

  /// Practical 5MB file size limit for boutique design images.
  static const int maxFileSizeBytes = 5 * 1024 * 1024;
  static const List<String> allowedExtensions = ['jpg', 'jpeg', 'png', 'webp'];

  /// Pick an image from gallery or camera.
  Future<XFile?> pickImage({ImageSource source = ImageSource.gallery}) async {
    return await _picker.pickImage(
      source: source,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );
  }

  /// Validates file size and format.
  String? validateImageFile(File file) {
    final length = file.lengthSync();
    if (length > maxFileSizeBytes) {
      return 'File size exceeds maximum limit of 5MB.';
    }
    final path = file.path.toLowerCase();
    final hasValidExt = allowedExtensions.any((ext) => path.endsWith('.$ext'));
    if (!hasValidExt) {
      return 'Unsupported image format. Allowed formats: JPG, PNG, WebP.';
    }
    return null;
  }

  /// Uploads image to specified storage path and returns result with download URL.
  Future<ImageUploadResult> uploadImage({
    required File file,
    required String storagePath,
    void Function(double progress)? onProgress,
  }) async {
    final validationError = validateImageFile(file);
    if (validationError != null) {
      throw Exception(validationError);
    }

    final ref = _storage.ref().child(storagePath);
    final ext = file.path.split('.').last.toLowerCase();
    final contentType = ext == 'png'
        ? 'image/png'
        : (ext == 'webp' ? 'image/webp' : 'image/jpeg');

    final uploadTask = ref.putFile(
      file,
      SettableMetadata(contentType: contentType),
    );

    if (onProgress != null) {
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        onProgress(progress);
      });
    }

    final snapshot = await uploadTask;
    final downloadUrl = await snapshot.ref.getDownloadURL();

    return ImageUploadResult(
      downloadUrl: downloadUrl,
      storagePath: storagePath,
    );
  }

  /// Deletes a file from Storage safely.
  Future<void> deleteImage(String storagePath) async {
    try {
      final ref = _storage.ref().child(storagePath);
      await ref.delete();
    } catch (_) {
      // Ignore missing or already deleted storage objects
    }
  }

  /// Generates a unique file ID.
  String generateFileId() => const Uuid().v4();
}
