// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Supplement Tracker';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonClose => 'Close';

  @override
  String get commonSave => 'Save';

  @override
  String get commonOk => 'OK';

  @override
  String get commonNotSet => 'Not set';

  @override
  String get commonPerDay => 'per day';

  @override
  String commonDays(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '$count day',
    );
    return '$_temp0';
  }

  @override
  String unitCapsule(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'capsules',
      one: 'capsule',
    );
    return '$_temp0';
  }

  @override
  String unitTablet(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'tablets',
      one: 'tablet',
    );
    return '$_temp0';
  }

  @override
  String unitDrop(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'drops',
      one: 'drop',
    );
    return '$_temp0';
  }

  @override
  String unitScoop(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'scoops',
      one: 'scoop',
    );
    return '$_temp0';
  }

  @override
  String get categoryVitamins => 'Vitamins';

  @override
  String get categoryMinerals => 'Minerals';

  @override
  String get categoryFattyAcids => 'Fatty acids';

  @override
  String get categoryProbiotics => 'Probiotics';

  @override
  String get categoryOther => 'Other';

  @override
  String get homeTabSupplements => 'My Supplements';

  @override
  String get homeTabAnalytics => 'Analytics';

  @override
  String get homeTooltipExportList => 'Export supplement list image';

  @override
  String get homeTooltipSettings => 'Settings';

  @override
  String get homeTooltipSwitchProfile => 'Switch profile';

  @override
  String get homeManageProfiles => 'Manage profiles…';

  @override
  String get homeDialogConfirmDeleteTitle => 'Confirm delete';

  @override
  String homeDialogConfirmDeleteContent(Object name) {
    return 'Delete “$name”?';
  }

  @override
  String homeSnackStartPostponed(Object name, Object date) {
    return 'Start date for “$name” postponed to $date.';
  }

  @override
  String homeSnackSkippedToday(Object name, Object date) {
    return 'Skipped $date for “$name” (no intake today).';
  }

  @override
  String homeSnackUpdated(Object name) {
    return 'Updated “$name”.';
  }

  @override
  String get homeDialogReplenishTitle => 'Add stock';

  @override
  String get homeFieldAddQuantityLabel => 'Quantity to add';

  @override
  String get homeFieldAddQuantityHint => 'e.g. 180';

  @override
  String get validationNumberMin1 => 'Enter a number ≥ 1';

  @override
  String get validationNumberMin0 => 'Enter a number ≥ 0';

  @override
  String get validationUrlInvalid => 'Enter a valid URL (http/https)';

  @override
  String get errorInvalidBackup => 'Invalid or unsupported backup file';

  @override
  String get errorUnableToExportImage => 'Unable to export image';

  @override
  String homeSnackReplenish(Object name, Object quantity, Object unit) {
    return 'Added +$quantity $unit to “$name”.';
  }

  @override
  String get statsTotalSupplementsLabel => 'Total supplements';

  @override
  String get statsTotalSupplementsTrend => 'Supplements you’re tracking';

  @override
  String get statsTodayCostLabel => 'Today’s cost';

  @override
  String get statsTodayCostTrend => 'Daily average';

  @override
  String get statsShortestRemainingLabel => 'Shortest remaining';

  @override
  String get statsShortestRemainingTrend => 'Runs out first';

  @override
  String get statsMonthlyCostLabel => 'Monthly total';

  @override
  String get statsMonthlyCostTrend => 'Estimated monthly spending';

  @override
  String get emptyTitle => 'No supplements yet';

  @override
  String get emptySubtitle =>
      'Add your first supplement to start tracking your health investment.';

  @override
  String get emptyAddButton => 'Add supplement';

  @override
  String get reminderSectionTitle => 'Reminders';

  @override
  String reminderLowStockTitle(Object name) {
    return '$name is running low';
  }

  @override
  String reminderLowStockMessage(num days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '$days day',
    );
    return 'Only $_temp0 left. Consider restocking.';
  }

  @override
  String get reminderJustNow => 'Just now';

  @override
  String supplementCardSubtitle(
      Object specification, Object dose, Object unit, Object startDate) {
    return '$specification · Daily $dose $unit · Start: $startDate';
  }

  @override
  String supplementCardRemaining(num days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days left',
      one: '$days day left',
    );
    return '$_temp0';
  }

  @override
  String get supplementCardMenuTooltip => 'Manage';

  @override
  String get supplementCardMenuEdit => 'Edit';

  @override
  String get supplementCardMenuReplenish => 'Add stock';

  @override
  String get supplementCardMenuSkipToday => 'Skip today';

  @override
  String get supplementCardMenuDelete => 'Delete';

  @override
  String get chartMonthlyCostByCategoryTitle => 'Monthly cost by category';

  @override
  String get chartSpendingTrendTitle => 'Spending trend';

  @override
  String get exportListTitle => 'Export supplement list';

  @override
  String get exportListSnackNoSupplements => 'No supplements to export.';

  @override
  String get exportListSnackShareOpened =>
      'Opened system share sheet (save/send the image).';

  @override
  String get exportListSnackPngExported => 'PNG exported.';

  @override
  String exportListSnackExportFailed(Object error) {
    return 'Export failed: $error';
  }

  @override
  String get exportListActionSharePng => 'Share PNG';

  @override
  String get exportListActionDownloadPng => 'Download PNG';

  @override
  String get exportListCardTitlePng => 'Export as image (PNG)';

  @override
  String get exportListCardDescriptionMobile =>
      'Use the top-right or button below to share the current profile’s supplement list.';

  @override
  String get exportListCardDescriptionDesktop =>
      'Use the top-right or button below to download the current profile’s supplement list image (PNG).';

  @override
  String exportListHeaderTitle(Object profileName) {
    return '$profileName’s Supplement List';
  }

  @override
  String get exportListHeaderSubtitle => 'A shareable supplement list';

  @override
  String exportListHeaderMeta(Object date) {
    return 'Exported: $date';
  }

  @override
  String get exportListInfoChipSupplementsCountLabel => 'Count';

  @override
  String get exportListInfoChipTodayCostLabel => 'Today';

  @override
  String get exportListInfoChipMonthlyCostLabel => 'Monthly';

  @override
  String get exportListHintShare =>
      'Share with friends or a nutritionist for a quick overview.';

  @override
  String exportListItemDailyDosage(Object dose, Object unit) {
    return 'Daily $dose $unit';
  }

  @override
  String exportListItemMeta(Object startDate, Object remaining, Object total) {
    return 'Start: $startDate · Qty: $remaining/$total';
  }

  @override
  String exportListItemRemaining(num days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days left',
      one: '$days day left',
    );
    return '$_temp0';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSectionData => 'Data';

  @override
  String get settingsBackupCardTitle => 'Export / Import';

  @override
  String get settingsBackupCardDescription =>
      'Use this for backup and migration. Import will overwrite current data.';

  @override
  String get settingsButtonExport => 'Export';

  @override
  String get settingsButtonImport => 'Import';

  @override
  String get settingsSnackExported => 'Backup exported.';

  @override
  String settingsSnackExportFailed(Object error) {
    return 'Export failed: $error';
  }

  @override
  String get settingsImportConfirmTitle => 'Confirm import';

  @override
  String get settingsImportConfirmContent =>
      'Import will overwrite all profiles and supplement data. Export a backup first if needed.';

  @override
  String get settingsImportContinue => 'Continue';

  @override
  String get settingsSnackImportDone => 'Import completed.';

  @override
  String settingsSnackImportFailed(Object error) {
    return 'Import failed: $error';
  }

  @override
  String get filePickerChooseExportLocation => 'Choose export location';

  @override
  String get filePickerChooseImportBackup => 'Choose a backup file';

  @override
  String get shareSubjectSupplementList => 'Supplement List';

  @override
  String get profileManagerTitle => 'Profiles';

  @override
  String get profileManagerDescription =>
      'Each profile is independent. You can switch anytime.';

  @override
  String get profileManagerTooltipClose => 'Close';

  @override
  String get profileManagerTooltipRename => 'Rename';

  @override
  String get profileManagerTooltipDelete => 'Delete';

  @override
  String get profileManagerButtonClose => 'Close';

  @override
  String get profileManagerButtonAdd => 'Add profile';

  @override
  String get profileDialogAddTitle => 'Add profile';

  @override
  String get profileDialogAddHint => 'e.g. Mom / Friend / Partner';

  @override
  String get profileDialogAddConfirm => 'Add and switch';

  @override
  String get profileDialogRenameTitle => 'Rename profile';

  @override
  String get profileDialogRenameHint => 'Enter profile name';

  @override
  String get profileDialogRenameConfirm => 'Save';

  @override
  String get profileDialogDeleteTitle => 'Confirm delete';

  @override
  String profileDialogDeleteContent(Object name) {
    return 'Deleting “$name” will also delete its supplement data.';
  }

  @override
  String get supplementEditorTitleAdd => 'Add supplement';

  @override
  String get supplementEditorTitleEdit => 'Edit supplement';

  @override
  String get supplementEditorTooltipClose => 'Close';

  @override
  String get supplementEditorFieldNameLabel => 'Supplement name';

  @override
  String get supplementEditorFieldNameHint => 'e.g. Vitamin D3';

  @override
  String get supplementEditorValidationNameRequired => 'Please enter a name';

  @override
  String get supplementEditorFieldSpecLabel => 'Specification';

  @override
  String get supplementEditorFieldSpecHint => 'e.g. 2000 IU, 180 capsules';

  @override
  String get supplementEditorValidationSpecRequired =>
      'Please enter a specification';

  @override
  String get supplementEditorFieldDailyDosageLabel => 'Daily dosage';

  @override
  String get supplementEditorFieldUnitLabel => 'Unit';

  @override
  String get supplementEditorFieldPriceLabel => 'Price (¥)';

  @override
  String get supplementEditorFieldPriceHint => '128';

  @override
  String get supplementEditorFieldTotalQtyLabel => 'Total quantity';

  @override
  String get supplementEditorFieldTotalQtyHint => '180';

  @override
  String get supplementEditorFieldStartUseDateLabel => 'Start date';

  @override
  String get supplementEditorDatePickerHelp => 'Select start date';

  @override
  String get supplementEditorButtonSkipToday => 'Skip today';

  @override
  String supplementEditorSkippedDays(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '$count day',
    );
    return 'Skipped $_temp0';
  }

  @override
  String get supplementEditorFieldCategoryLabel => 'Category';

  @override
  String get supplementEditorFieldPurchaseUrlLabel =>
      'Purchase link (optional)';

  @override
  String get supplementEditorFieldPurchaseUrlHint => 'https://...';

  @override
  String get supplementEditorButtonPickFromExisting => 'Pick from existing';

  @override
  String get supplementEditorTemplatePickerTitle => 'Choose an existing supplement';

  @override
  String get supplementEditorTemplatePickerSearchHint => 'Search by name or specification';

  @override
  String get supplementEditorTemplatePickerEmpty => 'No matching supplements';
}
