import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supplement_tracker/l10n/app_localizations.dart';

import 'controllers/supplements_controller.dart';
import 'theme/app_theme.dart';
import 'ui/home/home_screen.dart';

class SupplementTrackerApp extends StatelessWidget {
  const SupplementTrackerApp({super.key, required this.controller});

  final SupplementsController controller;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      debugShowCheckedModeBanner: false,
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
      localeResolutionCallback: (locale, supportedLocales) {
        if (locale == null) return supportedLocales.first;

        if (locale.languageCode == 'zh') {
          final script = locale.scriptCode?.toLowerCase();
          final country = locale.countryCode?.toUpperCase();
          if (script == 'hant' || country == 'TW' || country == 'HK' || country == 'MO') {
            return const Locale('zh', 'TW');
          }
          return const Locale('zh');
        }

        return supportedLocales.firstWhere(
          (l) => l.languageCode == locale.languageCode,
          orElse: () => supportedLocales.first,
        );
      },
      theme: AppTheme.lightTheme(),
      home: HomeScreen(controller: controller),
    );
  }
}
