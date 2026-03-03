import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
    Locale('zh', 'TW')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Supplement Tracker'**
  String get appTitle;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get commonOk;

  /// No description provided for @commonNotSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get commonNotSet;

  /// No description provided for @commonPerDay.
  ///
  /// In en, this message translates to:
  /// **'per day'**
  String get commonPerDay;

  /// No description provided for @commonDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} day} other{{count} days}}'**
  String commonDays(num count);

  /// No description provided for @unitCapsule.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{capsule} other{capsules}}'**
  String unitCapsule(num count);

  /// No description provided for @unitTablet.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{tablet} other{tablets}}'**
  String unitTablet(num count);

  /// No description provided for @unitDrop.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{drop} other{drops}}'**
  String unitDrop(num count);

  /// No description provided for @unitScoop.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{scoop} other{scoops}}'**
  String unitScoop(num count);

  /// No description provided for @categoryVitamins.
  ///
  /// In en, this message translates to:
  /// **'Vitamins'**
  String get categoryVitamins;

  /// No description provided for @categoryMinerals.
  ///
  /// In en, this message translates to:
  /// **'Minerals'**
  String get categoryMinerals;

  /// No description provided for @categoryFattyAcids.
  ///
  /// In en, this message translates to:
  /// **'Fatty acids'**
  String get categoryFattyAcids;

  /// No description provided for @categoryProbiotics.
  ///
  /// In en, this message translates to:
  /// **'Probiotics'**
  String get categoryProbiotics;

  /// No description provided for @categoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get categoryOther;

  /// No description provided for @homeTabSupplements.
  ///
  /// In en, this message translates to:
  /// **'My Supplements'**
  String get homeTabSupplements;

  /// No description provided for @homeTabAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get homeTabAnalytics;

  /// No description provided for @homeTooltipExportList.
  ///
  /// In en, this message translates to:
  /// **'Export supplement list image'**
  String get homeTooltipExportList;

  /// No description provided for @homeTooltipSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get homeTooltipSettings;

  /// No description provided for @homeTooltipSwitchProfile.
  ///
  /// In en, this message translates to:
  /// **'Switch profile'**
  String get homeTooltipSwitchProfile;

  /// No description provided for @homeManageProfiles.
  ///
  /// In en, this message translates to:
  /// **'Manage profiles…'**
  String get homeManageProfiles;

  /// No description provided for @homeDialogConfirmDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm delete'**
  String get homeDialogConfirmDeleteTitle;

  /// No description provided for @homeDialogConfirmDeleteContent.
  ///
  /// In en, this message translates to:
  /// **'Delete “{name}”?'**
  String homeDialogConfirmDeleteContent(Object name);

  /// No description provided for @homeSnackStartPostponed.
  ///
  /// In en, this message translates to:
  /// **'Start date for “{name}” postponed to {date}.'**
  String homeSnackStartPostponed(Object name, Object date);

  /// No description provided for @homeSnackSkippedToday.
  ///
  /// In en, this message translates to:
  /// **'Skipped {date} for “{name}” (no intake today).'**
  String homeSnackSkippedToday(Object name, Object date);

  /// No description provided for @homeSnackUpdated.
  ///
  /// In en, this message translates to:
  /// **'Updated “{name}”.'**
  String homeSnackUpdated(Object name);

  /// No description provided for @homeDialogReplenishTitle.
  ///
  /// In en, this message translates to:
  /// **'Add stock'**
  String get homeDialogReplenishTitle;

  /// No description provided for @homeFieldAddQuantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Quantity to add'**
  String get homeFieldAddQuantityLabel;

  /// No description provided for @homeFieldAddQuantityHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 180'**
  String get homeFieldAddQuantityHint;

  /// No description provided for @validationNumberMin1.
  ///
  /// In en, this message translates to:
  /// **'Enter a number ≥ 1'**
  String get validationNumberMin1;

  /// No description provided for @validationNumberMin0.
  ///
  /// In en, this message translates to:
  /// **'Enter a number ≥ 0'**
  String get validationNumberMin0;

  /// No description provided for @validationUrlInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid URL (http/https)'**
  String get validationUrlInvalid;

  /// No description provided for @errorInvalidBackup.
  ///
  /// In en, this message translates to:
  /// **'Invalid or unsupported backup file'**
  String get errorInvalidBackup;

  /// No description provided for @errorUnableToExportImage.
  ///
  /// In en, this message translates to:
  /// **'Unable to export image'**
  String get errorUnableToExportImage;

  /// No description provided for @homeSnackReplenish.
  ///
  /// In en, this message translates to:
  /// **'Added +{quantity} {unit} to “{name}”.'**
  String homeSnackReplenish(Object name, Object quantity, Object unit);

  /// No description provided for @statsTotalSupplementsLabel.
  ///
  /// In en, this message translates to:
  /// **'Total supplements'**
  String get statsTotalSupplementsLabel;

  /// No description provided for @statsTotalSupplementsTrend.
  ///
  /// In en, this message translates to:
  /// **'Supplements you’re tracking'**
  String get statsTotalSupplementsTrend;

  /// No description provided for @statsTodayCostLabel.
  ///
  /// In en, this message translates to:
  /// **'Today’s cost'**
  String get statsTodayCostLabel;

  /// No description provided for @statsTodayCostTrend.
  ///
  /// In en, this message translates to:
  /// **'Daily average'**
  String get statsTodayCostTrend;

  /// No description provided for @statsShortestRemainingLabel.
  ///
  /// In en, this message translates to:
  /// **'Shortest remaining'**
  String get statsShortestRemainingLabel;

  /// No description provided for @statsShortestRemainingTrend.
  ///
  /// In en, this message translates to:
  /// **'Runs out first'**
  String get statsShortestRemainingTrend;

  /// No description provided for @statsMonthlyCostLabel.
  ///
  /// In en, this message translates to:
  /// **'Monthly total'**
  String get statsMonthlyCostLabel;

  /// No description provided for @statsMonthlyCostTrend.
  ///
  /// In en, this message translates to:
  /// **'Estimated monthly spending'**
  String get statsMonthlyCostTrend;

  /// No description provided for @emptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No supplements yet'**
  String get emptyTitle;

  /// No description provided for @emptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add your first supplement to start tracking your health investment.'**
  String get emptySubtitle;

  /// No description provided for @emptyAddButton.
  ///
  /// In en, this message translates to:
  /// **'Add supplement'**
  String get emptyAddButton;

  /// No description provided for @reminderSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get reminderSectionTitle;

  /// No description provided for @reminderLowStockTitle.
  ///
  /// In en, this message translates to:
  /// **'{name} is running low'**
  String reminderLowStockTitle(Object name);

  /// No description provided for @reminderLowStockMessage.
  ///
  /// In en, this message translates to:
  /// **'Only {days, plural, one{{days} day} other{{days} days}} left. Consider restocking.'**
  String reminderLowStockMessage(num days);

  /// No description provided for @reminderJustNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get reminderJustNow;

  /// No description provided for @supplementCardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{specification} · Daily {dose} {unit} · Start: {startDate}'**
  String supplementCardSubtitle(
      Object specification, Object dose, Object unit, Object startDate);

  /// No description provided for @supplementCardRemaining.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, one{{days} day left} other{{days} days left}}'**
  String supplementCardRemaining(num days);

  /// No description provided for @supplementCardMenuTooltip.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get supplementCardMenuTooltip;

  /// No description provided for @supplementCardMenuEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get supplementCardMenuEdit;

  /// No description provided for @supplementCardMenuReplenish.
  ///
  /// In en, this message translates to:
  /// **'Add stock'**
  String get supplementCardMenuReplenish;

  /// No description provided for @supplementCardMenuSkipToday.
  ///
  /// In en, this message translates to:
  /// **'Skip today'**
  String get supplementCardMenuSkipToday;

  /// No description provided for @supplementCardMenuDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get supplementCardMenuDelete;

  /// No description provided for @chartMonthlyCostByCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Monthly cost by category'**
  String get chartMonthlyCostByCategoryTitle;

  /// No description provided for @chartSpendingTrendTitle.
  ///
  /// In en, this message translates to:
  /// **'Spending trend'**
  String get chartSpendingTrendTitle;

  /// No description provided for @exportListTitle.
  ///
  /// In en, this message translates to:
  /// **'Export supplement list'**
  String get exportListTitle;

  /// No description provided for @exportListSnackNoSupplements.
  ///
  /// In en, this message translates to:
  /// **'No supplements to export.'**
  String get exportListSnackNoSupplements;

  /// No description provided for @exportListSnackShareOpened.
  ///
  /// In en, this message translates to:
  /// **'Opened system share sheet (save/send the image).'**
  String get exportListSnackShareOpened;

  /// No description provided for @exportListSnackPngExported.
  ///
  /// In en, this message translates to:
  /// **'PNG exported.'**
  String get exportListSnackPngExported;

  /// No description provided for @exportListSnackExportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export failed: {error}'**
  String exportListSnackExportFailed(Object error);

  /// No description provided for @exportListActionSharePng.
  ///
  /// In en, this message translates to:
  /// **'Share PNG'**
  String get exportListActionSharePng;

  /// No description provided for @exportListActionDownloadPng.
  ///
  /// In en, this message translates to:
  /// **'Download PNG'**
  String get exportListActionDownloadPng;

  /// No description provided for @exportListCardTitlePng.
  ///
  /// In en, this message translates to:
  /// **'Export as image (PNG)'**
  String get exportListCardTitlePng;

  /// No description provided for @exportListCardDescriptionMobile.
  ///
  /// In en, this message translates to:
  /// **'Use the top-right or button below to share the current profile’s supplement list.'**
  String get exportListCardDescriptionMobile;

  /// No description provided for @exportListCardDescriptionDesktop.
  ///
  /// In en, this message translates to:
  /// **'Use the top-right or button below to download the current profile’s supplement list image (PNG).'**
  String get exportListCardDescriptionDesktop;

  /// No description provided for @exportListHeaderTitle.
  ///
  /// In en, this message translates to:
  /// **'{profileName}’s Supplement List'**
  String exportListHeaderTitle(Object profileName);

  /// No description provided for @exportListHeaderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A shareable supplement list'**
  String get exportListHeaderSubtitle;

  /// No description provided for @exportListHeaderMeta.
  ///
  /// In en, this message translates to:
  /// **'Exported: {date}'**
  String exportListHeaderMeta(Object date);

  /// No description provided for @exportListInfoChipSupplementsCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Count'**
  String get exportListInfoChipSupplementsCountLabel;

  /// No description provided for @exportListInfoChipTodayCostLabel.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get exportListInfoChipTodayCostLabel;

  /// No description provided for @exportListInfoChipMonthlyCostLabel.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get exportListInfoChipMonthlyCostLabel;

  /// No description provided for @exportListHintShare.
  ///
  /// In en, this message translates to:
  /// **'Share with friends or a nutritionist for a quick overview.'**
  String get exportListHintShare;

  /// No description provided for @exportListItemDailyDosage.
  ///
  /// In en, this message translates to:
  /// **'Daily {dose} {unit}'**
  String exportListItemDailyDosage(Object dose, Object unit);

  /// No description provided for @exportListItemMeta.
  ///
  /// In en, this message translates to:
  /// **'Start: {startDate} · Qty: {remaining}/{total}'**
  String exportListItemMeta(Object startDate, Object remaining, Object total);

  /// No description provided for @exportListItemRemaining.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, one{{days} day left} other{{days} days left}}'**
  String exportListItemRemaining(num days);

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsSectionData.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get settingsSectionData;

  /// No description provided for @settingsBackupCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Export / Import'**
  String get settingsBackupCardTitle;

  /// No description provided for @settingsBackupCardDescription.
  ///
  /// In en, this message translates to:
  /// **'Use this for backup and migration. Import will overwrite current data.'**
  String get settingsBackupCardDescription;

  /// No description provided for @settingsButtonExport.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get settingsButtonExport;

  /// No description provided for @settingsButtonImport.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get settingsButtonImport;

  /// No description provided for @settingsSnackExported.
  ///
  /// In en, this message translates to:
  /// **'Backup exported.'**
  String get settingsSnackExported;

  /// No description provided for @settingsSnackExportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export failed: {error}'**
  String settingsSnackExportFailed(Object error);

  /// No description provided for @settingsImportConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm import'**
  String get settingsImportConfirmTitle;

  /// No description provided for @settingsImportConfirmContent.
  ///
  /// In en, this message translates to:
  /// **'Import will overwrite all profiles and supplement data. Export a backup first if needed.'**
  String get settingsImportConfirmContent;

  /// No description provided for @settingsImportContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get settingsImportContinue;

  /// No description provided for @settingsSnackImportDone.
  ///
  /// In en, this message translates to:
  /// **'Import completed.'**
  String get settingsSnackImportDone;

  /// No description provided for @settingsSnackImportFailed.
  ///
  /// In en, this message translates to:
  /// **'Import failed: {error}'**
  String settingsSnackImportFailed(Object error);

  /// No description provided for @filePickerChooseExportLocation.
  ///
  /// In en, this message translates to:
  /// **'Choose export location'**
  String get filePickerChooseExportLocation;

  /// No description provided for @filePickerChooseImportBackup.
  ///
  /// In en, this message translates to:
  /// **'Choose a backup file'**
  String get filePickerChooseImportBackup;

  /// No description provided for @shareSubjectSupplementList.
  ///
  /// In en, this message translates to:
  /// **'Supplement List'**
  String get shareSubjectSupplementList;

  /// No description provided for @profileManagerTitle.
  ///
  /// In en, this message translates to:
  /// **'Profiles'**
  String get profileManagerTitle;

  /// No description provided for @profileManagerDescription.
  ///
  /// In en, this message translates to:
  /// **'Each profile is independent. You can switch anytime.'**
  String get profileManagerDescription;

  /// No description provided for @profileManagerTooltipClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get profileManagerTooltipClose;

  /// No description provided for @profileManagerTooltipRename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get profileManagerTooltipRename;

  /// No description provided for @profileManagerTooltipDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get profileManagerTooltipDelete;

  /// No description provided for @profileManagerButtonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get profileManagerButtonClose;

  /// No description provided for @profileManagerButtonAdd.
  ///
  /// In en, this message translates to:
  /// **'Add profile'**
  String get profileManagerButtonAdd;

  /// No description provided for @profileDialogAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add profile'**
  String get profileDialogAddTitle;

  /// No description provided for @profileDialogAddHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Mom / Friend / Partner'**
  String get profileDialogAddHint;

  /// No description provided for @profileDialogAddConfirm.
  ///
  /// In en, this message translates to:
  /// **'Add and switch'**
  String get profileDialogAddConfirm;

  /// No description provided for @profileDialogRenameTitle.
  ///
  /// In en, this message translates to:
  /// **'Rename profile'**
  String get profileDialogRenameTitle;

  /// No description provided for @profileDialogRenameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter profile name'**
  String get profileDialogRenameHint;

  /// No description provided for @profileDialogRenameConfirm.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get profileDialogRenameConfirm;

  /// No description provided for @profileDialogDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm delete'**
  String get profileDialogDeleteTitle;

  /// No description provided for @profileDialogDeleteContent.
  ///
  /// In en, this message translates to:
  /// **'Deleting “{name}” will also delete its supplement data.'**
  String profileDialogDeleteContent(Object name);

  /// No description provided for @supplementEditorTitleAdd.
  ///
  /// In en, this message translates to:
  /// **'Add supplement'**
  String get supplementEditorTitleAdd;

  /// No description provided for @supplementEditorTitleEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit supplement'**
  String get supplementEditorTitleEdit;

  /// No description provided for @supplementEditorTooltipClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get supplementEditorTooltipClose;

  /// No description provided for @supplementEditorFieldNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Supplement name'**
  String get supplementEditorFieldNameLabel;

  /// No description provided for @supplementEditorFieldNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Vitamin D3'**
  String get supplementEditorFieldNameHint;

  /// No description provided for @supplementEditorValidationNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name'**
  String get supplementEditorValidationNameRequired;

  /// No description provided for @supplementEditorFieldSpecLabel.
  ///
  /// In en, this message translates to:
  /// **'Specification'**
  String get supplementEditorFieldSpecLabel;

  /// No description provided for @supplementEditorFieldSpecHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 2000 IU, 180 capsules'**
  String get supplementEditorFieldSpecHint;

  /// No description provided for @supplementEditorValidationSpecRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a specification'**
  String get supplementEditorValidationSpecRequired;

  /// No description provided for @supplementEditorFieldDailyDosageLabel.
  ///
  /// In en, this message translates to:
  /// **'Daily dosage'**
  String get supplementEditorFieldDailyDosageLabel;

  /// No description provided for @supplementEditorFieldUnitLabel.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get supplementEditorFieldUnitLabel;

  /// No description provided for @supplementEditorFieldPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Price (¥)'**
  String get supplementEditorFieldPriceLabel;

  /// No description provided for @supplementEditorFieldPriceHint.
  ///
  /// In en, this message translates to:
  /// **'128'**
  String get supplementEditorFieldPriceHint;

  /// No description provided for @supplementEditorFieldTotalQtyLabel.
  ///
  /// In en, this message translates to:
  /// **'Total quantity'**
  String get supplementEditorFieldTotalQtyLabel;

  /// No description provided for @supplementEditorFieldTotalQtyHint.
  ///
  /// In en, this message translates to:
  /// **'180'**
  String get supplementEditorFieldTotalQtyHint;

  /// No description provided for @supplementEditorFieldStartUseDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Start date'**
  String get supplementEditorFieldStartUseDateLabel;

  /// No description provided for @supplementEditorDatePickerHelp.
  ///
  /// In en, this message translates to:
  /// **'Select start date'**
  String get supplementEditorDatePickerHelp;

  /// No description provided for @supplementEditorButtonSkipToday.
  ///
  /// In en, this message translates to:
  /// **'Skip today'**
  String get supplementEditorButtonSkipToday;

  /// No description provided for @supplementEditorSkippedDays.
  ///
  /// In en, this message translates to:
  /// **'Skipped {count, plural, one{{count} day} other{{count} days}}'**
  String supplementEditorSkippedDays(num count);

  /// No description provided for @supplementEditorFieldCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get supplementEditorFieldCategoryLabel;

  /// No description provided for @supplementEditorFieldPurchaseUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'Purchase link (optional)'**
  String get supplementEditorFieldPurchaseUrlLabel;

  /// No description provided for @supplementEditorFieldPurchaseUrlHint.
  ///
  /// In en, this message translates to:
  /// **'https://...'**
  String get supplementEditorFieldPurchaseUrlHint;

  /// No description provided for @supplementEditorButtonPickFromExisting.
  ///
  /// In en, this message translates to:
  /// **'Pick from existing'**
  String get supplementEditorButtonPickFromExisting;

  /// No description provided for @supplementEditorTemplatePickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose an existing supplement'**
  String get supplementEditorTemplatePickerTitle;

  /// No description provided for @supplementEditorTemplatePickerSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name or specification'**
  String get supplementEditorTemplatePickerSearchHint;

  /// No description provided for @supplementEditorTemplatePickerEmpty.
  ///
  /// In en, this message translates to:
  /// **'No matching supplements'**
  String get supplementEditorTemplatePickerEmpty;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.countryCode) {
          case 'TW':
            return AppLocalizationsZhTw();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
