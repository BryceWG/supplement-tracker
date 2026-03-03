// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '补剂管家';

  @override
  String get commonCancel => '取消';

  @override
  String get commonDelete => '删除';

  @override
  String get commonClose => '关闭';

  @override
  String get commonSave => '保存';

  @override
  String get commonOk => '确定';

  @override
  String get commonNotSet => '未设置';

  @override
  String get commonPerDay => '每日';

  @override
  String commonDays(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 天',
      one: '$count 天',
    );
    return '$_temp0';
  }

  @override
  String unitCapsule(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '粒',
      one: '粒',
    );
    return '$_temp0';
  }

  @override
  String unitTablet(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '片',
      one: '片',
    );
    return '$_temp0';
  }

  @override
  String unitDrop(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '滴',
      one: '滴',
    );
    return '$_temp0';
  }

  @override
  String unitScoop(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '勺',
      one: '勺',
    );
    return '$_temp0';
  }

  @override
  String get categoryVitamins => '维生素';

  @override
  String get categoryMinerals => '矿物质';

  @override
  String get categoryFattyAcids => '脂肪酸';

  @override
  String get categoryProbiotics => '益生菌';

  @override
  String get categoryOther => '其他';

  @override
  String get homeTabSupplements => '我的补剂';

  @override
  String get homeTabAnalytics => '数据分析';

  @override
  String get homeTooltipExportList => '导出补剂清单为图片';

  @override
  String get homeTooltipSettings => '设置';

  @override
  String get homeTooltipSwitchProfile => '切换成员';

  @override
  String get homeManageProfiles => '管理成员…';

  @override
  String get homeDialogConfirmDeleteTitle => '确认删除';

  @override
  String homeDialogConfirmDeleteContent(Object name) {
    return '确定要删除「$name」吗？';
  }

  @override
  String homeSnackStartPostponed(Object name, Object date) {
    return '已将「$name」开始使用日期延期至 $date';
  }

  @override
  String homeSnackSkippedToday(Object name, Object date) {
    return '已为「$name」跳过 $date（当天不吃）';
  }

  @override
  String homeSnackUpdated(Object name) {
    return '已更新「$name」';
  }

  @override
  String get homeDialogReplenishTitle => '补充总量';

  @override
  String get homeFieldAddQuantityLabel => '新增数量';

  @override
  String get homeFieldAddQuantityHint => '例如：180';

  @override
  String get validationNumberMin1 => '请输入 >= 1 的数字';

  @override
  String get validationNumberMin0 => '请输入 >= 0 的数字';

  @override
  String get validationUrlInvalid => '请输入有效的链接（包含 http/https）';

  @override
  String get errorInvalidBackup => '备份文件无效或不支持';

  @override
  String get errorUnableToExportImage => '无法导出图片';

  @override
  String homeSnackReplenish(Object name, Object quantity, Object unit) {
    return '已为「$name」补充 +$quantity$unit';
  }

  @override
  String get statsTotalSupplementsLabel => '补剂总数';

  @override
  String get statsTotalSupplementsTrend => '当前跟踪的补剂数量';

  @override
  String get statsTodayCostLabel => '今日花费';

  @override
  String get statsTodayCostTrend => '日均花费';

  @override
  String get statsShortestRemainingLabel => '最短剩余';

  @override
  String get statsShortestRemainingTrend => '最早用完的补剂';

  @override
  String get statsMonthlyCostLabel => '月度总花费';

  @override
  String get statsMonthlyCostTrend => '预计本月支出';

  @override
  String get emptyTitle => '还没有添加补剂';

  @override
  String get emptySubtitle => '添加您的第一个营养补剂，开始跟踪您的健康投资';

  @override
  String get emptyAddButton => '添加补剂';

  @override
  String get reminderSectionTitle => '提醒';

  @override
  String reminderLowStockTitle(Object name) {
    return '$name 库存不足';
  }

  @override
  String reminderLowStockMessage(num days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '仅剩 $days 天的用量，建议尽快购买',
      one: '仅剩 $days 天的用量，建议尽快购买',
    );
    return '$_temp0';
  }

  @override
  String get reminderJustNow => '刚刚';

  @override
  String supplementCardSubtitle(
      Object specification, Object dose, Object unit, Object startDate) {
    return '$specification · 每日$dose$unit · 开始：$startDate';
  }

  @override
  String supplementCardRemaining(num days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '剩余 $days 天',
      one: '剩余 $days 天',
    );
    return '$_temp0';
  }

  @override
  String get supplementCardMenuTooltip => '管理';

  @override
  String get supplementCardMenuEdit => '编辑';

  @override
  String get supplementCardMenuReplenish => '补充总量';

  @override
  String get supplementCardMenuSkipToday => '跳过今天';

  @override
  String get supplementCardMenuDelete => '删除';

  @override
  String get chartMonthlyCostByCategoryTitle => '月度花费分布';

  @override
  String get chartSpendingTrendTitle => '花费趋势';

  @override
  String get exportListTitle => '导出补剂清单';

  @override
  String get exportListSnackNoSupplements => '当前没有补剂可导出';

  @override
  String get exportListSnackShareOpened => '已打开系统分享（可保存/发送图片）';

  @override
  String get exportListSnackPngExported => '已导出 PNG 图片';

  @override
  String exportListSnackExportFailed(Object error) {
    return '导出失败：$error';
  }

  @override
  String get exportListActionSharePng => '分享 PNG';

  @override
  String get exportListActionDownloadPng => '下载 PNG';

  @override
  String get exportListCardTitlePng => '导出为图片（PNG）';

  @override
  String get exportListCardDescriptionMobile =>
      '点击右上角或下方按钮即可分享当前成员的补剂清单（适合发给朋友/营养师）。';

  @override
  String get exportListCardDescriptionDesktop =>
      '点击右上角或下方按钮即可下载当前成员的补剂清单图片（PNG）。';

  @override
  String exportListHeaderTitle(Object profileName) {
    return '$profileName 的补剂清单';
  }

  @override
  String get exportListHeaderSubtitle => '一份可分享的补剂清单';

  @override
  String exportListHeaderMeta(Object date) {
    return '导出：$date';
  }

  @override
  String get exportListInfoChipSupplementsCountLabel => '补剂数';

  @override
  String get exportListInfoChipTodayCostLabel => '今日花费';

  @override
  String get exportListInfoChipMonthlyCostLabel => '月度总花费';

  @override
  String get exportListHintShare => '可分享给朋友/营养师，便于快速了解你的补剂情况';

  @override
  String exportListItemDailyDosage(Object dose, Object unit) {
    return '每日$dose$unit';
  }

  @override
  String exportListItemMeta(Object startDate, Object remaining, Object total) {
    return '开始：$startDate · 数量：$remaining/$total';
  }

  @override
  String exportListItemRemaining(num days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '剩余 $days 天',
      one: '剩余 $days 天',
    );
    return '$_temp0';
  }

  @override
  String get settingsTitle => '设置';

  @override
  String get settingsSectionData => '数据';

  @override
  String get settingsBackupCardTitle => '数据导出 / 导入';

  @override
  String get settingsBackupCardDescription => '用于备份与换机迁移。导入会覆盖当前数据。';

  @override
  String get settingsButtonExport => '导出';

  @override
  String get settingsButtonImport => '导入';

  @override
  String get settingsSnackExported => '已导出备份文件';

  @override
  String settingsSnackExportFailed(Object error) {
    return '导出失败：$error';
  }

  @override
  String get settingsImportConfirmTitle => '确认导入';

  @override
  String get settingsImportConfirmContent => '导入将覆盖当前所有成员与补剂数据。建议先导出备份再继续。';

  @override
  String get settingsImportContinue => '继续导入';

  @override
  String get settingsSnackImportDone => '导入完成';

  @override
  String settingsSnackImportFailed(Object error) {
    return '导入失败：$error';
  }

  @override
  String get filePickerChooseExportLocation => '选择导出位置';

  @override
  String get filePickerChooseImportBackup => '选择要导入的备份文件';

  @override
  String get shareSubjectSupplementList => '补剂清单';

  @override
  String get profileManagerTitle => '成员管理';

  @override
  String get profileManagerDescription => '每个成员的数据相互独立，可随时切换。';

  @override
  String get profileManagerTooltipClose => '关闭';

  @override
  String get profileManagerTooltipRename => '重命名';

  @override
  String get profileManagerTooltipDelete => '删除';

  @override
  String get profileManagerButtonClose => '关闭';

  @override
  String get profileManagerButtonAdd => '添加成员';

  @override
  String get profileDialogAddTitle => '添加成员';

  @override
  String get profileDialogAddHint => '例如：妈妈 / 朋友 / 伴侣';

  @override
  String get profileDialogAddConfirm => '添加并切换';

  @override
  String get profileDialogRenameTitle => '重命名成员';

  @override
  String get profileDialogRenameHint => '请输入成员名称';

  @override
  String get profileDialogRenameConfirm => '保存';

  @override
  String get profileDialogDeleteTitle => '确认删除';

  @override
  String profileDialogDeleteContent(Object name) {
    return '删除「$name」后，该成员的补剂数据也会一并删除。';
  }

  @override
  String get supplementEditorTitleAdd => '添加补剂';

  @override
  String get supplementEditorTitleEdit => '编辑补剂';

  @override
  String get supplementEditorTooltipClose => '关闭';

  @override
  String get supplementEditorFieldNameLabel => '补剂名称';

  @override
  String get supplementEditorFieldNameHint => '例如：维生素D3';

  @override
  String get supplementEditorValidationNameRequired => '请输入补剂名称';

  @override
  String get supplementEditorFieldSpecLabel => '规格';

  @override
  String get supplementEditorFieldSpecHint => '例如：2000IU, 180粒';

  @override
  String get supplementEditorValidationSpecRequired => '请输入规格';

  @override
  String get supplementEditorFieldDailyDosageLabel => '每日服用量';

  @override
  String get supplementEditorFieldUnitLabel => '单位';

  @override
  String get supplementEditorFieldPriceLabel => '购买价格 (¥)';

  @override
  String get supplementEditorFieldPriceHint => '128';

  @override
  String get supplementEditorFieldTotalQtyLabel => '总数量';

  @override
  String get supplementEditorFieldTotalQtyHint => '180';

  @override
  String get supplementEditorFieldStartUseDateLabel => '开始使用日期';

  @override
  String get supplementEditorDatePickerHelp => '选择开始使用日期';

  @override
  String get supplementEditorButtonSkipToday => '跳过今天';

  @override
  String supplementEditorSkippedDays(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已跳过 $count 天',
      one: '已跳过 $count 天',
    );
    return '$_temp0';
  }

  @override
  String get supplementEditorFieldCategoryLabel => '分类';

  @override
  String get supplementEditorFieldPurchaseUrlLabel => '购买链接（可选）';

  @override
  String get supplementEditorFieldPurchaseUrlHint => 'https://...';

  @override
  String get supplementEditorButtonPickFromExisting => '从已有补剂复制';

  @override
  String get supplementEditorTemplatePickerTitle => '选择已有补剂';

  @override
  String get supplementEditorTemplatePickerSearchHint => '搜索补剂名称/规格';

  @override
  String get supplementEditorTemplatePickerEmpty => '没有找到匹配的补剂';
}

