import 'package:flutter/material.dart';

import 'src/app.dart';
import 'src/controllers/supplements_controller.dart';
import 'src/services/supplements_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final controller = SupplementsController(
    store: SupplementsStore(),
  );
  await controller.init();

  runApp(SupplementTrackerApp(controller: controller));
}

