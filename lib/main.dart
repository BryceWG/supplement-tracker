import 'package:flutter/material.dart';

import 'src/app.dart';
import 'src/controllers/supplements_controller.dart';
import 'src/services/supplements_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final locale = WidgetsBinding.instance.platformDispatcher.locale;
  final defaultProfileName = locale.languageCode == 'zh' ? '我' : 'Me';

  final controller = SupplementsController(
    store: SupplementsStore(),
    defaultProfileName: defaultProfileName,
  );
  await controller.init();

  runApp(SupplementTrackerApp(controller: controller));
}
