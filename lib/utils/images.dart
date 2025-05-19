import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

class Images {
  
  static Future<String?> selectImage() async {
    FilePickerResult? imageSelected = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (imageSelected != null && imageSelected.files.single.path != null) {
      return imageSelected.files.single.path;
    }
    return null;
  }

  static String getDefaultImage(bool administrador) {
    return administrador
        ? 'assets/images/profile_default.jpg'
        : 'assets/images/profile_default.jpg';
  }

  static bool isAssetImage(String path) {
    return path.startsWith('assets/');
  }

  static ImageProvider getImageProvider(String imagePath) {
    if (isAssetImage(imagePath)) {
      return AssetImage(imagePath);
    } else if (imagePath.isNotEmpty) {
      return FileImage(File(imagePath));
    }
    return const AssetImage('assets/images/product_default.png');
  }
}


