import 'package:flutter/widgets.dart';
import 'package:supplement_tracker/l10n/app_localizations.dart';

extension AppL10nX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}

String categoryLabel(BuildContext context, String category) {
  final l10n = context.l10n;
  switch (category) {
    case '维生素':
      return l10n.categoryVitamins;
    case '矿物质':
      return l10n.categoryMinerals;
    case '脂肪酸':
      return l10n.categoryFattyAcids;
    case '益生菌':
      return l10n.categoryProbiotics;
    default:
      return l10n.categoryOther;
  }
}

String dosageUnitLabel(BuildContext context, String unit, {required num count}) {
  final l10n = context.l10n;
  switch (unit) {
    case '粒':
      return l10n.unitCapsule(count);
    case '片':
      return l10n.unitTablet(count);
    case '滴':
      return l10n.unitDrop(count);
    case '勺':
      return l10n.unitScoop(count);
    default:
      return unit;
  }
}
