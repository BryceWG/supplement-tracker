abstract interface class BackupFileService {
  Future<bool> saveJson({
    required String suggestedFileName,
    required String json,
  });

  Future<String?> pickJson();
}
