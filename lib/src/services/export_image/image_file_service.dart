import 'dart:typed_data';

abstract interface class ImageFileService {
  Future<bool> savePng({
    required String dialogTitle,
    required String shareSubject,
    required String suggestedFileName,
    required Uint8List pngBytes,
  });
}
