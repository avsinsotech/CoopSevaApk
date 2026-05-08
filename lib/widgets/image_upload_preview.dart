import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:form_app_27_3_2026/image_preview_screen.dart';

/// A reusable image preview box that shows:
/// - A circular progress indicator while [isUploading] is true
/// - The captured/picked image once upload is done
/// - An empty placeholder with [emptyIcon] and [emptyLabel] when no image is set
///
/// Use this widget in both new_customer_screen.dart and update_customer_screen.dart
/// to provide consistent visual feedback during image uploads.
class ImageUploadPreview extends StatelessWidget {
  /// Set to `true` while the upload API call is in progress.
  final bool isUploading;

  /// Image file path to display once uploaded (from XFile).
  final XFile? imageFile;

  /// Raw bytes to display (takes priority over [imageFile]).
  final Uint8List? imageBytes;

  /// Icon shown in the empty state placeholder.
  final IconData emptyIcon;

  /// Label shown below the icon in the empty state.
  final String emptyLabel;

  /// Height of the preview box.
  final double height;

  /// Width of the preview box. Defaults to double.infinity.
  final double width;

  /// Border radius for the preview box. Defaults to 12.
  final double borderRadius;

  const ImageUploadPreview({
    super.key,
    required this.isUploading,
    this.imageFile,
    this.imageBytes,
    this.emptyIcon = Icons.document_scanner,
    this.emptyLabel = 'Tap to Capture or Upload',
    this.height = 140,
    this.width = double.infinity,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    if (isUploading) {
      return _buildShell(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 36,
              width: 36,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: const Color(0xFF1A6B5A),
                backgroundColor: Colors.grey.shade300,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Uploading…',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (imageBytes != null) {
      return _buildImageShell(
        context,
        child: Image.memory(
          imageBytes!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (_, __, ___) => _errorPlaceholder(),
        ),
      );
    }

    if (imageFile != null) {
      final file = File(imageFile!.path);
      if (file.existsSync()) {
        return _buildImageShell(
          context,
          child: Image.file(
            file,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (_, __, ___) => _errorPlaceholder(),
          ),
        );
      }
    }

    // Empty placeholder
    return _buildShell(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(emptyIcon, color: const Color(0xFF233C67), size: 36),
          const SizedBox(height: 8),
          Text(
            emptyLabel,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
        ],
      ),
    );
  }

  /// Plain bordered container — used for loading & empty states.
  Widget _buildShell({required Widget child}) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: Colors.grey.shade300, width: 1.5),
      ),
      child: child,
    );
  }

  /// Bordered container with image + edit-icon overlay.
  Widget _buildImageShell(BuildContext context, {required Widget child}) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: Colors.grey.shade300, width: 1.5),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius - 1.5),
              child: child,
            ),
          ),
          Positioned(
            top: 6,
            right: 6,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ImagePreviewScreen(
                          imageBytes: imageBytes,
                          imageFile: imageFile,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.visibility,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit, color: Colors.white, size: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image_outlined,
            color: Colors.grey.shade400,
            size: 32,
          ),
          const SizedBox(height: 6),
          Text(
            'Preview unavailable',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
