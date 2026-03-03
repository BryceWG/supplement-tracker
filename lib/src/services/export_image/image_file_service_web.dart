// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:html' as html;
import 'dart:typed_data';

import 'image_file_service.dart';

class _ImageFileServiceWeb implements ImageFileService {
  @override
  Future<bool> savePng({
    required String dialogTitle,
    required String shareSubject,
    required String suggestedFileName,
    required Uint8List pngBytes,
  }) async {
    var fileName = suggestedFileName.trim();
    if (!fileName.toLowerCase().endsWith('.png')) fileName = '$fileName.png';

    final blob = html.Blob([pngBytes], 'image/png');
    final url = html.Url.createObjectUrlFromBlob(blob);

    final anchor = html.AnchorElement(href: url)
      ..download = fileName
      ..style.display = 'none';

    html.document.body?.children.add(anchor);
    anchor.click();
    anchor.remove();
    html.Url.revokeObjectUrl(url);
    return true;
  }
}

ImageFileService createImageFileServiceImpl() => _ImageFileServiceWeb();
