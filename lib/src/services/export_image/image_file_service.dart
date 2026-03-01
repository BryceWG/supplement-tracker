import 'dart:typed_data';

abstract interface class ImageFileService {
  Future<bool> savePng({
    required String suggestedFileName,
    required Uint8List pngBytes,
  });
}

