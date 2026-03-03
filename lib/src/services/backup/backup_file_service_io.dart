import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';

import 'backup_file_service.dart';

class _BackupFileServiceIo implements BackupFileService {
  @override
  Future<bool> saveJson({
    required String dialogTitle,
    required String suggestedFileName,
    required String json,
  }) async {
    final outputPath = await FilePicker.platform.saveFile(
      dialogTitle: dialogTitle,
      fileName: suggestedFileName,
      type: FileType.custom,
      allowedExtensions: const ['json'],
    );

    if (outputPath == null || outputPath.trim().isEmpty) return false;
    await File(outputPath).writeAsString(json, encoding: utf8, flush: true);
    return true;
  }

  @override
  Future<String?> pickJson({required String dialogTitle}) async {
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: dialogTitle,
      type: FileType.custom,
      allowedExtensions: const ['json'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) return null;
    final file = result.files.single;

    if (file.bytes != null) {
      return utf8.decode(file.bytes!);
    }

    final path = file.path;
    if (path == null || path.trim().isEmpty) return null;
    return File(path).readAsString(encoding: utf8);
  }
}

BackupFileService createBackupFileServiceImpl() => _BackupFileServiceIo();
