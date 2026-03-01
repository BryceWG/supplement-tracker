import 'package:flutter/material.dart';

import 'controllers/supplements_controller.dart';
import 'theme/app_theme.dart';
import 'ui/home/home_screen.dart';

class SupplementTrackerApp extends StatelessWidget {
  const SupplementTrackerApp({super.key, required this.controller});

  final SupplementsController controller;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '补剂管家',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(),
      home: HomeScreen(controller: controller),
    );
  }
}

