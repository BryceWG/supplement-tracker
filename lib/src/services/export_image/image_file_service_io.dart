import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'image_file_service.dart';

class _ImageFileServiceIo implements ImageFileService {
  @override
  Future<bool> savePng({
    required String dialogTitle,
    required String shareSubject,
    required String suggestedFileName,
    required Uint8List pngBytes,
  }) async {
    var fileName = suggestedFileName.trim();
    if (!fileName.toLowerCase().endsWith('.png')) fileName = '$fileName.png';

    // `FilePicker.platform.saveFile` is not reliably supported on Android/iOS.
    // Use the system share sheet as a mobile-friendly export path.
    if (Platform.isAndroid || Platform.isIOS) {
      final dir = await getTemporaryDirectory();
      final path = '${dir.path}${Platform.pathSeparator}$fileName';
      final file = File(path);
      await file.writeAsBytes(pngBytes, flush: true);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'image/png', name: fileName)],
          subject: shareSubject,
        ),
      );
      return true;
    }

    final outputPath = await FilePicker.platform.saveFile(
      dialogTitle: dialogTitle,
      fileName: fileName,
      type: FileType.custom,
      allowedExtensions: const ['png'],
    );

    if (outputPath == null || outputPath.trim().isEmpty) return false;
    await File(outputPath).writeAsBytes(pngBytes, flush: true);
    return true;
  }
}

ImageFileService createImageFileServiceImpl() => _ImageFileServiceIo();
