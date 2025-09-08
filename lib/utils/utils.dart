import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void showSnackBar(BuildContext context, String content) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(content),
      backgroundColor: Colors.red,
      duration: const Duration(seconds: 3),
    ),
  );
}

Future<Uint8List?> pickImage() async {
  try {
    FilePickerResult? pickedImage = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
    );
    if (pickedImage != null) {
      if (kIsWeb) {
        return pickedImage.files.single.bytes;
      }
      if (pickedImage.files.single.path != null) {
        return await File(pickedImage.files.single.path!).readAsBytes();
      }
    }
    return null;
  } catch (e) {
    return null; // Let the caller handle the error with showSnackBar
  }
}