import 'backup_file_service.dart';
import 'backup_file_service_stub.dart'
    if (dart.library.io) 'backup_file_service_io.dart'
    if (dart.library.html) 'backup_file_service_web.dart';

BackupFileService createBackupFileService() => createBackupFileServiceImpl();