/// The translations for Chinese, as used in Taiwan (`zh_TW`).
class AppLocalizationsZhTw extends AppLocalizationsZh {
  AppLocalizationsZhTw() : super('zh_TW');

  @override
  String get appTitle => '補劑管家';

  @override
  String get commonCancel => '取消';

  @override
  String get commonDelete => '刪除';

  @override
  String get commonClose => '關閉';

  @override
  String get commonSave => '儲存';

  @override
  String get commonOk => '確定';

  @override
  String get commonNotSet => '未設定';

  @override
  String get commonPerDay => '每日';

  @override
  String commonDays(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 天',
      one: '$count 天',
    );
    return '$_temp0';
  }

  @override
  String unitCapsule(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '粒',
      one: '粒',
    );
    return '$_temp0';
  }

  @override
  String unitTablet(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '片',
      one: '片',
    );
    return '$_temp0';
  }

  @override
  String unitDrop(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '滴',
      one: '滴',
    );
    return '$_temp0';
  }

  @override
  String unitScoop(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '勺',
      one: '勺',
    );
    return '$_temp0';
  }

  @override
  String get categoryVitamins => '維生素';

  @override
  String get categoryMinerals => '礦物質';

  @override
  String get categoryFattyAcids => '脂肪酸';

  @override
  String get categoryProbiotics => '益生菌';

  @override
  String get categoryOther => '其他';

  @override
  String get homeTabSupplements => '我的補劑';

  @override
  String get homeTabAnalytics => '資料分析';

  @override
  String get homeTooltipExportList => '匯出補劑清單為圖片';

  @override
  String get homeTooltipSettings => '設定';

  @override
  String get homeTooltipSwitchProfile => '切換成員';

  @override
  String get homeManageProfiles => '管理成員…';

  @override
  String get homeDialogConfirmDeleteTitle => '確認刪除';

  @override
  String homeDialogConfirmDeleteContent(Object name) {
    return '確定要刪除「$name」嗎？';
  }

  @override
  String homeSnackStartPostponed(Object name, Object date) {
    return '已將「$name」開始使用日期延後至 $date';
  }

  @override
  String homeSnackSkippedToday(Object name, Object date) {
    return '已為「$name」跳過 $date（當天不吃）';
  }

  @override
  String homeSnackUpdated(Object name) {
    return '已更新「$name」';
  }

  @override
  String get homeDialogReplenishTitle => '補充總量';

  @override
  String get homeFieldAddQuantityLabel => '新增數量';

  @override
  String get homeFieldAddQuantityHint => '例如：180';

  @override
  String get validationNumberMin1 => '請輸入 >= 1 的數字';

  @override
  String get validationNumberMin0 => '請輸入 >= 0 的數字';

  @override
  String get validationUrlInvalid => '請輸入有效的連結（包含 http/https）';

  @override
  String get errorInvalidBackup => '備份檔無效或不支援';

  @override
  String get errorUnableToExportImage => '無法匯出圖片';

  @override
  String homeSnackReplenish(Object name, Object quantity, Object unit) {
    return '已為「$name」補充 +$quantity$unit';
  }

  @override
  String get statsTotalSupplementsLabel => '補劑總數';

  @override
  String get statsTotalSupplementsTrend => '目前追蹤的補劑數量';

  @override
  String get statsTodayCostLabel => '今日花費';

  @override
  String get statsTodayCostTrend => '日均花費';

  @override
  String get statsShortestRemainingLabel => '最短剩餘';

  @override
  String get statsShortestRemainingTrend => '最早用完的補劑';

  @override
  String get statsMonthlyCostLabel => '月度總花費';

  @override
  String get statsMonthlyCostTrend => '預估本月支出';

  @override
  String get emptyTitle => '還沒有新增補劑';

  @override
  String get emptySubtitle => '新增您的第一個營養補劑，開始追蹤您的健康投資';

  @override
  String get emptyAddButton => '新增補劑';

  @override
  String get reminderSectionTitle => '提醒';

  @override
  String reminderLowStockTitle(Object name) {
    return '$name 庫存不足';
  }

  @override
  String reminderLowStockMessage(num days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '僅剩 $days 天的用量，建議盡快購買',
      one: '僅剩 $days 天的用量，建議盡快購買',
    );
    return '$_temp0';
  }

  @override
  String get reminderJustNow => '剛剛';

  @override
  String supplementCardSubtitle(
      Object specification, Object dose, Object unit, Object startDate) {
    return '$specification · 每日$dose$unit · 開始：$startDate';
  }

  @override
  String supplementCardRemaining(num days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '剩餘 $days 天',
      one: '剩餘 $days 天',
    );
    return '$_temp0';
  }

  @override
  String get supplementCardMenuTooltip => '管理';

  @override
  String get supplementCardMenuEdit => '編輯';

  @override
  String get supplementCardMenuReplenish => '補充總量';

  @override
  String get supplementCardMenuSkipToday => '跳過今天';

  @override
  String get supplementCardMenuDelete => '刪除';

  @override
  String get chartMonthlyCostByCategoryTitle => '月度花費分布';

  @override
  String get chartSpendingTrendTitle => '花費趨勢';

  @override
  String get exportListTitle => '匯出補劑清單';

  @override
  String get exportListSnackNoSupplements => '目前沒有補劑可匯出';

  @override
  String get exportListSnackShareOpened => '已開啟系統分享（可儲存/傳送圖片）';

  @override
  String get exportListSnackPngExported => '已匯出 PNG 圖片';

  @override
  String exportListSnackExportFailed(Object error) {
    return '匯出失敗：$error';
  }

  @override
  String get exportListActionSharePng => '分享 PNG';

  @override
  String get exportListActionDownloadPng => '下載 PNG';

  @override
  String get exportListCardTitlePng => '匯出為圖片（PNG）';

  @override
  String get exportListCardDescriptionMobile =>
      '點擊右上角或下方按鈕即可分享目前成員的補劑清單（適合發給朋友/營養師）。';

  @override
  String get exportListCardDescriptionDesktop =>
      '點擊右上角或下方按鈕即可下載目前成員的補劑清單圖片（PNG）。';

  @override
  String exportListHeaderTitle(Object profileName) {
    return '$profileName 的補劑清單';
  }

  @override
  String get exportListHeaderSubtitle => '一份可分享的補劑清單';

  @override
  String exportListHeaderMeta(Object date) {
    return '匯出：$date';
  }

  @override
  String get exportListInfoChipSupplementsCountLabel => '補劑數';

  @override
  String get exportListInfoChipTodayCostLabel => '今日花費';

  @override
  String get exportListInfoChipMonthlyCostLabel => '月度總花費';

  @override
  String get exportListHintShare => '可分享給朋友/營養師，方便快速了解你的補劑情況';

  @override
  String exportListItemDailyDosage(Object dose, Object unit) {
    return '每日$dose$unit';
  }

  @override
  String exportListItemMeta(Object startDate, Object remaining, Object total) {
    return '開始：$startDate · 數量：$remaining/$total';
  }

  @override
  String exportListItemRemaining(num days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '剩餘 $days 天',
      one: '剩餘 $days 天',
    );
    return '$_temp0';
  }

  @override
  String get settingsTitle => '設定';

  @override
  String get settingsSectionData => '資料';

  @override
  String get settingsBackupCardTitle => '資料匯出 / 匯入';

  @override
  String get settingsBackupCardDescription => '用於備份與換機遷移。匯入會覆蓋目前資料。';

  @override
  String get settingsButtonExport => '匯出';

  @override
  String get settingsButtonImport => '匯入';

  @override
  String get settingsSnackExported => '已匯出備份檔';

  @override
  String settingsSnackExportFailed(Object error) {
    return '匯出失敗：$error';
  }

  @override
  String get settingsImportConfirmTitle => '確認匯入';

  @override
  String get settingsImportConfirmContent => '匯入將覆蓋目前所有成員與補劑資料。建議先匯出備份再繼續。';

  @override
  String get settingsImportContinue => '繼續匯入';

  @override
  String get settingsSnackImportDone => '匯入完成';

  @override
  String settingsSnackImportFailed(Object error) {
    return '匯入失敗：$error';
  }

  @override
  String get filePickerChooseExportLocation => '選擇匯出位置';

  @override
  String get filePickerChooseImportBackup => '選擇要匯入的備份檔';

  @override
  String get shareSubjectSupplementList => '補劑清單';

  @override
  String get profileManagerTitle => '成員管理';

  @override
  String get profileManagerDescription => '每個成員的資料彼此獨立，可隨時切換。';

  @override
  String get profileManagerTooltipClose => '關閉';

  @override
  String get profileManagerTooltipRename => '重新命名';

  @override
  String get profileManagerTooltipDelete => '刪除';

  @override
  String get profileManagerButtonClose => '關閉';

  @override
  String get profileManagerButtonAdd => '新增成員';

  @override
  String get profileDialogAddTitle => '新增成員';

  @override
  String get profileDialogAddHint => '例如：媽媽 / 朋友 / 伴侶';

  @override
  String get profileDialogAddConfirm => '新增並切換';

  @override
  String get profileDialogRenameTitle => '重新命名成員';

  @override
  String get profileDialogRenameHint => '請輸入成員名稱';

  @override
  String get profileDialogRenameConfirm => '儲存';

  @override
  String get profileDialogDeleteTitle => '確認刪除';

  @override
  String profileDialogDeleteContent(Object name) {
    return '刪除「$name」後，該成員的補劑資料也會一併刪除。';
  }

  @override
  String get supplementEditorTitleAdd => '新增補劑';

  @override
  String get supplementEditorTitleEdit => '編輯補劑';

  @override
  String get supplementEditorTooltipClose => '關閉';

  @override
  String get supplementEditorFieldNameLabel => '補劑名稱';

  @override
  String get supplementEditorFieldNameHint => '例如：維生素D3';

  @override
  String get supplementEditorValidationNameRequired => '請輸入補劑名稱';

  @override
  String get supplementEditorFieldSpecLabel => '規格';

  @override
  String get supplementEditorFieldSpecHint => '例如：2000IU, 180粒';

  @override
  String get supplementEditorValidationSpecRequired => '請輸入規格';

  @override
  String get supplementEditorFieldDailyDosageLabel => '每日服用量';

  @override
  String get supplementEditorFieldUnitLabel => '單位';

  @override
  String get supplementEditorFieldPriceLabel => '購買價格 (¥)';

  @override
  String get supplementEditorFieldPriceHint => '128';

  @override
  String get supplementEditorFieldTotalQtyLabel => '總數量';

  @override
  String get supplementEditorFieldTotalQtyHint => '180';

  @override
  String get supplementEditorFieldStartUseDateLabel => '開始使用日期';

  @override
  String get supplementEditorDatePickerHelp => '選擇開始使用日期';

  @override
  String get supplementEditorButtonSkipToday => '跳過今天';

  @override
  String supplementEditorSkippedDays(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已跳過 $count 天',
      one: '已跳過 $count 天',
    );
    return '$_temp0';
  }

  @override
  String get supplementEditorFieldCategoryLabel => '分類';

  @override
  String get supplementEditorFieldPurchaseUrlLabel => '購買連結（可選）';

  @override
  String get supplementEditorFieldPurchaseUrlHint => 'https://...';

  @override
  String get supplementEditorButtonPickFromExisting => '從已有補劑複製';

  @override
  String get supplementEditorTemplatePickerTitle => '選擇已有補劑';

  @override
  String get supplementEditorTemplatePickerSearchHint => '搜尋補劑名稱/規格';

  @override
  String get supplementEditorTemplatePickerEmpty => '沒有找到符合的補劑';
}
