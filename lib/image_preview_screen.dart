import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePreviewScreen extends StatelessWidget {
  final Uint8List? imageBytes;
  final XFile? imageFile;

  const ImagePreviewScreen({super.key, this.imageBytes, this.imageFile});

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;

    if (imageBytes != null) {
      imageWidget = Image.memory(
        imageBytes!,
        fit: BoxFit.contain,
        width: double.infinity,
        height: double.infinity,
      );
    } else if (imageFile != null) {
      final file = File(imageFile!.path);
      if (file.existsSync()) {
        imageWidget = Image.file(
          file,
          fit: BoxFit.contain,
          width: double.infinity,
          height: double.infinity,
        );
      } else {
        imageWidget = _errorPlaceholder();
      }
    } else {
      imageWidget = _errorPlaceholder();
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Image Preview",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.1,
          maxScale: 4.0,
          child: imageWidget,
        ),
      ),
    );
  }

  Widget _errorPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(Icons.broken_image_outlined, color: Colors.white54, size: 48),
        SizedBox(height: 16),
        Text(
          "Image not available",
          style: TextStyle(color: Colors.white54, fontSize: 16),
        ),
      ],
    );
  }
}
