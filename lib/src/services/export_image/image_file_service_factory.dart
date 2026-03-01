import 'image_file_service.dart';
import 'image_file_service_stub.dart'
    if (dart.library.io) 'image_file_service_io.dart'
    if (dart.library.html) 'image_file_service_web.dart';

ImageFileService createImageFileService() => createImageFileServiceImpl();

