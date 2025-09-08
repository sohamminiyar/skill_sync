import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';

class StorageMethods {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Uploads an image to Firebase Storage and returns the download URL.
  ///
  /// [childName] is the storage path (e.g., 'images').
  /// [file] is the image data as Uint8List.
  /// [uid] is the unique identifier to organize the file in storage.
  /// [contentType] is the MIME type of the image (e.g., 'image/jpeg', 'image/png').
  Future<String?> uploadImageToStorage(
      String childName,
      Uint8List file,
      String uid, {
        String contentType = 'image/jpeg',
      }) async {
    try {
      Reference ref = _storage.ref().child(childName).child(uid);
      UploadTask uploadTask = ref.putData(
        file,
        SettableMetadata(contentType: contentType),
      );
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image to Firebase Storage: $e');
      return null;
    }
  }
}