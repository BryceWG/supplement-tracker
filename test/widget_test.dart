import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:supplement_tracker/src/controllers/supplements_controller.dart';
import 'package:supplement_tracker/l10n/app_localizations.dart';
import 'package:supplement_tracker/src/services/supplements_store.dart';
import 'package:supplement_tracker/src/ui/home/home_screen.dart';

void main() {
  testWidgets('Home renders stats', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    final controller = SupplementsController(store: SupplementsStore(), defaultProfileName: '我');
    await controller.init();

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('zh'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'),
          Locale('zh'),
          Locale('zh', 'TW'),
        ],
        home: HomeScreen(controller: controller),
      ),
    );

    expect(find.text('补剂总数'), findsOneWidget);
  });
}
