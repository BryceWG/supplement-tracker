abstract interface class BackupFileService {
  Future<bool> saveJson({
    required String dialogTitle,
    required String suggestedFileName,
    required String json,
  });

  Future<String?> pickJson({required String dialogTitle});
}
