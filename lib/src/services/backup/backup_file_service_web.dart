// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:convert';
import 'dart:html' as html;

import 'package:file_picker/file_picker.dart';

import 'backup_file_service.dart';

class _BackupFileServiceWeb implements BackupFileService {
  @override
  Future<bool> saveJson({
    required String suggestedFileName,
    required String json,
  }) async {
    final bytes = utf8.encode(json);
    final blob = html.Blob([bytes], 'application/json;charset=utf-8');
    final url = html.Url.createObjectUrlFromBlob(blob);

    final anchor = html.AnchorElement(href: url)
      ..download = suggestedFileName
      ..style.display = 'none';

    html.document.body?.children.add(anchor);
    anchor.click();
    anchor.remove();
    html.Url.revokeObjectUrl(url);
    return true;
  }

  @override
  Future<String?> pickJson() async {
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: '选择要导入的备份文件',
      type: FileType.custom,
      allowedExtensions: const ['json'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) return null;
    final bytes = result.files.single.bytes;
    if (bytes == null) return null;
    return utf8.decode(bytes);
  }
}

BackupFileService createBackupFileServiceImpl() => _BackupFileServiceWeb();
